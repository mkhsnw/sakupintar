import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakupintar/data/models/budget/budget_model.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<BudgetModel?> streamBudget(String monthKey) {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(monthKey)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return BudgetModel.fromJson(doc.data()!);
    });
  }

  Future<void> saveBudget(BudgetModel budget) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budget.monthKey)
          .set(budget.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Gagal menyimpan budget: ${e.message}');
    }
  }
}
