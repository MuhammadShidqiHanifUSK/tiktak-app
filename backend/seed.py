from database import get_db, init_db
import hashlib
import os

def hash_password(password):
  return hashlib.sha256(password.encode()).hexdigest()

def seed():
  # Hapus database lama dulu
  db_path = os.path.join(os.path.dirname(__file__), 'tiktak.db')
  if os.path.exists(db_path):
    os.remove(db_path)
    print("Database lama dihapus!")

  # Buat ulang database
  init_db()

  conn = get_db()
  cursor = conn.cursor()

  # Seed guru
  cursor.execute(
    'INSERT INTO guru (nama, email, password) VALUES (?, ?, ?)',
    ('Hanif', 'hanif@gmail.com', hash_password('hanif123'))
  )
  print("✅ Guru ditambahkan!")

  # Seed kelas
  cursor.execute(
    'INSERT INTO kelas (guru_id, nama_kelas, tingkatan) VALUES (?, ?, ?)',
    (1, 'Kelas 3A', '3')
  )
  print("✅ Kelas ditambahkan!")

  # Seed siswa
  siswa_list = ['Budi Santoso', 'Ani Rahayu', 'Cici Permata']
  for nama in siswa_list:
    cursor.execute(
      'INSERT INTO siswa (kelas_id, nama) VALUES (?, ?)',
      (1, nama)
    )
  print("✅ Siswa ditambahkan!")

  # Seed soal
  soal_list = [
    ('Pak Budi berangkat ke sawah pada pukul 06.30. Tibalah mereka di sawah pada pukul 07.00.', 7, 0, 1),
    ('Ani berangkat sekolah pukul 07.15. Ia tiba di sekolah pukul 07.45.', 7, 45, 1),
    ('Kereta berangkat pukul 08.00 dan tiba di stasiun tujuan pukul 09.30.', 9, 30, 2),
  ]
  for cerita, jam, menit, tingkat in soal_list:
    cursor.execute(
      'INSERT INTO soal (cerita, jawaban_jam, jawaban_menit, tingkat_kesulitan) VALUES (?, ?, ?, ?)',
      (cerita, jam, menit, tingkat)
    )
  print("✅ Soal ditambahkan!")

  conn.commit()
  conn.close()
  print("\n🎉 Seed selesai! Database siap dipakai.")

if __name__ == '__main__':
  seed()