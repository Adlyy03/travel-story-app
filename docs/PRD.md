PRD — App Mobile Timeline Perjalanan
1. Product Overview

Nama sementara: Travel Timeline

Platform: Mobile — Flutter

Tujuan utama:
Membuat aplikasi yang otomatis merekam perjalanan user berdasarkan lokasi/GPS, lalu menyusunnya menjadi timeline perjalanan yang bisa dilihat kembali.

Core experience:

User mulai perjalanan → aplikasi merekam lokasi → perjalanan terbentuk sebagai timeline → user bisa melihat riwayat perjalanan.

2. Problem

Saat bepergian, user sering punya banyak foto, lokasi, dan aktivitas, tapi semuanya tersebar.

Aplikasi ini ingin menyediakan satu tempat untuk melihat:

kapan perjalanan dimulai
rute/lokasi yang dilewati
tempat yang dikunjungi
urutan perjalanan
ringkasan perjalanan

MVP tidak bertujuan menjadi Google Maps / social media / travel planner.

3. Target User
Primary User

Orang yang sering melakukan perjalanan dan ingin menyimpan rekam jejak perjalanan pribadi secara otomatis.

Contoh:

road trip
traveling
perjalanan kerja
eksplorasi kota
perjalanan harian yang ingin disimpan
4. MVP Goal

MVP dianggap berhasil kalau user bisa:

Membuka aplikasi.
Memulai perjalanan.
Memberikan izin lokasi.
Aplikasi mengambil lokasi secara berkala.
Lokasi disimpan secara lokal.
User menghentikan perjalanan.
Perjalanan tersimpan.
User melihat daftar perjalanan.
User membuka satu perjalanan.
User melihat timeline/rute perjalanan.
5. Core User Flow
Open App
   ↓
Home
   ↓
Start Trip
   ↓
Location Permission
   ↓
Tracking Active
   ↓
GPS Points Collected
   ↓
Stop Trip
   ↓
Trip Saved
   ↓
Trip Detail
   ↓
Timeline / Route
6. MVP Features
F1 — Home

Home menampilkan:

status tracking
tombol Start Trip
perjalanan terakhir
akses ke riwayat perjalanan
State

Idle

No active trip

[ Start Trip ]

Tracking

Trip is active

Duration
Current location

[ Stop Trip ]
F2 — Trip Tracking

Ketika user menekan Start Trip:

buat Trip baru
simpan waktu mulai
mulai location tracking
ambil GPS point secara berkala
simpan GPS point
tampilkan status tracking

Setiap GPS point minimal memiliki:

latitude
longitude
timestamp
accuracy
7. Tracking Rules

Ini penting banget. Jangan biarkan AI agent ngarang algoritma sendiri.

Location sampling

MVP menggunakan interval sederhana.

Contoh awal:

GPS update interval: 10–30 seconds

Nilai final bisa dituning setelah testing.

Minimum data

GPS point hanya disimpan jika:

koordinat valid
timestamp valid
accuracy masih masuk batas wajar
Outlier

GPS point dengan accuracy terlalu buruk boleh diabaikan.

8. Trip Model

Satu Trip minimal punya:

id
startedAt
endedAt
status

Status:

active
completed

Trip memiliki banyak:

LocationPoint

Relasinya:

Trip
 ├── metadata
 └── LocationPoints
       ├── point 1
       ├── point 2
       ├── point 3
       └── ...
9. Timeline

Timeline adalah representasi perjalanan berdasarkan urutan waktu.

Contoh:

08:10
Trip started

08:25
Location recorded

08:42
Location recorded

09:05
Location recorded

09:30
Trip ended

MVP belum perlu AI-generated storytelling.

Jangan tiba-tiba agent bikin:

“You started your beautiful journey through the heart of Jakarta...”

Itu sampah scope.

10. Trip History

User bisa melihat daftar perjalanan:

Trip — 2 Sep 2026
08:10 → 11:45

Trip — 30 Aug 2026
14:20 → 17:10

Trip — 28 Aug 2026
09:00 → 12:30

Sort:

