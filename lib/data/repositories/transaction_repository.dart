import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Constants for file validation
  static const int _maxReceiptSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedReceiptTypes = ['image/jpeg', 'image/png', 'image/webp'];

  /// Validasi file receipt sebelum upload
  Future<void> _validateReceiptFile(File file) async {
    if (!await file.exists()) {
      throw Exception('File tidak ditemukan.');
    }

    final fileSize = await file.length();
    if (fileSize > _maxReceiptSize) {
      throw Exception('Ukuran file struk maksimal 5MB.');
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !_allowedReceiptTypes.contains(mimeType)) {
      throw Exception('Hanya file gambar (JPEG, PNG, WebP) yang diperbolehkan.');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transaction.id);

      await docRef.set(transaction.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Gagal menyimpan transaksi: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<String> uploadReceipt(File file, String transactionId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      // Validasi file sebelum upload
      await _validateReceiptFile(file);

      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('receipts')
          .child('$transactionId.jpg');

      // Upload dengan metadata
      final metadata = SettableMetadata(
        contentType: lookupMimeType(file.path),
        customMetadata: {'uploadedBy': uid, 'transactionId': transactionId},
      );

      final uploadTask = await ref.putFile(file, metadata);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengunggah struk: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Stream<List<TransactionModel>> streamTransactions(String monthKey) {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; // ensure ID is passed
        return TransactionModel.fromJson(data);
      }).toList();
      
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<List<TransactionModel>> getTransactions(String monthKey) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('monthKey', isEqualTo: monthKey)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
      
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil transaksi: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Fetch the latest [limit] transactions for the current month (dashboard preview)
  Future<List<TransactionModel>> getRecentTransactions(String monthKey, {int limit = 3}) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('monthKey', isEqualTo: monthKey)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil transaksi terbaru: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Paginated fetch for transaction list page.
  /// Returns a map with 'transactions' list and 'lastDocument' for cursor.
  Future<Map<String, dynamic>> getTransactionsPaginated(
    String monthKey, {
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      Query query = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('monthKey', isEqualTo: monthKey)
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final transactions = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();

      return {
        'transactions': transactions,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'hasMore': snapshot.docs.length == limit,
      };
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil transaksi: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
