import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login dengan Email
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        throw Exception('Data pengguna tidak ditemukan di database.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak diketahui: $e');
    }
  }

  // Register dengan Email
  Future<UserModel> registerWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        createdAt: Timestamp.now(),
      );

      await _saveUserToFirestore(newUser);
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  // Login dengan Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login Google dibatalkan.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        // Jika pengguna baru, simpan ke Firestore
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? googleUser.email,
          nickname: userCredential.user!.displayName ?? googleUser.displayName,
          createdAt: Timestamp.now(),
        );
        await _saveUserToFirestore(newUser);
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan login Google: $e');
    }
  }

  // Reset Password via Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Gagal mengirim instruksi reset password.');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal melakukan logout: $e');
    }
  }

  // Ambil Data Pengguna Saat Ini
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memuat profil pengguna: $e');
    }
  }

  // Update Profil Onboarding
  Future<UserModel> completeOnboarding({
    required String nickname,
    required String school,
    required String primaryGoal,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      await docRef.update({
        'nickname': nickname,
        'school': school,
        'primaryGoal': primaryGoal,
      });

      final updatedDoc = await docRef.get();
      return UserModel.fromJson(updatedDoc.data()!);
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  // Simpan ke Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan data pengguna ke database.');
    }
  }

  // Helper untuk mengubah error Firebase menjadi pesan yang dimengerti pengguna
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      default:
        return 'Gagal melakukan autentikasi: ${e.message}';
    }
  }
}
