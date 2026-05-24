import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mime/mime.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import '../models/user/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'] ?? '',
  );

  // Validasi input
  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static const int _maxNicknameLength = 50;
  static const int _minPasswordLength = 6;
  static const int _maxFileSize = 2 * 1024 * 1024; // 2MB
  static const List<String> _allowedImageTypes = ['image/jpeg', 'image/png', 'image/webp'];

  // Validasi email
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong.');
    }
    if (!_emailRegex.hasMatch(email)) {
      throw Exception('Format email tidak valid.');
    }
  }

  // Validasi password
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong.');
    }
    if (password.length < _minPasswordLength) {
      throw Exception('Password minimal $_minPasswordLength karakter.');
    }
  }

  // Validasi nickname
  void _validateNickname(String nickname) {
    if (nickname.trim().isEmpty) {
      throw Exception('Nama panggilan tidak boleh kosong.');
    }
    if (nickname.trim().length > _maxNicknameLength) {
      throw Exception('Nama panggilan maksimal $_maxNicknameLength karakter.');
    }
  }

  // Validasi file upload
  Future<void> _validateFile(File file) async {
    // Cek file exists
    if (!await file.exists()) {
      throw Exception('File tidak ditemukan.');
    }

    // Cek ukuran file
    final fileSize = await file.length();
    if (fileSize > _maxFileSize) {
      throw Exception('Ukuran file maksimal 2MB.');
    }

    // Cek tipe file
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !_allowedImageTypes.contains(mimeType)) {
      throw Exception('Hanya file gambar (JPEG, PNG, WebP) yang diperbolehkan.');
    }
  }

  // Login dengan Email
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      _validateEmail(email);
      _validatePassword(password);

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
      _validateEmail(email);
      _validatePassword(password);

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
      // Clear AI cache to remove sensitive financial data from memory
      AiService.clearCache();
      
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

      _validateNickname(nickname);

      final docRef = _firestore.collection('users').doc(user.uid);
      await docRef.update({
        'nickname': nickname.trim(),
        'school': school.trim(),
        'primaryGoal': primaryGoal,
      });

      final updatedDoc = await docRef.get();
      return UserModel.fromJson(updatedDoc.data()!);
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  // Update Foto Profil
  Future<UserModel> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      await docRef.update({'photoUrl': photoUrl});

      final updatedDoc = await docRef.get();
      return UserModel.fromJson(updatedDoc.data()!);
    } catch (e) {
      throw Exception('Gagal memperbarui foto profil: $e');
    }
  }

  // Upload Foto Profil ke Firebase Storage
  Future<UserModel> uploadProfilePhoto(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      // Validasi file sebelum upload
      await _validateFile(file);

      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile.jpg');

      // Upload dengan metadata
      final metadata = SettableMetadata(
        contentType: lookupMimeType(file.path),
        customMetadata: {'uploadedBy': user.uid},
      );

      await ref.putFile(file, metadata);
      final url = await ref.getDownloadURL();

      return await updatePhotoUrl(url);
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengunggah foto profil: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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
  // Menggunakan pesan generik untuk mencegah user enumeration attack
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Gunakan pesan generik yang sama untuk login errors
      // untuk mencegah attacker mengetahui apakah email terdaftar atau tidak
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi support untuk bantuan.';
      default:
        return 'Gagal melakukan autentikasi. Silakan coba lagi.';
    }
  }
}
