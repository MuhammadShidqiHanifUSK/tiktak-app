import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/session.dart';
import 'kelas_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> kelasList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService.getKelas(Session.guruId!);
      if (result['success']) {
        setState(() => kelasList = result['data']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data kelas!')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _tambahKelas() async {
    final namaController = TextEditingController();
    final tingkatanController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kelas Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kelas',
                hintText: 'contoh: Kelas 3A',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tingkatanController,
              decoration: const InputDecoration(
                labelText: 'Tingkatan',
                hintText: 'contoh: 3',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.isEmpty ||
                  tingkatanController.text.isEmpty) return;
              await ApiService.addKelas(
                Session.guruId!,
                namaController.text,
                tingkatanController.text,
              );
              if (mounted) Navigator.pop(context);
              _loadKelas();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusKelas(int kelasId) async {
    await ApiService.deleteKelas(kelasId);
    _loadKelas();
  }

  void _logout() {
    Session.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TikTak',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Halo, ${Session.guruNama}!',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kelasList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.class_outlined,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada kelas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _tambahKelas,
                        child: const Text('Tambah Kelas Pertama'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadKelas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kelasList.length,
                    itemBuilder: (context, index) {
                      final kelas = kelasList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1A237E),
                            child: Text(
                              kelas['tingkatan'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            kelas['nama_kelas'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Text('Tingkat ${kelas['tingkatan']}  •  '),
                              const Icon(Icons.vpn_key, size: 14, color: Color(0xFF1A237E)),
                              const SizedBox(width: 2),
                              Text(
                                kelas['kode_kelas'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.people,
                                    color: Color(0xFF1A237E)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          KelasScreen(kelas: kelas),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => _hapusKelas(kelas['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahKelas,
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}