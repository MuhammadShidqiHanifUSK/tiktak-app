from flask import Blueprint, request, jsonify
from database import get_db, generate_kode_kelas

kelas_bp = Blueprint('kelas', __name__)

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

    return jsonify({'success': True, 'data': [dict(row) for row in rows]}), 200

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

    while True:
        kode = generate_kode_kelas()
        cursor.execute('SELECT id FROM kelas WHERE kode_kelas = ?', (kode,))
        if not cursor.fetchone():
            break

    cursor.execute(
        'INSERT INTO kelas (guru_id, nama_kelas, tingkatan, kode_kelas) VALUES (?, ?, ?, ?)',
        (guru_id, nama_kelas, tingkatan, kode)
    )
    conn.commit()
    kelas_id = cursor.lastrowid
    conn.close()

    return jsonify({
        'success': True,
        'message': 'Kelas berhasil ditambahkan!',
        'id': kelas_id,
        'kode_kelas': kode
    }), 201

@kelas_bp.route('/<int:kelas_id>', methods=['DELETE'])
def delete_kelas(kelas_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM kelas WHERE id = ?', (kelas_id,))
    conn.commit()
    conn.close()

    return jsonify({'success': True, 'message': 'Kelas berhasil dihapus!'}), 200

# Endpoint baru khusus siswa: cari kelas berdasarkan kode
@kelas_bp.route('/kode/<string:kode>', methods=['GET'])
def get_kelas_by_kode(kode):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM kelas WHERE kode_kelas = ?', (kode.upper(),))
    row = cursor.fetchone()
    conn.close()

    if not row:
        return jsonify({'success': False, 'message': 'Kode kelas tidak ditemukan!'}), 404

    return jsonify({'success': True, 'data': dict(row)}), 200