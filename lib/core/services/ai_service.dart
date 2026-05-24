import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sakupintar/data/models/category/category_model.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/data/models/user/user_model.dart';

class AiService {
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  static bool get _isKeyValid {
    final key = _apiKey;
    return key.isNotEmpty &&
        key != 'YOUR_OPENAI_API_KEY_HERE' &&
        key.startsWith('sk-');
  }

  static Dio get _dio {
    if (!_isKeyValid) {
      throw Exception(
        'API Key tidak valid. Pastikan API_KEY di .env sudah diisi dengan benar.',
      );
    }
    return Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // Cache
  static Map<String, dynamic>? _cachedInsight;
  static int _lastTransactionCount = -1;
  static double _lastSavedAmount = -1;
  static int _lastGoalCount = -1;

  /// Clear all cached data. Call this when user logs out.
  static void clearCache() {
    _cachedInsight = null;
    _lastTransactionCount = -1;
    _lastSavedAmount = -1;
    _lastGoalCount = -1;
    _cachedEducation = null;
    _lastEducationFetch = null;
    developer.log('[AiService] Cache cleared');
  }

  // =========================
  // AGREGASI TRANSAKSI
  // =========================
  static Map<String, dynamic> _buildSummary(
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) {
      return {
        'totalExpense': 0,
        'totalIncome': 0,
        'transactionCount': 0,
        'dailyAverage': 0,
        'topCategory': '-',
        'breakdown': [],
      };
    }

    // Hitung total pemasukan & pengeluaran
    double totalExpense = 0;
    double totalIncome = 0;
    final categoryMap = <String, double>{};

    for (final tx in transactions) {
      if (tx.type == 'expense') {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }

      // Agregasi per kategori
      String catKey = tx.categoryId;
      if (catKey == 'nabung') catKey = 'Nabung';
      if (catKey == 'jajan') catKey = 'Jajan';
      if (catKey == 'hiburan') catKey = 'Hiburan';

      categoryMap[catKey] = (categoryMap[catKey] ?? 0) + tx.amount;
    }

    // Urutkan kategori terbesar
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.isNotEmpty
        ? sortedCategories.first.key
        : '-';

    // Breakdown dengan persentase
    final totalForPercent = totalExpense > 0 ? totalExpense : 1;
    final breakdown = sortedCategories.map((e) {
      final percent = ((e.value / totalForPercent) * 100).round();
      return {'category': e.key, 'amount': e.value, 'percent': percent};
    }).toList();

    // Hitung rata-rata harian (berdasarkan rentang tanggal unik)
    final uniqueDates = transactions.map((tx) {
      return tx.date.toDate().toIso8601String().substring(0, 10);
    }).toSet();

    final dayCount = uniqueDates.isEmpty ? 1 : uniqueDates.length;
    final dailyAverage = totalExpense / dayCount;

    return {
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'transactionCount': transactions.length,
      'dailyAverage': dailyAverage,
      'topCategory': topCategory,
      'breakdown': breakdown,
    };
  }

