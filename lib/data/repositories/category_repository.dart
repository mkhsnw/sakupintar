import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakupintar/data/models/category/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Default Categories
  List<CategoryModel> get defaultCategories => [
        CategoryModel(
          id: 'jajan',
          name: 'Jajan',
          icon: 'restaurant_rounded',
          color: '0xFFFF5252',
          createdAt: Timestamp.now(),
        ),
        CategoryModel(
          id: 'nabung',
          name: 'Nabung',
          icon: 'savings_rounded',
          color: '0xFF00BFA5',
          createdAt: Timestamp.now(),
        ),
        CategoryModel(
          id: 'hiburan',
          name: 'Hiburan',
          icon: 'sports_esports_rounded',
          color: '0xFF651FFF',
          createdAt: Timestamp.now(),
        ),
      ];

  Future<void> addCategory(CategoryModel category) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(category.id)
          .set(category.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Gagal menyimpan kategori: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menyimpan kategori: $e');
    }
  }

  Stream<List<CategoryModel>> streamCategories() {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      final customCategories = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
      
      return [...defaultCategories, ...customCategories];
    });
  }

  Future<List<CategoryModel>> getCategories() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .get();

      final customCategories = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();

      return [...defaultCategories, ...customCategories];
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil kategori: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil kategori: $e');
    }
  }
}
