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
  final Color warna;

  _StepData(this.emoji, this.judul, this.isi, this.warna);
}

class _MateriScreenState extends State<MateriScreen> {
  int _step = 0;

  final List<_StepData> _steps = [
    _StepData(
      '📖',
      'Ayo Mengenal Teks Narasi!',
      'Teks narasi adalah cerita yang menceritakan urutan kejadian, seperti kegiatan sehari-hari.\n\n'
          'Contoh: "Pak Budi berangkat ke sawah pukul 06.30. Ia tiba di sawah pukul 07.00."\n\n'
          'Di dalam cerita, sering ada informasi tentang WAKTU. Nah, kita akan belajar menemukan informasi waktu itu sambil membaca jam analog!',
      Color(0xFFE3F2FD),
    ),
    _StepData(
      '🤔',
      'Yuk, Kita Pikirkan Bersama!',
      'Coba pikirkan pertanyaan ini:\n\n'
          '"Kalau ada orang berangkat sekolah pukul 07.15, dan sampai 30 menit kemudian, jam berapa dia sampai di sekolah?"\n\n'
          'Diskusikan dengan pasanganmu! Bagaimana cara kalian menemukan jawabannya?',
      Color(0xFFFFF3E0),
    ),
    _StepData(
      '👫',
      'Waktunya Kerja Berpasangan! (LKPD)',
      'Sekarang, bersama pasanganmu:\n\n'
          '1️⃣ Dengarkan cerita yang akan dibacakan guru\n'
          '2️⃣ Catat informasi WAKTU yang kalian dengar di LKPD\n'
          '3️⃣ Diskusikan bersama pasangan, tentukan jawabannya\n'
          '4️⃣ Coba praktikkan di jam analog TikTak\n\n'
          'Contoh soal untuk kalian diskusikan:\n'
          '"Salsa makan siang pukul 12.00 selama 25 menit. Pukul berapa Salsa selesai makan?"\n\n'
          'Tuliskan jawaban kelompok kalian di kertas LKPD ya!',
      Color(0xFFE8F5E9),
    ),
    _StepData(
      '🔍',
      'Buktikan Jawabanmu!',
      'Setelah berdiskusi, coba putar jarum jam analog sesuai jawaban kelompok kalian.\n\n'
          'Perhatikan: apakah jawabannya sudah tepat? Kalau masih ragu, dengarkan lagi ceritanya, lalu coba sekali lagi bersama pasanganmu.',
      Color(0xFFFCE4EC),
    ),
    _StepData(
      '🎤',
      'Ceritakan ke Teman-teman!',
      'Setiap kelompok akan maju ke depan kelas untuk:\n\n'
          '• Menceritakan kembali isi cerita yang disimak\n'
          '• Menjelaskan bagaimana kelompok kalian menemukan jawabannya\n\n'
          'Setelah semua kelompok presentasi, kita simpulkan bersama apa yang sudah kita pelajari hari ini!',
      Color(0xFFF3E5F5),
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
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            Row(
              children: List.generate(_steps.length, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: step.warna,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.emoji, style: const TextStyle(fontSize: 50)),
                      const SizedBox(height: 12),
                      Text(
                        step.judul,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.isi,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prev,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Kembali', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _step < _steps.length - 1 ? 'Lanjut ➡️' : 'Selesai ✅',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}