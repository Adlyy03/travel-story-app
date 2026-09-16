KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG EDIT/CODING FILE YANG DIPERLUKAN.

TASK:
Ubah fitur "Story" pada aplikasi Travel Story agar hasil story memiliki tampilan visual seperti activity/share card pada aplikasi olahraga modern, terinspirasi dari gaya Strava pada gambar referensi yang diberikan user.

TUJUAN:
Story yang dibuat user harus terlihat seperti sebuah "travel activity card" yang siap dilihat/dibagikan, bukan sekadar kumpulan teks biasa.

REFERENSI VISUAL:
Gunakan gambar referensi yang diberikan user sebagai inspirasi layout:
- background berupa foto full-screen
- informasi aktivitas berada di atas foto
- typography besar dan jelas
- angka/statistik menjadi elemen visual utama
- overlay/transparansi agar teks tetap terbaca
- desain minimalis, modern, clean
- jangan menyalin logo, branding, atau aset Strava
- gunakan branding aplikasi Travel Story sendiri

ATURAN UTAMA:

1. STORY MENGGUNAKAN BACKGROUND IMAGE
Buat story menggunakan gambar sebagai background utama.

Background image harus:
- memenuhi seluruh area story/card
- menggunakan BoxFit.cover
- tetap terlihat bagus pada berbagai ukuran layar
- memiliki overlay gradient/transparan supaya tulisan mudah dibaca
- tidak membuat informasi statistik sulit dibaca

Jika trip belum memiliki gambar:
- gunakan placeholder/default background yang sudah tersedia di project jika ada
- jangan membuat sistem gambar baru yang tidak diperlukan

2. USER BISA MENGGANTI BACKGROUND IMAGE
Tambahkan fitur untuk mengganti background story.

User harus bisa:
- memilih gambar dari gallery/device
- melihat gambar yang dipilih sebagai background
- mengganti gambar kembali kapan saja
- menghapus/reset gambar custom dan kembali ke default

Gunakan image picker/package yang SUDAH ADA di project jika tersedia.
Jika belum ada package yang sesuai, tambahkan dependency yang memang diperlukan.

Jangan membuat flow yang rumit.

Flow yang diinginkan:

Story Detail
    ↓
Button "Ganti Foto"
    ↓
Gallery/Image Picker
    ↓
User memilih foto
    ↓
Preview Story langsung berubah
    ↓
User dapat menyimpan perubahan

3. DATA TRIP HARUS TETAP DINAMIS
Jangan hardcode data story.

Gunakan data trip yang sudah ada di project.

Minimal story menampilkan data seperti:
- nama/judul perjalanan
- distance/jarak jika tersedia
- duration/waktu jika tersedia
- tanggal perjalanan jika tersedia
- lokasi/start-end location jika tersedia
- informasi perjalanan lain yang memang sudah tersedia di model/database

Contoh visual:

[BACKGROUND PHOTO]

        TRAVEL STORY

        BALI TRIP
        10.25 km

        58m 37s
        Duration

        DENPASAR → UBUD

        03 SEPTEMBER 2026

Jangan memaksakan field yang belum tersedia.
Gunakan data yang memang sudah ada.

4. STORY HARUS PUNYA PREVIEW
Buat halaman preview story yang menampilkan hasil akhir secara visual.

Preview harus terasa seperti sebuah shareable story.

Gunakan layout portrait yang cocok untuk:
- mobile screen
- story-style image
- screenshot/share nantinya

Prioritaskan aspect ratio portrait sekitar 9:16 jika arsitektur project memungkinkan.

5. TYPOGRAPHY
Buat tulisan mudah dibaca.

Aturan:
- judul trip lebih besar
- angka statistik lebih besar dan bold
- label statistik lebih kecil
- informasi tambahan menggunakan ukuran sedang
- jangan terlalu banyak jenis font
- gunakan hierarchy yang jelas
- jangan menaruh terlalu banyak teks

Contoh:

TRAVEL STORY
10.25 KM
Distance

58m 37s
Duration

BALI → UBUD
03 SEP 2026

Gunakan bahasa yang sederhana dan mudah dimengerti.

6. LAYOUT
Rapikan posisi semua elemen.

Gunakan:
- SafeArea
- padding yang konsisten
- alignment yang jelas
- spacing yang cukup
- responsive layout

