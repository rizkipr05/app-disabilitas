# GrahiEdu

GrahiEdu adalah aplikasi pembelajaran untuk anak berkebutuhan khusus. Proyek ini terdiri dari:

- backend PHP + MySQL
- aplikasi mobile Flutter
- penyimpanan file upload lokal

README ini dibuat khusus agar mudah diikuti oleh pengguna Windows.

## Isi Proyek

Folder penting:

- `api/` : backend PHP
- `mobile/` : aplikasi Flutter
- `uploads/` : tempat file upload
- `schema.sql` : file database

## Software yang Harus Diinstal

Sebelum menjalankan proyek ini, install:

1. `XAMPP`
   Untuk menjalankan Apache dan MySQL.

2. `Flutter SDK`
   Untuk menjalankan aplikasi mobile.

3. `Android Studio`
   Untuk emulator Android dan Android SDK.

4. `Git`
   Jika proyek diambil dari GitHub.

## Lokasi Folder Proyek di Windows

Simpan proyek ini di dalam folder `htdocs` milik XAMPP.

Contoh:

```text
C:\xampp\htdocs\app-disabilitas
```

Kalau folder proyek tidak berada di `htdocs`, backend PHP tidak akan bisa diakses lewat browser.

## Langkah 1: Jalankan XAMPP

1. Buka `XAMPP Control Panel`
2. Klik `Start` pada:
   - `Apache`
   - `MySQL`
3. Pastikan keduanya berwarna hijau

Jika sudah aktif, coba buka:

```text
http://localhost/dashboard/
```

Jika halaman XAMPP terbuka, berarti Apache sudah jalan.

## Langkah 2: Buat Database

1. Buka browser
2. Masuk ke:

```text
http://localhost/phpmyadmin
```

3. Klik `New`
4. Buat database dengan nama:

```text
app_disabilitas
```

5. Klik `Create`

## Langkah 3: Import Database

1. Di phpMyAdmin, klik database `app_disabilitas`
2. Klik tab `Import`
3. Klik `Choose File`
4. Pilih file [schema.sql](/opt/lampp/htdocs/app-disabilitas/schema.sql)
5. Klik `Go`

Jika berhasil, tabel-tabel database akan otomatis dibuat.

## Langkah 4: Cek Koneksi Database PHP

File yang dipakai:

[api/db_config.php](/opt/lampp/htdocs/app-disabilitas/api/db_config.php)

Isi default yang penting:

```php
$host = "localhost";
$db_name = "app_disabilitas";
$username = "root";
$password = "";
```

Penjelasan:

- `localhost` artinya database ada di komputer yang sama
- `root` adalah username default MySQL XAMPP
- `""` artinya password kosong

Kalau MySQL Anda memakai password, ubah bagian:

```php
$password = "";
```

menjadi:

```php
$password = "password_mysql_anda";
```

## Langkah 5: Cek Backend di Browser

Setelah Apache dan MySQL aktif, coba buka:

```text
http://localhost/app-disabilitas/api/auth/login.php
```

Atau jika XAMPP Anda memakai port `8080`, buka:

```text
http://localhost:8080/app-disabilitas/api/auth/login.php
```

Kalau muncul respons dari PHP, berarti backend sudah terbaca.

Catatan:

- beberapa komputer memakai `http://localhost/...`
- beberapa setup memakai `http://localhost:8080/...`

Jadi sesuaikan dengan XAMPP di laptop Anda.

## Langkah 6: Siapkan Folder Upload

Pastikan folder berikut ada:

- `uploads/profiles`
- `uploads/materials`
- `uploads/images`
- `uploads/audio`

Kalau foldernya belum ada, buat manual lewat File Explorer di dalam:

```text
C:\xampp\htdocs\app-disabilitas\uploads
```

## Langkah 7: Jalankan Flutter

Buka terminal atau Command Prompt, lalu masuk ke folder mobile:

```bash
cd C:\xampp\htdocs\app-disabilitas\mobile
```

Lalu jalankan:

```bash
flutter pub get
```

Setelah itu cek apakah Flutter sudah siap:

