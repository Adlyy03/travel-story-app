# 🌍 Travel Story — Minimalist Travel Tracker & Visual Journal

<p align="center">
  <img src="assets/images/logoAPP.png" alt="Travel Story Logo" width="120" style="border-radius: 24px;" />
</p>

<p align="center">
  <strong>Aplikasi Pelacak Rute Perjalanan Otomatis & Pembuat Story Visual (Travel Journal) Berbasis Flutter</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/SQLite-Offline--First-003B57?style=flat-square&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=flat-square" alt="Platform" />
</p>

---

## 📖 Tentang Aplikasi

Saat bepergian atau menjelajah tempat baru, kita sering mengambil banyak foto, singgah di berbagai tempat menarik, dan melalui rute seru. Namun, foto dan momen tersebut sering kali berantakan di galeri smartphone tanpa urutan kronologis dan konteks cerita yang utuh.

**Travel Story** hadir sebagai solusi jurnal perjalanan pribadi yang praktis dan estetik. Aplikasi ini secara otomatis merekam pergerakan dan rute GPS Anda, mendeteksi tempat-tempat Anda beristirahat/singgah (*stop detection*), menghitung data statistik perjalanan secara akurat, serta mengemasnya menjadi **timeline perjalanan interaktif** dan **kartu cerita visual (Story Cards rasio 9:16)** yang siap disimpan ke galeri atau dibagikan ke media sosial (seperti Instagram Story, WhatsApp Status, TikTok).

Mengusung konsep desain **"Minimalist Travel Journal / Paper Passport"**, Travel Story menyajikan antarmuka yang bersih, tenang, dan elegan agar fokus utama tetap pada foto dan kisah perjalanan Anda.

---

## ✨ Fitur-Fitur Utama

### 1. 📍 Pelacakan Perjalanan Real-time (Live Trip Tracking)
- **Satu Ketukan untuk Memulai**: Mulai, jeda (*pause* saat istirahat), dan selesaikan perjalanan dengan sangat mudah.
- **Pembersihan GPS Pintar (*GPS Cleaner*)**: Algoritma cerdas yang menyaring sinyal GPS liar/outlier dan noise akurasi rendah.
- **Deteksi Pemberhentian Otomatis (*Stop Detector*)**: Mengenali otomatis saat Anda sedang singgah atau berhenti di suatu lokasi.
- **Penghalusan Rute (*Route Smoother*)**: Mengubah titik-titik koordinat mentah menjadi jalur rute yang mulus di peta.
- **Live Trip Sheet**: Pantau durasi berjalan, jarak tempuh (km), kecepatan rata-rata, dan perubahan elevasi secara langsung saat tracking berlangsung.

### 2. 🗺️ Peta Interaktif & Rincian Perjalanan (Trip Details)
- **Peta Rute Interaktif**: Visualisasi polyline rute perjalanan menggunakan OpenStreetMap & CartoDB tiles berbasis `flutter_map`.
- **Penanda Titik Singgah & Foto**: Menampilkan titik perhentian (*stops*) dan foto-foto yang diambil pada koordinat terkait.
- **Statistik Lengkap**: Rangkuman jarak total, waktu tempuh aktif vs waktu istirahat, kecepatan maksimum/rata-rata, serta *elevation gain/loss*.

### 3. 🎨 Generator & Editor Story Visual (Story Cards 9:16)
- **Format Vertikal Siap Pakai**: Otomatis menghasilkan story card beresolusi tinggi dengan rasio 9:16 yang cocok untuk status media sosial.
- **Template Desain Variatif**: Pilihan tampilan visual menarik (Minimalist, Modern, Retro, dll.).
- **Kustomisasi Fleksibel**: Personalisasi foto latar belakang, catatan narasi perjalanan, teks highlight, dan stiker statistik.
- **Pemutar Animasi Cerita (*Story Animated Player*)**: Putar ulang perjalanan Anda dalam bentuk animasi interaktif.
- **Ekspor & Berbagi**: Simpan kartu cerita langsung ke galeri perangkat atau bagikan langsung ke aplikasi lain.

### 4. 📱 Dukungan Home Screen Widget & Notifikasi Background
- **Android Home Screen Widget**: Kontrol dan pantau status perjalanan aktif langsung dari home screen HP tanpa membuka aplikasi.
- **Foreground Notification**: Menjaga aplikasi tetap aktif merekam rute di background secara stabil dan hemat baterai.