  static Future<Map<String, dynamic>> generateArsaInsight({
    required UserModel user,
    required List<TransactionModel> recentTransactions,
    required List<GoalModel> goals,
    double? incomeToAllocate,
    List<CategoryModel>? categories,
  }) async {
    try {
      // =========================
      // AGREGASI TRANSAKSI
      // =========================
      final summary = _buildSummary(recentTransactions);

      final breakdownText = (summary['breakdown'] as List<dynamic>)
          .map(
            (b) => '- ${b['category']}: Rp ${b['amount']} (${b['percent']}%)',
          )
          .join('\n');

      // =========================
      // GOAL
      // =========================
      final activeGoal = goals.isNotEmpty
          ? goals.firstWhere((g) => g.isActive, orElse: () => goals.first)
          : null;

      final goalInfo = activeGoal != null
          ? 'Target saat ini: "${activeGoal.title}" '
                'sebesar Rp ${activeGoal.targetAmount}, '
                'terkumpul Rp ${activeGoal.savedAmount}.'
          : 'Belum ada target impian aktif.';

      // =========================
      // CACHE CHECK
      // =========================
      if (incomeToAllocate == null &&
          _cachedInsight != null &&
          _lastTransactionCount == recentTransactions.length &&
          _lastGoalCount == goals.length &&
          _lastSavedAmount == (activeGoal?.savedAmount ?? 0)) {
        developer.log('[AiService] Using cached insight');

        return _cachedInsight!;
      }

      // =========================
      // BUDGET INSTRUCTION
      // =========================
      final categoriesInstruction =
          (incomeToAllocate != null &&
              categories != null &&
              categories.isNotEmpty)
          ? '''
User memiliki total pemasukan Rp $incomeToAllocate.

Berikan saran alokasi budget bulanan dalam bentuk persentase (%) untuk kategori berikut:
${categories.map((c) => "${c.id} (${c.name})").join(', ')}

Total persentase wajib 100%.
'''
          : (incomeToAllocate != null)
          ? '''
User baru saja mendapatkan pemasukan Rp $incomeToAllocate.

Berikan saran alokasi budget bulanan dalam bentuk persentase (%) untuk kategori:
- nabung
- jajan
- hiburan
- lainnya

Total persentase wajib 100%.
'''
          : '';

      // =========================
      // JSON STRUCTURE
      // =========================
      final budgetJsonStructure =
          (incomeToAllocate != null &&
              categories != null &&
              categories.isNotEmpty)
          ? '''
,
"budget": {
${categories.map((c) => '"${c.id}": 0').join(',\n')}
}
'''
          : (incomeToAllocate != null)
          ? '''
,
"budget": {
"nabung": 0,
"jajan": 0,
"hiburan": 0,
"lainnya": 0
}
'''
          : '';

      // =========================
      // PROMPT
      // =========================
      final prompt =
          '''
Kamu adalah ARSA (AI-based Personal Resource Assistant),
asisten keuangan hologram milik ${user.nickname}.

Aturan komunikasi ARSA:
- Bahasa: Indonesia informal, tidak lebay, tidak pakai kata "kamu yuk" atau "bestie"
- Nada: logis tapi hangat, seperti kakak kelas yang pintar finansial
- Panjang pesan: maks 2–3 kalimat untuk insight utama
- Satu saran tindakan konkret dan spesifik (bukan generik seperti "hemat ya!")
- Selalu sebut nama: ${user.nickname}
- Jangan gunakan kata "aku" terlalu sering — variasikan

Nama user: ${user.nickname}

Fokus utama:
${user.primaryGoal ?? 'Mengatur Uang'}

Tugas Utama:
1. Berikan insight dari pola pengeluaran dan pemasukan user.
2. Berikan 1 saran tindakan (actionable advice) yang spesifik untuk membantu user mencapai fokus utamanya.
3. Tentukan TIPE PENGELUARAN user HANYA ke salah satu dari 3 kategori berikut:
   - "Pemboros (Big Spender)": Pengeluaran besar untuk kepuasan sesaat (hiburan, jajan berlebihan), impulsif.
   - "Si Bijak (The Investor)": Pengeluaran besar tidak masalah asalkan untuk hal bernilai/return (aset, pendidikan, nabung).
   - "Penghemat (Savers)": Sangat berhati-hati, prioritas menabung tinggi, jarang ada pengeluaran impulsif.

Ringkasan keuangan 7 hari terakhir:
- Total pengeluaran: Rp ${summary['totalExpense']}
- Total pemasukan: Rp ${summary['totalIncome']}
- Jumlah transaksi: ${summary['transactionCount']}x
- Rata-rata pengeluaran harian: Rp ${summary['dailyAverage'].toStringAsFixed(0)}
- Kategori terbesar: ${summary['topCategory']}

Breakdown per kategori:
$breakdownText

$goalInfo

$categoriesInstruction

Balas WAJIB dalam format JSON VALID tanpa markdown.

Format JSON:

{
  "insight": {
    "title": "Judul singkat yang menarik",
    "message": "Insight dari pola keuangan + 1 saran actionable & spesifik (maks 3 kalimat)",
    "segment_type": "Pilih salah satu: Pemboros (Big Spender) ATAU Si Bijak (The Investor) ATAU Penghemat (Savers)",
    "segment_explanation": "1 kalimat penjelasan mengapa user masuk ke kategori tersebut berdasarkan data transaksinya",
    "goal_estimation": "Estimasi target",
    "alerts": [
      {
        "title": "Judul",
        "message": "Isi alert",
        "type": "warning"
      }
    ]
  }
  $budgetJsonStructure
}
''';

      developer.log('[AiService] Prompt length: ${prompt.length}');

      // =========================
      // API CALL
      // =========================
      final response = await _dio.post(
        '/chat/completions',
        data: {
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "Kamu adalah ARSA, AI assistant keuangan untuk anak sekolah.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.4,
          "max_tokens": 500,
          "response_format": {"type": "json_object"},
        },
      );

      developer.log('[AiService] Status Code: ${response.statusCode}');

      // =========================
      // PARSE RESPONSE
      // =========================
      final text = response.data['choices'][0]['message']['content'];

      developer.log('[AiService] AI Text Response: $text');

      final result = jsonDecode(text);

      // =========================
      // SAVE CACHE
      // =========================
      if (incomeToAllocate == null) {
        _cachedInsight = result;
        _lastTransactionCount = recentTransactions.length;
        _lastGoalCount = goals.length;
        _lastSavedAmount = activeGoal?.savedAmount ?? 0;
      }

      return result;
    } on DioException catch (e, stackTrace) {
      developer.log(
        '[AiService] DIO ERROR',
        error: e.response?.data ?? e.message,
        stackTrace: stackTrace,
      );

      return _fallbackData(user, incomeToAllocate, categories);
    } catch (e, stackTrace) {
      developer.log(
        '[AiService] GENERAL ERROR',
        error: e,
        stackTrace: stackTrace,
      );

      return _fallbackData(user, incomeToAllocate, categories);
    }
  }

