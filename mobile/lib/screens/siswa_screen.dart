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
      if (result['success']) {
        setState(() => detailData = result['data']);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
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

                      // Card statistik
                      const Text(
                        'Statistik',
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
                        'Riwayat 5 Sesi Terakhir',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (detailData!['sesi_terakhir'].isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Belum ada sesi'),
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