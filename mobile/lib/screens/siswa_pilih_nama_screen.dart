import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/siswa_session.dart';
import 'siswa_home_screen.dart';

class SiswaPilihNamaScreen extends StatefulWidget {
  final Map<String, dynamic> kelas;

  const SiswaPilihNamaScreen({super.key, required this.kelas});

  @override
  State<SiswaPilihNamaScreen> createState() => _SiswaPilihNamaScreenState();
}

class _SiswaPilihNamaScreenState extends State<SiswaPilihNamaScreen> {
  List<dynamic> siswaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    try {
      final result = await ApiService.getSiswa(widget.kelas['id']);
      if (result['success']) {
        setState(() => siswaList = result['data']);
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _pilihSiswa(Map<String, dynamic> siswa) {
    SiswaSession.login(
      siswaId: siswa['id'],
      namaSiswa: siswa['nama'],
      kelasId: widget.kelas['id'],
      namaKelas: widget.kelas['nama_kelas'],
      levelKemampuan: siswa['level_kemampuan'],
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SiswaHomeScreen()),
    );
  }

  static const List<Color> _warnaAvatar = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
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
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Kamu yang mana? 👋',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E)),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = siswaList[index];
                      final warna = _warnaAvatar[index % _warnaAvatar.length];
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _pilihSiswa(siswa),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: warna,
                                child: Text(
                                  siswa['nama'][0],
                                  style: const TextStyle(
                                      fontSize: 26,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                siswa['nama'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}