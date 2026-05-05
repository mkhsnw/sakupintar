import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakupintar/data/models/education/education_model.dart';

class EducationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EducationModel>> getEducationContents() async {
    try {
      final snapshot = await _firestore.collection('education_content').get();
      
      if (snapshot.docs.isEmpty) {
        // Return fallback data if collection is empty
        return _getFallbackContents();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EducationModel.fromJson(data);
      }).toList();
    } catch (e) {
      // In case of error (e.g. no internet or permission denied), return fallback
      return _getFallbackContents();
    }
  }

  List<EducationModel> _getFallbackContents() {
    return [
      EducationModel(
        id: '1',
        title: 'Keinginan vs Kebutuhan',
        category: 'Basic',
        content: 'Sebelum membeli sesuatu, tanyakan pada dirimu: "Apakah aku akan baik-baik saja tanpa ini besok?". Jika ya, itu berarti keinginan, bukan kebutuhan. Tunda dulu transaksimu selama 24 jam untuk memastikan kamu tidak membelinya secara impulsif!',
        imageUrl: '',
      ),
      EducationModel(
        id: '2',
        title: 'Aturan 50/30/20',
        category: 'Budgeting',
        content: 'Coba bagi pemasukanmu dengan rumus 50% untuk Kebutuhan (makan, kuota, transport), 30% untuk Keinginan (jajan, nonton, nongkrong), dan 20% untuk Tabungan (dana darurat, target impian). Konsisten dengan rumus ini adalah kunci kaya di masa depan!',
        imageUrl: '',
      ),
      EducationModel(
        id: '3',
        title: 'Bahaya Latte Factor',
        category: 'Awareness',
        content: 'Pernah dengar Latte Factor? Itu adalah pengeluaran kecil yang sering tidak kamu sadari, seperti jajan kopi 20rb setiap hari. Walau terlihat kecil, 20rb dikali 30 hari itu 600rb lho! Uang sebesar itu bisa ditabung buat beli barang impianmu.',
        imageUrl: '',
      ),
      EducationModel(
        id: '4',
        title: 'Mulai Dana Darurat',
        category: 'Savings',
        content: 'Dana darurat adalah sahabat sejatimu. Sisihkan sedikit uang saku setiap bulannya secara konsisten untuk menghadapi hal-hal tidak terduga, misal HP rusak atau butuh beli buku dadakan.',
        imageUrl: '',
      ),
    ];
  }
}
