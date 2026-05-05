import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';
import 'package:sakupintar/data/models/user/user_model.dart';

class AiService {
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  static GenerativeModel get _model => GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  static Map<String, dynamic>? _cachedInsight;
  static int _lastTransactionCount = -1;
  static double _lastSavedAmount = -1;

  static Future<Map<String, dynamic>> generateArsaInsight({
    required UserModel user,
    required List<TransactionModel> recentTransactions,
    required List<GoalModel> goals,
    double? incomeToAllocate,
  }) async {
    // Menyiapkan context
    final txList = recentTransactions
        .map(
          (tx) =>
              '${tx.date.toDate().toIso8601String().substring(0, 10)}: ${tx.type == 'expense' ? 'Keluar' : 'Masuk'} Rp ${tx.amount} untuk ${tx.categoryId}',
        )
        .join('\n');
    final activeGoal = goals.isNotEmpty
        ? goals.firstWhere((g) => g.isActive, orElse: () => goals.first)
        : null;
    final goalInfo = activeGoal != null
        ? 'Target saat ini: "${activeGoal.title}" sebesar Rp ${activeGoal.targetAmount}, terkumpul Rp ${activeGoal.savedAmount}.'
        : 'Belum ada target impian aktif.';

    if (incomeToAllocate == null &&
        _cachedInsight != null &&
        _lastTransactionCount == recentTransactions.length &&
        _lastSavedAmount == (activeGoal?.savedAmount ?? 0)) {
      return _cachedInsight!;
    }

    final prompt =
        '''
Kamu adalah ARSA (Asisten Realitas Saku Anak), asisten keuangan pintar berbentuk robot hologram AI yang ceria, pintar, dan asik diajak ngobrol oleh anak sekolah (SMA/SMP).
Nama user adalah ${user.nickname}. Tipe karakternya: ${user.userType ?? 'Campuran'}. Fokus utamanya: ${user.primaryGoal ?? 'Mengatur Uang'}.

Berikut adalah data transaksi terbarunya (7 hari terakhir):
$txList
$goalInfo

${incomeToAllocate != null ? 'User baru saja mendapatkan pemasukan/uang saku sebesar Rp $incomeToAllocate. Berikan saran alokasi budget bulanan dalam bentuk persentase (%) untuk 4 kategori ini: default_nabung, default_jajan, default_entertainment, default_lainnya. Total persentase harus 100%.' : ''}

Tugasmu:
Buatlah kembalian dalam format JSON yang valid.
Struktur JSON-nya:
{
  "insight": {
    "title": "Judul singkat (max 2 kata)",
    "message": "Pesan utama (max 2 kalimat singkat). Harus padat, jelas, dan langsung to the point berupa langkah/saran konkrit untuk user dengan gaya bahasa gaul.",
    "segment_type": "Tipe user (1-2 kata, contoh: Si Hemat, Boros Jajan)",
    "goal_estimation": "Estimasi kapan target tercapai (max 1 kalimat singkat dan jelas)",
    "alerts": [
      {
        "title": "Judul Alert (Singkat)",
        "message": "Pesan spesifik to the point (max 1 kalimat)",
        "type": "warning | success"
      }
    ]
  }${incomeToAllocate != null ? ''',
  "budget": {
    "default_nabung": <angka_persen>,
    "default_jajan": <angka_persen>,
    "default_entertainment": <angka_persen>,
    "default_lainnya": <angka_persen>
  }''' : ''}
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      var text = response.text ?? '{}';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final result = jsonDecode(text) as Map<String, dynamic>;

      if (incomeToAllocate == null) {
        _cachedInsight = result;
        _lastTransactionCount = recentTransactions.length;
        _lastSavedAmount = activeGoal?.savedAmount ?? 0;
      }

      return result;
    } catch (e) {
      print('Error AI: ${e}');
      // Fallback
      return {
        "insight": {
          "title": "Halo ${user.nickname}!",
          "message":
              "Aku ARSA! Lagi nyiapin data transaksi kamu nih biar makin jago nabung.",
          "segment_type": user.userType ?? "Konsisten",
          "goal_estimation":
              "Targetmu masih dalam perhitungan, semangat menabung!",
          "alerts": [],
        },
        if (incomeToAllocate != null)
          "budget": {
            "default_nabung": 30,
            "default_jajan": 40,
            "default_entertainment": 20,
            "default_lainnya": 10,
          },
      };
    }
  }
}
