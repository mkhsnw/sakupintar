# AGENTS.md — SakuPintar

> **Baca file ini sebelum menulis satu baris kode pun.**
> File ini adalah sumber kebenaran tunggal untuk semua AI agent (Claude, Cursor, Copilot, dll.)
> yang bekerja di project ini. Jika ada konflik antara instruksi user dan aturan di sini,
> tanyakan terlebih dahulu — jangan langsung override.

---

## 1. Tentang SakuPintar

### Apa itu SakuPintar?

SakuPintar adalah aplikasi mobile (Flutter) untuk **siswa SMA** yang membantu mereka
mencatat, memahami, dan merencanakan keuangan pribadi (uang saku) dengan bantuan
kecerdasan buatan. Aplikasi ini dikembangkan sebagai bagian dari **penelitian akademik**
(Penelitian Dosen/Hibah) dengan metodologi kuantitatif.

### Tujuan Penelitian

1. Mengukur pengaruh fitur AI Advisory terhadap peningkatan **literasi keuangan** siswa SMA
2. Menganalisis pola pengeluaran remaja melalui data transaksi yang dikumpulkan
3. Menguji efektivitas pendekatan gamifikasi dan edukasi mikro dalam membentuk
   kebiasaan keuangan yang sehat

### Pengguna Target

- Siswa SMA usia 15–18 tahun
- Login via **Email & Password** atau **Google Sign-In** (Gmail / Belajar.id)
- Distribusi APK terbatas ke sekolah mitra — **bukan** aplikasi publik di Play Store

### Karakter AI — ARSA

ARSA adalah maskot dan AI advisor aplikasi ini. Singkatan dari
**AI-based Personal Resource Assistant**. Karakter ini divisualisasikan sebagai robot
kecil yang terbang (seperti drone) memancarkan hologram laporan keuangan.
Kepribadiannya: **logis, cepat, modern, ramah ke remaja**.

ARSA bukan model AI yang dilatih dari nol. ARSA adalah persona yang dibangun di atas
LLM (Claude Haiku atau Gemini Flash) yang diberi konteks data keuangan pengguna untuk
menghasilkan insight yang terasa personal.

---

## 2. Fitur-Fitur Aplikasi

### Fitur 1 — Onboarding & Autentikasi

**Halaman:** `pages/auth/`

- Splash screen dengan logo SakuPintar dan animasi lembut (2 detik)
- Dua metode login yang tersedia:
  - **Email & Password** — register dengan email, password, dan konfirmasi password
  - **Google Sign-In** — satu tap dengan akun Gmail atau Belajar.id
- Reset password via email (Firebase Auth `sendPasswordResetEmail`)
- Untuk pengguna baru (setelah register): formulir onboarding singkat
  - Nama panggilan (untuk personalisasi ARSA)
  - Asal sekolah (untuk data demografi penelitian)
  - Target utama keuangan: pilih **satu** dari tiga opsi:
    - 🐷 **Menabung** — fokus pada akumulasi tabungan
    - 🍜 **Mengatur Jajan** — fokus pada kontrol pengeluaran harian
    - 📈 **Investasi** — fokus pada alokasi dana untuk investasi jangka panjang
- Target yang dipilih saat onboarding menentukan **template alokasi budget awal**
  yang direkomendasikan ARSA di bulan pertama
- Di balik layar: sistem membuat profil keuangan awal dan inisialisasi
  dokumen `budgets/{YYYY-MM}` untuk bulan berjalan

### Fitur 2 — Dashboard Utama

**Halaman:** `pages/dashboard/`

- Header bulan aktif (misal "Oktober 2025") dengan navigasi ke bulan sebelumnya
- **Banner pemasukan bulan ini** — jika belum ada pemasukan di bulan berjalan,
  tampilkan CTA "Catat Pemasukan Bulan Ini" yang mencolok
- Ringkasan keuangan bulan berjalan:
  - **Pemasukan** (dari dokumen `budgets/{YYYY-MM}`)
  - **Total Pengeluaran** (agregat transaksi bulan ini)
  - **Sisa Budget** (pemasukan - pengeluaran; bisa negatif)
