MODIFIKASI FITUR SHARE STORY YANG SUDAH ADA.

Jangan bikin fitur share baru dari nol. Inspect implementasi Share Story yang sekarang, lalu ubah hasil visualnya sesuai requirement berikut.

TUJUAN:
Hasil Share Story harus berupa foto/video perjalanan fullscreen dengan overlay statistik perjalanan dan GPS route berbentuk POLYLINE, terinspirasi dari visual share Strava seperti referensi yang diberikan.

REQUIREMENT:

1. BACKGROUND
- Gunakan foto/video story yang dipilih user sebagai background fullscreen.
- Pertahankan aspect ratio share yang cocok untuk Instagram Story (9:16).
- Jangan membuat card putih atau layout recap terpisah.
- Foto/video harus menjadi elemen visual utama.

2. STATISTIK
Overlay statistik perjalanan di atas background.
Gunakan data trip yang SUDAH ADA di aplikasi, jangan membuat data dummy.

Minimal tampilkan:
- Distance / Jarak
- Duration / Waktu
- Pace atau Speed jika data tersebut memang tersedia/relevan

Contoh visual:
Jarak
18,25 km

Waktu
1j 44m

Gunakan typography yang clean, bold, dan mudah dibaca di atas foto/video.

3. GPS ROUTE
Ini bagian UTAMA.

Gunakan routePoints/GPS coordinates yang SUDAH direkam oleh trip.

Render route tersebut sebagai POLYLINE di atas share visual.

Requirement polyline:
- Ambil seluruh titik GPS perjalanan.
- Connect titik-titik tersebut menjadi satu polyline.
- Route harus merepresentasikan rute yang benar-benar sudah dilewati user.
- Jangan menggunakan screenshot Google Maps sebagai background.
- Jangan menampilkan full Google Maps UI.
- Jangan membuat route manual/dummy.
- Route harus mengikuti data GPS aktual.
- Visual route dibuat minimalis seperti GPS trace pada Strava.
- Tambahkan start/end marker jika mudah diintegrasikan tanpa mengganggu desain.

4. VISUAL STYLE
Target visual:
FULLSCREEN PHOTO/VIDEO
+
STATISTIK
+
MINIMAL GPS POLYLINE
+
TRAVEL STORY BRANDING

Jangan mengubahnya menjadi:
- white card
- dashboard
- map screenshot
- Google Maps screen
- generic AI-looking travel card

Harus terasa seperti sebuah foto perjalanan yang diberi GPS activity overlay.

5. IMPLEMENTATION
- Reuse arsitektur, model, state, dan Share Story flow yang SUDAH ADA.
- Jangan membuat duplicate implementation.
- Cari source data routePoints dari trip tracking yang sekarang.
- Gunakan data aktual tersebut untuk membuat polyline.
- Pastikan route hanya muncul jika GPS route tersedia.
- Jika route tidak tersedia, share story tetap bisa dibuat tanpa polyline.
- Jangan merusak fitur Share Story yang sudah berjalan.
- Jangan mengubah database/schema kecuali benar-benar diperlukan.
- Jangan menambahkan dependency baru kalau functionality existing sudah cukup.

6. OUTPUT
Saat user menekan Share Story:
1. pilih story/photo/video seperti flow existing
2. generate share visual
3. background = media yang dipilih
4. overlay = trip statistics
5. overlay = GPS polyline berdasarkan routePoints
6. branding = Travel Story
7. user tetap bisa save/share seperti flow existing

PRIORITAS:
1. POLYLINE GPS AKTUAL
2. FOTO/VIDEO FULLSCREEN
3. STATISTIK
4. MINIMAL BRANDING

Langsung inspect codebase dan kerjakan perubahan ini pada implementasi existing.
Jangan bikin penjelasan panjang.
Jangan menunggu approval.
Jangan membuat mockup saja.
Implementasikan langsung.