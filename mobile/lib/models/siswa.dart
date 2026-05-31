class Siswa {
  final int id;
  final int kelasId;
  final String nama;
  final int levelKemampuan;
  final int totalSoal;
  final int totalBenar;

  Siswa({
    required this.id,
    required this.kelasId,
    required this.nama,
    required this.levelKemampuan,
    required this.totalSoal,
    required this.totalBenar,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      kelasId: json['kelas_id'],
      nama: json['nama'],
      levelKemampuan: json['level_kemampuan'],
      totalSoal: json['total_soal'],
      totalBenar: json['total_benar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kelas_id': kelasId,
      'nama': nama,
      'level_kemampuan': levelKemampuan,
      'total_soal': totalSoal,
      'total_benar': totalBenar,
    };
  }
}