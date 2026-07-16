import sqlite3
import os
import random
import string

DB_PATH = os.path.join(os.path.dirname(__file__), 'tiktak.db')

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def generate_kode_kelas():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def init_db():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS guru (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS kelas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guru_id INTEGER NOT NULL,
            nama_kelas TEXT NOT NULL,
            tingkatan TEXT NOT NULL,
            kode_kelas TEXT UNIQUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (guru_id) REFERENCES guru(id)
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS siswa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kelas_id INTEGER NOT NULL,
            nama TEXT NOT NULL,
            level_kemampuan INTEGER DEFAULT 1,
            total_soal INTEGER DEFAULT 0,
            total_benar INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (kelas_id) REFERENCES kelas(id)
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS soal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cerita TEXT NOT NULL,
            jawaban_jam INTEGER NOT NULL,
            jawaban_menit INTEGER NOT NULL,
            tingkat_kesulitan INTEGER DEFAULT 1,
            audio_path TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sesi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            siswa_id INTEGER NOT NULL,
            soal_id INTEGER NOT NULL,
            jawaban_jam INTEGER,
            jawaban_menit INTEGER,
            adalah_benar INTEGER DEFAULT 0,
            waktu_respons REAL,
            jumlah_koreksi INTEGER DEFAULT 0,
            jumlah_ulang_audio INTEGER DEFAULT 0,
            jenis_sesi TEXT DEFAULT 'latihan',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (siswa_id) REFERENCES siswa(id),
            FOREIGN KEY (soal_id) REFERENCES soal(id)
        )
    ''')

    conn.commit()

    # ---- Migrasi otomatis untuk database lama yang sudah pernah dibuat ----
    cursor.execute("PRAGMA table_info(kelas)")
    kolom_kelas = [k[1] for k in cursor.fetchall()]
    if 'kode_kelas' not in kolom_kelas:
        cursor.execute('ALTER TABLE kelas ADD COLUMN kode_kelas TEXT')
        # isi kode unik untuk kelas yang sudah ada sebelumnya
        cursor.execute('SELECT id FROM kelas WHERE kode_kelas IS NULL')
        for row in cursor.fetchall():
            while True:
                kode = generate_kode_kelas()
                cursor.execute('SELECT id FROM kelas WHERE kode_kelas = ?', (kode,))
                if not cursor.fetchone():
                    break
            cursor.execute('UPDATE kelas SET kode_kelas = ? WHERE id = ?', (kode, row['id']))
        conn.commit()

    cursor.execute("PRAGMA table_info(sesi)")
    kolom_sesi = [k[1] for k in cursor.fetchall()]
    if 'jenis_sesi' not in kolom_sesi:
        cursor.execute("ALTER TABLE sesi ADD COLUMN jenis_sesi TEXT DEFAULT 'latihan'")
        conn.commit()

    cursor.execute("PRAGMA table_info(soal)")
    kolom_soal = [k[1] for k in cursor.fetchall()]
    if 'jenis' not in kolom_soal:
        cursor.execute("ALTER TABLE soal ADD COLUMN jenis TEXT DEFAULT 'latihan'")
        conn.commit()

    conn.close()
    print("Database TikTak berhasil diinisialisasi!")

if __name__ == '__main__':
    init_db()