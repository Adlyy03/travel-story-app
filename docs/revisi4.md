KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG CODING DAN EDIT FILE YANG DIPERLUKAN.

TASK:
Audit dan rapikan seluruh button, icon button, menu, FAB, card yang clickable, dan action pada aplikasi Travel Story.

TUJUAN:
Semua tombol yang ditampilkan ke user harus memiliki fungsi yang jelas dan benar-benar bekerja. Tambahkan action penting yang masih belum tersedia agar aplikasi terasa lengkap dan interaktif.

1. AUDIT SEMUA HALAMAN

Periksa:
- Splash
- Home
- Create Trip
- Edit Trip
- Trip Detail
- Story
- GPS/Tracking
- Settings jika ada
- Dialog
- Bottom Navigation jika ada

Cari semua:
- ElevatedButton
- FilledButton
- OutlinedButton
- TextButton
- IconButton
- FloatingActionButton
- GestureDetector
- InkWell
- clickable Card
- PopupMenu
- menu item

2. HOME

Pastikan tersedia dan berfungsi:

"+ Buat Trip"
→ membuka Create Trip.

Trip Card
→ membuka Trip Detail.

Jika ada search/filter/sort:
→ hanya tampilkan jika functionality-nya memang tersedia.

Jika belum ada trip:
→ tampilkan:
"Belum ada perjalanan"
"Yuk, mulai simpan perjalananmu."

Button:
"Buat Trip"

3. CREATE TRIP

Button:

"Batalkan"
→ kembali tanpa menyimpan.

"Simpan Trip"
→ validasi → simpan ke database → kembali ke halaman yang sesuai.

Pastikan button disabled/loading ketika proses save berlangsung.

4. TRIP DETAIL

Tambahkan/rapikan action:

"Edit"
→ Edit Trip.

"Hapus Trip"
→ confirmation dialog → hapus dari persistence → kembali.

"Lihat Story"
→ membuka Story.

Jika tracking sudah tersedia:

"Mulai Perjalanan"
→ mulai tracking.

Jika sedang tracking:

"Berhenti"
→ menghentikan tracking dan menyimpan hasil sesuai logic yang sudah ada.

Jangan menampilkan action tracking jika fitur tracking belum tersedia.

5. DELETE

Gunakan confirmation:

"Hapus Trip?"

"Trip ini akan dihapus dan tidak bisa dikembalikan."

Button:
"Batal"
"Hapus"

Setelah berhasil:
- hapus data
- tutup dialog
- kembali ke halaman sebelumnya
- UI langsung update
- tampilkan feedback singkat

6. EDIT

Button:

"Batalkan"
→ kembali tanpa menyimpan perubahan.

"Simpan Perubahan"
→ update database → update UI → kembali ke detail.

7. STORY

Pastikan:

"Ganti Foto"
→ image picker → pilih foto → preview berubah → simpan.

"Reset Foto"
→ confirmation jika diperlukan → kembali ke background default.

"Kembali"
→ kembali ke Trip Detail.

Jika terdapat "Simpan Story":
→ simpan perubahan yang memang perlu disimpan.

Jika terdapat button yang tidak memiliki fungsi:
→ implementasikan jika relevan atau hapus.

8. BACKGROUND IMAGE

User harus bisa:

Ganti Foto
↓
Pilih dari gallery
↓
Preview berubah
↓
Simpan

Dan:

Reset Foto
↓
Background kembali default

Pastikan path/image state tersimpan menggunakan persistence yang sudah digunakan project.

9. GPS / TRACKING

Jika fitur GPS sudah tersedia, rapikan action-nya.

Minimal:

"Mulai Perjalanan"
→ mulai mengambil lokasi.

"Berhenti"
→ stop tracking.

Jika ada:
"Pause"
→ pause tracking.

Jika ada:
"Lanjutkan"
→ lanjut tracking.

Jangan membuat tombol GPS palsu.

10. BACK NAVIGATION

Pastikan setiap halaman memiliki navigation yang jelas.

Jika ada AppBar:
- gunakan back button yang sesuai.

Jika halaman utama:
- jangan menampilkan back yang tidak diperlukan.

Pastikan Android system back juga bekerja.

11. LOADING

Untuk action async:

Sebelum:
[Simpan Trip]

Saat proses:
[Loading...]

