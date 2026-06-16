from flask import Blueprint, request, jsonify
from flask_socketio import emit
from database import get_db
import time

iot_bp = Blueprint('iot', __name__)

# Simpan state jarum jam terkini per siswa
jam_state = {}

@iot_bp.route('/update', methods=['POST'])
def update_jam():
    data = request.get_json()
    siswa_id = data.get('siswa_id')
    soal_id = data.get('soal_id')
    sudut_jam = data.get('sudut_jam', 0)
    sudut_menit = data.get('sudut_menit', 0)
    jam_value = data.get('jam_value', 0)
    menit_value = data.get('menit_value', 0)
    jumlah_koreksi = data.get('jumlah_koreksi', 0)
    mode = data.get('mode', 'jam')

    if not siswa_id:
        return jsonify({'success': False, 'message': 'siswa_id harus diisi!'}), 400

    # Simpan state terkini
    jam_state[siswa_id] = {
        'siswa_id': siswa_id,
        'soal_id': soal_id,
        'sudut_jam': sudut_jam,
        'sudut_menit': sudut_menit,
        'jam_value': jam_value,
        'menit_value': menit_value,
        'jumlah_koreksi': jumlah_koreksi,
        'mode': mode,
        'timestamp': time.time()
    }

    # Broadcast ke semua client via WebSocket
    from app import socketio
    socketio.emit('jam_update', jam_state[siswa_id])

    return jsonify({'success': True}), 200

@iot_bp.route('/state/<int:siswa_id>', methods=['GET'])
def get_state(siswa_id):
    state = jam_state.get(siswa_id)
    if not state:
        return jsonify({
            'success': True,
            'data': {
                'sudut_jam': 0,
                'sudut_menit': 0,
                'jam_value': 0,
                'menit_value': 0,
                'jumlah_koreksi': 0,
                'mode': 'jam'
            }
        }), 200
    return jsonify({'success': True, 'data': state}), 200

@iot_bp.route('/reset', methods=['POST'])
def reset_jam():
    data = request.get_json()
    siswa_id = data.get('siswa_id')

    if siswa_id in jam_state:
        del jam_state[siswa_id]

    from app import socketio
    socketio.emit('jam_reset', {'siswa_id': siswa_id})

    return jsonify({'success': True, 'message': 'Jam berhasil direset!'}), 200