import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'siswa_screen.dart';

class KelasScreen extends StatefulWidget {
  final Map<String, dynamic> kelas;

  const KelasScreen({super.key, required this.kelas});

  @override
  State<KelasScreen> createState() => _KelasScreenState();
}

class _KelasScreenState extends State<KelasScreen> {
  List<dynamic> siswaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService.getSiswa(widget.kelas['id']);
      if (result['success']) {
        setState(() => siswaList = result['data']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data siswa!')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _tambahSiswa() async {
    final namaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Siswa'),
        content: TextField(
          controller: namaController,
          decoration: const InputDecoration(
            labelText: 'Nama Siswa',
            hintText: 'contoh: Budi Santoso',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.isEmpty) return;
              await ApiService.addSiswa(
                widget.kelas['id'],
                namaController.text,
              );
              if (mounted) Navigator.pop(context);
              _loadSiswa();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusSiswa(int siswaId) async {
    await ApiService.deleteSiswa(siswaId);
    _loadSiswa();
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
          widget.kelas['nama_kelas'],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : siswaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada siswa',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _tambahSiswa,
                        child: const Text('Tambah Siswa Pertama'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSiswa,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = siswaList[index];
                      final akurasi = siswa['total_soal'] > 0
                          ? (siswa['total_benar'] / siswa['total_soal'] * 100)
                              .toStringAsFixed(1)
                          : '0.0';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor:
                                _getLevelColor(siswa['level_kemampuan']),
                            child: Text(
                              siswa['nama'][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            siswa['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(
                                          siswa['level_kemampuan']),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getLevelLabel(siswa['level_kemampuan']),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Akurasi: $akurasi%'),
                                ],
                              ),
                              Text(
                                  '${siswa['total_benar']}/${siswa['total_soal']} soal benar'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.bar_chart,
                                    color: Color(0xFF1A237E)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SiswaScreen(siswa: siswa),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => _hapusSiswa(siswa['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahSiswa,
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}