- Doughnut chart interaktif: proporsi pengeluaran per kategori bulan ini
- **Kartu Alokasi Budget** — breakdown alokasi yang direkomendasikan ARSA
  berdasarkan profil & goal (misal: Menabung 30%, Jajan 40%, Entertainment 20%, dll.)
- Kartu insight ARSA terbaru (di-cache 6 jam)
- Tombol FAB "Catat Transaksi" sebagai aksi utama
- Shortcut ke Goal, Analitik, dan Budgeting

### Fitur 3 — Pencatatan Transaksi

**Halaman:** `pages/transaction/`

- Input: nominal, kategori, catatan opsional, tanggal
- **Kategori default (tidak bisa dihapus):**
  - 🍜 **Jajan** — makanan, minuman, jajanan harian
  - 🐷 **Nabung** — uang yang disisihkan untuk tabungan
  - 🎮 **Entertainment** — hiburan, kuota, streaming, dll.
- **Kategori custom** — user bisa membuat kategori sendiri di luar 3 default:
  - Dibuat dari halaman Profil atau saat input transaksi (tombol "+ Kategori Baru")
  - Disimpan di subcollection `users/{uid}/categories/{catId}`
  - Ditampilkan bersama kategori default dalam satu list saat pilih kategori
  - Bisa diedit nama dan ikonnya, bisa dihapus (jika tidak ada transaksi terkait)
- Opsional: unggah foto struk (disimpan ke Firebase Storage)
- Setelah save: animasi sukses Lottie `success_check.json`, lalu kembali ke halaman sebelumnya
- Riwayat transaksi: list terfilter per bulan, bisa filter per kategori

### Fitur 4 — Budgeting Bulanan

**Halaman:** `pages/budget/`

Ini adalah fitur inti sistem keuangan SakuPintar. Pemasukan bersifat **per bulan**,
dan balance di-reset ke 0 setiap awal bulan hingga user mencatat pemasukan baru.

**Konsep siklus bulan:**

- Setiap bulan punya satu dokumen `budgets/{uid}/{YYYY-MM}` di Firestore
- Jika dokumen bulan ini belum ada → balance dianggap 0, tampilkan prompt input pemasukan
- Setelah user input pemasukan bulan ini → dokumen dibuat, budget aktif
- User bisa melihat ringkasan bulan-bulan sebelumnya (read-only)

**Alur input pemasukan:**

1. User buka halaman Budget atau klik CTA dari Dashboard
2. Input nominal pemasukan bulan ini (uang saku dari orang tua, beasiswa, dll.)
3. ARSA otomatis **merekomendasikan alokasi** berdasarkan profil dan goal aktif:
   - Contoh profil "Menabung": Tabungan 30% · Jajan 40% · Entertainment 20% · Bebas 10%
   - Contoh profil "Investasi": Investasi 25% · Tabungan 20% · Jajan 40% · Entertainment 15%
   - Contoh profil "Mengatur Jajan": Jajan 50% · Tabungan 25% · Entertainment 15% · Bebas 10%
4. User bisa **menerima rekomendasi** atau **menyesuaikan alokasi** secara manual
5. Alokasi final tersimpan di `budgets/{uid}/{YYYY-MM}/allocations`

**Tampilan halaman Budget:**

- Progress bar per kategori alokasi: sudah terpakai vs. batas alokasi
- Peringatan visual jika satu kategori sudah >80% dari alokasi
- Ringkasan: total pemasukan, total pengeluaran, sisa budget keseluruhan
- Tab navigasi antar bulan (bulan sebelumnya read-only)

**Aturan implementasi penting:**

- Dokumen budget bulan ini dibuat **hanya saat user input pemasukan** — jangan auto-create
- Field `monthKey` format wajib: `YYYY-MM` (contoh: `2025-10`) — konsisten di seluruh app
- Query transaksi untuk dashboard selalu filter berdasarkan `monthKey` yang sama
- Saat ganti bulan, dashboard otomatis menampilkan bulan berjalan yang kosong

