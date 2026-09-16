KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG CODING DAN EDIT FILE YANG DIPERLUKAN.

TASK:
Lakukan UI/UX cleanup menyeluruh pada aplikasi Travel Story agar layout lebih rapi, proporsional, nyaman dilihat, dan terasa seperti aplikasi mobile yang benar-benar siap digunakan.

JANGAN MENGUBAH TUJUAN UTAMA APLIKASI.
Fokus pada:
- layout
- spacing
- ukuran
- posisi
- bentuk komponen
- typography
- hierarchy
- alignment
- responsive UI
- konsistensi antar halaman

1. AUDIT SEMUA HALAMAN

Periksa dan rapikan:
- Splash Screen
- Home
- Create Trip
- Edit Trip
- Trip Detail
- Story
- GPS/Tracking
- Dialog
- Bottom Navigation jika ada
- Empty State
- Loading State

Jangan hanya memperbaiki satu halaman.

2. GUNAKAN SPACING YANG KONSISTEN

Buat sistem spacing yang konsisten.

Gunakan nilai yang masuk akal seperti:
- 8dp
- 12dp
- 16dp
- 20dp
- 24dp
- 32dp

Hindari setiap widget memiliki padding random.

Contoh:

Screen padding:
16–24dp

Section spacing:
20–24dp

Card internal padding:
16dp

Button spacing:
8–12dp

Sesuaikan dengan UI yang sudah ada.

3. HOME

Buat Home terlihat bersih dan mudah dipahami.

Struktur:

AppBar
↓
Greeting / title
↓
Summary jika memang tersedia
↓
Daftar Trip
↓
FAB / button Buat Trip

Trip card harus:
- memiliki ukuran proporsional
- tidak terlalu tinggi
- tidak terlalu kecil
- spacing antar card konsisten
- radius konsisten
- informasi penting terlihat jelas
- bisa ditekan

Jika list panjang:
gunakan scrolling.

Jangan membuat semua elemen memenuhi layar.

4. TRIP CARD

Rapikan hierarchy:

Nama Trip
Lokasi
Tanggal
Statistik penting

Jangan menampilkan terlalu banyak informasi.

Contoh:

Bali Trip
Denpasar → Ubud

10.25 km · 58m 37s
03 Sep 2026

Pastikan text tidak bertabrakan.

5. CREATE / EDIT TRIP

Gunakan form yang rapi.

Contoh:

Nama Trip
[________________]

Lokasi Mulai
[________________]

Lokasi Tujuan
[________________]

[ Batal ] [ Simpan Trip ]

Aturan:
- label jelas
- hint sederhana
- input tinggi nyaman
- jarak antar field cukup
- keyboard tidak menutupi input/button
- halaman dapat di-scroll

Jangan menumpuk semua field terlalu rapat.

6. BUTTON

Rapikan seluruh button.

Button harus:
- tinggi nyaman
- text mudah dibaca
- icon jika diperlukan
- radius konsisten
- tidak terlalu besar
- tidak terlalu kecil

Gunakan hierarchy:

Primary:
[Simpan Trip]

Secondary:
[Batal]

Destructive:
[Hapus Trip]

Jangan semua button memiliki visual yang sama.

7. APPBAR

Buat AppBar konsisten.

Setiap halaman harus memiliki:
- title yang jelas
- back button jika diperlukan
- action button hanya jika memang berguna

Jangan menaruh terlalu banyak icon di AppBar.

8. TRIP DETAIL

Susun informasi berdasarkan prioritas.

Contoh:

Trip Title
Location
Date

────────────

Distance
10.25 km

Duration
58m 37s

────────────

[ Lihat Story ]

[ Edit ]

[ Hapus Trip ]

Buat informasi mudah discan.

Jangan membuat semua text memiliki ukuran sama.

9. STORY

Pertahankan desain Story dari revisi sebelumnya.

Story harus menjadi bagian paling visual dari aplikasi.

Pastikan:
- background image memenuhi card/screen
- overlay cukup
- text memiliki contrast
- statistik besar dan jelas
- title tidak bertabrakan
- button tidak mengganggu preview

Struktur visual:

PHOTO
↓
Travel Story
↓
Trip Name
↓
Main Statistics
↓
Location / Date
↓
Actions

Jangan memenuhi foto dengan terlalu banyak text.

10. STORY STATISTICS

Buat statistik terlihat seperti activity card modern.

Contoh:

10.25
km
Jarak

58:37
Durasi

2.4
km/h
Avg. Speed

Hanya tampilkan data yang memang tersedia.

Angka:
- besar
- bold

Label:
- lebih kecil
- mudah dibaca

11. GPS / TRACKING

Jika halaman tracking tersedia, buat layout fokus pada informasi utama.

Contoh:

        Jarak
       10.25 km

        Waktu
        58:37

     [ PETA / MAP ]

     [ Berhenti ]

Jangan menampilkan terlalu banyak informasi kecil.

12. EMPTY STATE

Empty state harus berada di area yang nyaman secara visual.

Contoh:

[ icon ]

Belum ada perjalanan

Yuk, mulai simpan perjalananmu.

[ + Buat Trip ]

Jangan terlalu banyak whitespace kosong.

13. CARD DESIGN

Jika menggunakan Card:

Gunakan radius yang konsisten.

Contoh sekitar:
12–20dp.

