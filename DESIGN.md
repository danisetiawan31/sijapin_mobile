---
name: SIIJAPIN Mobile Design System
description: Sistem desain resmi RSUP Dr. Sitanala berbasis palet warna Coklat Khas Sitanala & Standar Aksesibilitas Mobile
author: Ahmad Dhani Setiawan, S.Kom.
colors:
  brand-dark-espresso: "#1C140E"
  brand-deep-chocolate: "#493306"
  brand-warm-umber: "#614925"
  brand-warm-bronze: "#825B0B"
  brand-golden-caramel: "#AA7409"
  brand-soft-sand: "#D3B577"
  brand-cream-linen: "#F7F3ED"
  surface-bg: "#FAF8F5"
  surface-card: "#FFFFFF"
  surface-overlay: "#FFFFFF"
  clinical-teal: "#1B7369"
  danger-crimson: "#AA2D11"
  warning-amber: "#D97706"
  success-emerald: "#15803D"
  text-primary: "#1C140E"
  text-secondary: "#5C5046"
  text-muted: "#8C7E74"
  border-subtle: "#EAE2D8"
  border-focus: "#AA7409"
typography:
  display:
    fontFamily: Plus Jakarta Sans, Inter, sans-serif
    fontSize: 26px
    fontWeight: 700
    lineHeight: 34px
    letterSpacing: -0.02em
  headline:
    fontFamily: Plus Jakarta Sans, Inter, sans-serif
    fontSize: 20px
    fontWeight: 600
    lineHeight: 28px
    letterSpacing: -0.01em
  title:
    fontFamily: Plus Jakarta Sans, Inter, sans-serif
    fontSize: 16px
    fontWeight: 600
    lineHeight: 24px
    letterSpacing: 0em
  body:
    fontFamily: Plus Jakarta Sans, Inter, sans-serif
    fontSize: 14px
    fontWeight: 400
    lineHeight: 22px
    letterSpacing: 0em
  label:
    fontFamily: Plus Jakarta Sans, Inter, sans-serif
    fontSize: 12px
    fontWeight: 600
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 8px
  md: 14px
  lg: 20px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
components:
  button-primary:
    backgroundColor: "{colors.brand-golden-caramel}"
    textColor: "#FFFFFF"
    rounded: "{rounded.full}"
    padding: 14px 28px
  button-primary-hover:
    backgroundColor: "{colors.brand-warm-bronze}"
  button-danger:
    backgroundColor: "{colors.danger-crimson}"
    textColor: "#FFFFFF"
    rounded: "{rounded.full}"
    padding: 14px 28px
  card-elevated:
    backgroundColor: "{colors.surface-card}"
    rounded: "{rounded.lg}"
    padding: 16px 20px
---

# 🎨 DESIGN SYSTEM: SIIJAPIN MOBILE (RSUP DR. SITANALA)

> **Creative North Star: _"The Healing Sanctuary of Warmth & Dignity"_**  
> _(Oase Pelayanan Kesehatan yang Teduh, Hangat, dan Bermartabat)_

---

## 1. Overview

Desain antarmuka **SIIJAPIN Mobile** menolak estetika aplikasi rumah sakit konvensional yang dingin, steril, intimidatif, dan kaku serba biru/putih rumah sakit generik. Mengambil inspirasi dari arsitektur visual resmi web RSUP Dr. Sitanala, sistem desain ini merangkul kehangatan tanah nusantara melalui perpaduan **Coklat Tua Espresso, Keemasan Karamel Hangat (Warm Amber Bronze), dan Lembutnya Pasir Linen (Soft Sand Cream)**.

Aplikasi ini diciptakan untuk pasien dari segala usia—dari orang tua yang mengantar anaknya berobat, pasien lansia yang rutin kontrol penyakit dalam, hingga generasi muda yang mendaftar MCU mandiri. Desain mengutamakan kejelasan hierarki, keterbacaan instan (_high glanceability_), sentuhan tombol yang ramah jempol (_thumb-zone ergonomics_), serta ketenangan psikologis bagi pasien yang sedang mengalami kecemasan medis.