### Fitur 5 — Target Keuangan (Dream Goal)

**Halaman:** `pages/goal/`

- Pengguna buat target dengan nama, nominal, dan deadline
- Progress bar visual menunjukkan persentase ketercapaian
- Sistem hitung otomatis: "kamu perlu menabung Rp X per hari"
- ARSA memberi peringatan jika pola pengeluaran berisiko gagalkan target
- Animasi konfeti (Lottie `confetti.json`) saat goal 100% tercapai

### Fitur 6 — Analitik Personal (ARSA Brain)

**Halaman:** `pages/analytics/`

- Grafik tren pengeluaran mingguan per kategori (line chart / bar chart)
- Kartu insight ARSA: analisis naratif otomatis dari data 7 hari terakhir
- Segmentasi otomatis tipe pengguna: **Hemat / Impulsif / Konsisten**
- Estimasi ketercapaian goal berdasarkan pola saat ini
- ARSA robot tampil animasi idle (Lottie loop) selama halaman ini aktif

### Fitur 7 — Edukasi Mikro

**Halaman:** `pages/education/`

- Kartu tips harian yang bisa di-swipe (seperti story/card deck)
- Konten dipilih secara adaptif berdasarkan kategori pengeluaran terbesar pengguna
- Topik: Keinginan vs Kebutuhan, cara menabung, membuat anggaran, dll.
- Konten disimpan di Firestore collection `education_content` (diisi admin)

### Fitur 8 — Profil & Pengaturan

**Halaman:** `pages/profile/`

- Tampilkan data profil: nama panggilan, sekolah, tipe pengguna (Hemat/Impulsif/Konsisten)
- Edit nama panggilan dan target utama
- **Kelola kategori custom**: lihat, edit, hapus kategori buatan sendiri
- Ringkasan statistik penelitian: total transaksi dicatat, streak hari aktif
- Logout

---

## 3. Tech Stack

| Layer          | Teknologi                                                       |
| -------------- | --------------------------------------------------------------- |
| **Frontend**   | Flutter (Dart) — satu codebase iOS & Android                    |
| **Auth**       | Firebase Auth (Email/Password + Google Sign-In)                 |
| **Database**   | Cloud Firestore (realtime listener untuk dashboard)             |
| **Storage**    | Firebase Storage (foto struk)                                   |
| **Notifikasi** | Firebase Cloud Messaging (FCM) + flutter_local_notifications    |
| **AI Advisor** | HTTP langsung ke Claude Haiku / Gemini Flash (dikontrol `.env`) |
| **State**      | flutter_bloc v8+                                                |
| **Navigasi**   | go_router                                                       |
| **Animasi**    | flutter_animate + lottie + animate_do + shimmer                 |
| **Font**       | Plus Jakarta Sans (via google_fonts)                            |
| **Model**      | Freezed                                                         |

### Struktur Firestore

