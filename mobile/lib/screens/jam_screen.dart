import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/api_service.dart';

class JamScreen extends StatefulWidget {
  final Map<String, dynamic> siswa;
  final Map<String, dynamic> soal;

  const JamScreen({super.key, required this.siswa, required this.soal});

  @override
  State<JamScreen> createState() => _JamScreenState();
}

class _JamScreenState extends State<JamScreen> {
  double _jamAngle = 0;
  double _menitAngle = 0;
  int _jumlahKoreksi = 0;
  int _jumlahUlangAudio = 0;
  DateTime? _startTime;
  bool _sudahSubmit = false;
  bool _audioDiputar = false;
  bool _sedangBerbicara = false;

  static const _ttsChannel = MethodChannel('com.tiktak/tts');

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _ttsChannel.invokeMethod('setup', {'language': 'id-ID', 'rate': 0.45});
    } catch (e) {
      // TTS tidak tersedia, lanjut tanpa suara
    }
  }

  @override
  void dispose() {
    _stopTts();
    super.dispose();
  }

  Future<void> _stopTts() async {
    try {
      await _ttsChannel.invokeMethod('stop');
    } catch (e) {
      // ignore
    }
  }

  int get _jamValue => ((_jamAngle / (2 * math.pi)) * 12).round() % 12;
  int get _menitValue => ((_menitAngle / (2 * math.pi)) * 60).round() % 60;

  Future<void> _putarAudio() async {
    setState(() {
      _jumlahUlangAudio++;
      _audioDiputar = true;
      _sedangBerbicara = true;
    });
    try {
      await _ttsChannel.invokeMethod('speak', {'text': widget.soal['cerita']});
    } catch (e) {
      // TTS tidak tersedia
    } finally {
      setState(() => _sedangBerbicara = false);
    }
  }

  Future<void> _submitJawaban() async {
    if (_sudahSubmit) return;
    if (!_audioDiputar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Putar cerita dulu sebelum menjawab!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _stopTts();

    final waktuRespons =
        DateTime.now().difference(_startTime!).inSeconds.toDouble();

    setState(() => _sudahSubmit = true);

    final result = await ApiService.submitJawaban(
      siswaId: widget.siswa['id'],
      soalId: widget.soal['id'],
      jawabanJam: _jamValue,
      jawabanMenit: _menitValue,
      waktuRespons: waktuRespons,
      jumlahKoreksi: _jumlahKoreksi,
      jumlahUlangAudio: _jumlahUlangAudio,
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            result['adalah_benar'] ? '🎉 Benar!' : '❌ Kurang Tepat!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: result['adalah_benar'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result['adalah_benar']
                    ? 'Hebat! Kamu menyimak dengan baik!'
                    : 'Yuk coba lagi, dengarkan ceritanya baik-baik!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Level sekarang: ${result['level_sekarang']}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Text(
          widget.siswa['nama'],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Dengarkan cerita lalu tunjukkan waktunya!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _sedangBerbicara ? null : _putarAudio,
                      icon: Icon(
                        _sedangBerbicara ? Icons.volume_up : Icons.play_circle,
                        size: 28,
                      ),
                      label: Text(
                        _sedangBerbicara
                            ? 'Sedang diputar...'
                            : _audioDiputar
                                ? 'Putar Ulang ($_jumlahUlangAudio)'
                                : 'Putar Cerita',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sedangBerbicara
                            ? Colors.grey
                            : const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gerakkan jarum jam sesuai cerita!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sentuh dan geser jarum pada jam',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 280,
              height: 280,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  final center = Offset(size.width / 2, size.height / 2);
                  final radius = size.width / 2;
                  return GestureDetector(
                    onPanUpdate: (details) {
                      final angle = math.atan2(
                            details.localPosition.dy - center.dy,
                            details.localPosition.dx - center.dx,
                          ) +
                          math.pi / 2;
                      final normalizedAngle =
                          angle < 0 ? angle + 2 * math.pi : angle;
                      final jamX =
                          center.dx + (radius * 0.5) * math.sin(_jamAngle);
                      final jamY =
                          center.dy - (radius * 0.5) * math.cos(_jamAngle);
                      final menitX =
                          center.dx + (radius * 0.75) * math.sin(_menitAngle);
                      final menitY =
                          center.dy - (radius * 0.75) * math.cos(_menitAngle);
                      final distJam = math.sqrt(
                        math.pow(details.localPosition.dx - jamX, 2) +
                            math.pow(details.localPosition.dy - jamY, 2),
                      );
                      final distMenit = math.sqrt(
                        math.pow(details.localPosition.dx - menitX, 2) +
                            math.pow(details.localPosition.dy - menitY, 2),
                      );
                      setState(() {
                        if (distJam < distMenit) {
                          _jamAngle = normalizedAngle;
                        } else {
                          _menitAngle = normalizedAngle;
                        }
                        _jumlahKoreksi++;
                      });
                    },
                    child: CustomPaint(
                      painter: ClockPainter(
                        jamAngle: _jamAngle,
                        menitAngle: _menitAngle,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 4, color: const Color(0xFF1A237E)),
                const SizedBox(width: 4),
                const Text('Jarum Jam  ', style: TextStyle(fontSize: 12)),
                Container(width: 20, height: 4, color: Colors.red),
                const SizedBox(width: 4),
                const Text('Jarum Menit', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sudahSubmit ? null : _submitJawaban,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kumpulkan Jawaban',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double jamAngle;
  final double menitAngle;

  ClockPainter({required this.jamAngle, required this.menitAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(center, radius,
        Paint()
          ..color = const Color(0xFF1A237E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final x = center.dx + (radius - 24) * math.cos(angle);
      final y = center.dy + (radius - 24) * math.sin(angle);
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final innerRadius = i % 5 == 0 ? radius - 12 : radius - 8;
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(angle),
            center.dy + innerRadius * math.sin(angle)),
        Offset(center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle)),
        Paint()
          ..color = Colors.black
          ..strokeWidth = i % 5 == 0 ? 2 : 1,
      );
    }

    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.5) * math.sin(jamAngle),
        center.dy - (radius * 0.5) * math.cos(jamAngle),
      ),
      Paint()
        ..color = const Color(0xFF1A237E)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.75) * math.sin(menitAngle),
        center.dy - (radius * 0.75) * math.cos(menitAngle),
      ),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF1A237E));
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true;
}[]