class Soal {
  final int id;
  final String cerita;
  final int jawabanJam;
  final int jawabanMenit;
  final int tingkatKesulitan;
  final String? audioPath;

  Soal({
    required this.id,
    required this.cerita,
    required this.jawabanJam,
    required this.jawabanMenit,
    required this.tingkatKesulitan,
    this.audioPath,
  });

  factory Soal.fromJson(Map<String, dynamic> json) {
    return Soal(
      id: json['id'],
      cerita: json['cerita'],
      jawabanJam: json['jawaban_jam'],
      jawabanMenit: json['jawaban_menit'],
      tingkatKesulitan: json['tingkat_kesulitan'],
      audioPath: json['audio_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cerita': cerita,
      'jawaban_jam': jawabanJam,
      'jawaban_menit': jawabanMenit,
      'tingkat_kesulitan': tingkatKesulitan,
      'audio_path': audioPath,
    };
  }
}