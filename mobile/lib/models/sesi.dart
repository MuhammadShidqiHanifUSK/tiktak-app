class Sesi {
  final int id;
  final int siswaId;
  final int soalId;
  final int jawabanJam;
  final int jawabanMenit;
  final bool adalahBenar;
  final double waktuRespons;
  final int jumlahKoreksi;
  final int jumlahUlangAudio;
  final String createdAt;

  Sesi({
    required this.id,
    required this.siswaId,
    required this.soalId,
    required this.jawabanJam,
    required this.jawabanMenit,
    required this.adalahBenar,
    required this.waktuRespons,
    required this.jumlahKoreksi,
    required this.jumlahUlangAudio,
    required this.createdAt,
  });

  factory Sesi.fromJson(Map<String, dynamic> json) {
    return Sesi(
      id: json['id'],
      siswaId: json['siswa_id'],
      soalId: json['soal_id'],
      jawabanJam: json['jawaban_jam'],
      jawabanMenit: json['jawaban_menit'],
      adalahBenar: json['adalah_benar'] == 1,
      waktuRespons: json['waktu_respons']?.toDouble() ?? 0.0,
      jumlahKoreksi: json['jumlah_koreksi'],
      jumlahUlangAudio: json['jumlah_ulang_audio'],
      createdAt: json['created_at'],
    );
  }
}