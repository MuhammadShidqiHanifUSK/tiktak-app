// Simpan session di memory sementara (cukup untuk prototype)
class Session {
  static int? guruId;
  static String? guruNama;
  static String? guruEmail;

  static void login(int id, String nama, String email) {
    guruId = id;
    guruNama = nama;
    guruEmail = email;
  }

  static void logout() {
    guruId = null;
    guruNama = null;
    guruEmail = null;
  }

  static bool get isLoggedIn => guruId != null;
}