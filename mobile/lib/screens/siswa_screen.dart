import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SiswaScreen extends StatefulWidget {
  final Map<String, dynamic> siswa;

  const SiswaScreen({super.key, required this.siswa});

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen> {
  Map<String, dynamic>? detailData;
  Map<String, dynamic>? prePostData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService.getDetailSiswa(widget.siswa['id']);
      final prePost = await ApiService.getPretestPosttest(widget.siswa['id']);
      if (result['success']) {
        setState(() => detailData = result['data']);
      }
      if (prePost['success']) {
        setState(() => prePostData = prePost['data']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail siswa!')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _getLevelLabel(int level) {
    switch (level) {
      case 1: return 'Pemula';
      case 2: return 'Menengah';
      case 3: return 'Mahir';
      default: return 'Pemula';
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Colors.orange;
      case 2: return Colors.blue;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }

  Widget _buildPrePostCard() {
    final pretest = prePostData?['pretest'];
    final posttest = prePostData?['posttest'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.compare_arrows, color: Color(0xFF1A237E)),
                SizedBox(width: 8),
                Text(
                  'Hasil Pretest vs Posttest',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSesiBox('📝 Pretest', pretest, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSesiBox('✅ Posttest', posttest, Colors.green)),
              ],
            ),
            if (pretest != null && posttest != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getKesimpulanWarna(pretest, posttest).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getKesimpulanText(pretest, posttest),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getKesimpulanWarna(pretest, posttest),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSesiBox(String label, Map<String, dynamic>? sesi, Color warna) {
    if (sesi == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Belum dikerjakan', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    final benar = sesi['adalah_benar'] == 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: warna)),
          const SizedBox(height: 8),
          Icon(
            benar ? Icons.check_circle : Icons.cancel,
            color: benar ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            benar ? 'Benar' : 'Salah',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: benar ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jawaban: ${sesi['jawaban_jam']}:${sesi['jawaban_menit'].toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            'Waktu: ${sesi['waktu_respons']}s',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getKesimpulanWarna(Map<String, dynamic> pre, Map<String, dynamic> post) {
    final preBenar = pre['adalah_benar'] == 1;
    final postBenar = post['adalah_benar'] == 1;
    if (!preBenar && postBenar) return Colors.green;
    if (preBenar && !postBenar) return Colors.red;
    return Colors.blueGrey;
  }

  String _getKesimpulanText(Map<String, dynamic> pre, Map<String, dynamic> post) {
    final preBenar = pre['adalah_benar'] == 1;
    final postBenar = post['adalah_benar'] == 1;
    if (!preBenar && postBenar) return '🎉 Ada peningkatan! Siswa berhasil menjawab benar setelah belajar.';
    if (preBenar && !postBenar) return '⚠️ Perlu perhatian, hasil posttest menurun dari pretest.';
    if (preBenar && postBenar) return '✅ Konsisten menjawab benar di kedua tes.';
    return 'ℹ️ Masih perlu bimbingan lebih lanjut di kedua tes.';
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
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : detailData == null
                ? const Center(child: Text('Data tidak ditemukan'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card info siswa
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: _getLevelColor(
                                    detailData!['siswa']['level_kemampuan']),
                                child: Text(
                                  widget.siswa['nama'][0],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.siswa['nama'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(detailData!['siswa']
                                          ['level_kemampuan']),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getLevelLabel(detailData!['siswa']
                                          ['level_kemampuan']),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Pretest vs Posttest (BARU)
                      _buildPrePostCard(),
                      const SizedBox(height: 16),

                      // Card statistik latihan
                      const Text(
                        'Statistik Latihan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _statRow('Total Sesi',
                                  '${detailData!['statistik']['total_sesi']}'),
                              _statRow('Total Benar',
                                  '${detailData!['statistik']['total_benar'] ?? 0}'),
                              _statRow('Rata-rata Waktu Respons',
                                  '${detailData!['statistik']['rata_waktu_respons'] ?? 0} detik'),
                              _statRow('Rata-rata Koreksi',
                                  '${detailData!['statistik']['rata_koreksi'] ?? 0}x'),
                              _statRow('Rata-rata Ulang Audio',
                                  '${detailData!['statistik']['rata_ulang_audio'] ?? 0}x'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Riwayat sesi terakhir
                      const Text(
                        'Riwayat 5 Sesi Latihan Terakhir',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (detailData!['sesi_terakhir'].isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Belum ada sesi latihan'),
                          ),
                        )
                      else
                        ...detailData!['sesi_terakhir'].map<Widget>((sesi) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                sesi['adalah_benar'] == 1
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: sesi['adalah_benar'] == 1
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                'Jawaban: ${sesi['jawaban_jam']}:${sesi['jawaban_menit'].toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Benar: ${sesi['benar_jam']}:${sesi['benar_menit'].toString().padLeft(2, '0')}'),
                                  Text(
                                      'Waktu: ${sesi['waktu_respons']}s | Koreksi: ${sesi['jumlah_koreksi']}x | Ulang: ${sesi['jumlah_ulang_audio']}x'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}