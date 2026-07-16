import 'package:flutter/material.dart';

class MateriScreen extends StatefulWidget {
  final VoidCallback onSelesai;

  const MateriScreen({super.key, required this.onSelesai});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _StepData {
  final String emoji;
  final String judul;
  final String isi;
  final Color warnaMuda;
  final Color warnaTua;

  _StepData(this.emoji, this.judul, this.isi, this.warnaMuda, this.warnaTua);
}

class _MateriScreenState extends State<MateriScreen> {
  int _step = 0;

  final List<_StepData> _steps = [
    _StepData(
      '📖',
      'Ayo Mengenal\nTeks Narasi!',
      'Teks narasi adalah teks yang menceritakan suatu peristiwa atau kejadian secara beruntun dan mendetail (dari awal, tengah, hingga akhir) dengan urutan waktu atau bersifat kronologis.\n\n'
      'Tujuan dari teks ini adalah untuk menceritakan kepada pembaca seolah-olah mereka sedang berada di dalam cerita tersebut atau sedang mengalami hal tersebut dan untuk menambah wawasan pembaca\n\n'
          'Contoh:\n"Pak Budi berangkat ke sawah pukul 06.30. Ia tiba di sawah pukul 07.00."\n\n'
          'Di dalam cerita, sering ada info tentang WAKTU. Yuk kita cari sambil belajar jam! 🕐',
      Color(0xFFBBDEFB),
      Color(0xFF1565C0),
    ),
    _StepData(
      '📖',
      'Ciri-Ciri Teks Narasi',
        '1. Berisi peristiwa, baik yang nyata, imajinasi, maupun gabungan dari keduanya\n'
        '2. Terdiri atas beberaoa paragraf yang tiap-tiap paragraf menitikberatkan pada perbuatan/peristiwa\n'
        '3. Disusun berdasarkan kronologi atau urutan waktu yang di dalamnya terdapat konflik',
      Color(0xFFBBDEFB),
      Color(0xFF1565C0),
    ),
    _StepData(
      '📖',
      'Struktur Teks Narasi',
        '1. Tema atau gagasan pokok\n'
        'Misalnya: Pertemanan, keluarga, pengalaman\n'
        '2. Latar (tempat dan waktu)\n'
        '3. Alur atau pola penyampaian peristiwa dalam cerita.\n'
        'Alur ini bisa maju, mundur, maupun maju mundur.\n'
        '4. Tokoh atau karakter yang ada dalam cerita\n'
        '5. Sudut pandang atau arah pandangan.',
      Color(0xFFBBDEFB),
      Color(0xFF1565C0),
    ),
    _StepData(
      '🤔',
      'Yuk, Kita\nPikirkan Bersama!',
      'Coba pikirkan pertanyaan ini bersama teman:\n\n'
          '"Kalau ada yang berangkat sekolah pukul 07.15, dan sampai 30 menit kemudian, jam berapa dia sampai di sekolah?"\n\n'
          'Diskusikan dengan pasanganmu! Gimana caranya menemukan jawabannya? 💬',
      Color(0xFFFFE0B2),
      Color(0xFFE65100),
    ),
    _StepData(
      '💡',
      'Waktunya Diskusi!\nAyo dengarkan instruksi dari guru.',
      '1️⃣ Dengarkan cerita dari guru\n\n'
          '2️⃣ Catat info WAKTU yang kalian dengar di LKPD\n\n'
          '3️⃣ Diskusikan bersama pasangan\n\n'
          '4️⃣ Praktikkan di jam analog TikTak\n\n',
      Color(0xFFC8E6C9),
      Color(0xFF2E7D32),
    ),
    _StepData(
      '🔍',
      'Buktikan\nJawabanmu!',
      'Setelah berdiskusi, coba putar jarum jam sesuai jawaban kelompok kalian.\n\n'
          'Perhatikan baik-baik: apakah jawabannya sudah tepat?\n\n'
          'Kalau masih ragu, dengarkan lagi ceritanya, lalu coba sekali lagi bersama pasanganmu! 💪',
      Color(0xFFF8BBD0),
      Color(0xFFAD1457),
    ),
    _StepData(
      '🎤',
      'Ceritakan ke\nTeman-teman!',
      'Setiap kelompok maju ke depan kelas untuk:\n\n'
          '• Menceritakan kembali isi cerita yang disimak\n\n'
          '• Menjelaskan cara kelompok kalian menemukan jawabannya\n\n'
          'Setelah semua presentasi, kita simpulkan bersama yuk apa yang sudah kita pelajari! 🌟',
      Color(0xFFE1BEE7),
      Color(0xFF6A1B9A),
    ),
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      widget.onSelesai();
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('Materi & Latihan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            children: [
              // Progress indicator berupa titik bulat
              Row(
                children: List.generate(_steps.length, (i) {
                  final aktif = i <= _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 10,
                      decoration: BoxDecoration(
                        color: aktif ? step.warnaTua : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Langkah ${_step + 1} dari ${_steps.length}',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Kartu materi
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: step.warnaMuda,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: step.warnaTua.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: step.warnaTua.withOpacity(0.2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(step.emoji,
                                style: const TextStyle(fontSize: 56)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          step.judul,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: step.warnaTua,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            step.isi,
                            style: const TextStyle(
                              fontSize: 16.5,
                              height: 1.7,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol navigasi
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _prev,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Kembali',
                            style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A237E),
                          side: const BorderSide(
                              color: Color(0xFF1A237E), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _next,
                      icon: Icon(_step < _steps.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_outline),
                      label: Text(
                        _step < _steps.length - 1 ? 'Lanjut' : 'Selesai',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: step.warnaTua,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}