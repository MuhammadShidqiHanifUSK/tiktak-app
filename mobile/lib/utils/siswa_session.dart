class SiswaSession {
  static int? siswaId;
  static String? namaSiswa;
  static int? kelasId;
  static String? namaKelas;
  static int? levelKemampuan;

  static bool pretestDone = false;
  static bool materiDone = false;
  static bool posttestDone = false;

  static void login({
    required int siswaId,
    required String namaSiswa,
    required int kelasId,
    required String namaKelas,
    required int levelKemampuan,
  }) {
    SiswaSession.siswaId = siswaId;
    SiswaSession.namaSiswa = namaSiswa;
    SiswaSession.kelasId = kelasId;
    SiswaSession.namaKelas = namaKelas;
    SiswaSession.levelKemampuan = levelKemampuan;
    pretestDone = false;
    materiDone = false;
    posttestDone = false;
  }

  static void logout() {
    siswaId = null;
    namaSiswa = null;
    kelasId = null;
    namaKelas = null;
    levelKemampuan = null;
    pretestDone = false;
    materiDone = false;
    posttestDone = false;
  }

  static bool get isLoggedIn => siswaId != null;
}