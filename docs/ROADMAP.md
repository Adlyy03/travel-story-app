ROADMAP MVP — 30 HARI
Gambaran besar
Hari	Fokus	Output
1	Product + rules	Scope MVP terkunci
2	Environment setup	Flutter siap
3	Project initialization	Skeleton app
4	Architecture	Struktur code final
5	Domain model	Model perjalanan
6	Database	Local persistence
7	GPS foundation	GPS bisa direkam
8	GPS data pipeline	Raw GPS → clean data
9	Distance + duration	Metric engine
10	Elevation	Elevation engine
11	Stop detection	Stop engine
12	Trip Engine v1	Raw GPS → Trip
13	Testing engine	Engine tervalidasi
14	Trip storage	Trip tersimpan
15	Trip detail UI	Journey bisa dilihat
16	Map	Route divisualkan
17	Place information	Koordinat → tempat
18	Import pipeline	External data → Trip
19	Trip Engine v2	Semua sumber disatukan
20	Daily Journey	Today's Journey
21	Story architecture	Trip → StoryModel
22	Story template	Design story
23	Story renderer	Story → image
24	Story preview	Preview story
25	Export/share	PNG/JPG
26	Edge cases	Data aneh ditangani
27	Real-world test	Test perjalanan nyata
28	Battery/privacy	Android hardening
29	UI polish	MVP final
30	Release APK	MVP v0.1
DAY 1 — KUNCI PRODUK

Jangan install Flutter dulu.

Kita bikin otak proyeknya dulu.

1. Buat repository
travel-story/
├── README.md
├── docs/
├── app/
└── .gitignore
2. Buat dokumen
docs/
├── PRODUCT.md
├── MVP_SCOPE.md
├── REQUIREMENTS.md
├── ARCHITECTURE.md
├── DATA_MODEL.md
├── TRIP_ENGINE.md
├── STORY_ENGINE.md
├── DATA_SOURCES.md
├── PRIVACY.md
└── AI_RULES.md
3. PRODUCT.md

AI harus tahu:

Problem

User punya data perjalanan tetapi datanya tersebar dan sulit diceritakan.

Solution

Aplikasi mengubah data perjalanan menjadi visual journey story.

Core flow

Journey Data
     ↓
Trip Engine
     ↓
Journey
     ↓
Story Engine
     ↓
Story Image
4. MVP_SCOPE.md

Tulis eksplisit:

IN

Android
Flutter
local storage
GPS
imported journey data
distance
duration
elevation
stops
places
map
story image
export

OUT

account
login
cloud
social
AI-generated text
iOS
subscription
multiplayer
website
5. AI_RULES.md

Ini penting banget.

AI wajib:

1. Read docs before coding.
2. Never invent requirements.
3. Never add features without approval.
4. Never change architecture silently.
5. Never duplicate domain models.
6. Business logic belongs outside UI.
7. Every important calculation gets tests.
8. Prefer simple implementation.
9. Do not optimize prematurely.
10. If requirement is ambiguous, stop and ask.
Output Day 1

Repo + documentation lengkap.

DAY 2 — SETUP DEVELOPMENT ENVIRONMENT

Sekarang baru install tools.

Wajib
Flutter SDK
Android Studio
Android SDK
Android Emulator
Git
VS Code / Android Studio
JDK
Check
flutter doctor

Target:

