from flask import Flask
from flask_cors import CORS
from flask_socketio import SocketIO
from database import init_db
from auth import auth_bp
from kelas import kelas_bp
from siswa import siswa_bp
from soal import soal_bp

app = Flask(__name__)
app.config['SECRET_KEY'] = 'tiktak-secret-key'
CORS(app)
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(kelas_bp, url_prefix='/api/kelas')
app.register_blueprint(siswa_bp, url_prefix='/api/siswa')
app.register_blueprint(soal_bp, url_prefix='/api/soal')
socketio = SocketIO(app, cors_allowed_origins="*")

# Inisialisasi database saat app pertama jalan
init_db()

@app.route('/')
def index():
  return {'message': 'TikTak API berjalan! 🕐'}

if __name__ == '__main__':
  socketio.run(app, debug=True, host='0.0.0.0', port=5000)