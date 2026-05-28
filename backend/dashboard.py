from flask import Blueprint, request, jsonify
from database import get_db

dashboard_bp = Blueprint('dashboard', __name__)

# Ringkasan kelas untuk guru
@dashboard_bp.route('/kelas/<int:kelas_id>', methods=['GET'])
def get_ringkasan_kelas(kelas_id):
  conn = get_db()
  cursor = conn.cursor()

  # Total siswa di kelas
  cursor.execute('SELECT COUNT(*) as total FROM siswa WHERE kelas_id = ?', (kelas_id,))
  total_siswa = cursor.fetchone()['total']

  # Data per siswa + performa
  cursor.execute('''
    SELECT
      s.id,
      s.nama,
      s.level_kemampuan,
      s.total_soal,
      s.total_benar,
      CASE
        WHEN s.total_soal = 0 THEN 0
        ELSE ROUND(CAST(s.total_benar AS FLOAT) / s.total_soal * 100, 1)
      END as akurasi_persen
    FROM siswa s
    WHERE s.kelas_id = ?
    ORDER BY akurasi_persen DESC
  ''', (kelas_id,))
  siswa_list = cursor.fetchall()

  conn.close()

  return jsonify({
    'success': True,
    'data': {
      'total_siswa': total_siswa,
      'siswa': [dict(row) for row in siswa_list]
    }
  }), 200

# Detail performa siswa
@dashboard_bp.route('/siswa/<int:siswa_id>', methods=['GET'])
def get_detail_siswa(siswa_id):
  conn = get_db()
  cursor = conn.cursor()

  # Info dasar siswa
  cursor.execute('SELECT * FROM siswa WHERE id = ?', (siswa_id,))
  siswa = cursor.fetchone()
  if not siswa:
    conn.close()
    return jsonify({'success': False, 'message': 'Siswa tidak ditemukan!'}), 404

  # Statistik sesi siswa
  cursor.execute('''
    SELECT
      COUNT(*) as total_sesi,
      SUM(adalah_benar) as total_benar,
      ROUND(AVG(waktu_respons), 1) as rata_waktu_respons,
      ROUND(AVG(jumlah_koreksi), 1) as rata_koreksi,
      ROUND(AVG(jumlah_ulang_audio), 1) as rata_ulang_audio
    FROM sesi
    WHERE siswa_id = ?
  ''', (siswa_id,))
  statistik = cursor.fetchone()

  # 5 sesi terakhir
  cursor.execute('''
    SELECT
      se.id,
      se.adalah_benar,
      se.waktu_respons,
      se.jumlah_koreksi,
      se.jumlah_ulang_audio,
      se.jawaban_jam,
      se.jawaban_menit,
      se.created_at,
      sq.cerita,
      sq.jawaban_jam as benar_jam,
      sq.jawaban_menit as benar_menit,
      sq.tingkat_kesulitan
    FROM sesi se
    JOIN soal sq ON se.soal_id = sq.id
    WHERE se.siswa_id = ?
    ORDER BY se.created_at DESC
    LIMIT 5
  ''', (siswa_id,))
  sesi_terakhir = cursor.fetchall()

  conn.close()

  return jsonify({
    'success': True,
    'data': {
      'siswa': dict(siswa),
      'statistik': dict(statistik),
      'sesi_terakhir': [dict(row) for row in sesi_terakhir]
    }
  }), 200

# Siswa yang perlu perhatian guru (akurasi rendah)
@dashboard_bp.route('/perhatian/<int:kelas_id>', methods=['GET'])
def get_siswa_perhatian(kelas_id):
  conn = get_db()
  cursor = conn.cursor()

  cursor.execute('''
    SELECT
      s.id,
      s.nama,
      s.level_kemampuan,
      s.total_soal,
      s.total_benar,
      ROUND(AVG(se.waktu_respons), 1) as rata_waktu,
      ROUND(AVG(se.jumlah_koreksi), 1) as rata_koreksi,
      ROUND(AVG(se.jumlah_ulang_audio), 1) as rata_ulang,
      CASE
        WHEN s.total_soal = 0 THEN 0
        ELSE ROUND(CAST(s.total_benar AS FLOAT) / s.total_soal * 100, 1)
      END as akurasi_persen
    FROM siswa s
    LEFT JOIN sesi se ON s.id = se.siswa_id
    WHERE s.kelas_id = ? AND s.total_soal >= 3
    GROUP BY s.id
    HAVING akurasi_persen < 50
    ORDER BY akurasi_persen ASC
  ''', (kelas_id,))
  rows = cursor.fetchall()
  conn.close()

  return jsonify({
    'success': True,
    'data': [dict(row) for row in rows]
  }), 200