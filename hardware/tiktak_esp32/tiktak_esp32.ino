#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ========== KONFIGURASI ==========
const char* WIFI_SSID     = "NAMA_WIFI_KAMU";
const char* WIFI_PASSWORD = "PASSWORD_WIFI_KAMU";
const char* SERVER_URL    = "http://192.168.100.246:5000"; // IP laptop kamu

// ========== PIN ROTARY ENCODER ==========
#define PIN_CLK 18
#define PIN_DT  19
#define PIN_SW  21  // tombol push (opsional)

// ========== VARIABEL ==========
int lastStateCLK;
int currentStateCLK;
float sudutJam   = 0;   // 0-360 derajat
float sudutMenit = 0;   // 0-360 derajat
int jumlahKoreksi = 0;
bool modeJam = true;    // true = putar jarum jam, false = putar jarum menit

int siswaId = 1;   // nanti diisi dari app
int soalId  = 1;   // nanti diisi dari app

unsigned long lastSendTime = 0;
const int SEND_INTERVAL = 200; // kirim data setiap 200ms

void setup() {
  Serial.begin(115200);

  // Setup pin rotary encoder
  pinMode(PIN_CLK, INPUT_PULLUP);
  pinMode(PIN_DT,  INPUT_PULLUP);
  pinMode(PIN_SW,  INPUT_PULLUP);

  lastStateCLK = digitalRead(PIN_CLK);

  // Koneksi WiFi
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.println("IP: " + WiFi.localIP().toString());
}

void loop() {
  // Baca rotary encoder
  currentStateCLK = digitalRead(PIN_CLK);

  if (currentStateCLK != lastStateCLK && currentStateCLK == 1) {
    if (digitalRead(PIN_DT) != currentStateCLK) {
      // Putar kanan (clockwise)
      if (modeJam) {
        sudutJam += 6;   // 1 langkah = 6 derajat
        if (sudutJam >= 360) sudutJam = 0;
      } else {
        sudutMenit += 6;
        if (sudutMenit >= 360) sudutMenit = 0;
      }
    } else {
      // Putar kiri (counter-clockwise)
      if (modeJam) {
        sudutJam -= 6;
        if (sudutJam < 0) sudutJam = 354;
      } else {
        sudutMenit -= 6;
        if (sudutMenit < 0) sudutMenit = 354;
      }
    }
    jumlahKoreksi++;
    Serial.printf("Sudut Jam: %.0f, Sudut Menit: %.0f\n", sudutJam, sudutMenit);
  }

  lastStateCLK = currentStateCLK;

  // Tombol SW untuk ganti mode jam/menit
  if (digitalRead(PIN_SW) == LOW) {
    modeJam = !modeJam;
    Serial.println(modeJam ? "Mode: JARUM JAM" : "Mode: JARUM MENIT");
    delay(300); // debounce
  }

  // Kirim data ke backend setiap 200ms
  if (millis() - lastSendTime >= SEND_INTERVAL) {
    kirimData();
    lastSendTime = millis();
  }
}

void kirimData() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(String(SERVER_URL) + "/api/iot/update");
  http.addHeader("Content-Type", "application/json");

  // Konversi sudut ke jam dan menit
  int jamValue   = (int)(sudutJam / 30) % 12;    // 360/12 = 30 derajat per jam
  int menitValue = (int)(sudutMenit / 6) % 60;   // 360/60 = 6 derajat per menit

  StaticJsonDocument<200> doc;
  doc["siswa_id"]      = siswaId;
  doc["soal_id"]       = soalId;
  doc["sudut_jam"]     = sudutJam;
  doc["sudut_menit"]   = sudutMenit;
  doc["jam_value"]     = jamValue;
  doc["menit_value"]   = menitValue;
  doc["jumlah_koreksi"] = jumlahKoreksi;
  doc["mode"]          = modeJam ? "jam" : "menit";

  String jsonStr;
  serializeJson(doc, jsonStr);

  int httpCode = http.POST(jsonStr);
  if (httpCode > 0) {
    Serial.printf("Terkirim! HTTP: %d\n", httpCode);
  }
  http.end();
}

void resetJam() {
  sudutJam   = 0;
  sudutMenit = 0;
  jumlahKoreksi = 0;
  modeJam = true;
  Serial.println("Jam direset ke 12:00");
}