```
users/{uid}
  ├── nickname        : String
  ├── email           : String
  ├── school          : String
  ├── primaryGoal     : String  — "Menabung" | "Mengatur Jajan" | "Investasi"
  ├── userType        : String  — "Hemat" | "Impulsif" | "Konsisten"
  ├── createdAt       : Timestamp
  └── fcmToken        : String?

  ├── transactions/{txId}
  │     ├── type       : String  — "income" | "expense"
  │     ├── amount     : Number
  │     ├── categoryId : String  — ID dari kategori default atau custom
  │     ├── note       : String?
  │     ├── receiptUrl : String?
  │     ├── date       : Timestamp
  │     └── monthKey   : String  — format "YYYY-MM", wajib ada di setiap transaksi
  │
  ├── categories/{catId}              ← HANYA kategori CUSTOM buatan user
  │     ├── name       : String
  │     ├── icon       : String       — nama icon Material atau emoji
  │     ├── color      : String       — hex color string, misal "#FF5252"
  │     └── createdAt  : Timestamp
  │
  ├── budgets/{YYYY-MM}               ← satu dokumen per bulan, dibuat saat input pemasukan
  │     ├── monthKey   : String       — "YYYY-MM"
  │     ├── income     : Number       — total pemasukan bulan ini
  │     ├── createdAt  : Timestamp
  │     └── allocations/{allocId}    ← alokasi per kategori
  │           ├── categoryId : String
  │           ├── label      : String — nama kategori saat alokasi dibuat
  │           ├── limitAmount: Number — batas nominal yang dialokasikan
  │           └── percentage : Number — persentase dari total income
  │
  ├── goals/{goalId}
  │     ├── title        : String
  │     ├── targetAmount : Number
  │     ├── savedAmount  : Number
  │     ├── deadline     : Timestamp
  │     ├── imageUrl     : String?
  │     └── isCompleted  : Boolean
  │
  └── insights/{insightId}
        ├── content      : String
        ├── insightType  : String  — "weekly_summary" | "budget_warning" | "goal_alert"
        ├── generatedAt  : Timestamp
        └── isRead       : Boolean

config/api_keys              → read: auth only | write: false
education_content/{id}       → read: auth only | write: false
```

**Kategori default (hardcoded di `AppConstants`, tidak disimpan di Firestore):**

| categoryId              | Nama          | Icon | Warna                     |
| ----------------------- | ------------- | ---- | ------------------------- |
| `default_jajan`         | Jajan         | 🍜   | `AppColors.categoryJajan` |
| `default_nabung`        | Nabung        | 🐷   | `AppColors.secondary`     |
| `default_entertainment` | Entertainment | 🎮   | `AppColors.arsaPrimary`   |

Kategori custom user disimpan di Firestore dengan ID `custom_{uuid}`.
Saat menampilkan pilihan kategori, selalu gabungkan default + custom dalam satu list.
Jangan hardcode list kategori di UI — selalu ambil dari `CategoryRepository`.

---

## 4. Struktur Folder — Wajib Diikuti

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # string, nilai konstanta, KATEGORI DEFAULT
│   │   ├── app_animations.dart    # path file Lottie (.json)
│   │   └── env_config.dart        # baca .env via flutter_dotenv
│   ├── network/
│   │   └── ai_service.dart        # HTTP ke Claude/Gemini, baca EnvConfig
│   ├── theme/
│   │   ├── app_colors.dart        # SEMUA warna — satu-satunya sumber warna
│   │   ├── app_typography.dart    # SEMUA text style — Plus Jakarta Sans
│   │   ├── app_dimensions.dart    # SEMUA spacing, radius, ukuran
│   │   ├── app_theme.dart         # ThemeData lengkap Material 3
│   │   └── theme.dart             # barrel export (import ini saja)
│   └── utils/
│       ├── app_router.dart        # semua route go_router
│       ├── formatters.dart        # Rp format, tanggal, timeAgo, monthKey
│       └── notification_service.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart  # wajib punya field monthKey
│   │   ├── category_model.dart     # model untuk kategori custom
│   │   ├── budget_model.dart       # budget bulanan + allocations
│   │   ├── goal_model.dart
│   │   └── insight_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── transaction_repository.dart
│       ├── category_repository.dart   # gabungkan default + custom
│       ├── budget_repository.dart     # CRUD budget bulanan & alokasi
│       ├── goal_repository.dart
│       └── insight_repository.dart
└── presentation/
    ├── bloc/
    │   ├── auth/
    │   ├── transaction/
    │   ├── category/               # manage kategori custom
    │   ├── budget/                 # budget bulanan & alokasi
    │   ├── goal/
    │   └── analytics/
    ├── pages/
    │   ├── auth/                   # splash, login, register, onboarding
    │   ├── dashboard/
    │   ├── transaction/            # add_transaction, transaction_list
    │   ├── budget/                 # budget_page, input_income, allocation_editor
    │   ├── goal/                   # goal_list, add_goal, goal_detail
    │   ├── analytics/
    │   ├── education/
    │   └── profile/                # profile, manage_categories
    └── widgets/
        ├── arsa/                   # arsa_insight_card, arsa_avatar
        ├── charts/                 # donut_chart, bar_chart, budget_progress_bar
        └── common/                 # app_button, app_card, shimmer_*,
                                    # category_chip, category_picker,
                                    # month_selector, empty_state, ...
