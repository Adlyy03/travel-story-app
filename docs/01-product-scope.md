A. Problem

Jelaskan masalah utama:

Orang punya foto/video perjalanan yang tersebar di galeri, tapi tidak punya cara sederhana untuk mengubahnya menjadi cerita perjalanan yang terstruktur.

B. Solusi MVP

App memungkinkan user:

Membuat perjalanan
Memberikan nama perjalanan
Menambahkan lokasi
Menambahkan foto/video
Menulis cerita/catatan
Mengatur urutan timeline
Melihat perjalanan sebagai story/timeline

Jangan masuk dulu ke:

social media
followers
likes
comments
marketplace
AI generatif kompleks
recommendation engine
collaborative trip
monetisasi

Kalau masukin semua itu sekarang, MVP bakal jadi monster yang nggak pernah selesai.

1.2 — Tentukan user flow

Bikin flow utama:

OPEN APP
   ↓
HOME
   ↓
CREATE TRIP
   ↓
TRIP INFO
   ↓
ADD MOMENT
   ↓
PHOTO / VIDEO
   ↓
LOCATION
   ↓
STORY / NOTE
   ↓
SAVE
   ↓
TIMELINE
   ↓
VIEW STORY

Minimal harus ada satu happy path yang bisa selesai dari awal sampai akhir.

1.3 — Tentukan screen MVP

Untuk versi pertama, kunci:

Screen 1 — Home

Menampilkan:

daftar perjalanan
tombol Create Trip
Screen 2 — Create Trip

Input:

Trip name
Start date
End date
Cover image
Screen 3 — Trip Detail

Menampilkan:

nama perjalanan
tanggal
daftar moments
tombol Add Moment
Screen 4 — Add Moment

Input:

foto/video
waktu
lokasi
caption/story
Screen 5 — Story / Timeline

Menampilkan perjalanan dalam urutan waktu.

1.4 — Tentukan data model

Ini WAJIB dikunci sebelum coding.

Minimal:

Trip
├── id
├── title
├── coverImage
├── startDate
├── endDate
└── moments[]

Moment
├── id
├── tripId
├── media
├── timestamp
├── location
└── caption

Nanti database bisa berubah.

Tapi struktur konsepnya jangan berubah tiap 3 jam.