Jangan membuat elemen:
- terlalu mepet ke pinggir
- terlalu kecil
- bertumpuk
- keluar dari layar
- sulit dibaca di atas background

Informasi utama sebaiknya berada di area yang memiliki kontras cukup terhadap foto.

7. VISUAL STYLE
Gunakan desain:
- modern
- minimal
- clean
- premium
- travel + activity tracking
- tidak terlalu ramai

Background foto adalah elemen visual utama.

Tambahkan overlay gradient bila diperlukan.

Contoh struktur:

┌─────────────────────────┐
│                         │
│     TRAVEL STORY        │
│                         │
│     [PHOTO AREA]        │
│                         │
│     BALI TRIP           │
│                         │
│     10.25 KM            │
│     Distance            │
│                         │
│     58m 37s             │
│     Duration            │
│                         │
│     DENPASAR → UBUD     │
│                         │
│     03 SEP 2026         │
│                         │
└─────────────────────────┘

Sesuaikan posisi berdasarkan desain aplikasi yang sudah ada.

8. EDIT BACKGROUND
Pada halaman story tambahkan kontrol yang jelas, misalnya:

"Ganti Foto"

dan bila diperlukan:

"Reset Foto"

Button harus mudah ditemukan tetapi tidak mengganggu preview story.

Gunakan icon yang sesuai seperti:
- photo/image
- edit
- refresh/reset

9. PERSISTENCE
Background custom harus disimpan bersama data story/trip jika arsitektur database/local persistence project sudah mendukungnya.

Artinya:
- user memilih foto
- keluar dari halaman
- masuk kembali
- background tetap menggunakan foto yang dipilih

Ikuti architecture dan database/persistence yang SUDAH ADA.

Jangan membuat database architecture baru kalau tidak diperlukan.

Jika model Trip/Story membutuhkan field tambahan, tambahkan field yang paling sederhana dan konsisten, misalnya:
backgroundImagePath

Sesuaikan dengan naming convention project.

10. JANGAN MERUSAK FITUR LAMA
Pertahankan:
- model trip yang sudah ada
- database yang sudah ada
- navigation yang sudah ada
- GPS/data perjalanan yang sudah ada
- fitur story sebelumnya

Refactor hanya bagian yang memang diperlukan.

11. KOMPONEN
Pisahkan UI menjadi widget/component yang masuk akal bila diperlukan.

Contoh:

StoryPreview
StoryBackground
StoryStats
StoryHeader
BackgroundPickerButton

Jangan over-engineering.

12. BUTTON DAN INTERACTION
Minimal interaction yang harus berfungsi:

- Ganti Foto
- Reset Foto
- kembali ke halaman sebelumnya
- buka detail/preview story sesuai flow aplikasi yang sudah ada

Jangan hanya membuat button visual tanpa functionality.

13. ERROR HANDLING
Tangani kondisi sederhana:
- user membatalkan pemilihan foto
- foto gagal dipilih
- file tidak ditemukan
- background belum tersedia

Jangan sampai aplikasi crash hanya karena user membatalkan image picker.

14. IMPLEMENTASI
Sebelum coding:
- baca struktur project yang sudah ada
- cari model Trip/Story
- cari halaman Story yang sekarang
- cari database/local persistence
- cari routing/navigation
- cari dependency yang sudah digunakan

Kemudian implementasikan fitur ini menggunakan architecture yang sudah ada.

JANGAN membuat architecture baru jika tidak diperlukan.

15. HASIL AKHIR
Setelah selesai, fitur Story harus terasa seperti:

User membuka Trip
→ membuka Story
→ melihat preview travel activity dengan background foto
→ statistik perjalanan tampil besar dan jelas
→ user menekan "Ganti Foto"
→ memilih foto dari gallery
→ preview langsung menggunakan foto baru
→ user dapat reset foto
→ perubahan background tetap tersimpan

LANGSUNG KERJAKAN CODING DI PROJECT.
JANGAN MEMBERIKAN PENJELASAN PANJANG.
JANGAN MEMBUAT TEST.
JANGAN BERHENTI DI ANALISIS.
SETELAH MEMAHAMI PROJECT, LANGSUNG IMPLEMENTASIKAN REVISI INI.