```

**Aturan struktur:**

- Satu file page = satu halaman layar. Komponen dalam halaman → ekstrak ke `widgets/`
- Nama file: `snake_case.dart`. Nama class: `PascalCase`
- Jangan buat folder atau layer baru tanpa mendiskusikan dulu dengan developer

---

## 5. Design System — Tidak Boleh Dilanggar

### 5.1 Palet Warna

| Token                          | Hex                 | Digunakan untuk                            |
| ------------------------------ | ------------------- | ------------------------------------------ |
| `AppColors.primary`            | `#2962FF`           | Tombol utama, AppBar accent, link, focus   |
| `AppColors.primaryContainer`   | `#E8EDFF`           | Background chip, badge, highlight ringan   |
| `AppColors.secondary`          | `#00BFA5`           | Income, konfirmasi, progress positif       |
| `AppColors.secondaryContainer` | `#E0FAF6`           | Background kartu income                    |
| `AppColors.tertiary`           | `#FFAB40`           | Saving, goal, warning soft                 |
| `AppColors.tertiaryContainer`  | `#FFF3E0`           | Background kartu goal                      |
| `AppColors.neutral`            | `#73739E`           | Teks sekunder, ikon disabled, subtitle     |
| `AppColors.neutralContainer`   | `#F0F0F8`           | Background input, chip non-aktif           |
| `AppColors.expense`            | `#FF5252`           | Pengeluaran, error, alert merah            |
| `AppColors.background`         | `#F6F7FB`           | Scaffold background                        |
| `AppColors.surface`            | `#FFFFFF`           | Card, bottom sheet, dialog                 |
| `AppColors.arsaPrimary`        | `#651FFF`           | Elemen ARSA + warna kategori Entertainment |
| `AppColors.arsaGradient`       | `#651FFF → #2962FF` | Card ARSA gradient                         |
| `AppColors.categoryJajan`      | `#FF5252`           | Warna chip & ikon kategori Jajan           |

```dart
// ✅ BENAR
Container(color: AppColors.primaryContainer)
Text('...', style: AppTypography.bodyMedium.copyWith(color: AppColors.expense))

// ❌ SALAH — tidak boleh ada di widget manapun
Container(color: Color(0xFF2962FF))
Container(color: Colors.blue)
Container(color: Colors.red.shade200)
```

### 5.2 Typography

Semua text style menggunakan **Plus Jakarta Sans** via `AppTypography`.
Jangan buat `TextStyle(...)` inline di widget — tidak ada pengecualian.

```dart
// ✅ BENAR
Text('Rp 150.000', style: AppTypography.currencyLarge)
Text('Dashboard', style: AppTypography.headlineMedium)
Text('Jajan', style: AppTypography.labelMedium.copyWith(color: AppColors.neutral))
Text('Info ARSA', style: AppTypography.arsaMessage)

// ❌ SALAH
Text('...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
Text('...', style: TextStyle(fontFamily: 'Poppins'))
```

Referensi style yang tersedia:

- Display: `displayLarge`, `displayMedium`
- Headline: `headlineLarge`, `headlineMedium`, `headlineSmall`
- Title: `titleLarge`, `titleMedium`
- Body: `bodyLarge`, `bodyMedium`, `bodySmall`
- Label: `labelLarge`, `labelMedium`, `labelSmall`
- Khusus: `currencyLarge`, `currencyMedium`, `currencySmall`, `arsaMessage`

### 5.3 Spacing & Radius

Gunakan `AppDimensions` untuk semua angka ukuran. Tidak boleh ada angka literal.