Jangan membuat:
- satu card radius 8
- card lain 20
- card lain 30

kecuali memang ada alasan desain.

Elevation/shadow juga harus subtle.

14. COLORS

Gunakan color scheme dari Theme project yang sudah ada.

Jangan menambahkan terlalu banyak warna.

Prioritaskan:
- background
- surface/card
- primary
- text
- secondary text
- error/destructive

Pastikan contrast cukup.

Jangan menggunakan warna mencolok tanpa alasan.

15. TYPOGRAPHY

Buat hierarchy yang jelas.

Contoh:

Page Title
28–32

Section Title
20–24

Trip Title
18–22

Body
14–16

Caption
12–14

Sesuaikan dengan Theme dan ukuran layar.

Jangan menggunakan terlalu banyak font size berbeda.

16. ICON

Gunakan icon yang:
- konsisten
- relevan
- mudah dipahami

Jangan menggunakan icon hanya untuk dekorasi.

Icon button harus memiliki ukuran touch area yang nyaman.

17. RESPONSIVE

Pastikan layout tetap bagus pada:
- Android kecil
- Android besar
- portrait

Hindari:
- hardcoded width berlebihan
- posisi absolute yang tidak diperlukan
- overflow
- RenderFlex overflow
- text keluar layar

Gunakan:
- Expanded
- Flexible
- ListView
- SingleChildScrollView
- LayoutBuilder
sesuai kebutuhan.

18. KEYBOARD

Pada Create/Edit Trip:

Saat keyboard muncul:
- input tetap bisa terlihat
- button tidak tertutup
- halaman bisa scroll

Gunakan konfigurasi dan layout Flutter yang tepat.

19. SAFE AREA

Pastikan konten tidak tertutup:
- status bar
- camera notch
- navigation bar

Gunakan SafeArea jika diperlukan.

20. BOTTOM NAVIGATION

Jika project memiliki Bottom Navigation:

Rapikan:
- icon
- label
- spacing
- selected state
- unselected state

Jangan membuat navigation terlalu tinggi.

Jika Bottom Navigation tidak diperlukan, jangan memaksakan membuatnya.

21. FLOATING ACTION BUTTON

Jika Home menggunakan FAB:

Pastikan:
- tidak menutupi content penting
- posisi aman
- icon jelas
- action → Buat Trip
- ukurannya proporsional

22. DIALOG

Rapikan dialog delete/confirmation.

Jangan terlalu besar.

Contoh:

Hapus Trip?

Trip ini akan dihapus dan tidak bisa dikembalikan.

[Batal] [Hapus]

Button destructive harus mudah dibedakan.

23. LOADING

Loading state harus tetap terlihat rapi.

Jangan membuat seluruh layar menjadi blank.

Gunakan:
- CircularProgressIndicator
- disabled button
- loading text jika memang diperlukan

24. MICRO INTERACTION

Tambahkan feedback visual ringan:
- InkWell ripple
- button pressed state
- card pressed state
- smooth transition jika sudah sesuai architecture

Jangan menambahkan animasi berlebihan.

25. CONSISTENCY

Seluruh aplikasi harus terasa dibuat dengan design system yang sama.

Konsisten dalam:
- padding
- margin
- radius
- button
- card
- icon
- typography
- warna
- AppBar

26. JANGAN OVER-DESIGN

Travel Story harus terasa:
- modern
- sederhana
- travel-oriented
- clean
- nyaman

Bukan:
- terlalu ramai
- terlalu banyak gradient
- terlalu banyak shadow
- terlalu banyak icon
- terlalu banyak decoration

27. JANGAN MERUSAK FUNCTIONALITY

Semua functionality dari revisi sebelumnya harus tetap bekerja:

- Create Trip
- Edit Trip
- Delete Trip
- Story
- Ganti Foto
- Reset Foto
- GPS/Tracking
- Navigation
- Database/Persistence
- Splash Screen

UI cleanup tidak boleh menghapus functionality tersebut.

28. HAPUS UI YANG TIDAK BERGUNA

Jika ada:
- button kosong
- placeholder yang tidak diperlukan
- text debug
- decoration berlebihan
- section yang tidak memiliki fungsi
- duplicate information

hapus atau sederhanakan.

29. HASIL AKHIR YANG DIINGINKAN

Aplikasi harus terlihat seperti:

SPLASH
→ clean dan profesional

HOME
→ daftar trip rapi

CREATE/EDIT
→ form nyaman

TRIP DETAIL
→ informasi jelas + action mudah ditemukan

STORY
→ visual kuat, seperti travel activity/share card

TRACKING
→ fokus pada peta dan statistik

Semua halaman harus memiliki visual language yang konsisten.

30. IMPLEMENTASI

Sebelum coding:
- baca struktur project
- cek Theme
- cek semua screen
- cek reusable widgets
- cek navigation
- cek model/database
- cek dependency

Kemudian langsung lakukan UI/UX cleanup pada project.

Jangan membuat architecture baru hanya untuk mempercantik UI.

LANGSUNG CODING DI PROJECT.
JANGAN MEMBUAT TEST.
JANGAN MEMBERIKAN CONTOH CODE.
JANGAN MEMBERIKAN PENJELASAN PANJANG.
JANGAN BERHENTI DI ANALISIS.
IMPLEMENTASIKAN REVISI INI LANGSUNG SAMPAI SELESAI.