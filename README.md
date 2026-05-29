# GrahiEdu

Aplikasi pembelajaran untuk anak berkebutuhan khusus dengan backend PHP MySQL dan frontend Flutter. Proyek ini menyediakan:

- aplikasi mobile Flutter untuk admin, guru BK, dan siswa
- API backend berbasis PHP
- database MySQL untuk data pengguna, materi, dan progres belajar
- penyimpanan file lokal untuk foto profil, materi gambar, dan audio

## Gambaran Singkat

Stack yang dipakai:

- Backend: PHP + MySQL
- Mobile app: Flutter
- Web server lokal: XAMPP/LAMPP
- API format: JSON

Fitur utama:

- login dan registrasi pengguna
- manajemen user oleh admin
- materi membaca, menulis, dan berhitung oleh guru
- pencatatan progres belajar siswa
- upload foto profil dan aset materi

## Software yang Dibutuhkan

Pastikan software berikut sudah terpasang:

| Software | Minimal | Keterangan |
| --- | --- | --- |
| PHP | 7.4+ | Untuk menjalankan API di folder `api/` |
| MySQL / MariaDB | 5.7+ | Untuk database `app_disabilitas` |
| XAMPP / LAMPP | Versi terbaru | Agar Apache dan MySQL mudah dijalankan |
| Flutter SDK | 3.x | Untuk aplikasi mobile di folder `mobile/` |
| Dart SDK | Mengikuti Flutter | Sudah ikut dari instalasi Flutter |
| Android Studio / SDK Android | Disarankan | Untuk emulator Android dan build APK |
| Git | Disarankan | Untuk clone dan version control |

Tambahan yang biasanya dibutuhkan saat development Flutter:

- browser Chrome jika ingin uji target web
- device Android fisik atau emulator
- `adb` untuk debug device Android

## Struktur Proyek

```text
app-disabilitas/
├── api/                    # Endpoint backend PHP
├── mobile/                 # Aplikasi Flutter
├── uploads/                # File upload lokal
│   ├── profiles/
│   ├── materials/
│   ├── images/
│   └── audio/
├── schema.sql              # Skema dan data awal database
└── README.md
```

Folder penting:

- `api/db_config.php`: koneksi database
- `api/auth/`: login dan registrasi
- `api/admin/`: manajemen user
- `api/teacher/`: CRUD materi belajar
- `api/student/`: simpan dan lihat progres
- `api/user/`: profil, password, upload foto
- `mobile/lib/core/services/api_service.dart`: base URL API Flutter

## Persiapan Backend

### 1. Letakkan proyek di folder web server

Untuk LAMPP Linux, proyek idealnya berada di:

```bash
/opt/lampp/htdocs/app-disabilitas
```

Jika menggunakan XAMPP Windows, biasanya di:

```bash
C:\xampp\htdocs\app-disabilitas
```

### 2. Jalankan Apache dan MySQL

Contoh LAMPP Linux:

```bash
sudo /opt/lampp/lampp start
```

Lalu pastikan layanan aktif:

- Apache berjalan
- MySQL berjalan

### 3. Buat database

Buka phpMyAdmin:

```text
http://localhost/phpmyadmin
```

Buat database dengan nama:

```sql
CREATE DATABASE app_disabilitas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4. Import skema database

Gunakan file [schema.sql](/opt/lampp/htdocs/app-disabilitas/schema.sql) yang sudah tersedia.

Opsi phpMyAdmin:

1. Pilih database `app_disabilitas`
2. Buka tab `Import`
3. Pilih file `schema.sql`
4. Jalankan import

Opsi terminal:

```bash
mysql -u root -p app_disabilitas < schema.sql
```

Jika MySQL lokal Anda tidak memakai password untuk user `root`, bisa pakai:

```bash
mysql -u root app_disabilitas < schema.sql
```

### 5. Konfigurasi koneksi database PHP

Periksa file [api/db_config.php](/opt/lampp/htdocs/app-disabilitas/api/db_config.php).

Nilai default saat ini:

```php
$host = "localhost";
$db_name = "app_disabilitas";
$username = "root";
$password = "";
```

Ubah `$password` jika MySQL lokal Anda memakai password.

### 6. Pastikan folder upload tersedia

Project ini memakai folder upload lokal berikut:

- `uploads/profiles`
- `uploads/materials`
- `uploads/images`
- `uploads/audio`

Jika perlu, buat ulang dengan:

```bash
mkdir -p /opt/lampp/htdocs/app-disabilitas/uploads/profiles
mkdir -p /opt/lampp/htdocs/app-disabilitas/uploads/materials
mkdir -p /opt/lampp/htdocs/app-disabilitas/uploads/images
mkdir -p /opt/lampp/htdocs/app-disabilitas/uploads/audio
```

Untuk development lokal Linux, permission tulis kadang perlu disesuaikan:

```bash
chmod -R 777 /opt/lampp/htdocs/app-disabilitas/uploads
```

## URL Backend

Jika Apache berjalan pada port default XAMPP/LAMPP di mesin ini, endpoint utama API biasanya:

```text
http://localhost:8080/app-disabilitas/api
```

Contoh endpoint login:

```text
http://localhost:8080/app-disabilitas/api/auth/login.php
```

Sebelum menjalankan Flutter, uji dulu apakah backend bisa diakses dari browser atau Postman.

## Persiapan Aplikasi Flutter

Masuk ke folder mobile:

```bash
cd /opt/lampp/htdocs/app-disabilitas/mobile
```

Lalu install dependency:

```bash
flutter pub get
```

Disarankan cek environment Flutter:

```bash
flutter doctor
```

## Konfigurasi Base URL Flutter

File yang perlu disesuaikan:

[mobile/lib/core/services/api_service.dart](/opt/lampp/htdocs/app-disabilitas/mobile/lib/core/services/api_service.dart)

Saat ini nilai default:

```dart
static const String baseUrl = "http://localhost:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://localhost:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://localhost:8080/app-disabilitas/uploads/materials/";
```

Gunakan URL sesuai target run:

### Android emulator

```dart
static const String baseUrl = "http://10.0.2.2:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://10.0.2.2:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://10.0.2.2:8080/app-disabilitas/uploads/materials/";
```

### Device fisik dalam satu jaringan Wi-Fi

Ganti `192.168.1.xxx` dengan IP laptop/PC yang menjalankan Apache:

```dart
static const String baseUrl = "http://192.168.1.xxx:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://192.168.1.xxx:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://192.168.1.xxx:8080/app-disabilitas/uploads/materials/";
```

### Linux desktop / macOS desktop

```dart
static const String baseUrl = "http://localhost:8080/app-disabilitas/api";
```

Catatan:

- `localhost` di Android emulator tidak menunjuk ke komputer host
- `10.0.2.2` adalah alamat khusus untuk host pada emulator Android
- untuk device fisik, Apache harus bisa diakses dari jaringan lokal

## Menjalankan Aplikasi

Lihat device yang tersedia:

```bash
flutter devices
```

Jalankan aplikasi:

```bash
flutter run
```

Atau ke device tertentu:

```bash
flutter run -d <device-id>
```

Jika ingin build APK:

```bash
flutter build apk
```

## Akun Default

Setelah `schema.sql` berhasil di-import, gunakan akun awal berikut:

| Role | Username | Password |
| --- | --- | --- |
| Admin | `admin` | `admin123` |
| Guru BK | `guru` | `guru123` |
| Siswa | `budi` | `siswa123` |

Jika isi `schema.sql` Anda berbeda, sesuaikan akun dengan data yang ada di database.

## Alur Setup Cepat

Kalau ingin ringkas, urutannya seperti ini:

1. Jalankan Apache dan MySQL dari XAMPP/LAMPP.
2. Buat database `app_disabilitas`.
3. Import [schema.sql](/opt/lampp/htdocs/app-disabilitas/schema.sql).
4. Cek [api/db_config.php](/opt/lampp/htdocs/app-disabilitas/api/db_config.php).
5. Pastikan folder `uploads/` bisa ditulis.
6. Jalankan `flutter pub get` di folder `mobile/`.
7. Sesuaikan `baseUrl` pada [api_service.dart](/opt/lampp/htdocs/app-disabilitas/mobile/lib/core/services/api_service.dart).
8. Jalankan `flutter run`.

## Troubleshooting

### API tidak bisa diakses

Periksa:

- Apache sudah aktif
- path proyek benar-benar ada di `htdocs`
- URL memakai port yang benar, misalnya `8080`

### Login gagal padahal database sudah ada

Periksa:

- tabel `users` benar-benar terisi
- konfigurasi database di `api/db_config.php` benar
- endpoint `auth/login.php` bisa diakses

### Aplikasi Flutter tidak bisa terhubung ke backend

Penyebab paling umum:

- `baseUrl` salah
- memakai `localhost` di Android emulator
- device fisik tidak satu jaringan dengan komputer host
- firewall memblokir akses ke Apache

### Upload file gagal

Periksa:

- folder `uploads/` ada
- permission folder mengizinkan write
- URL upload dan URL asset sesuai dengan alamat backend

## Catatan Pengembangan

- `mobile/README.md` masih README bawaan Flutter dan belum menjadi dokumentasi utama proyek ini.
- Dokumentasi utama sebaiknya menggunakan file [README.md](/opt/lampp/htdocs/app-disabilitas/README.md) di root repository ini.
