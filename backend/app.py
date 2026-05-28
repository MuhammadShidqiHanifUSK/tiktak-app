from flask import Flask
from flask_cors import CORS
from flask_socketio import SocketIO
from database import init_db

app = Flask(__name__)
app.config['SECRET_KEY'] = 'tiktak-secret-key'
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# Inisialisasi database saat app pertama jalan
init_db()

@app.route('/')
def index():
  return {'message': 'TikTak API berjalan! 🕐'}

if __name__ == '__main__':
  socketio.run(app, debug=True, host='0.0.0.0', port=5000)