```dart
// ✅ BENAR
Padding(padding: EdgeInsets.all(AppDimensions.md))                 // 16
SizedBox(height: AppDimensions.sm)                                  // 8
BorderRadius.circular(AppDimensions.radiusLg)                       // 20
BorderRadius.circular(AppDimensions.radiusFull)                     // pill

// ❌ SALAH
Padding(padding: EdgeInsets.all(16))
SizedBox(height: 8)
BorderRadius.circular(12)
```

Referensi spacing: `xs=4`, `sm=8`, `md=16`, `lg=24`, `xl=32`, `xxl=48`
Referensi radius: `radiusXs=6`, `radiusSm=10`, `radiusMd=14`, `radiusLg=20`, `radiusXl=28`, `radiusFull=100`

### 5.4 Kartu (Card)

Semua card di aplikasi ini menggunakan border tipis, **bukan shadow/elevation**.

```dart
// ✅ Pola kartu standar SakuPintar
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius), // 16
    border: Border.all(color: AppColors.cardBorder, width: 1),
  ),
  padding: const EdgeInsets.all(AppDimensions.cardPadding), // 16
  child: ...,
)

// ❌ Jangan gunakan shadow berat atau elevation tinggi
Card(elevation: 4, shadowColor: Colors.black26, ...)
```

---

## 6. Aturan Animasi

Aplikasi ini menargetkan siswa SMA — UI harus **hidup, modern, dan menyenangkan**,
tapi tidak noise. Setiap animasi harus punya tujuan: memberi feedback, mengarahkan
perhatian, atau menyampaikan status.

### Kapan Wajib Pakai Animasi

| Situasi                                 | Package           | Pola                                                        |
| --------------------------------------- | ----------------- | ----------------------------------------------------------- |
| Halaman atau widget pertama kali muncul | `flutter_animate` | `.animate().fadeIn(duration: 350.ms).slideY(begin: 0.08)`   |
| List item muncul satu per satu          | `flutter_animate` | `.animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.04)` |
| ARSA idle / berpikir                    | `lottie`          | `Lottie.asset(AppAnimations.arsaIdle)` loop                 |
| Loading data                            | `shimmer`         | `Shimmer.fromColors(baseColor: ..., highlightColor: ...)`   |
| Transaksi berhasil disimpan             | `lottie`          | `AppAnimations.success` sekali putar lalu pop               |
| Goal 100% tercapai                      | `lottie`          | `AppAnimations.confetti` sekali putar                       |
| Empty state (belum ada data)            | `lottie`          | `AppAnimations.emptyWallet` loop lambat                     |
| Tap tombol / chip kecil                 | `animate_do`      | `BounceIn(duration: 200ms, child: ...)`                     |

### Aturan Durasi

- Masuk halaman: **300–400ms**, curve `Curves.easeOutCubic`
- Feedback sukses/error: **400–600ms**
- Stagger list item: delay **50–80ms** per item
- ARSA idle: loop tanpa batas, gunakan controller — jangan auto-play tanpa controller

### Yang Tidak Boleh Dianimasi

- Scroll list — jangan tambah animasi saat user sedang scroll
- Tap yang sering diulang (misal tombol + / -)
- Perpindahan teks/angka yang berubah tiap detik

### Shimmer — Wajib untuk Semua Loading State

```dart
// ✅ BENAR — loading state pakai shimmer
if (state.isLoading) return const ShimmerTransactionList();
if (state.isLoading) return const ShimmerDashboardCard();

// ❌ SALAH — jangan pakai ini untuk loading state utama
if (state.isLoading) return const CircularProgressIndicator();
if (state.isLoading) return const Center(child: CircularProgressIndicator());
```

Buat widget shimmer terpisah di `widgets/common/shimmer_*.dart` untuk setiap
tipe konten yang bisa loading (kartu, list tile, chart placeholder, dll).

---

## 7. State Management — BLoC

### Struktur Per Fitur

