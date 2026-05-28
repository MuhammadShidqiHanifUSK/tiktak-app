from flask import Blueprint, request, jsonify
from database import get_db

siswa_bp = Blueprint('siswa', __name__)

# Ambil semua siswa dalam kelas
@siswa_bp.route('/', methods=['GET'])
def get_siswa():
  kelas_id = request.args.get('kelas_id')
  if not kelas_id:
    return jsonify({'success': False, 'message': 'kelas_id harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()
  cursor.execute('SELECT * FROM siswa WHERE kelas_id = ?', (kelas_id,))
  rows = cursor.fetchall()
  conn.close()

  return jsonify({
    'success': True,
    'data': [dict(row) for row in rows]
  }), 200

# Tambah siswa baru
@siswa_bp.route('/', methods=['POST'])
def add_siswa():
  data = request.get_json()
  kelas_id = data.get('kelas_id')
  nama = data.get('nama')

  if not kelas_id or not nama:
    return jsonify({'success': False, 'message': 'Semua field harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()
  cursor.execute(
    'INSERT INTO siswa (kelas_id, nama) VALUES (?, ?)',
    (kelas_id, nama)
  )
  conn.commit()
  siswa_id = cursor.lastrowid
  conn.close()

  return jsonify({'success': True, 'message': 'Siswa berhasil ditambahkan!', 'id': siswa_id}), 201

# Update level kemampuan siswa
@siswa_bp.route('/<int:siswa_id>/level', methods=['PUT'])
def update_level(siswa_id):
  data = request.get_json()
  level = data.get('level_kemampuan')

  if not level:
    return jsonify({'success': False, 'message': 'level_kemampuan harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()
  cursor.execute(
    'UPDATE siswa SET level_kemampuan = ? WHERE id = ?',
    (level, siswa_id)
  )
  conn.commit()
  conn.close()

  return jsonify({'success': True, 'message': 'Level siswa berhasil diupdate!'}), 200

# Hapus siswa
@siswa_bp.route('/<int:siswa_id>', methods=['DELETE'])
def delete_siswa(siswa_id):
  conn = get_db()
  cursor = conn.cursor()
  cursor.execute('DELETE FROM siswa WHERE id = ?', (siswa_id,))
  conn.commit()
  conn.close()

  return jsonify({'success': True, 'message': 'Siswa berhasil dihapus!'}), 200