### 5. 🔒 Offline-First & Privasi Penuh
- **Penyimpanan Lokal (SQLite)**: Semua riwayat perjalanan, koordinat lokasi, dan foto disimpan aman di memori lokal HP Anda.
- **Dapat Digunakan Tanpa Sinyal/Internet**: Aplikasi tetap berfungsi optimal saat Anda menjelajah daerah terpencil atau tanpa koneksi data.
- **Layanan Sinkronisasi Opsional**: Tersedia modul sinkronisasi untuk kebutuhan pencadangan (*backup*).

### 6. 📊 Dashboard, Riwayat & Kenangan (Memories)
- **Dashboard**: Ringkasan statistik perjalanan (total kilometer, jumlah perjalanan, dan akumulasi jam perjalanan).
- **Tab Riwayat (Trips)**: Kelola dan buka kembali seluruh riwayat trip yang pernah dilakukan.
- **Tab Kenangan (Memories)**: Galeri kilas balik kumpulan momen dan story favorit.

---

## 🛠️ Arsitektur & Teknologi

Aplikasi ini dibangun menggunakan arsitektur modular berbasis fitur (*feature-first architecture*) dengan pemisahan tanggung jawab yang jelas:

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK ^3.13.1)
- **Database Lokal**: [SQLite](https://pub.dev/packages/sqflite) via `sqflite` & `path_provider`
- **Geolokasi & Pemetaan**: `geolocator`, `flutter_map`, `latlong2`
- **Sistem Notifikasi & Widget**: `flutter_local_notifications`, `home_widget`
- **Manajemen Media & Berbagi**: `image_picker`, `file_picker`, `gal`, `share_plus`
- **Format Tanggal & Angka**: `intl`

---

## 📁 Struktur Direktori

```text
lib/
├── app/                  # Inisialisasi aplikasi, routing navigasi, dan konfigurasi global
├── core/
│   ├── database/         # Konfigurasi SQLite (AppDatabase) & migrasi schema
│   ├── services/         # Algoritma GPS (gps_cleaner, stop_detector, route_smoother),
│   │                     # kalkulasi elevasi, tracking background, notifikasi, & widget
│   └── theme/            # Sistem warna (AppColors) dan gaya tema (AppTheme)
├── features/
│   ├── home/             # Tab Dashboard utama & ringkasan statistik perjalanan
│   ├── trip/             # Tracking aktif (LiveTripSheet), detail trip, peta, & formulir trip
│   ├── story/            # Engine renderer story canvas, preview, editor, & player animasi
│   ├── memories/         # Tab galeri kenangan perjalanan
│   ├── trips/            # Tab daftar riwayat perjalanan
│   ├── profile/          # Halaman pengaturan profil & preferensi
│   ├── shell/            # Navigasi utama bottom navigation bar
│   └── splash/           # Layar pembuka (splash screen)
└── shared/
    ├── models/           # Data models (Trip, LocationPoint, Stop, TripPhoto)
    └── widgets/          # Komponen UI bersama
```

---

## 🚀 Panduan Memulai (Getting Started)

### Prasyarat
Pastikan lingkungan pengembangan Anda telah terpasang:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.13.1 atau lebih baru)
- Dart SDK
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK (API 26+) atau perangkat Android/iOS fisik untuk pengujian GPS

### Langkah Instalasi

1. **Clone repositori**:
   ```bash
   git clone https://github.com/Adlyy03/travel-story-app.git
   cd travel-story-app
   ```

2. **Unduh seluruh dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   Hubungkan perangkat atau nyalakan emulator, lalu jalankan:
   ```bash
   flutter run
   ```

4. **Menjalankan Pengujian (Testing)**:
   Untuk memverifikasi algoritma kalkulator perjalanan dan GPS cleaner:
   ```bash
   flutter test
   ```

---

## 📌 Izin Perangkat (Permissions)

Untuk menjalankan fungsionalitas pelacakan dengan optimal, aplikasi membutuhkan izin:
- **Lokasi (Location)**: Akses lokasi akurat (*fine location*) dan background location untuk mencatat rute perjalanan.
- **Penyimpanan / Galeri (Photos & Storage)**: Untuk memilih foto dokumentasi perjalanan dan menyimpan hasil ekspor Story Card.
- **Notifikasi (Notifications)**: Untuk menampilkan status pelacakan perjalanan yang sedang berjalan di background.

---

## 📄 Lisensi

Proyek ini dikembangkan untuk kebutuhan personal/portofolio perjalanan. Hak cipta dilindungi undang-undang.
