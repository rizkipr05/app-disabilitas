# GrahiEdu - Aplikasi Pembelajaran untuk Anak Berkebutuhan Khusus

> Aplikasi mobile Flutter berbasis LAMP Stack untuk mendukung pembelajaran anak dengan disabilitas intelektual.

---

## 📋 Persyaratan Sistem

| Kebutuhan | Versi |
|-----------|-------|
| Flutter | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| PHP | ≥ 7.4 |
| MySQL | ≥ 5.7 |
| XAMPP / LAMPP | Terbaru |

---

## 🗄️ Setup Database

### 1. Jalankan XAMPP/LAMPP
```bash
# Linux
sudo /opt/lampp/lampp start

# Atau gunakan panel XAMPP
```

### 2. Buat Database
Buka **phpMyAdmin** di `http://localhost/phpmyadmin`, lalu buat database baru:
```sql
CREATE DATABASE app_disabilitas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. Import Skema Database
Jalankan SQL berikut di phpMyAdmin atau terminal MySQL:

```sql
USE app_disabilitas;

-- Tabel Pengguna
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'guru_bk', 'siswa') NOT NULL DEFAULT 'siswa',
  profile_image VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Materi Membaca
CREATE TABLE reading_materials (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(50) DEFAULT 'word',
  content VARCHAR(255) NOT NULL,
  level INT DEFAULT 1,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel Materi Menulis
CREATE TABLE writing_materials (
  id INT AUTO_INCREMENT PRIMARY KEY,
  content VARCHAR(255) NOT NULL,
  level INT DEFAULT 1,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel Materi Berhitung
CREATE TABLE math_materials (
  id INT AUTO_INCREMENT PRIMARY KEY,
  operand1 INT NOT NULL,
  operand2 INT NOT NULL,
  explanation VARCHAR(255) DEFAULT NULL,
  level INT DEFAULT 1,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel Progres Siswa
CREATE TABLE student_progress (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  module VARCHAR(50) NOT NULL,
  material_id INT NOT NULL,
  score INT DEFAULT 0,
  completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 4. Tambahkan Data Awal (Akun Default)

```sql
USE app_disabilitas;

-- Password: admin123
INSERT INTO users (full_name, username, password, role) VALUES
('Administrator', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
-- Password: guru123
('Guru Pembimbing Khusus', 'guru', '$2y$10$TKh8H1.PJy3GeDwzOXB4O.uqE5yVCm03LzR1FHCLDc9OaA89bvnG', 'guru_bk'),
-- Password: siswa123
('Budi Santoso', 'budi', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'siswa');

-- Materi Awal
INSERT INTO reading_materials (content, level, created_by) VALUES ('BUKU', 1, 2), ('MEJA', 1, 2), ('APEL', 2, 2);
INSERT INTO writing_materials (content, level, created_by) VALUES ('A', 1, 2), ('I', 1, 2), ('BOLA', 2, 2);
INSERT INTO math_materials (operand1, operand2, level, created_by) VALUES (1, 2, 1, 2), (3, 4, 1, 2), (5, 6, 2, 2);
```

> **Catatan:** Password di atas menggunakan hash Bcrypt. Ubah melalui fitur "Ganti Password" di dalam aplikasi setelah login pertama.

---

## 📁 Struktur Proyek

```
app-disabilitas/
├── api/                        # Backend PHP
│   ├── db_config.php           # Koneksi database
│   ├── auth/
│   │   └── login.php
│   ├── teacher/
│   │   ├── reading.php         # CRUD materi membaca
│   │   ├── writing.php         # CRUD materi menulis
│   │   └── math.php            # CRUD materi berhitung
│   ├── student/
│   │   └── progress.php        # Simpan & ambil progres
│   └── user/
│       ├── profile.php
│       ├── update_profile.php
│       ├── change_password.php
│       └── upload_profile.php
├── mobile/                     # Aplikasi Flutter
│   ├── lib/
│   │   ├── main.dart           # Entry point & routing
│   │   ├── core/
│   │   │   ├── constants/      # AppTheme
│   │   │   ├── models/         # Data models
│   │   │   └── services/       # ApiService, VoiceService
│   │   ├── providers/          # AuthProvider
│   │   └── ui/screens/
│   │       ├── auth/           # LoginScreen
│   │       ├── admin/          # AdminDashboard
│   │       ├── teacher/        # TeacherDashboard
│   │       ├── student/        # StudentHome
│   │       ├── modules/        # ReadingScreen, WritingScreen, MathScreen
│   │       └── profile/        # ProfileScreen
│   └── pubspec.yaml
└── uploads/profiles/           # Foto profil pengguna
```

---

## ⚙️ Konfigurasi Backend

### db_config.php
Pastikan file `/api/db_config.php` berisi:
```php
<?php
$host = 'localhost';
$db   = 'app_disabilitas';
$user = 'root';
$pass = ''; // Sesuaikan dengan password MySQL Anda

try {
    $conn = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Koneksi database gagal: " . $e->getMessage()]);
    exit();
}
?>
```

### Folder Uploads
Buat folder untuk menyimpan foto profil:
```bash
mkdir -p /opt/lampp/htdocs/app-disabilitas/uploads/profiles
chmod 777 /opt/lampp/htdocs/app-disabilitas/uploads/profiles
```

---

## 📱 Setup Flutter (Mobile)

### 1. Masuk ke Direktori Mobile
```bash
cd /opt/lampp/htdocs/app-disabilitas/mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Konfigurasi URL API

Buka `lib/core/services/api_service.dart` dan sesuaikan URL:

```dart
// Untuk emulator Android:
static const String baseUrl = "http://10.0.2.2:8080/app-disabilitas/api";

// Untuk device fisik (ganti dengan IP komputer Anda):
static const String baseUrl = "http://192.168.1.XXX:8080/app-disabilitas/api";

// Untuk localhost (Linux/macOS desktop):
static const String baseUrl = "http://localhost:8080/app-disabilitas/api";
```

### 4. Jalankan Aplikasi
```bash
# Debug mode
flutter run

# Untuk device spesifik
flutter run -d <device-id>

# Lihat daftar device
flutter devices
```

---

## 🔑 Akun Default

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Guru BK | `guru` | `guru123` |
| Siswa | `budi` | `siswa123` |

---

## ✨ Fitur Utama

### 👨‍🏫 Guru BK
- Kelola materi Membaca, Menulis, Berhitung (CRUD)
- Lihat progres belajar semua siswa
- Edit profil dan ganti password

### 🎓 Siswa
- Belajar Membaca: baca kata & dengarkan suara
- Belajar Menulis: gambar huruf dengan jari
- Belajar Berhitung: jawab soal penjumlahan
- Feedback suara otomatis saat selesai

### 🛡️ Admin
- Lihat semua pengguna
- Pantau seluruh progres siswa
- Akses Dashboard Guru

---

## 🛠️ Dependensi Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.0.0
  image_picker: ^1.0.0
  flutter_tts: ^3.8.5
  http_parser: ^4.0.2
  google_fonts: ^6.0.0
```

---

## 📞 Support

Proyek ini dibuat untuk mendukung pembelajaran anak berkebutuhan khusus. Jika menemukan kendala, periksa:
1. XAMPP/LAMPP sudah berjalan
2. Database sudah diimport
3. URL API sudah sesuai
4. Port 8080 tidak diblokir firewall