```bash
flutter doctor
```

Kalau ada error di Android SDK atau emulator, selesaikan dulu lewat Android Studio.

## Langkah 8: Atur URL API di Flutter

File yang harus diubah:

[mobile/lib/core/services/api_service.dart](/opt/lampp/htdocs/app-disabilitas/mobile/lib/core/services/api_service.dart)

Di file itu ada bagian seperti ini:

```dart
static const String baseUrl = "http://localhost:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://localhost:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://localhost:8080/app-disabilitas/uploads/materials/";
```

Pilih salah satu sesuai cara Anda menjalankan aplikasi.

### Jika pakai Android emulator

Gunakan:

```dart
static const String baseUrl = "http://10.0.2.2:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://10.0.2.2:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://10.0.2.2:8080/app-disabilitas/uploads/materials/";
```

Kenapa bukan `localhost`?

Karena di emulator Android, `localhost` menunjuk ke emulator itu sendiri, bukan ke laptop Anda.

### Jika pakai HP Android langsung

Gunakan IP laptop Anda, misalnya:

```dart
static const String baseUrl = "http://192.168.1.5:8080/app-disabilitas/api";
static const String assetBaseUrl = "http://192.168.1.5:8080/app-disabilitas/uploads/profiles/";
static const String materialAssetBaseUrl = "http://192.168.1.5:8080/app-disabilitas/uploads/materials/";
```

Syarat:

- HP dan laptop harus satu Wi-Fi
- Apache di XAMPP harus sedang aktif

### Jika pakai Flutter Windows Desktop atau test lokal tertentu

Gunakan:

```dart
static const String baseUrl = "http://localhost:8080/app-disabilitas/api";
```

Kalau XAMPP Anda tidak memakai port `8080`, ubah menjadi:

```dart
static const String baseUrl = "http://localhost/app-disabilitas/api";
```

## Langkah 9: Jalankan Aplikasi

Lihat device yang tersedia:

```bash
flutter devices
```

Jalankan aplikasi:

```bash
flutter run
```

Kalau ingin ke device tertentu:

```bash
flutter run -d <device-id>
```

## Akun Default

Setelah `schema.sql` berhasil di-import, gunakan akun ini:

| Role | Username | Password |
| --- | --- | --- |
| Admin | `admin` | `admin123` |
| Guru BK | `guru` | `guru123` |
| Siswa | `budi` | `siswa123` |

## Urutan Singkat Paling Mudah

Kalau ingin cepat, ikuti urutan ini:

1. Install `XAMPP`, `Flutter`, dan `Android Studio`
2. Simpan proyek di `C:\xampp\htdocs\app-disabilitas`
3. Jalankan `Apache` dan `MySQL` dari XAMPP
4. Buka `phpMyAdmin`
5. Buat database `app_disabilitas`
6. Import file `schema.sql`
7. Cek `api/db_config.php`
8. Ubah `baseUrl` di `api_service.dart`
9. Jalankan `flutter pub get`
10. Jalankan `flutter run`

## Jika Terjadi Error

### 1. phpMyAdmin tidak bisa dibuka

Penyebab biasanya:

- Apache belum aktif
- XAMPP belum dijalankan

### 2. Database tidak konek

Periksa:

- nama database harus `app_disabilitas`
- username MySQL biasanya `root`
- password di `db_config.php` harus benar

### 3. Flutter tidak bisa login ke API

Periksa:

- URL di `api_service.dart` sudah benar
- kalau pakai emulator, gunakan `10.0.2.2`
- kalau pakai HP, gunakan IP laptop, bukan `localhost`

### 4. File upload gagal

Periksa:

- folder `uploads` lengkap
- path proyek benar-benar ada di `C:\xampp\htdocs\app-disabilitas`

## Catatan

File README ini dipakai sebagai panduan utama proyek.

Jika Anda mau, saya bisa lanjut bantu buat versi README yang lebih rapi lagi dengan:

- gambar alur instalasi
- penjelasan cara mencari IP laptop
- penjelasan cara menjalankan lewat emulator Android
