import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'tiktak.db')

def get_db():
  conn = sqlite3.connect(DB_PATH)
  conn.row_factory = sqlite3.Row
  return conn

def init_db():
  conn = get_db()
  cursor = conn.cursor()

  # Tabel guru
  cursor.execute('''
    CREATE TABLE IF NOT EXISTS guru (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ''')

  # Tabel kelas
  cursor.execute('''
    CREATE TABLE IF NOT EXISTS kelas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      guru_id INTEGER NOT NULL,
      nama_kelas TEXT NOT NULL,
      tingkatan TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (guru_id) REFERENCES guru(id)
    )
  ''')

  # Tabel siswa
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

  # Tabel soal
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

  # Tabel sesi belajar
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
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (siswa_id) REFERENCES siswa(id),
      FOREIGN KEY (soal_id) REFERENCES soal(id)
    )
  ''')

  conn.commit()
  conn.close()
  print("Database TikTak berhasil diinisialisasi!")

if __name__ == '__main__':
  init_db()