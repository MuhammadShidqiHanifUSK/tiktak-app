import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'siswa_pilih_nama_screen.dart';

class SiswaKodeScreen extends StatefulWidget {
  const SiswaKodeScreen({super.key});

  @override
  State<SiswaKodeScreen> createState() => _SiswaKodeScreenState();
}

class _SiswaKodeScreenState extends State<SiswaKodeScreen> {
  final _kodeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _cariKelas() async {
    if (_kodeController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result =
          await ApiService.getKelasByKode(_kodeController.text.trim());

      if (result['success']) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SiswaPilihNamaScreen(kelas: result['data']),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = 'Kode kelas tidak ditemukan 😢');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal terhubung ke server!');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔑', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 16),
                const Text(
                  'Masukkan Kode Kelas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Minta kode kelas dari Ibu/Bapak Guru ya!',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _kodeController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABC123',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cariKelas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Masuk Kelas 🚀',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}