### Key Characteristics:

- **Organic Warmth (Bukan Dingin Kemenkes Biasa)**: Nuansa coklat bumi menghadirkan ketenangan, rasa disambut, dan keramahan pelayanan RSUP Dr. Sitanala.
- **Radical Accessibility (WCAG 2.1 AA Compliant)**: Kontras rasio teks $\ge 4.5:1$ pada latar belakang hangat, touch target $\ge 48 \times 48\text{ dp}$, dan label teks yang tidak ambigu.
- **Calm Density**: Memaksimalkan kenyamanan bernapas (_whitespace_ hangat), menghindari layar yang padat tabel seperti web desktop lama.
- **Tactile Elevation**: Bayangan lembut bernuansa amber hangat (_warm ambient shadows_), bukan bayangan abu-abu dingin.

---

## 2. Colors

Karakter palet warna memadukan kewibawaan coklat tua dengan kehangatan karamel keemasan dan fungsionalitas status medis modern:

### A. Palet Inti Khas Sitanala (Brand Essence)

- **Coklat Tua Espresso (`brand-dark-espresso` / `#1C140E`)**: Digunakan untuk teks utama, judul tebal, ikon navigasi primer, dan elemen dengan kontras tertinggi (rasio 15:1 di atas background).
- **Coklat Tua Klasik (`brand-deep-chocolate` / `#493306`)**: Dipakai untuk header kartu, background status penting, dan tombol sekunder.
- **Coklat Karamel Keemasan (`brand-golden-caramel` / `#AA7409`)**: Aksen vokal utama! Dipakai untuk tombol aksi primer (_Call-to-Action_), tab navigasi aktif, highlight nomor antrean, dan countdown Virtual Account.
- **Coklat Muda Pasir (`brand-soft-sand` / `#D3B577`)**: Warna jembatan untuk chip kategori, border aksen, dan background container ikon.
- **Krem Linen Hangat (`brand-cream-linen` / `#F7F3ED`)**: Background kontainer lembut, kartu tidak aktif, dan kolom input form.

### B. Distribusi Proporsi Warna (60 - 30 - 10 Rule)

- **60% Dominan (Latar & Permukaan)**: `surface-bg` (`#FAF8F5`) dan `surface-card` (`#FFFFFF`). Bersih, terang, hangat, dan tidak menyilaukan mata pasien.
- **30% Struktur (Teks & Kontainer)**: `brand-dark-espresso` (`#1C140E`) untuk teks tajam, dipadu `brand-cream-linen` (`#F7F3ED`) untuk kartu berbayang hangat.
- **10% Aksen (Aksi & Fokus)**: `brand-golden-caramel` (`#AA7409`) untuk memandu pandangan mata ke aksi berikutnya (misal: tombol _"Daftar Sekarang"_, tombol _"Buka Tiket"_).

### C. Warna Status Klinis (Semantic Roles)

- **🟢 Tersedia / Aman (`#15803D`)**: Tempat tidur kosong $>3$, status SEP BPJS valid, dokter buka praktik.
- **🟡 Terbatas / Perhatian (`#D97706`)**: Kuota poliklinik menipis, nomor antrean mendekati giliran pasien (sisa 3–5 pasien lagi), atau kamar inap tersisa 1–2 bed.
- **🔴 Penuh / Kritis (`#AA2D11`)**: Kamar rawat inap penuh, dokter sedang libur/cuti, pembatalan janji temu.
- **Teal Penyeimbang (`#1B7369`)**: Aksen klinis penyeimbang yang menenangkan untuk riwayat medis dan resume dokter (mengadopsi warna tombol riwayat di web Sitanala).

---

## 3. Typography

- **Font Primer**: **Plus Jakarta Sans** (Alternatif: **Inter**). Tipografi modern, tegas, dengan lengkungan ramah yang terbaca sangat jelas pada layar AMOLED maupun IPS beresolusi rendah.

