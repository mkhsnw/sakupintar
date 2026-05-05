import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

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
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('receipts')
          .child('$transactionId.jpg');

      final uploadTask = await ref.putFile(file);
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
        final data = doc.data();
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
        final data = doc.data();
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
}
