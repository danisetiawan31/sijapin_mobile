<div align="center">

# 📱 SIIJAPIN MOBILE
### Sistem Informasi dan Janji Temu Pasien Online
**RSUP Dr. Sitanala Tangerang — Kementerian Kesehatan RI**

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Feature--First-AA7409?style=for-the-badge)](docs/ARCHITECTURE.md)
[![Sentry](https://img.shields.io/badge/Sentry-Monitored-362D59?style=for-the-badge&logo=sentry&logoColor=white)](https://sentry.io)
[![CI/CD](https://img.shields.io/badge/Quality%20Gate-100%25%20Automated-15803D?style=for-the-badge&logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![Compliance](https://img.shields.io/badge/Kepatuhan-UU%20PDP%20No.%2027%2F2022-825B0B?style=for-the-badge)]()

*Klien mobile modern berstandar enterprise yang bertindak sebagai adapter stateful di atas backend SIMRS CodeIgniter 3.*

[🏛️ Arsitektur](#-arsitektur-sistem) • [✨ Fitur Utama](#-fitur-utama--status) • [🎨 Design System](#-design-system-palet-sitanala) • [🚀 Mulai Cepat](#-instalasi--pengembangan) • [🛡️ Kepatuhan](#️-keamanan--kepatuhan-data)

---
</div>

## 🌐 Arsitektur Sistem

```mermaid
flowchart LR
    subgraph MobileClient["📱 SIIJAPIN Mobile (Flutter)"]
        UI["🎨 UI Layer (Material 3)"]
        State["⚡ State (Riverpod)"]
        Adapter["🔌 Network Adapter (Dio + CookieJar)"]
        Storage["💾 Dual Local Storage\n• Hive CE (Cache)\n• SecureStorage (Keystore)"]
    end

    subgraph Gateway["🛡️ RS Sitanala Gateway"]
        CI3["⚙️ Legacy PHP CI3\n• ci_session Cookie\n• ci_csrf_token"]
    end

    subgraph CoreSIMRS["🏛️ SIMRS & Kemenkes"]
        DB[(🗄️ PostgreSQL SIMRS)]
        BPJS["🏥 BPJS Antrean & V-Claim"]
        APM["📟 Mesin Kiosk Fisik (APM)"]
    end

    UI --> State
    State --> Storage
    State --> Adapter
    Adapter <== HTTP Form-Data / Cookie ==> CI3
    CI3 <--> DB
    CI3 <--> BPJS
    UI -. 13-Digit QR Scan .-> APM
```

## 🏗️ Feature-First Clean Architecture

```mermaid
flowchart TD
    subgraph Feature["Feature Module (lib/features/*)"]
        direction TB
        subgraph Presentation["🎨 Presentation Layer"]
            UI["Screens / Widgets"] --> Notifier["Riverpod Controller"]
        end

        subgraph Domain["🧠 Domain Layer (Pure Dart)"]
            UseCase["UseCases"] --> Entity["Domain Entities"]
            UseCase --> RepoContract["Repository Contracts"]
        end

        subgraph Data["💾 Data Layer"]
            RepoImpl["Repository Impl"] --> RemoteDS["Remote DS (Dio CI3)"]
            RepoImpl --> LocalDS["Local DS (Hive / Secure)"]
        end
    end

    Notifier ==> UseCase
    RepoImpl -. implements .-> RepoContract
```

## 🎯 Alur Pasien & Mesin APM Kiosk

```mermaid
sequenceDiagram
    autonumber
    actor Pasien as 🧑 Pasien
    participant App as 📱 SIIJAPIN Mobile
    participant CI3 as ⚙️ Backend CI3
    participant Kiosk as 📟 Kiosk APM Fisik (Lobi RS)

    Pasien->>App: Pilih Poli & Jadwal Dokter
    App->>CI3: POST /Daftar_Kunj_Raja/insert_daftar_rajal
    CI3-->>App: Kode Booking (13 Digit Numerik)
    App->>App: Simpan Tiket Offline (Hive CE)
    Note over Pasien,App: Hari-H Kunjungan di RSUP Dr. Sitanala
    Pasien->>Kiosk: Tunjukkan Layar HP (QR Code 13 Digit)
    Kiosk->>Kiosk: Scan Optik 2D -> Check-in Sukses & Cetak Karcis
```

## 🚀 Fitur Utama & Status

| Modul | Kemampuan Sistem | Offline Ready | Status |
| :--- | :--- | :---: | :---: |
| 🔐 **Autentikasi & Akun** | Registrasi, Login stateful `ci_session`, auto CSRF, Hardware Keystore | ❌ | 🟡 In Progress |
| 🏥 **Informasi Publik** | Cek Bed Rawat Inap Real-time, Jadwal Dokter Poliklinik | ⚠️ Cache | ⚪ Terencana |
| 🎫 **Booking Rajal** | Wizard pendaftaran Poli, Validasi Rujukan BPJS & Pasien Umum | ❌ | ⚪ Terencana |
| 📱 **Tiket Digital APM** | QR Code 13-Digit, Antrean Poliklinik, Navigasi Check-in Fisik | 🟢 **100%** | ⚪ Terencana |
| 🔔 **Notifikasi Lokal** | Pengingat H-1 Jadwal Poliklinik & Konfirmasi Antrean | 🟢 **100%** | ⚪ Terencana |
| 📊 **Monitoring & Audit** | Sentry Crash Reporting, Breadcrumb Navigasi, Auto Session | 🟢 **100%** | 🟢 **Aktif (Live)** |

## 🎨 Design System: Palet Sitanala

> *Panduan lengkap filosofi desain, tipografi, ergonomi, dan komponen UI dapat dilihat di [DESIGN.md](DESIGN.md).*

| Token | Warna | Hex Code | Peruntukan Utama |
| :--- | :---: | :--- | :--- |
| `brandDarkEspresso` | 🟫 | `#1C140E` | Teks utama, judul, header kontras tinggi |
| `brandGoldenCaramel` | 🟨 | `#AA7409` | Aksen primer, tombol CTA utama, ikon aktif |
| `brandWarmBronze` | 🟧 | `#825B0B` | Secondary branding, border fokus, kartu sorotan |
| `surfaceBg` | ⬜ | `#FAF8F5` | Background layar utama (warm clinical) |
| `clinicalTeal` | 🟩 | `#1B7369` | Status rawat inap, info medis & BPJS |
| `dangerCrimson` | 🟥 | `#AA2D11` | Error state, status batal & peringatan |

## 🛠️ Tech Stack & Standar Rekayasa

```text
├── Framework        : Flutter 3.47+ / Dart 3.13+ (Strict Mode)
├── State Management : Flutter Riverpod 2.6+ (Code Generation)
├── Network Engine   : Dio 5.8+ & CookieJar (ci_session Stateful Adapter)
├── Dual Storage     : Hive CE 2.2+ (Fast Key-Value) & FlutterSecureStorage (Keystore)
├── Monitoring       : Sentry Flutter 8.11+ (Real-time Crash Tracing)
├── Code Quality     : Strict Linter (0 warnings) & GitNexus Code Intelligence
└── Quality Gate     : Pre-Push Git Hook & GitHub Actions CI (100% Automated)
```

## ⚡ Instalasi & Pengembangan

```bash
# 1. Unduh Dependensi
flutter pub get

# 2. Jalankan Code Generator
dart run build_runner build --delete-conflicting-outputs

# 3. Jalankan Strict Linter (0 warnings)
flutter analyze

# 4. Jalankan Pengujian Otomatis
flutter test
```

## 🛡️ Keamanan & Kepatuhan Data

```mermaid
flowchart LR
    A["📄 Input Pasien"] --> B{"🛡️ Masking Layer\n(UU PDP No. 27/2022)"}
    B -->|"NIK 16-Digit"| C["367104******0002"]
    B -->|"No. BPJS"| D["000123****789"]
    B -->|"No. HP"| E["0812****8901"]
    B -->|"Kredensial Sesi"| F["Hardware Keystore\n(FlutterSecureStorage)"]
```

---

<div align="center">
<b>Instalasi Sistem Informasi Rumah Sakit (ISIRS)</b><br>
RSUP Dr. Sitanala Tangerang — Jl. Dr. Sitanala No. 99, Karangsari, Neglasari, Tangerang, Banten
</div>
