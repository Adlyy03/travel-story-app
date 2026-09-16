KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG CODING DAN EDIT FILE YANG DIPERLUKAN.

TASK:
Buat aplikasi Travel Story menjadi benar-benar interaktif.

TUJUAN:
Setiap elemen yang terlihat seperti tombol, menu, card, atau aksi harus memiliki fungsi nyata. Jangan membuat UI yang hanya terlihat bagus tetapi tidak melakukan apa-apa ketika ditekan.

ATURAN UTAMA:

1. CEK SEMUA HALAMAN YANG SUDAH ADA
Baca struktur project terlebih dahulu dan identifikasi:
- halaman Home
- halaman Trip
- halaman Trip Detail
- halaman Story
- halaman Create/Add Trip
- halaman GPS/Tracking jika sudah ada
- navigation/router
- database/local persistence

Jangan mengubah architecture yang sudah ada tanpa alasan.

2. HOME HARUS INTERAKTIF

Jika terdapat daftar trip:
- setiap trip card bisa ditekan
- tap card → masuk ke Trip Detail
- gunakan InkWell/GestureDetector atau mekanisme yang sesuai
- berikan feedback visual saat ditekan

Jika belum ada trip:
- tampilkan empty state yang jelas
- sediakan button seperti:
  "Buat Trip"

Button tersebut harus benar-benar membuka halaman pembuatan trip.

3. CREATE TRIP HARUS BERFUNGSI

Pastikan user dapat:
- memasukkan nama trip
- memasukkan informasi yang memang tersedia di model
- menyimpan trip
- membatalkan pembuatan trip

Button:
"Save Trip" / "Simpan Trip"

harus:
- melakukan validasi sederhana
- menyimpan data ke persistence yang sudah digunakan project
- kembali ke halaman sebelumnya
- data baru langsung muncul di daftar trip

Jangan menggunakan dummy action.

4. TRIP DETAIL HARUS INTERAKTIF

Pada Trip Detail, buat action yang relevan benar-benar berfungsi.

Minimal:
- Edit Trip
- Delete Trip
- Open Story
- Start/Continue tracking jika fitur tracking sudah tersedia
- Back

Jangan menampilkan button untuk fitur yang belum bisa dilakukan.

5. DELETE TRIP

Tambahkan button:

"Hapus Trip"

Ketika ditekan:
- tampilkan confirmation dialog
- jelaskan secara sederhana bahwa trip akan dihapus
- tersedia:
  "Batal"
  "Hapus"

Jika user memilih "Hapus":
- hapus trip dari database/local persistence
- kembali ke halaman sebelumnya
- daftar trip langsung ter-update

Jangan langsung menghapus tanpa konfirmasi.

6. EDIT TRIP

Jika fitur edit belum ada, implementasikan flow sederhana.

Flow:

Trip Detail
↓
Edit
↓
Edit Trip Page
↓
ubah data
↓
Save
↓
database diperbarui
↓
Trip Detail menampilkan data terbaru

Gunakan model dan persistence yang sudah ada.

7. STORY HARUS INTERAKTIF

Integrasikan dengan revisi Story sebelumnya.

Minimal:
- Open Story
- Ganti Foto
- Reset Foto
- Back

Jika terdapat button share/save dan memang mudah diimplementasikan berdasarkan architecture project, buat button tersebut berfungsi juga.

Jangan membuat tombol palsu.

8. NAVIGATION

Pastikan seluruh navigation terasa natural.

Contoh flow:

HOME
 ↓
Trip Card
 ↓
TRIP DETAIL
 ├── Edit
 ├── Delete
 ├── Story
 └── Tracking

Create Trip:
HOME
 ↓
Buat Trip
 ↓
Save
 ↓
HOME / TRIP DETAIL

Gunakan navigation/router yang sudah digunakan project.

Jangan membuat sistem routing baru kalau project sudah memiliki router.

9. FEEDBACK SETIAP ACTION

Setelah user melakukan action penting, berikan feedback yang jelas.

Contoh:
- trip berhasil dibuat
- trip berhasil dihapus
- perubahan berhasil disimpan
- foto berhasil diganti

Gunakan SnackBar, dialog, atau feedback UI yang sesuai.

Jangan terlalu banyak popup.

10. LOADING STATE

Untuk action yang membutuhkan proses asynchronous, tampilkan loading state.

Contoh:
User menekan "Simpan"
→ button/loading berubah
→ proses save
→ selesai
→ kembali/feedback

Jangan membuat user bisa menekan button berkali-kali saat proses berjalan.

11. EMPTY STATE

Jika tidak ada trip, jangan hanya menampilkan halaman kosong.

Buat:

Belum ada perjalanan

"Mulai simpan cerita perjalananmu."

Button:
"+ Buat Trip"

Button harus berfungsi.

Gunakan bahasa yang sederhana dan mudah dimengerti.

12. INTERACTIVE CARD

Trip card harus:
- bisa ditekan
- memiliki visual feedback
- membuka detail trip
- tidak membuat seluruh layout berantakan

Jika ada icon/menu pada card, pastikan action-nya jelas.