| Token Peran    | Ukuran |     Bobot      | Line Height | Keterangan & Kasus Penggunaan                           |
| :------------- | :----: | :------------: | :---------: | :------------------------------------------------------ |
| **`display`**  | 26 px  |   Bold (700)   |    34 px    | Nomor Antrean Besar (`PD-014`), Angka Kamar Kosong      |
| **`headline`** | 20 px  | SemiBold (600) |    28 px    | Judul Layar & Section Utama ("Jadwal Dokter Hari Ini")  |
| **`title`**    | 16 px  | SemiBold (600) |    24 px    | Nama Dokter Spesialis, Nama Bangsal Rawat Inap          |
| **`body`**     | 14 px  | Regular (400)  |    22 px    | Teks instruksi pasien, deskripsi persyaratan, alur poli |
| **`label`**    | 12 px  | SemiBold (600) |    16 px    | Badge status ("TERSEDIA", "BPJS"), estimasi jam periksa |

> [!NOTE] Keterbacaan Lansia
> Body text menggunakan `lineHeight` yang lega (22px pada font 14px) agar mata tidak cepat lelah saat membaca instruksi puasa MCU atau syarat rujukan BPJS.

---

## 4. Layout & Ergonomi Mobile

1. **Sistem Kisi 8-Point (8-Point Grid)**: Seluruh margin, padding, dan jarak antar elemen adalah kelipatan 8 (atau 4 untuk mikro-jarak):
   - _Screen Horizontal Padding_: `16 dp` (ponsel standar) / `20 dp` (layar lebar).
   - _Gap Antar Kartu_: `12 dp` atau `16 dp`.
   - _Internal Card Padding_: `16 dp` atas-bawah, `20 dp` kiri-kanan.
2. **Thumb-Zone Architecture**:
   - Seluruh tombol aksi utama ditempatkan di **sepertiga bawah layar** (_bottom floating bar_ atau _bottom sheet_) agar mudah dijangkau satu jempol tanpa meregangkan tangan.
   - Tombol navigasi krusial mengandalkan **Bottom Navigation Bar 4-Tab** yang tetap terlihat di beranda.
3. **Adaptive Form Scaffolding**:
   - Form panjang dibagi menjadi **Wizard Multi-Step** (hanya 2-3 input per langkah).
   - Input keyboard otomatis menyesuaikan tipe data: angka telepon memunculkan _dial-pad_, NIK memunculkan _numeric pad_, dan tanggal lahir memunculkan _wheel/modal date picker_.

---

## 5. Elevation & Depth

Untuk memberikan kesan modern dan bukan desain datar membosankan, kita menggunakan **Warm Ambient Shadows**:

```css
/* Token Shadow Kartu Sitanala */
box-shadow:
  0 4px 16px -2px rgba(73, 51, 6, 0.06),
  0 2px 6px -1px rgba(73, 51, 6, 0.04);
```

- **Level 0 (Flat Surface)**: Background layar `#FAF8F5`.
- **Level 1 (Card Default)**: Latar putih `#FFFFFF` dengan garis tepi super halus `border: 1px solid #EAE2D8` dan bayangan hangat 4px.
- **Level 2 (Active / Highlighted Card)**: Kartu antrean aktif hari-H dengan bayangan 8px dan aksen border karamel keemasan `2px solid #AA7409`.
- **Level 3 (Modal & Bottom Sheet)**: Panel muncul dari bawah dengan bayangan 24px dan backdrop blur gelap hangat `rgba(28, 20, 14, 0.45)`.

---

## 6. Shapes & Form Language

Mengadopsi pola bentuk di web eksisting (`border-radius: 100px` untuk pill buttons dan `border-radius: 14px–20px` untuk cards), kita memperhalusnya menjadi standar modern:

1. **Pill Buttons (`rounded.full` / `9999px`)**:
   - Digunakan untuk tombol aksi utama (_Primary CTA_), tombol tab pemilih hari, dan tombol salin nomor VA. Bentuk oval kapsul ini terbukti paling mengundang klik (_high affordance_).
