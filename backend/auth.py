from flask import Blueprint, request, jsonify
from database import get_db
import hashlib

auth_bp = Blueprint('auth', __name__)

def hash_password(password):
  return hashlib.sha256(password.encode()).hexdigest()

# Register guru
@auth_bp.route('/register', methods=['POST'])
def register():
  data = request.get_json()
  nama = data.get('nama')
  email = data.get('email')
  password = data.get('password')

  if not nama or not email or not password:
    return jsonify({'success': False, 'message': 'Semua field harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()

  # Cek email sudah ada belum
  cursor.execute('SELECT id FROM guru WHERE email = ?', (email,))
  existing = cursor.fetchone()
  if existing:
    conn.close()
    return jsonify({'success': False, 'message': 'Email sudah terdaftar!'}), 400

  # Simpan guru baru
  cursor.execute(
    'INSERT INTO guru (nama, email, password) VALUES (?, ?, ?)',
    (nama, email, hash_password(password))
  )
  conn.commit()
  conn.close()

  return jsonify({'success': True, 'message': 'Registrasi berhasil!'}), 201

# Login guru
@auth_bp.route('/login', methods=['POST'])
def login():
  data = request.get_json()
  email = data.get('email')
  password = data.get('password')

  if not email or not password:
    return jsonify({'success': False, 'message': 'Email dan password harus diisi!'}), 400

  conn = get_db()
  cursor = conn.cursor()

  cursor.execute(
    'SELECT id, nama, email FROM guru WHERE email = ? AND password = ?',
    (email, hash_password(password))
  )
  guru = cursor.fetchone()
  conn.close()

  if not guru:
    return jsonify({'success': False, 'message': 'Email atau password salah!'}), 401

  return jsonify({
    'success': True,
    'message': 'Login berhasil!',
    'data': {
        'id': guru['id'],
        'nama': guru['nama'],
        'email': guru['email']
    }
  }), 200