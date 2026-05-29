CREATE DATABASE IF NOT EXISTS app_disabilitas;
USE app_disabilitas;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'guru_bk', 'siswa') NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reading_materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('word', '2_words', 'sentence') NOT NULL,
    content TEXT NOT NULL,
    audio_path VARCHAR(255),
    level INT NOT NULL DEFAULT 1,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE writing_materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content VARCHAR(255) NOT NULL,
    guideline_image VARCHAR(255),
    level INT NOT NULL DEFAULT 1,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE math_materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    operand1 INT NOT NULL,
    operand2 INT NOT NULL,
    operation VARCHAR(10) DEFAULT '+',
    explanation TEXT,
    level INT NOT NULL DEFAULT 1,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE student_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    module ENUM('reading', 'writing', 'math') NOT NULL,
    material_id INT NOT NULL,
    score INT DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Initial Users
INSERT INTO users (username, password, role, full_name) VALUES 
('admin', 'admin123', 'admin', 'System Administrator'),
('guru1', 'guru123', 'guru_bk', 'Guru Pembimbing Khusus'),
('siswa1', 'siswa123', 'siswa', 'Budi Santoso');

-- Sample Reading Materials
INSERT INTO reading_materials (type, content, audio_path, level, created_by) VALUES 
('word', 'Buku', 'buku.mp3', 1, 2),
('word', 'Bola', 'bola.mp3', 1, 2),
('word', 'Meja', 'meja.mp3', 1, 2),
('2_words', 'Budi Baca', 'budi_baca.mp3', 2, 2),
('2_words', 'Susi Main', 'susi_main.mp3', 2, 2),
('sentence', 'Saya suka makan apel', 'sentence1.mp3', 3, 2),
('sentence', 'Ayah pergi ke kantor', 'sentence2.mp3', 3, 2);

-- Sample Writing Materials
INSERT INTO writing_materials (content, guideline_image, level, created_by) VALUES 
('A', 'a_guide.png', 1, 2),
('B', 'b_guide.png', 1, 2),
('C', 'c_guide.png', 1, 2),
('D', 'd_guide.png', 1, 2),
('E', 'e_guide.png', 1, 2);

-- Sample Math Materials
INSERT INTO math_materials (operand1, operand2, operation, explanation, level, created_by) VALUES 
(2, 1, '+', 'Dua ditambah satu', 1, 2),
(3, 2, '+', 'Tiga ditambah dua', 1, 2),
(4, 3, '+', 'Empat ditambah tiga', 2, 2),
(5, 5, '+', 'Lima ditambah lima', 3, 2);