Newest → Oldest
11. Trip Detail

Trip detail menampilkan:

tanggal
waktu mulai
waktu selesai
durasi
jumlah GPS points
route/map
timeline

Struktur:

Trip Detail

[ Map ]

2 Sep 2026

08:10 — Started
08:25 — Location
08:42 — Location
09:05 — Location
09:30 — Finished

Duration
1h 20m

Points
124
12. Database

MVP menggunakan local persistence.

Tidak ada backend dulu.

Tidak ada:

login
account
cloud sync
server
Firebase backend

Struktur konseptual:

trips
├── id
├── started_at
├── ended_at
└── status

location_points
├── id
├── trip_id
├── latitude
├── longitude
├── timestamp
└── accuracy
13. Architecture

Flutter menggunakan separation yang jelas:

Presentation
     ↓
Domain
     ↓
Data

Contoh:

UI
 ↓
Use Case
 ↓
Repository
 ↓
Local Data Source
 ↓
Database

GPS juga jangan langsung dipanggil dari Widget.

UI
 ↓
Trip Controller
 ↓
Tracking Service
 ↓
Location Provider

Tujuannya supaya nanti gampang dites dan diganti.

14. Permissions

MVP membutuhkan:

Location

Untuk:

mengambil posisi user
merekam perjalanan

Permission handling harus memiliki state:

not_requested
granted
denied
permanently_denied

Kalau permission ditolak:

Location permission is required
to record your trip.

[ Open Settings ]
15. Error Handling

Minimal handle:

GPS unavailable
Unable to get current location.
Permission denied
Location permission is required.
Database failure
Unable to save trip.
Tracking interruption

Tracking tidak boleh membuat aplikasi crash.

16. Offline Requirement

MVP harus offline-first.

User dapat:

start trip
tracking
stop trip
melihat history

tanpa internet.

Internet tidak diperlukan untuk menyimpan GPS data.

17. Non-Goals MVP

Ini bagian yang harus dikunci keras.

JANGAN dikerjakan di MVP:

Login/register
Cloud sync
Social sharing
Friends
Comments
Likes
AI travel story
AI summary
Photo recognition
Weather integration
Route optimization
Navigation
Booking hotel
Booking flight
Expense tracking
Gamification
Public profile
Multi-device sync

Semua itu post-MVP.

18. Technical Constraints
Framework:
Flutter

Language:
Dart

Architecture:
Layered / Clean-ish Architecture

Storage:
Local database

Location:
Device GPS/location service

Network:
Optional / not required for core functionality

Authentication:
None

Backend:
None
19. Definition of Done

MVP selesai kalau:

Trip
 User bisa start trip
 User bisa stop trip
 Trip memiliki start/end time
 Trip tersimpan lokal
 Active trip tidak hilang sembarangan
GPS
 Location permission bekerja
 GPS point berhasil diambil
 GPS point tersimpan
 Point memiliki timestamp
 Point memiliki accuracy
History
 Trip muncul di history
 History persistent setelah app restart
 Trip bisa dibuka
Detail
 Detail trip menampilkan metadata
 Timeline muncul
 GPS points ditampilkan
 Route/map dapat ditampilkan
Reliability
 Permission denial ditangani
 GPS error ditangani
 Database error ditangani
 App tidak crash karena tracking error
20. Success Criteria MVP

Kita pakai ukuran sederhana:

User bisa merekam satu perjalanan dari awal sampai selesai, menutup aplikasi, membukanya lagi, dan tetap melihat perjalanan tersebut secara utuh.

Kalau itu sudah bekerja dengan stabil, MVP berhasil.

21. Prioritas Development

Urutannya jangan dibalik-balik:

1. Project Setup
        ↓
2. Architecture
        ↓
3. Domain Model
        ↓
4. Local Database
        ↓
5. GPS / Location
        ↓
6. Trip Tracking
        ↓
7. Trip History
        ↓
8. Trip Detail
        ↓
9. Timeline
        ↓
10. Map / Route
        ↓
11. Error Handling
        ↓
12. Testing
        ↓
13. UI Polish