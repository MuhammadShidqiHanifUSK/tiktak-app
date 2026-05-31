class Guru {
  final int id;
  final String nama;
  final String email;

  Guru({required this.id, required this.nama, required this.email});

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
    };
  }
}