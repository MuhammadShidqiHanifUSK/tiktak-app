class Kelas {
  final int id;
  final int guruId;
  final String namaKelas;
  final String tingkatan;

  Kelas({
    required this.id,
    required this.guruId,
    required this.namaKelas,
    required this.tingkatan,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      guruId: json['guru_id'],
      namaKelas: json['nama_kelas'],
      tingkatan: json['tingkatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guru_id': guruId,
      'nama_kelas': namaKelas,
      'tingkatan': tingkatan,
    };
  }
}