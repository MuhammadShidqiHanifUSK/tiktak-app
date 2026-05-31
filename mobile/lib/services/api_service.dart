import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP laptop kamu saat testing
  static const String baseUrl = 'http://10.247.102.109:5000';

  // ========== AUTH ==========

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String nama, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ========== KELAS ==========

  static Future<Map<String, dynamic>> getKelas(int guruId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/kelas/?guru_id=$guruId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addKelas(
      int guruId, String namaKelas, String tingkatan) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/kelas/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'guru_id': guruId,
        'nama_kelas': namaKelas,
        'tingkatan': tingkatan,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteKelas(int kelasId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/kelas/$kelasId'),
    );
    return jsonDecode(response.body);
  }

  // ========== SISWA ==========

  static Future<Map<String, dynamic>> getSiswa(int kelasId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/siswa/?kelas_id=$kelasId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addSiswa(
      int kelasId, String nama) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/siswa/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'kelas_id': kelasId, 'nama': nama}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteSiswa(int siswaId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/siswa/$siswaId'),
    );
    return jsonDecode(response.body);
  }

  // ========== DASHBOARD ==========

  static Future<Map<String, dynamic>> getRingkasanKelas(int kelasId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/kelas/$kelasId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDetailSiswa(int siswaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/siswa/$siswaId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSiswaPerhatian(int kelasId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/perhatian/$kelasId'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitJawaban({
    required int siswaId,
    required int soalId,
    required int jawabanJam,
    required int jawabanMenit,
    required double waktuRespons,
    required int jumlahKoreksi,
    required int jumlahUlangAudio,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/sesi/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'siswa_id': siswaId,
        'soal_id': soalId,
        'jawaban_jam': jawabanJam,
        'jawaban_menit': jawabanMenit,
        'waktu_respons': waktuRespons,
        'jumlah_koreksi': jumlahKoreksi,
        'jumlah_ulang_audio': jumlahUlangAudio,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSoal(int tingkat) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/soal/?tingkat=$tingkat'),
    );
    return jsonDecode(response.body);
  }
}