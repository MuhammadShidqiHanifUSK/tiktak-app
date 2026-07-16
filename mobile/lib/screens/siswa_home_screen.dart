import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/siswa_session.dart';
import 'jam_screen.dart';
import 'materi_screen.dart';
import 'welcome_screen.dart';

class SiswaHomeScreen extends StatefulWidget {
  const SiswaHomeScreen({super.key});

  @override
  State<SiswaHomeScreen> createState() => _SiswaHomeScreenState();
}

class _SiswaHomeScreenState extends State<SiswaHomeScreen> {
  bool _isLoadingSoal = false;

  Future<Map<String, dynamic>?> _ambilSoal() async {
    setState(() => _isLoadingSoal = true);
    try {
      final result = await ApiService.getSoalEvaluasi();
      setState(() => _isLoadingSoal = false);
      if (result['success']) {
        return result['data'];
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Soal evaluasi belum tersedia!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      setState(() => _isLoadingSoal = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal terhubung ke server: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _mulaiPretest() async {
    final soal = await _ambilSoal();
    if (soal == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JamScreen(
          siswa: {'id': SiswaSession.siswaId, 'nama': SiswaSession.namaSiswa},
          soal: soal,
          jenisSesi: 'pretest',
          onSelesai: () => setState(() => SiswaSession.pretestDone = true),
        ),
      ),
    );
  }

  void _mulaiMateri() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateriScreen(
          onSelesai: () => setState(() => SiswaSession.materiDone = true),
        ),
      ),
    );
  }

  Future<void> _mulaiPosttest() async {
    final soal = await _ambilSoal();
    if (soal == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JamScreen(
          siswa: {'id': SiswaSession.siswaId, 'nama': SiswaSession.namaSiswa},
          soal: soal,
          jenisSesi: 'posttest',
          onSelesai: () => setState(() => SiswaSession.posttestDone = true),
        ),
      ),
    );
  }

  void _keluar() {
    SiswaSession.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        automaticallyImplyLeading: false,
        title: Text('Hai, ${SiswaSession.namaSiswa}! 👋',
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _keluar,
          ),
        ],
      ),
      body: _isLoadingSoal
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Ayo Belajar Jam! ⏰',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 24),
                  _StageCard(
                    emoji: '📝',
                    judul: '1. Pretest',
                    subtitle: 'Yuk coba dulu kemampuanmu!',
                    warna: const Color(0xFFBBDEFB),
                    selesai: SiswaSession.pretestDone,
                    terkunci: false,
                    onTap: _mulaiPretest,
                  ),
                  const SizedBox(height: 16),
                  _StageCard(
                    emoji: '📚',
                    judul: '2. Materi & Latihan',
                    subtitle: 'Belajar bareng teman sekelompok',
                    warna: const Color(0xFFC8E6C9),
                    selesai: SiswaSession.materiDone,
                    terkunci: !SiswaSession.pretestDone,
                    onTap: _mulaiMateri,
                  ),
                  const SizedBox(height: 16),
                  _StageCard(
                    emoji: '✅',
                    judul: '3. Posttest',
                    subtitle: 'Tunjukkan hasil belajarmu!',
                    warna: const Color(0xFFFFE0B2),
                    selesai: SiswaSession.posttestDone,
                    terkunci: !SiswaSession.materiDone,
                    onTap: _mulaiPosttest,
                  ),
                  if (SiswaSession.posttestDone) ...[
                    const SizedBox(height: 24),
                    const Text('🎉', style: TextStyle(fontSize: 50)),
                    const Text(
                      'Selamat! Kamu sudah menyelesaikan semua tahap!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final String emoji;
  final String judul;
  final String subtitle;
  final Color warna;
  final bool selesai;
  final bool terkunci;
  final VoidCallback onTap;

  const _StageCard({
    required this.emoji,
    required this.judul,
    required this.subtitle,
    required this.warna,
    required this.selesai,
    required this.terkunci,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: terkunci ? 0.5 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: terkunci ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: warna,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              if (terkunci)
                const Icon(Icons.lock, color: Colors.black38)
              else if (selesai)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}