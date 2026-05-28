from flask import Blueprint, request, jsonify
from database import get_db

kelas_bp = Blueprint('kelas', __name__)

# Ambil semua kelas milik guru
@kelas_bp.route('/', methods=['GET'])
def get_kelas():
  guru_id = request.args.get('guru_id')
  if not guru_id:
    return jsonify({'success': False, 'message': 'guru_id harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()
  cursor.execute('SELECT * FROM kelas WHERE guru_id = ?', (guru_id,))
  rows = cursor.fetchall()
  conn.close()

  return jsonify({
    'success': True,
    'data': [dict(row) for row in rows]
  }), 200

# Tambah kelas baru
@kelas_bp.route('/', methods=['POST'])
def add_kelas():
  data = request.get_json()
  guru_id = data.get('guru_id')
  nama_kelas = data.get('nama_kelas')
  tingkatan = data.get('tingkatan')

  if not guru_id or not nama_kelas or not tingkatan:
    return jsonify({'success': False, 'message': 'Semua field harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()
  cursor.execute(
    'INSERT INTO kelas (guru_id, nama_kelas, tingkatan) VALUES (?, ?, ?)',
    (guru_id, nama_kelas, tingkatan)
  )
  conn.commit()
  kelas_id = cursor.lastrowid
  conn.close()

  return jsonify({'success': True, 'message': 'Kelas berhasil ditambahkan!', 'id': kelas_id}), 201

# Hapus kelas
@kelas_bp.route('/<int:kelas_id>', methods=['DELETE'])
def delete_kelas(kelas_id):
  conn = get_db()
  cursor = conn.cursor()
  cursor.execute('DELETE FROM kelas WHERE id = ?', (kelas_id,))
  conn.commit()
  conn.close()

  return jsonify({'success': True, 'message': 'Kelas berhasil dihapus!'}), 200