  // =========================
  // EDUCATION MICRO — AI GENERATED
  // =========================
  static Map<String, dynamic>? _cachedEducation;
  static DateTime? _lastEducationFetch;
  static const _educationCacheDuration = Duration(hours: 6);

  static Future<List<Map<String, dynamic>>> generateEducationMicro({
    required UserModel user,
    required List<TransactionModel> recentTransactions,
    required List<GoalModel> goals,
  }) async {
    try {
      // Cache check
      if (_cachedEducation != null &&
          _lastEducationFetch != null &&
          DateTime.now().difference(_lastEducationFetch!) <
              _educationCacheDuration) {
        developer.log('[AiService] Using cached education');
        final tips = _cachedEducation!['education_tips'];
        if (tips is List) return tips.cast<Map<String, dynamic>>();
      }

      final summary = _buildSummary(recentTransactions);

      final breakdownText = (summary['breakdown'] as List<dynamic>)
          .map(
            (b) => '- ${b['category']}: Rp ${b['amount']} (${b['percent']}%)',
          )
          .join('\n');

      final activeGoal = goals.isNotEmpty
          ? goals.firstWhere((g) => g.isActive, orElse: () => goals.first)
          : null;

      final goalInfo = activeGoal != null
          ? 'Target aktif: ${activeGoal.title} (terkumpul Rp ${activeGoal.savedAmount} dari Rp ${activeGoal.targetAmount})'
          : 'Belum ada target keuangan aktif.';

      final prompt =
          '''
Kamu adalah ARSA (AI-based Personal Resource Assistant), asisten keuangan hologram milik ${user.nickname}.

User: ${user.nickname} | Tipe: ${user.userType ?? 'Campuran'} | Fokus: ${user.primaryGoal ?? 'Mengatur Uang'}

Data keuangan user:
- Total pengeluaran: Rp ${summary['totalExpense']}
- Kategori terbesar: ${summary['topCategory']}
- Rata-rata harian: Rp ${summary['dailyAverage'].toStringAsFixed(0)}

Breakdown:
$breakdownText

$goalInfo

TUGAS:
Buatkan 3 konten edukasi MIKRO (micro-learning) tentang KONSEP FINANSIAL FUNDAMENTAL.

INSTRUKSI PENTING:
- FOKUS ke MENJELASKAN KONSEP, BUKAN memberi saran/nasihat/action items.
- Jangan berisi kata seperti "sebaiknya", "harus", "coba", "lakukan" — itu saran, bukan edukasi.
- Tujuannya adalah membuat user MENGERTI konsep, bukan tahu apa yang harus dilakukan.

Konsep yang bisa dipilih (pilih yang relevan dengan data user):
1. Needs vs Wants — Perbedaan kebutuhan dan keinginan
2. #LatteFactor — Pengeluaran kecil yang terakumulasi besar
3. Compound Interest / Bunga Berbunga — Bagaimana uang bisa tumbuh
4. Delay Gratification — Kenapa menunda kesenangan itu penting
5. 50/30/20 Rule — Pembagian uang saku
6. Inflation / Inflasi — Kenapa harga naik dan uang menurun nilainya
7. Opportunity Cost — Biaya opportunity setiap pilihan
8. Emergency Fund — Dana darurat dan pentingnya

Aturan:
- Bahasa: Indonesia informal, ramah remaja, tidak lebay
- Judul: catchy, max 6 kata, pakai emoji relevan di awal
- Isi: 2-3 kalimat penjelasan konsep yang padat dan mudah dipahami
- Category: label kategori konsep (misal: "Needs vs Wants", "Tabungan", "Inflasi")
- Selalu sebut nama user minimal sekali secara natural
- Setiap konten harus MERUJUK ke data keuangan user agar terasa personal

Format JSON:
{
  "education_tips": [
    {
      "title": "Judul catchy",
      "content": "Penjelasan konsep...",
      "category": "Label Konsep",
      "priority": "high"
    }
  ]
}
''';

      final response = await _dio.post(
        '/chat/completions',
        data: {
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "Kamu adalah ARSA, AI assistant keuangan untuk anak sekolah. Generate 3 micro-learning content tentang konsep finansial fundamental. Fokus ke MENJELASKAN konsep, BUKAN memberi saran.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.4,
          "max_tokens": 900,
          "response_format": {"type": "json_object"},
        },
      );

      final text = response.data['choices'][0]['message']['content'];
      final result = jsonDecode(text);

      _cachedEducation = result;
      _lastEducationFetch = DateTime.now();

      final tips = result['education_tips'];
      if (tips is List) return tips.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e, stackTrace) {
      developer.log(
        '[AiService] EDU DIO ERROR',
        error: e.response?.data ?? e.message,
        stackTrace: stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      developer.log(
        '[AiService] EDU GENERAL ERROR',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // =========================
  // FALLBACK
  // =========================
  static Map<String, dynamic> _fallbackData(
    UserModel user,
    double? incomeToAllocate,
    List<CategoryModel>? categories,
  ) {
    return {
      "insight": {
        "title": "Halo ${user.nickname}!",
        "message": "Aku ARSA! Lagi nyiapin insight keuangan kamu nih ✨",
        "segment_type": "Penghemat (Savers)",
        "segment_explanation":
            "Kelihatannya kamu rajin menabung dan cukup berhati-hati dalam pengeluaran.",
        "goal_estimation": "Targetmu masih dihitung, tetap semangat nabung ya!",
        "alerts": [],
      },
      if (incomeToAllocate != null)
        "budget": (categories != null && categories.isNotEmpty)
            ? {
                for (var c in categories)
                  c.id: (100 / categories.length).floor(),
              }
            : {"nabung": 30, "jajan": 40, "hiburan": 20, "lainnya": 10},
    };
  }
}