13. FORM VALIDATION

Untuk input yang wajib:
- jangan izinkan save jika data wajib kosong
- tampilkan pesan error sederhana

Contoh:

"Nama trip harus diisi."

Jangan menggunakan pesan teknis seperti:
"Null check operator used..."
atau error developer lainnya.

14. BACK BUTTON

Pastikan:
- Android system back berfungsi
- tombol back pada UI berfungsi
- tidak menyebabkan navigation stack aneh
- user tidak kehilangan data secara tiba-tiba

Jika sedang mengisi form dan belum disimpan, jangan otomatis menghapus data yang sudah diketik tanpa alasan.

15. BUTTON STYLE

Semua button harus konsisten.

Gunakan:
- ukuran yang nyaman disentuh
- padding konsisten
- border radius konsisten
- icon jika membantu
- text yang singkat dan mudah dipahami

Minimal touch target sekitar 44–48dp.

15B. VISUAL STYLE: MINIMALISM

Seluruh tampilan app (bukan hanya button) harus mengikuti gaya minimalis.

Ketentuan:
- palet warna terbatas (1 warna utama + neutral/monochrome, hindari warna ramai)
- banyak whitespace, jangan padat/berantakan
- hilangkan shadow/gradient/dekorasi yang tidak perlu
- 1 font family, maksimal 2 font weight konsisten di seluruh app
- icon simple/outline, hindari icon terlalu ramai
- hierarchy jelas lewat ukuran & spacing, bukan lewat warna mencolok
- card/component flat, border radius konsisten, tanpa efek berlebihan
- animasi/transisi halus dan singkat, jangan berlebihan

Terapkan gaya ini konsisten ke semua halaman: Home, Trip Detail, Create/Edit Trip, Story, dialog, dan empty state.

Jangan ubah struktur/logic yang sudah ada hanya karena mengubah style — cukup sesuaikan tampilan (theme, spacing, warna, typography).

16. JANGAN ADA BUTTON PALSU

Cari seluruh UI yang sudah ada.

Jika ada:
- button
- icon button
- floating action button
- menu
- card
- clickable text
- navigation item

Pastikan action-nya:
A. benar-benar berfungsi

atau

B. jika memang belum diperlukan, hapus dari UI.

Jangan meninggalkan button yang ketika ditekan tidak melakukan apa-apa.

17. STATE HARUS LANGSUNG TERUPDATE

Setelah:
- create trip
- edit trip
- delete trip
- update background image

UI harus menampilkan data terbaru tanpa user harus menutup aplikasi.

Gunakan state management yang sudah ada di project.

Jangan menambahkan state management framework baru jika tidak diperlukan.

18. DATABASE / PERSISTENCE

Semua perubahan penting harus mengikuti persistence yang sudah digunakan:

CREATE
→ save

EDIT
→ update

DELETE
→ delete

BACKGROUND IMAGE
→ save/update

Pastikan data tidak hanya berubah sementara di memory.

19. JANGAN MENGUBAH DATA DENGAN HARDCODE

Jangan membuat action seperti:

onPressed: () {
  print("Delete");
}

atau:

onPressed: () {}

untuk fitur yang seharusnya berfungsi.

Semua action harus terhubung ke logic aplikasi.

20. RESPONSIVE INTERACTION

Pastikan interaksi nyaman digunakan di Android:
- button tidak terlalu kecil
- spacing cukup
- tidak ada overflow
- keyboard tidak menutupi form
- dialog tidak keluar layar
- scroll tersedia jika konten panjang

21. PRIORITAS IMPLEMENTASI

Kerjakan dengan urutan:

1. Home interaction
2. Create Trip
3. Trip Detail
4. Edit Trip
5. Delete Trip
6. Story interaction
7. Navigation
8. Feedback/loading
9. Empty state
10. Visual style minimalism (theme, spacing, warna, typography)
11. Rapikan seluruh clickable UI

22. JANGAN MERUSAK FITUR YANG SUDAH ADA

Pertahankan fitur:
- GPS
- trip data
- database
- story
- background image
- navigation
- architecture

Integrasikan interaction ke sistem yang sudah ada.

23. HASIL AKHIR YANG DIINGINKAN

User harus bisa melakukan flow nyata:

Buka App
↓
Home
↓
Buat Trip
↓
Isi data
↓
Simpan
↓
Trip muncul
↓
Tap Trip
↓
Trip Detail
↓
Edit / Delete / Story
↓
Buka Story
↓
Ganti background
↓
Data tersimpan

SEMUA ACTION DI ATAS HARUS BENAR-BENAR BERFUNGSI.
SELURUH TAMPILAN HARUS MENGIKUTI GAYA MINIMALIS.

LANGSUNG KERJAKAN CODING DI PROJECT.
JANGAN MEMBERIKAN PENJELASAN PANJANG.
JANGAN MEMBUAT TEST.
JANGAN BERHENTI DI ANALISIS.
JANGAN HANYA MEMBUAT UI.
IMPLEMENTASIKAN FUNCTIONALITY-NYA LANGSUNG.