import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<GoalModel>> streamGoals() {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return GoalModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      if (goal.isActive) {
        await _deactivateAllGoals(uid);
      }
      
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goal.id);

      await docRef.set(goal.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Gagal menyimpan target: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menyimpan target: $e');
    }
  }

  Future<void> updateGoal(GoalModel goal) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goal.id)
          .update(goal.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Gagal memperbarui target: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui target: $e');
    }
  }

  Future<void> setActiveGoal(String goalId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _deactivateAllGoals(uid);
      
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update({'isActive': true});
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengubah status target: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengubah status target: $e');
    }
  }

  Future<void> addSavedAmount(String goalId, double amount) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update({
            'savedAmount': FieldValue.increment(amount),
          });
    } on FirebaseException catch (e) {
      throw Exception('Gagal menambahkan tabungan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menambahkan tabungan: $e');
    }
  }

  Future<void> markGoalCompleted(String goalId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final batch = _firestore.batch();
      final goalRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId);

      batch.update(goalRef, {
        'isCompleted': true,
        'isActive': false,
      });

      // Find next active goal
      final otherGoals = await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .where('isActive', isEqualTo: false)
          .get();

      String? nextActiveGoalId;
      for (var doc in otherGoals.docs) {
        if (doc.id != goalId) {
          final data = doc.data();
          if (data['isCompleted'] != true) {
            nextActiveGoalId = doc.id;
            break;
          }
        }
      }

      if (nextActiveGoalId != null) {
        final nextGoalRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('goals')
            .doc(nextActiveGoalId);
        batch.update(nextGoalRef, {
          'isActive': true,
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Gagal menandai target selesai: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menandai target selesai: $e');
    }
  }

  Future<void> _deactivateAllGoals(String uid) async {
    final activeGoals = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .where('isActive', isEqualTo: true)
        .get();

    if (activeGoals.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in activeGoals.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();
    }
  }
}
