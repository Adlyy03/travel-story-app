# DESIGN.md — Travel Story (Minimalism)

Dokumen ini adalah design system yang WAJIB diikuti saat styling UI.
Konsep: "travel journal / paper passport" — tenang, bersih, fokus ke konten (foto & cerita), bukan ke dekorasi UI.

Jangan ubah logic/struktur widget. Ini HANYA panduan visual (color, type, spacing, component style).

---

## 1. PRINSIP

- Konten (foto trip, cerita) adalah hero. UI harus "diam", jangan bersaing dengan foto.
- 1 warna aksen saja, dipakai sangat sedikit (CTA utama, active state).
- Flat. Tanpa shadow tebal, tanpa gradient, tanpa border-radius yang beda-beda tiap komponen.
- Banyak whitespace. Kalau ragu, kasih spacing lebih, bukan elemen baru.
- Hierarchy dari ukuran + spacing, bukan dari warna-warni.

---

## 2. COLOR TOKENS

| Token | Hex | Pemakaian |
|---|---|---|
| `bg` | `#F7F6F3` | background utama (warm paper) |
| `surface` | `#FFFFFF` | card, sheet, dialog |
| `ink` | `#1C1C1A` | teks utama |
| `ink-soft` | `#6B6B65` | teks sekunder, caption, hint |
| `border` | `#E4E2DC` | divider, outline, input border |
| `accent` | `#2B4B3C` | deep pine — CTA, active tab, link, icon aktif |
| `accent-soft` | `#E9EFEA` | background untuk state selected/hover ringan |
| `danger` | `#B3413A` | delete, error, hanya dipakai saat perlu |
| `danger-soft` | `#F5E7E5` | background confirm delete |

Aturan pakai:
- `accent` MAKSIMAL untuk: 1 primary button per screen, active nav/tab, link teks.
- Jangan pakai `accent` untuk background besar/full card.
- `danger` hanya untuk delete/error, jangan dipakai dekoratif.

---

## 3. TYPOGRAPHY

- 1 font family untuk seluruh app (contoh: `Inter` / font default platform kalau mau simpel — jangan campur >1 family).
- Hanya 2 weight: **Regular (400)** untuk body, **SemiBold (600)** untuk heading & label penting.
- Sentence case semua (bukan ALL CAPS) untuk label, button, judul.

| Style | Size | Weight | Contoh pemakaian |
|---|---|---|---|
| Display | 28sp | 600 | judul trip di header/detail |
| Title | 20sp | 600 | judul section, nama trip di card |
| Body | 15sp | 400 | deskripsi, isi cerita |
| Caption | 13sp | 400 | tanggal, lokasi, meta info |
| Button | 15sp | 600 | teks tombol |

Line-height body: 1.4–1.5x. Line length nyaman dibaca, jangan full-width di layar lebar.

---

## 4. SPACING & RADIUS

Spacing scale (pakai kelipatan ini saja — jangan angka random):
`4 · 8 · 12 · 16 · 24 · 32 · 48`

- Padding screen: 16 (mobile default), 24 kalau layar lebih lega.
- Jarak antar section: 24–32.
- Jarak antar elemen dalam 1 group (label+input, icon+text): 8.

Radius (konsisten di semua komponen sejenis):
- Card / image / sheet: `16`
- Button: `12`
- Input field: `12`
- Chip/tag kecil: `999` (full round)

Jangan campur radius berbeda untuk komponen yang levelnya sama.

---

## 5. COMPONENTS

**Button (primary)**
- Background `accent`, teks putih, radius 12, height 48, padding horizontal 20.
- Tanpa shadow. State pressed: turunkan opacity background ke ~85%.
- Disabled/loading: background `border`, teks `ink-soft`, tampilkan spinner kecil menggantikan teks saat loading.

**Button (secondary / outline)**
- Background transparan, border 1px `border`, teks `ink`.
- Dipakai untuk "Batal", "Cancel", aksi non-utama.

**Button (destructive)**
- Sama seperti secondary, tapi teks & border pakai `danger`. Jangan fill solid kecuali di confirm dialog.

**Trip Card**
- Background `surface`, radius 16, tanpa shadow (cukup border 1px `border` atau flat di atas `bg`).
- Foto trip full-bleed di atas, radius mengikuti card. Info (nama, tanggal, lokasi) di bawah foto dengan padding 16.
- Pressed state: scale 0.98 atau overlay gelap tipis — pilih satu, jangan dua-duanya.

**Input Field**
- Background `surface`, border 1px `border`, radius 12, padding 12–16.
- Focus state: border `accent` 1.5px. Jangan pakai shadow glow.
- Error state: border `danger` + caption merah kecil di bawah field.

**Dialog / Confirm**
- Background `surface`, radius 16, padding 24, tanpa header berwarna.
- Judul pakai Title style, body pakai Body style ink-soft.
- 2 tombol sejajar: outline (Batal) + solid (aksi, pakai `danger` kalau delete).

**Empty State**
- Ikon outline sederhana (bukan ilustrasi ramai), ukuran sedang, warna `ink-soft`.
- Judul singkat (Title) + 1 kalimat penjelasan (Body, `ink-soft`) + 1 button primary.
- Center di layar, banyak whitespace di sekitar.

**Snackbar / Feedback**
- Background `ink`, teks putih, radius 8, muncul dari bawah, auto-dismiss ~2.5s.
- Jangan pakai warna hijau/merah cerah kecuali untuk error (pakai `danger`).

**Bottom Nav / Tab (jika ada)**
- Background `surface`, icon outline, active item pakai warna `accent` + label, inactive `ink-soft`.
- Tanpa background pill di belakang icon aktif — cukup ganti warna.

---

## 6. ICONOGRAPHY

- Style: outline/line icon, stroke konsisten (jangan campur outline + filled).
- Ukuran standar 20–24dp.
- Warna icon ikut context: `ink` (default), `ink-soft` (inactive), `accent` (active/primary).

---

## 7. MOTION

- Transisi halus, singkat (150–200ms), pakai easing standar (ease-in-out).
- Hindari animasi bertumpuk di banyak elemen sekaligus.
- Motion hanya untuk merespons aksi user (tap, save, delete, navigasi) — bukan animasi dekoratif otomatis.

---

## 8. CHECKLIST SEBELUM SELESAI STYLING

- [ ] Semua warna yang dipakai ada di token list section 2 (tidak ada warna baru sembarangan)
- [ ] Radius konsisten per jenis komponen
- [ ] Tidak ada shadow tebal / gradient dekoratif
- [ ] Hanya 1 font family, max 2 weight
- [ ] `accent` dipakai hemat, bukan di banyak tempat
- [ ] Spacing pakai scale di section 4
- [ ] Empty state & dialog mengikuti spec di section 5