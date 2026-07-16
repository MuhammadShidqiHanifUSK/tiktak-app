from flask import Blueprint, request, jsonify, send_file
from database import get_db
from gtts import gTTS
import os

soal_bp = Blueprint('soal', __name__)

AUDIO_DIR = os.path.join(os.path.dirname(__file__), 'audio')
os.makedirs(AUDIO_DIR, exist_ok=True)

# Ambil soal berdasarkan tingkat kesulitan
@soal_bp.route('/', methods=['GET'])
def get_soal():
    tingkat = request.args.get('tingkat', 1)
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT * FROM soal WHERE tingkat_kesulitan = ? AND jenis = 'latihan' ORDER BY RANDOM() LIMIT 1",
        (tingkat,)
    )
    row = cursor.fetchone()
    conn.close()

    if not row:
        return jsonify({'success': False, 'message': 'Soal tidak ditemukan!'}), 404

    return jsonify({'success': True, 'data': dict(row)}), 200

# Endpoint baru — khusus pretest/posttest
@soal_bp.route('/evaluasi', methods=['GET'])
def get_soal_evaluasi():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT * FROM soal WHERE jenis = 'evaluasi' ORDER BY RANDOM() LIMIT 1"
    )
    row = cursor.fetchone()
    conn.close()

    if not row:
        return jsonify({'success': False, 'message': 'Soal evaluasi belum tersedia!'}), 404

    return jsonify({'success': True, 'data': dict(row)}), 200

@soal_bp.route('/', methods=['POST'])
def add_soal():
    data = request.get_json()
    cerita = data.get('cerita')
    jawaban_jam = data.get('jawaban_jam')
    jawaban_menit = data.get('jawaban_menit')
    tingkat_kesulitan = data.get('tingkat_kesulitan', 1)
    jenis = data.get('jenis', 'latihan')  # 'latihan' | 'evaluasi'

    if not cerita or jawaban_jam is None or jawaban_menit is None:
        return jsonify({'success': False, 'message': 'Semua field harus diisi!'}), 400

    tts = gTTS(text=cerita, lang='id')
    audio_filename = f"soal_{jawaban_jam}_{jawaban_menit}_{tingkat_kesulitan}_{jenis}.mp3"
    audio_path = os.path.join(AUDIO_DIR, audio_filename)
    tts.save(audio_path)

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO soal (cerita, jawaban_jam, jawaban_menit, tingkat_kesulitan, audio_path, jenis) VALUES (?, ?, ?, ?, ?, ?)',
        (cerita, jawaban_jam, jawaban_menit, tingkat_kesulitan, audio_filename, jenis)
    )
    conn.commit()
    soal_id = cursor.lastrowid
    conn.close()

    return jsonify({
        'success': True,
        'message': 'Soal berhasil ditambahkan!',
        'id': soal_id,
        'audio': audio_filename
    }), 201

# Ambil file audio soal
@soal_bp.route('/audio/<filename>', methods=['GET'])
def get_audio(filename):
  audio_path = os.path.join(AUDIO_DIR, filename)
  if not os.path.exists(audio_path):
    return jsonify({'success': False, 'message': 'Audio tidak ditemukan!'}), 404
  return send_file(audio_path, mimetype='audio/mpeg')

# Hapus soal
@soal_bp.route('/<int:soal_id>', methods=['DELETE'])
def delete_soal(soal_id):
  conn = get_db()
  cursor = conn.cursor()
  cursor.execute('SELECT audio_path FROM soal WHERE id = ?', (soal_id,))
  row = cursor.fetchone()

  if row and row['audio_path']:
    audio_path = os.path.join(AUDIO_DIR, row['audio_path'])
    if os.path.exists(audio_path):
      os.remove(audio_path)

  cursor.execute('DELETE FROM soal WHERE id = ?', (soal_id,))
  conn.commit()
  conn.close()

  return jsonify({'success': True, 'message': 'Soal berhasil dihapus!'}), 200