Setelah:
kembali/feedback.

Cegah double tap.

12. FEEDBACK

Gunakan SnackBar/dialog seperlunya.

Contoh:

"Trip berhasil disimpan."

"Trip berhasil dihapus."

"Perubahan berhasil disimpan."

"Foto berhasil diganti."

Jangan menggunakan debug print sebagai feedback user.

13. TOUCH TARGET

Pastikan button/icon nyaman disentuh.

Target minimal sekitar 44–48dp.

Jangan membuat IconButton terlalu kecil.

14. ICON

Gunakan icon yang sesuai dengan action.

Contoh:
- tambah → add
- edit → edit
- hapus → delete
- story → image/photo
- ganti foto → photo_camera
- reset → refresh
- lokasi → location_on
- mulai → play_arrow
- berhenti → stop
- kembali → arrow_back

Jangan menggunakan icon yang membingungkan.

15. BUTTON HIERARCHY

Button utama harus lebih menonjol.

Contoh Trip Detail:

[ Lihat Story ]    ← primary

[ Edit ]            ← secondary

[ Hapus Trip ]      ← destructive

Jangan membuat semua button terlihat sama penting.

16. HAPUS BUTTON PALSU

Jika menemukan:

onPressed: null

atau:

onPressed: () {}

atau action yang hanya:
print(...)

dan button tersebut memang ditampilkan ke user:

- implementasikan functionality-nya jika relevan
- atau hapus button tersebut

Jangan meninggalkan UI palsu.

17. STATE UPDATE

Setelah action:
- create
- edit
- delete
- tracking
- update story
- update background

pastikan state dan UI langsung berubah.

Jangan mengharuskan user restart aplikasi.

18. DATABASE

Gunakan database/local persistence yang sudah ada.

Jangan membuat data hanya seperti:

final trips = [];

Jika project sudah memiliki repository/database, gunakan itu.

Pastikan:
CREATE → INSERT
EDIT → UPDATE
DELETE → DELETE
STORY → UPDATE
BACKGROUND → UPDATE

19. ERROR HANDLING

Jika action gagal:
- jangan crash
- tampilkan pesan sederhana

Contoh:

"Gagal menyimpan trip. Coba lagi."

"Gagal menghapus trip."

"Gagal memilih foto."

Jangan tampilkan stack trace kepada user.

20. RAPATKAN ACTION

Jangan memenuhi layar dengan terlalu banyak tombol.

Prioritaskan action utama.

Trip Detail:

[Lihat Story]
[Edit]
[Hapus Trip]

Story:

[Ganti Foto]
[Reset Foto]

Create/Edit:

[Batalkan] [Simpan]

Tracking:

[Mulai Perjalanan]
atau
[Berhenti]

21. RESPONSIVE

Pastikan:
- button tidak overflow
- text tidak terpotong
- icon tidak bertabrakan
- layout tetap bagus di layar kecil
- keyboard tidak menutupi button form
- halaman panjang bisa scroll

22. KONSISTENSI

Gunakan style button yang konsisten:
- radius
- padding
- typography
- icon spacing
- elevation
- margin

Ikuti Theme yang sudah ada.

Jangan membuat setiap halaman memiliki desain button yang berbeda.

23. JANGAN MERUSAK FITUR SEBELUMNYA

Pertahankan seluruh revisi sebelumnya:
- Story ala activity/share card
- background Story bisa diganti
- splash screen
- caption sederhana
- database
- GPS
- navigation

Integrasikan button ke fitur-fitur tersebut.

24. HASIL AKHIR

Pastikan flow utama benar-benar bisa dilakukan:

HOME
↓
Buat Trip
↓
Simpan
↓
Trip muncul
↓
Tap Trip
↓
Trip Detail
├── Edit → edit → save
├── Hapus → confirm → delete
├── Lihat Story → Story
│                  ├── Ganti Foto
│                  └── Reset Foto
└── Tracking → Mulai / Berhenti

Tidak boleh ada action penting yang hanya menjadi tampilan.

LANGSUNG IMPLEMENTASIKAN SEMUA PERUBAHAN DI PROJECT.
JANGAN MEMBUAT TEST.
JANGAN MEMBERIKAN CONTOH CODE SAJA.
JANGAN MENJELASKAN PANJANG.
LANGSUNG CODING SAMPAI SELESAI.