2. **Squircle Cards (`rounded.lg` / `20px`)**:
   - Kartu jadwal dokter, kartu ruangan rawat inap, dan kartu tiket antrean menggunakan radius 20px yang ramah dan modern.
3. **Avatars & Icons (`rounded.md` / `14px`)**:
   - Avatar dokter (ilustrasi medis berbasis gender L/P atau inisial nama) dan ikon layanan ditempatkan di dalam kontainer kotak bersudut lembut (_squircle container_) dengan latar belakang `brand-cream-linen` (`#F7F3ED`).

---

## 7. Komponen Kunci (Component Archetypes)

### A. Kartu Tiket Antrean Digital (Digital Boarding Pass)

- Bagian atas: Nomor antrean besar (`MAT-014`) warna espresso dengan latar karamel keemasan lembut.
- Bagian tengah: Detail dokter, poliklinik, dan estimasi jam periksa dengan divider titik-titik (_dashed line_).
- Bagian bawah: QR Code check-in yang tajam dan kontras (berisi kode booking 13 digit numerik), disertai instruksi scan di Kiosk APM, tombol _"Batal Janji Temu"_ (aktif hingga H-1 21:00 WIB), dan tombol _"Petunjuk Arah RS"_.

### B. Kartu Ketersediaan Kamar (Bed Availability Card)

- Menampilkan nama bangsal (misal: _Ruang Rawat Inap Anak_).
- Indikator kapasitas bar visual (Progress bar warna coklat keemasan).
- Badge pil status di kanan atas:
  - `🟢 5 Bed Kosong` (badge latar hijau lembut).
  - `🔴 Penuh` (badge latar merah pudar).

### C. Kartu Tagihan Virtual Account (VA Copy Card)

- Kotak tagihan dengan background `#F7F3ED` berbingkai border karamel putus-putus.
- Nomor VA 16 digit ditampilkan dalam font monospaced tebal (`18px`).
- Tombol **"Salin Nomor VA"** dengan micro-interaction: saat ditekan, ikon berubah centang hijau disertai toast _"Nomor VA berhasil disalin"_.

---

## 8. Do's and Don'ts

| Do's (Wajib Dilakukan)                                                                                             | Don'ts (Dilarang Keras)                                                                                               |
| :----------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------- |
| **Gunakan aksen coklat keemasan (`#AA7409`)** sebagai pemandu tombol aksi utama.                                   | **Jangan gunakan warna biru rumah sakit generik** yang merusak identitas visual asli RSUP Dr. Sitanala.               |
| **Pastikan teks di atas latar coklat muda** menggunakan warna coklat tua espresso (`#1C140E`) agar kontras tinggi. | **Jangan menaruh teks putih di atas coklat muda/sand** karena rasio kontrasnya tidak lulus uji aksesibilitas (< 3:1). |
| **Gunakan visual card bertahap** untuk pendaftaran agar pasien lansia tidak bingung.                               | **Jangan memindahkan tabel datar web** yang panjang ratusan baris mentah-mentah ke layar ponsel.                      |
| **Sediakan tombol salin otomatis** untuk nomor Virtual Account bank.                                               | **Jangan memaksa pasien menghafal** atau mengetik ulang nomor tagihan VA secara manual.                               |
| **Terapkan animasi transisi halus (200–300 ms)** saat membuka detail jadwal dokter atau kamar.                     | **Jangan gunakan animasi berlebihan** yang membuat ponsel pasien terasa lambat atau menghabiskan baterai.             |

---

## 9. Pola Desain Eye-Catching & Benchmark Eksternal (Mobbin & Healthtech)

Mengadopsi pola antarmuka terbaik dari aplikasi kesehatan kelas dunia (_One Medical, Mayo Clinic, Oscar Health, Apple Health_) yang dipadukan dengan identitas khas Sitanala:

