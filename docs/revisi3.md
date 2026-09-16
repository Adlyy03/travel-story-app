KERJAKAN LANGSUNG DI PROJECT INI. JANGAN BANYAK PENJELASAN. JANGAN MEMBUAT TEST. LANGSUNG CODING DAN EDIT FILE YANG DIPERLUKAN.

TASK:
Rapikan dan ubah seluruh tulisan/caption yang ada di aplikasi Travel Story agar lebih sederhana, jelas, natural, dan mudah dimengerti oleh user.

TUJUAN:
Aplikasi harus terasa seperti aplikasi yang dibuat untuk pengguna biasa, bukan menggunakan istilah teknis atau kalimat yang membingungkan.

1. CEK SELURUH UI

Cari semua tulisan yang muncul di:
- Splash Screen
- Home
- Empty State
- Create Trip
- Edit Trip
- Trip Detail
- Story
- GPS/Tracking
- Dialog
- Confirmation
- Error message
- SnackBar
- Button
- Menu
- Bottom navigation
- Form
- Image picker/background image
- Loading state

Jangan hanya mengubah Story.

2. GUNAKAN BAHASA SEDERHANA

Gunakan kata-kata yang langsung dimengerti.

Contoh:

"Create Trip"
→ "Buat Trip"

"Save Changes"
→ "Simpan Perubahan"

"Delete Trip"
→ "Hapus Trip"

"Cancel"
→ "Batal"

"Edit"
→ "Edit"

"Trip Details"
→ "Detail Trip"

"Add New Trip"
→ "Buat Trip Baru"

"Choose Background"
→ "Ganti Foto"

"Reset Background"
→ "Kembalikan Foto"

"Duration"
→ "Durasi"

"Distance"
→ "Jarak"

"Start Location"
→ "Lokasi Mulai"

"End Location"
→ "Lokasi Tujuan"

3. EMPTY STATE

Jika belum ada trip, gunakan tulisan sederhana:

"Belum ada perjalanan"

"Yuk, mulai simpan perjalananmu."

Button:
"+ Buat Trip"

Jangan menggunakan tulisan teknis seperti:
"No data available"
atau
"Empty collection".

4. CREATE TRIP

Gunakan label yang jelas.

Contoh:

Nama Trip

Hint:
"Contoh: Liburan ke Bali"

Lokasi Mulai

Hint:
"Masukkan lokasi mulai"

Lokasi Tujuan

Hint:
"Masukkan tujuan"

Button:
"Simpan Trip"

Jika ada field lain, gunakan bahasa yang sama sederhananya.

5. VALIDATION

Error harus mudah dipahami.

Jangan:

"Field cannot be null."

Gunakan:

"Nama trip belum diisi."

atau:

"Lokasi tujuan belum diisi."

Jika input tidak valid:

"Masukkan data yang benar."

6. DELETE DIALOG

Gunakan dialog sederhana.

Title:

"Hapus Trip?"

Description:

"Trip ini akan dihapus dan tidak bisa dikembalikan."

Button:

"Batal"
"Hapus"

Jangan menggunakan kalimat teknis.

7. SUCCESS MESSAGE

Gunakan feedback singkat.

Contoh:

"Trip berhasil disimpan."

"Trip berhasil dihapus."

"Perubahan berhasil disimpan."

"Foto berhasil diganti."

Jangan terlalu panjang.

8. STORY

Pastikan tulisan pada Story mudah dipahami.

Contoh:

TRAVEL STORY

10.25 km
Jarak

58m 37s
Durasi

Denpasar → Ubud

03 Sep 2026

Button:

"Ganti Foto"

"Reset Foto"

"Simpan"

Jika terdapat istilah teknis, ubah ke bahasa yang lebih umum.

9. GPS / TRACKING

Jika ada fitur tracking, gunakan istilah sederhana.

Contoh:

"Mulai Perjalanan"

"Berhenti"

"Jarak"

"Waktu"

"Kecepatan"

"Lokasi"

Jika tracking sedang berjalan:

"Perjalanan sedang direkam"

Jika belum mulai:

"Belum mulai"

Jangan menggunakan istilah developer seperti:
"Tracking service initialized"
"GPS state"
"Location provider"

10. BUTTON

Semua button harus singkat.

Hindari:
"Click Here To Create A New Travel Story"

Gunakan:

"Buat Trip"

Hindari:
"Click Here To Change Your Background Image"

Gunakan:

"Ganti Foto"

11. SPLASH SCREEN

Pastikan splash menggunakan:

"Travel Story"

"Ceritakan perjalananmu."

Jangan menggunakan tagline yang terlalu panjang.

12. KONSISTENSI BAHASA

Gunakan satu gaya bahasa di seluruh aplikasi.

Gunakan bahasa Indonesia yang santai tetapi tetap rapi.

Contoh gaya:

"Buat Trip"
"Simpan Trip"
"Edit Trip"
"Hapus Trip"
"Ganti Foto"
"Mulai Perjalanan"
"Lihat Story"

Jangan mencampur terlalu banyak bahasa Indonesia dan Inggris tanpa alasan.

Istilah umum seperti "Story", "GPS", atau "Trip" boleh tetap digunakan jika memang sudah menjadi bagian dari konsep aplikasi.

13. TONE

Tulisan harus:
- ramah
- singkat
- jelas
- tidak kaku
- tidak terlalu formal
- mudah dimengerti pengguna baru

Hindari:
- istilah teknis
- kalimat terlalu panjang
- jargon developer
- pesan error mentah dari Flutter
- tulisan yang berulang

14. JANGAN MENGUBAH FUNCTIONALITY

Fokus revisi ini hanya pada:
- text
- label
- caption
- hint
- button text
- dialog text
- error message
- success message

Jangan merusak functionality yang sudah dibuat pada revisi sebelumnya.

15. CEK HARDCODE TEXT

Cari text yang tersebar di seluruh project.

Rapikan semuanya agar:
- konsisten
- mudah dibaca
- tidak ada typo
- tidak ada tulisan developer yang muncul ke user

Jika ada text seperti:
"TODO"
"Coming Soon"
"Not Implemented"
"Lorem Ipsum"
"Test"
"Debug"
atau pesan teknis lain yang terlihat oleh user, hapus atau ubah menjadi UI yang sesuai.

16. HASIL AKHIR

Setelah revisi ini, user baru harus bisa membuka aplikasi dan langsung memahami:

Apa aplikasi ini?
→ Travel Story

Apa yang harus dilakukan?
→ Buat Trip

Bagaimana melihat perjalanan?
→ Buka Trip

Bagaimana melihat Story?
→ Buka Story

Bagaimana mengganti foto?
→ Ganti Foto

Bagaimana menghapus trip?
→ Hapus Trip

Semua tulisan harus membantu user memahami fungsi aplikasi tanpa perlu penjelasan tambahan.

LANGSUNG KERJAKAN CODING DI PROJECT.
JANGAN MEMBUAT TEST.
JANGAN MEMBERIKAN PENJELASAN PANJANG.
JANGAN HANYA MEMBERIKAN CONTOH.
LANGSUNG CARI DAN UBAH TEXT/CAPTION YANG DIPERLUKAN DI SELURUH PROJECT.