```
presentation/bloc/transaction/
├── transaction_bloc.dart   # handler event → emit state
├── transaction_event.dart  # semua event (sealed class atau abstract)
└── transaction_state.dart  # satu state class dengan copyWith
```

### Aturan Wajib BLoC

**State harus extend Equatable dan override props:**
**State jangan gunakan freezed**

```dart
// ✅ BENAR
class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) => TransactionState(
    transactions: transactions ?? this.transactions,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [transactions, isLoading, error];
}
```

**Page tidak boleh punya logika bisnis:**

```dart
// ✅ BENAR — page hanya kirim event dan baca state
onPressed: () => context.read<TransactionBloc>().add(const AddTransaction(...)),

// ❌ SALAH — logika ada di page
onPressed: () async {
  final repo = TransactionRepository();
  await repo.addTransaction(...);
  setState(() => _transactions = ...);
}
```

**Gunakan BlocListener untuk side effect (navigasi, snackbar, dialog):**

```dart
BlocListener<TransactionBloc, TransactionState>(
  listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.error!)),
    );
  },
  child: BlocBuilder<TransactionBloc, TransactionState>(
    builder: (context, state) => ...,
  ),
)
```

---

## 8. Repository — Aturan Akses Data

- **Satu-satunya tempat** yang boleh mengimport `cloud_firestore`, `firebase_auth`,
  `firebase_storage` adalah file `*_repository.dart`
- BLoC hanya memanggil method repository — tidak boleh tahu Firebase ada
- Repository tidak boleh import apapun dari `flutter/material.dart`
- Semua method repository yang async harus punya try/catch dan melempar
  exception yang bermakna (bukan raw Firebase exception)

```dart
// ✅ BENAR — repository melempar exception yang jelas
Future<void> addTransaction(...) async {
  try {
    await _firestore.collection(...).doc(id).set(...);
  } on FirebaseException catch (e) {
    throw Exception('Gagal menyimpan transaksi: ${e.message}');
  }
}

// ✅ BENAR — BLoC tangkap exception dari repository
on<AddTransactionEvent>((event, emit) async {
  emit(state.copyWith(isLoading: true));
  try {
    await _repo.addTransaction(...);
    emit(state.copyWith(isLoading: false));
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: e.toString()));
  }
});
```

---

## 9. ARSA — Aturan Khusus AI

### Visual ARSA

- ARSA selalu hadir sebagai **animasi Lottie**, bukan gambar statis
- Saat idle: `AppAnimations.arsaIdle` (loop)
- Saat memuat insight dari API: `AppAnimations.arsaThinking` (loop sampai selesai)
- Saat greeting pertama: `AppAnimations.arsaWave` (sekali putar, lalu switch ke idle)
- Warna elemen ARSA: gunakan `AppColors.arsaGradient` atau `AppColors.arsaPrimary`
- Card ARSA selalu pakai gradient ungu-biru (`AppColors.arsaGradient`), bukan warna flat

### Logika AI

- API key hanya boleh ada di `EnvConfig` — dibaca oleh `AiService`
- Sebelum call API: cek cache di `InsightRepository` — jika insight < 6 jam, pakai cache
- Selalu ada **fallback message** jika API gagal — jangan tampilkan error teknis ke user
- Bahasa output ARSA: Indonesia, maksimal 3 kalimat + 1 saran, nada ramah remaja
- Data yang dikirim ke AI: **ringkasan agregat** saja (total, persentase, kategori terbesar)
  — bukan raw transaksi satu per satu

### Switching Provider

Provider AI dikendalikan dari `.env`:

- `AI_PROVIDER=gemini` → Gemini Flash (default, free tier 1500 req/hari)
- `AI_PROVIDER=claude` → Claude Haiku (berbayar, kualitas lebih tinggi)

Jangan hardcode nama model di luar `EnvConfig` dan `AiService`.

---

## 10. Keamanan

