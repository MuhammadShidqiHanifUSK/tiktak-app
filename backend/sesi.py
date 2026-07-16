from flask import Blueprint, request, jsonify
from database import get_db

sesi_bp = Blueprint('sesi', __name__)

@sesi_bp.route('/', methods=['POST'])
def submit_jawaban():
    data = request.get_json()
    siswa_id = data.get('siswa_id')
    soal_id = data.get('soal_id')
    jawaban_jam = data.get('jawaban_jam')
    jawaban_menit = data.get('jawaban_menit')
    waktu_respons = data.get('waktu_respons')
    jumlah_koreksi = data.get('jumlah_koreksi', 0)
    jumlah_ulang_audio = data.get('jumlah_ulang_audio', 0)
    jenis_sesi = data.get('jenis_sesi', 'latihan')  # 'pretest' | 'posttest' | 'latihan'

    if not siswa_id or not soal_id or jawaban_jam is None or jawaban_menit is None:
        return jsonify({'success': False, 'message': 'Semua field harus diisi!'}), 400

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('SELECT jawaban_jam, jawaban_menit FROM soal WHERE id = ?', (soal_id,))
    soal = cursor.fetchone()

    if not soal:
        conn.close()
        return jsonify({'success': False, 'message': 'Soal tidak ditemukan!'}), 404

    adalah_benar = 1 if (
        int(jawaban_jam) == soal['jawaban_jam'] and
        int(jawaban_menit) == soal['jawaban_menit']
    ) else 0

    cursor.execute('''
        INSERT INTO sesi (
            siswa_id, soal_id, jawaban_jam, jawaban_menit,
            adalah_benar, waktu_respons, jumlah_koreksi, jumlah_ulang_audio, jenis_sesi
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        siswa_id, soal_id, jawaban_jam, jawaban_menit,
        adalah_benar, waktu_respons, jumlah_koreksi, jumlah_ulang_audio, jenis_sesi
    ))

    # Pretest/posttest tidak mempengaruhi statistik latihan reguler & level adaptif
    if jenis_sesi == 'latihan':
        cursor.execute('''
            UPDATE siswa SET
                total_soal = total_soal + 1,
                total_benar = total_benar + ?
            WHERE id = ?
        ''', (adalah_benar, siswa_id))

        cursor.execute('''
            SELECT total_soal, total_benar, level_kemampuan FROM siswa WHERE id = ?
        ''', (siswa_id,))
        siswa = cursor.fetchone()

        level_baru = siswa['level_kemampuan']
        if siswa['total_soal'] >= 5:
            akurasi = siswa['total_benar'] / siswa['total_soal']
            if akurasi >= 0.8 and level_baru < 3:
                level_baru += 1
            elif akurasi < 0.5 and level_baru > 1:
                level_baru -= 1
            cursor.execute(
                'UPDATE siswa SET level_kemampuan = ? WHERE id = ?',
                (level_baru, siswa_id)
            )
    else:
        cursor.execute('SELECT level_kemampuan FROM siswa WHERE id = ?', (siswa_id,))
        level_baru = cursor.fetchone()['level_kemampuan']

    conn.commit()
    conn.close()

    return jsonify({
        'success': True,
        'adalah_benar': adalah_benar == 1,
        'level_sekarang': level_baru,
        'jenis_sesi': jenis_sesi,
        'message': 'Jawaban benar! 🎉' if adalah_benar else 'Jawaban salah, coba lagi!'
    }), 201

@sesi_bp.route('/siswa/<int:siswa_id>', methods=['GET'])
def get_riwayat(siswa_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('''
        SELECT s.*, sq.cerita, sq.jawaban_jam as benar_jam, sq.jawaban_menit as benar_menit
        FROM sesi s
        JOIN soal sq ON s.soal_id = sq.id
        WHERE s.siswa_id = ?
        ORDER BY s.created_at DESC
    ''', (siswa_id,))
    rows = cursor.fetchall()
    conn.close()

    return jsonify({'success': True, 'data': [dict(row) for row in rows]}), 200

@sesi_bp.route('/pretest-posttest/<int:siswa_id>', methods=['GET'])
def get_pretest_posttest(siswa_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute('''
        SELECT s.*, sq.cerita, sq.jawaban_jam as benar_jam, sq.jawaban_menit as benar_menit
        FROM sesi s
        JOIN soal sq ON s.soal_id = sq.id
        WHERE s.siswa_id = ? AND s.jenis_sesi = 'pretest'
        ORDER BY s.created_at DESC
        LIMIT 1
    ''', (siswa_id,))
    pretest_row = cursor.fetchone()

    cursor.execute('''
        SELECT s.*, sq.cerita, sq.jawaban_jam as benar_jam, sq.jawaban_menit as benar_menit
        FROM sesi s
        JOIN soal sq ON s.soal_id = sq.id
        WHERE s.siswa_id = ? AND s.jenis_sesi = 'posttest'
        ORDER BY s.created_at DESC
        LIMIT 1
    ''', (siswa_id,))
    posttest_row = cursor.fetchone()

    conn.close()

    return jsonify({
        'success': True,
        'data': {
            'pretest': dict(pretest_row) if pretest_row else None,
            'posttest': dict(posttest_row) if posttest_row else None,
        }
    }), 200