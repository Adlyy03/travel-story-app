KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG CODING DAN EDIT FILE YANG DIPERLUKAN.

TASK:
Tambahkan Splash Screen pada aplikasi Travel Story agar ketika aplikasi pertama kali dibuka, user melihat tampilan pembuka yang rapi, modern, dan sesuai dengan identitas aplikasi.

TUJUAN:
Buat opening app yang terasa seperti aplikasi sungguhan, bukan langsung menampilkan halaman Home.

FLOW:
App dibuka
↓
Splash Screen
↓
inisialisasi aplikasi
↓
Home

1. BUAT SPLASH SCREEN

Buat halaman Splash Screen khusus.

Tampilan harus:
- clean
- minimal
- modern
- cocok dengan tema Travel Story
- tidak terlalu ramai
- fokus pada branding aplikasi

Struktur visual kira-kira:

┌─────────────────────────┐
│                         │
│                         │
│                         │
│          LOGO           │
│                         │
│      Travel Story       │
│                         │
│  Ceritakan perjalananmu │
│                         │
│                         │
│                         │
└─────────────────────────┘

Gunakan logo/aset aplikasi yang SUDAH ADA di project jika tersedia.

Jika belum ada logo yang bisa digunakan:
- gunakan icon/logo sederhana berbasis asset yang tersedia
- jangan membuat asset eksternal yang tidak diperlukan

2. BRANDING

Tampilkan:
- logo aplikasi
- nama "Travel Story"
- tagline pendek

Gunakan caption yang gampang dimengerti.

Contoh tagline:
"Ceritakan perjalananmu."

Jangan menggunakan kalimat marketing yang terlalu panjang.

3. ANIMASI SEDERHANA

Tambahkan animasi ringan agar splash terasa modern.

Contoh:
- logo fade in
- logo scale sedikit
- text fade in

Gunakan animasi Flutter bawaan jika memungkinkan.

Jangan menggunakan animasi berat.

Durasi splash jangan terlalu lama.

Target sekitar 1–2 detik sudah cukup.

4. NAVIGATION

Setelah splash selesai:
→ otomatis masuk ke halaman utama aplikasi.

Jangan membuat user harus menekan tombol untuk masuk ke Home.

Flow harus:

Splash
↓
Home

5. JANGAN MENGGANGGU DATABASE

Splash harus tetap berjalan normal meskipun:
- database belum memiliki trip
- database memiliki banyak trip
- user baru pertama kali membuka aplikasi
- user sudah pernah menggunakan aplikasi

Splash hanya menjadi entry point aplikasi.

6. INITIALIZATION

Jika project sudah memiliki proses initialization seperti:
- database initialization
- local storage
- shared preferences
- repository initialization
- state initialization

Pastikan splash tidak selesai sebelum initialization penting tersebut siap.

Flow:

App Start
↓
Initialize dependency/data
↓
Splash
↓
Home

Atau sesuaikan dengan architecture project yang sudah ada.

Jangan membuat initialization baru jika tidak diperlukan.

7. FIRST LAUNCH

Pastikan aplikasi tetap memiliki splash setiap kali aplikasi dibuka dari awal.

Jangan membuat onboarding yang panjang.

Jangan membuat login.

Jangan membuat halaman tambahan yang tidak diminta.

8. SYSTEM UI

Rapikan:
- status bar
- navigation bar
- background
- SafeArea

Splash harus terlihat penuh dan tidak berantakan di berbagai ukuran Android.

Jika project menggunakan theme tertentu, ikuti theme yang sudah ada.

9. APP ICON / NATIVE SPLASH

Jika project menggunakan konfigurasi native Android untuk splash screen, gunakan mekanisme yang sesuai dengan versi Flutter/Android yang sudah digunakan.

Jangan membuat dua splash screen yang terlihat bertabrakan.

Jika diperlukan, sesuaikan:
- Android launch theme
- splash configuration
- Flutter splash page

Tujuannya adalah transisi:

Native launch
→ Travel Story Splash
→ Home

terasa mulus.

10. LOADING / ERROR

Jika initialization membutuhkan waktu:
- tampilkan splash sampai siap
- jangan menampilkan Home sebelum dependency penting siap

Jika ada error initialization yang memang harus ditangani:
- jangan crash tanpa alasan
- gunakan mekanisme error handling yang sudah ada di project

Jangan membuat UI error kompleks.

11. RESPONSIVE

Pastikan logo dan tulisan:
- berada di tengah
- tidak terlalu besar
- tidak terlalu kecil
- memiliki spacing yang proporsional
- tetap bagus pada layar Android kecil maupun besar

Gunakan responsive layout Flutter yang sederhana.

12. CODE STRUCTURE

Ikuti struktur folder project yang sudah ada.

Jika project memiliki folder:
lib/
  screens/
  widgets/
  services/
  models/

ikuti struktur tersebut.

Buat file Splash Screen di lokasi yang paling sesuai dengan architecture project.

Jangan membuat struktur folder baru yang tidak diperlukan.

13. ROUTING

Cari sistem navigation/router yang sudah digunakan project.

Integrasikan Splash ke router tersebut.

Jangan mengganti navigation system yang sudah ada.

Pastikan user tidak bisa kembali dari Home ke Splash menggunakan tombol Back Android.

Splash adalah halaman pembuka, bukan halaman yang masuk ke navigation stack seperti halaman biasa.

14. JANGAN MERUSAK FITUR LAMA

Pastikan revisi ini tidak merusak:
- Home
- Create Trip
- Edit Trip
- Delete Trip
- Trip Detail
- Story
- Background Image
- GPS/tracking
- Database
- Local persistence
- Navigation

15. HASIL AKHIR

Saat user membuka aplikasi:

[APP START]
      ↓
[TRAVEL STORY SPLASH]
      ↓
logo muncul
      ↓
"Travel Story"
      ↓
"Ceritakan perjalananmu."
      ↓
[HOME]

Splash harus terasa singkat, smooth, dan profesional.

16. IMPLEMENTASI

Sebelum coding:
- baca struktur project
- cari main.dart
- cari MaterialApp/CupertinoApp
- cari router/navigation
- cari theme
- cari asset/logo
- cari initialization/database

Setelah itu langsung implementasikan Splash Screen dengan mengikuti architecture yang sudah ada.

JANGAN MEMBUAT TEST.
JANGAN HANYA MEMBERIKAN CONTOH CODE.
JANGAN MEMBERIKAN PENJELASAN PANJANG.
JANGAN BERHENTI DI ANALISIS.
LANGSUNG EDIT DAN CODING PROJECT INI SAMPAI REVISI SPLASH SCREEN SELESAI.