| Aturan                 | Detail                                                                          |
| ---------------------- | ------------------------------------------------------------------------------- |
| `.env` di gitignore    | Wajib. Jangan pernah commit file ini                                            |
| `google-services.json` | Wajib di gitignore                                                              |
| API key di widget/BLoC | **Dilarang keras** — hanya boleh di `AiService` via `EnvConfig`                 |
| Token sensitif         | Simpan di `flutter_secure_storage`, bukan `SharedPreferences`                   |
| Log data user          | Dilarang — jangan `print(userId)`, `print(amount)`, dll.                        |
| Firestore Rules        | User hanya bisa baca/tulis data miliknya sendiri (`request.auth.uid == userId`) |

---

## 11. Naming Convention

| Jenis                | Format               | Contoh                                             |
| -------------------- | -------------------- | -------------------------------------------------- |
| File                 | `snake_case.dart`    | `transaction_bloc.dart`                            |
| Class, Widget        | `PascalCase`         | `TransactionBloc`, `ArsaInsightCard`               |
| Variable, fungsi     | `camelCase`          | `isLoading`, `fetchInsight()`                      |
| Konstanta class      | `camelCase`          | `AppColors.primary`, `AppDimensions.md`            |
| Method build private | prefix `_build`      | `_buildHeader()`, `_buildEmptyState()`             |
| BLoC Event           | verb + noun          | `LoadTransactions`, `AddTransaction`, `DeleteGoal` |
| BLoC State           | noun tunggal + State | `TransactionState`, `GoalState`                    |
| Model                | suffix `Model`       | `TransactionModel`, `GoalModel`                    |
| Repository           | suffix `Repository`  | `TransactionRepository`                            |
| Page                 | suffix `Page`        | `DashboardPage`, `AddTransactionPage`              |
| Shimmer widget       | prefix `Shimmer`     | `ShimmerTransactionList`, `ShimmerDashboardCard`   |

---

## 12. Hal yang Dilarang Keras

```
❌ Color(0xFFxxxxxx) atau Colors.xxx di dalam widget
❌ TextStyle(...) inline di dalam widget
❌ Angka literal untuk spacing/radius/ukuran di widget (gunakan AppDimensions)
❌ Import cloud_firestore / firebase_auth di luar repository
❌ API key hardcode di source code
❌ print() untuk debugging — gunakan Logger dari package logger
❌ setState() untuk state kompleks — gunakan BLoC
❌ CircularProgressIndicator polos sebagai loading state utama — wajib shimmer
❌ Raw error Firebase/API ditampilkan langsung ke user
❌ Log data pribadi: uid, nama, nominal, token
❌ Font selain Plus Jakarta Sans
❌ Commit file .env, google-services.json, atau GoogleService-Info.plist
❌ Hardcode list kategori di widget — selalu ambil dari CategoryRepository
❌ Auto-create dokumen budget — hanya dibuat saat user input pemasukan
❌ Field monthKey dengan format selain "YYYY-MM"
❌ Query transaksi tanpa filter monthKey untuk fitur yang bersifat per-bulan
```

---

## 13. Checklist Sebelum Pull Request / Commit

- [ ] Tidak ada warna hardcode di widget
- [ ] Tidak ada TextStyle inline di widget
- [ ] Tidak ada angka literal untuk spacing atau radius
- [ ] Semua state loading menggunakan widget shimmer, bukan spinner polos
- [ ] Widget yang pertama kali muncul di layar punya animasi masuk (`flutter_animate`)
- [ ] ARSA card/avatar menggunakan Lottie, bukan gambar statis
- [ ] Tidak ada akses Firestore langsung di luar repository
- [ ] Semua BLoC state extend Equatable dan override props
- [ ] Tidak ada `print()` — semua log pakai `Logger`
- [ ] `.env` tidak ikut ter-commit (cek `git status`)
- [ ] Error dari API/repository tidak di-expose langsung ke user
- [ ] Setiap transaksi baru punya field `monthKey` format `YYYY-MM`
- [ ] List kategori tidak di-hardcode di UI — diambil dari `CategoryRepository`
- [ ] Dokumen budget tidak di-auto-create — hanya dibuat saat user input pemasukan

---