### A. Dynamic Hero Boarding Pass (Kartu Utama Beranda)

- Ketika pasien memiliki janji temu aktif, bagian teratas Beranda menampilkan kartu tiket melayang dengan latar gradasi hangat (`#493306` ke `#2C1810`):
  - **Status Real-Time**: Badge _"Besok, Pukul 08:30 WIB"_.
  - **Info Pelayanan**: Nama Poli Mata & Avatar dr. Hendra, Sp.M. (Ilustrasi Dokter Pria)
  - **Aksi Cepat**: Tombol pil putih transparan _"Buka Tiket QR"_ dan tombol _"Petunjuk Arah RS"_.
  - Memberikan rasa tenang (_reassurance_) seketika saat pasien membuka aplikasi.

### B. Bento Grid Menu Cepat dengan Live Badge

- Menggantikan ikon flat kaku dengan **Bento Card Layout** interaktif:
  - **Kartu Pendaftaran Rawat Jalan (Besar)**: Aksen karamel keemasan `#AA7409`, ilustrasi dokter ramah, tombol _"Daftar Poli"_.
  - **Kartu Ketersediaan Kamar (Sedang)**: Ikon bed dengan **Live Badge Dinamis**: `🟢 18 Bed Kosong`.
  - **Kartu Jadwal Dokter (Sedang)**: Kalender dengan teks _"Cari Spesialis & Hari"_.
  - **Kartu Paket MCU (Kompak)**: Ikon perisai detak jantung dengan teks _"Pemeriksaan Rutin"_.

### C. Horizontal Sticky Calendar Strip (Pemilih Tanggal Intuitif)

- Menggantikan kalender grid bulanan desktop yang sempit di ponsel dengan **Horizontal Date Strip** yang dapat digeser mulus:
  - Bentuk kartu pil vertikal: `[SEN | 28] [SEL | 29] [RAB | 30]`.
  - Hari yang dipilih otomatis aktif dengan latar coklat keemasan `#AA7409` dan teks putih tebal.
  - Hari libur poli otomatis berstatus _disabled_ dengan visual abu-abu pudar.

### D. Perforated Digital Ticket (Tiket Berlekuk & Auto-Brightness QR)

- Desain tiket menyerupai _boarding pass_ maskapai penerbangan modern:
  - Terdapat lekukan setengah lingkaran (_cutout notches_) di sisi kiri dan kanan dengan garis batas putus-putus (_perforated dashed divider_).
  - **Fitur Cerdas Native (Auto-Brightness)**: Begitu layar tiket ini dibuka, aplikasi secara otomatis menaikkan tingkat kecerahan layar ponsel hingga 100% sementara agar mesin scanner APM di lobi RSUP Dr. Sitanala dapat membaca QR code dalam sepersekian detik.

### E. Live Queue Pulse Tracker (Pelacak Antrean Real-Time)

- Widget antrean saat hari-H di area poliklinik:
  - Titik hijau berdenyut halus (_pulsing emerald dot_): `● Sedang Dilayani: MAT-011`.
  - Kartu perbandingan: `Nomor Anda: MAT-014` $\rightarrow$ `Sisa: 3 Pasien Lagi (Estimasi ~15 Menit)`.
  - Pasien dapat menunggu di kantin atau taman rumah sakit dengan tenang tanpa takut terlewat giliran panggilan.

### F. Haptic Feedback & Tactile Micro-Interactions

- **Light Haptic (Vibrasi Halus)**: Terasa saat pasien mengetuk tab tanggal atau tombol aksi.
- **Success Haptic (Getar Ganda Mantap)**: Terasa saat submit pendaftaran sukses menerbitkan tiket atau saat menyalin kode booking/VA MCU.
- **One-Tap Copy Animation**: Saat tombol _"Salin Kode Booking"_ atau _"Salin Nomor VA (MCU)"_ ditekan, tombol bertransformasi sekejap menampilkan ikon centang hijau disertai notifikasi toast melayang lembut.