[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
[✓] Connected device

Kalau flutter doctor masih merah, beresin dulu. Jangan coding.

Git
git init
git branch -M main

Initial commit:

chore: initialize project environment
Output Day 2

HP/emulator bisa menjalankan Flutter sample app.

DAY 3 — BUAT PROJECT FLUTTER

Create:

flutter create .

Kita target:

Android

Jalankan:

flutter run

Kemudian bersihkan sample counter.

Target screen pertama:

Journey

Belum cakep.

Cuma memastikan:

Android
 ↓
Flutter
 ↓
App

berhasil.

Setup package management

Kita tentukan dependency satu per satu, bukan AI bebas install package.

Kategori:

State management
Routing
Database
Location
Maps
Permissions
Image rendering
Sharing
Testing

Hari ini jangan install semuanya kalau belum dibutuhkan.

Output

Empty Journey App.

DAY 4 — ARCHITECTURE

Sekarang kita menentukan struktur permanen.

Gue sarankan:

lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│
├── core/
│   ├── error/
│   ├── utils/
│   └── services/
│
├── features/
│   ├── location/
│   ├── trip/
│   ├── places/
│   └── story/
│
└── main.dart

Trip:

features/trip/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   └── repositories/
│
├── application/
│
├── data/
│
└── presentation/
Prinsip

UI:

UI
 ↓
Application
 ↓
Domain
 ↓
Repository
 ↓
Data source

UI nggak boleh melakukan:

calculateDistance()
detectStop()
calculateElevation()

Itu kerja Trip Engine.

Output

Architecture document + folder skeleton.

DAY 5 — DOMAIN MODEL

Sekarang kita definisikan benda-benda inti.

LocationPoint
id
latitude
longitude
altitude
accuracy
speed
timestamp
Trip
id
startTime
endTime
distanceMeters
durationSeconds
elevationGainMeters
elevationLossMeters
routePoints
stops
Stop
id
arrivalTime
departureTime
latitude
longitude
duration
placeId
Place
id
name
latitude
longitude
category

Jangan bikin:

Journey
Travel
TripData
TravelSession
RouteSession

yang semuanya sebenarnya benda sama.

Satu konsep = satu model.

Output

DATA_MODEL.md + Dart models.

DAY 6 — DATABASE

Sekarang kita bikin local persistence.

Target:

LocationPoint
Trip
Stop
Place

tersimpan lokal.

Flow:

GPS
 ↓
LocationPoint
 ↓
Database

dan:

Trip
 ↓
Database
 ↓
App restart
 ↓
Trip masih ada
Test wajib
Insert
Read
Update
Delete
Restart app
Output

Database repository bekerja.

DAY 7 — GPS FOUNDATION

Sekarang kita sentuh GPS.

App:

Start Journey

↓

request permission.

User approve.

↓

GPS stream.

↓

LocationPoint

Contoh:

12:00:00
lat/lng

12:00:05
lat/lng

12:00:10
lat/lng
UI sementara
[ START ]

Recording...

Latitude:
Longitude:
Accuracy:
Altitude:

[ STOP ]

Nggak perlu cakep.

Output

HP bisa merekam GPS.

DAY 8 — GPS CLEANING

Raw GPS masuk:

P1
P2
P3
P4
...

Kita filter:

invalid coordinate
duplicate
poor accuracy
timestamp aneh
impossible movement
altitude noise

Flow:

Raw GPS
 ↓
Validator
 ↓
Cleaner
 ↓
Clean LocationPoint[]
Wajib bikin test

Kasih fake GPS data:

normal
duplicate
bad accuracy
GPS jump
missing timestamp

Pastikan hasil sesuai aturan.

DAY 9 — DISTANCE + DURATION

Trip Engine mulai hidup.

Distance
Point A
 ↓
Point B
 ↓
Point C
 ↓
Point D

Hitung total perpindahan.

Duration
last.timestamp - first.timestamp

Output:

Distance: 127.4 km
Duration: 4h 12m
Penting

Jangan percaya angka sebelum dites dengan dataset yang diketahui.

Bikin test:

Known route
Expected distance
Actual distance
DAY 10 — ELEVATION

Input:

altitude:
120
123
125
124
131
...

Kita perlu:

elevation gain
elevation loss
highest
lowest

Tapi GPS altitude noisy.

Jadi:

Raw altitude
 ↓
Filtering
 ↓
Elevation calculation

Output:

+842 m
-817 m
Highest: 1,421 m
Lowest: 32 m

Kalau altitude tidak tersedia/terlalu buruk:

elevation = unavailable

Jangan ngarang angka.

DAY 11 — STOP DETECTION

Input:

LocationPoint[]

Output:

Stop[]

Contoh:

08:00 ───────────────→
09:15 ● STOP
10:02 ───────────────→
12:30 ● STOP
13:10 ───────────────→

Kita definisikan parameter:

minimum stop duration
movement radius
GPS tolerance

Angka finalnya ditentukan dari testing, bukan asal AI bikin.

DAY 12 — TRIP ENGINE V1

Sekarang semua disatukan.

LocationPoint[]
        ↓
Clean
        ↓
Detect movement
        ↓
Detect stops
        ↓
Distance
Duration
Elevation
        ↓
Trip

Input:

LocationPoint[]

Output:

Trip

Ini milestone terbesar pertama.

DAY 13 — TEST TRIP ENGINE

Bikin dataset fixture:

test/data/
├── short_trip
├── long_trip
├── stationary
├── noisy_gps
├── missing_points
├── elevation_noise
└── multiple_stops

Test:

distance
duration
elevation
stops
trip boundaries

Target:

Trip Engine bisa dites tanpa Android, tanpa GPS, tanpa UI.

Kalau ini nggak bisa, architecture lu salah.

DAY 14 — TRIP STORAGE

Sekarang hasil engine:

Trip

disimpan.

History:

MY JOURNEYS

26 Aug
Jakarta → Bogor
138 km · 4h 21m

24 Aug
Bandung → Garut
...

Belum perlu fancy.

DAY 15 — TRIP DETAIL UI

Tap trip:

JAKARTA → BOGOR

26 August 2026

138 km
4h 21m
+1,120 m

STOPS

09:42
Bogor

11:20
Puncak

Ini pertama kali user bisa merasakan hasil engine.

DAY 16 — MAP

Trip route:

routePoints[]

↓

Map.

Tampilkan:

start
route
stops
end

Map harus mengikuti data Trip.

Map bukan sumber kebenaran.

Trip Engine tetap source of truth.

DAY 17 — PLACE INFORMATION

Stop:

lat
lng

↓

Place provider.

↓

Kebun Raya Bogor

Kita simpan hasilnya.

Harus handle:

no internet
API failure
no result
duplicate
quota
DAY 18 — IMPORT PIPELINE

Sekarang baru external data.

Imported Data
     ↓
Parser
     ↓
Normalized LocationPoint[]
     ↓
Trip Engine

Parser tidak boleh punya business logic Trip.

Tugas parser cuma:

“ubah format external menjadi format internal.”

DAY 19 — TRIP ENGINE V2

Sekarang:

GPS
 ──────┐
       ├──→ LocationPoint[]
Import ────┘
               ↓
          Trip Engine
               ↓
              Trip

Jadi engine nggak peduli datanya berasal dari mana.

Ini arsitektur yang kita pertahankan.

DAY 20 — TODAY'S JOURNEY

Home screen akhirnya punya tujuan.

TODAY

Your Journey

Jakarta → Bogor → Puncak

138 km
4h 21m
+1,120 m
6 places

[ VIEW JOURNEY ]
[ CREATE STORY ]

Kalau nggak ada data:

No journey today.

[ START JOURNEY ]
DAY 21 — STORY ENGINE

Sekarang kita pisahkan:

Trip
 ↓
StoryBuilder
 ↓
StoryModel

StoryModel:

title
date
route
distance
duration
elevation
places
timeline

Story Engine tidak menghitung distance.

Dia cuma mengubah Trip menjadi konten story.

DAY 22 — STORY TEMPLATE

Cuma 1 template.

Ukuran misalnya:

1080 × 1920

Struktur:

TITLE

DATE

MAP

DISTANCE
DURATION
ELEVATION

PLACES

TIMELINE

Kita bikin design system:

typography
spacing
margins
map placement
stat cards
text hierarchy
DAY 23 — STORY RENDERER

Sekarang:

StoryModel
 ↓
Renderer
 ↓
Canvas
 ↓
PNG

Harus bisa render tanpa screenshot UI.

Jadi:

Story UI ≠ Story image renderer.

Ini penting supaya hasil export konsisten.

DAY 24 — STORY PREVIEW

Flow:

Trip Detail
 ↓
Create Story
 ↓
Story Preview

User melihat exact output sebelum export.

DAY 25 — EXPORT & SHARE

Flow final:

Create Story
 ↓
Preview
 ↓
Export
 ↓
PNG/JPG
 ↓
Share

Test:

save
share
cancel
storage permission
filename
duplicate export
DAY 26 — EDGE CASES

Sekarang kita sengaja bikin app menderita.

Test:

0 GPS points
1 GPS point
2 GPS points
GPS noisy
No elevation
No place
1 stop
100 stops
Very long trip
Very short trip
No internet
Permission denied
Permission revoked
Storage failure

App nggak boleh crash.

DAY 27 — REAL WORLD TEST

Sekarang keluar rumah.

Bawa HP.

Test:

Test 1

Jalan kaki.

Test 2

Motor.

Test 3

Mobil.

Test 4

Berhenti 30 menit.

Test 5

Masuk area GPS jelek.

Test 6

Internet dimatikan.

Kita catat:

Expected
Actual
Difference
Bug

Ini menghasilkan dataset asli untuk memperbaiki Trip Engine.

DAY 28 — BATTERY + PRIVACY

Karena GPS itu bisa ngisep baterai, kita cek:

location interval
accuracy mode
background behavior
recording lifecycle

Permission harus jelas:

Why does this app need location?

Dan data journey:

local-first.

Jangan kirim ke server kalau MVP memang nggak membutuhkan.

DAY 29 — UI POLISH

Baru sekarang kita bikin cakep.

Screen:

Home
 ↓
Journey Detail
 ↓
Story Preview
 ↓
Export

Fokus:

typography
spacing
loading
empty states
error states
animation secukupnya

Jangan tiba-tiba bikin 17 screen tambahan.

DAY 30 — MVP RELEASE

Build:

flutter build apk --release

Install APK ke HP.

Final test:

Install
 ↓
Permission
 ↓
Record/import
 ↓
Trip Engine
 ↓
Journey
 ↓
Map
 ↓
Story
 ↓
Export

Kalau flow itu berhasil:

MVP v0.1 SELESAI
Struktur kerja AI-nya

Nah, ini yang bakal gue pakai kalau kita nanti mulai ngoding bareng.

AI nggak boleh dikasih task:

“Bikin aplikasi travel story.”

Itu terlalu tolol dan luas.

Kita kasih:

PHASE 7 — GPS COLLECTION

Context:
Read:
- PRODUCT.md
- ARCHITECTURE.md
- DATA_MODEL.md
- AI_RULES.md

Goal:
Implement GPS collection.

Requirements:
1. Request permission.
2. Start location stream.
3. Convert GPS result to LocationPoint.
4. Store points.
5. Stop recording.
6. No Trip calculation yet.

Do NOT:
- calculate distance
- detect stops
- create story
- modify database architecture

Acceptance criteria:
- GPS permission works.
- LocationPoint generated.
- Start/stop works.
- Unit tests pass.
- flutter analyze passes.
- flutter test passes.

Nah, model AI bakal jauh lebih susah ngaco kalau dikasih kontrak kayak gini.

Dan kita mulai dari sini

Urutan praktis kita sekarang:

TODAY
│
├── 1. Create repository
├── 2. Create /docs
├── 3. Write product definition
├── 4. Lock MVP scope
├── 5. Define architecture
├── 6. Setup Flutter
├── 7. Run blank Android app
└── 8. Commit