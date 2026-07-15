#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ===============================
// KONFIGURASI WIFI & SERVER
// ===============================
const char* WIFI_SSID     = "AkuSukaMainRaket";
const char* WIFI_PASSWORD = "goindonesia";
const char* SERVER_URL    = "http://10.247.102.109:5000";
bool dataChanged = false;

// ===============================
// PIN ROTARY ENCODER
// ===============================
#define PIN_CLK 18
#define PIN_DT  19
#define PIN_SW  21

// ===============================
// ROTARY ENCODER
// ===============================
int lastStateCLK;
int currentStateCLK;

bool lastButtonState = HIGH;

// ===============================
// DATA JAM
// ===============================

// Total menit pada jam analog
// 0 = 12:00
// 719 = 11:59
int totalMinutes = 0;

// Nilai yang dikirim ke Flutter
int jamValue = 0;
int menitValue = 0;

float sudutJam = 0;
float sudutMenit = 0;

// Statistik
int jumlahKoreksi = 0;

// Data siswa
int siswaId = 1;
int soalId = 1;

// Waktu mulai mengerjakan soal
unsigned long startTime = 0;

// Interval update
unsigned long lastSendTime = 0;
const unsigned long SEND_INTERVAL = 200;

// ===============================
// HITUNG POSISI JARUM
// ===============================
void updateClock()
{
    jamValue = (totalMinutes / 60) % 12;

    if (jamValue == 0)
        jamValue = 12;

    menitValue = totalMinutes % 60;

    // Jarum menit
    sudutMenit = menitValue * 6;

    // Jarum jam bergerak perlahan
    sudutJam =
        ((jamValue % 12) * 30)
        +
        (menitValue * 0.5);
}

// ===============================
// SETUP
// ===============================
void setup()
{
    Serial.begin(115200);

    pinMode(PIN_CLK, INPUT_PULLUP);
    pinMode(PIN_DT, INPUT_PULLUP);
    pinMode(PIN_SW, INPUT_PULLUP);

    lastStateCLK = digitalRead(PIN_CLK);

    updateClock();

    Serial.println("Connecting WiFi...");

    WiFi.begin(
        WIFI_SSID,
        WIFI_PASSWORD
    );

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();
    Serial.println("WiFi Connected");
    Serial.println(WiFi.localIP());

    // Mulai timer pengerjaan
    startTime = millis();
}

void loop()
{
    // ==========================
    // BACA ROTARY ENCODER
    // ==========================
    currentStateCLK = digitalRead(PIN_CLK);

    if (currentStateCLK != lastStateCLK &&
        currentStateCLK == HIGH)
    {

        // Putar searah jarum jam
        if (digitalRead(PIN_DT) != currentStateCLK)
        {

            totalMinutes++;

            if (totalMinutes >= 720)
                totalMinutes = 0;

        }
        // Putar berlawanan arah
        else
        {

            totalMinutes--;

            if (totalMinutes < 0)
                totalMinutes = 719;

        }

        jumlahKoreksi++;

        updateClock();

        Serial.printf(
            "Jam : %02d:%02d | Sudut Jam %.1f | Sudut Menit %.1f\n",
            jamValue,
            menitValue,
            sudutJam,
            sudutMenit
        );

        // Langsung kirim update posisi
        dataChanged = true;
    }

    lastStateCLK = currentStateCLK;

    // ==========================
    // TOMBOL SUBMIT
    // ==========================
    bool currentButtonState = digitalRead(PIN_SW);

    if (lastButtonState == HIGH &&
        currentButtonState == LOW)
    {

        Serial.println("----------------------");
        Serial.println("SUBMIT JAWABAN");
        Serial.println("----------------------");

        submitJawaban();
    }

    lastButtonState = currentButtonState;

    // ==========================
    // HEARTBEAT
    // ==========================
    if (millis() - lastSendTime >= SEND_INTERVAL){
    if (dataChanged)
    {
        kirimData();

        dataChanged = false;
    }

    lastSendTime = millis();
}
}

void kirimData()
{
    if (WiFi.status() != WL_CONNECTED)
        return;

    HTTPClient http;

    http.begin(String(SERVER_URL) + "/api/iot/update");

    http.addHeader("Content-Type", "application/json");

    StaticJsonDocument<256> doc;

    doc["siswa_id"] = siswaId;
    doc["soal_id"] = soalId;

    doc["sudut_jam"] = sudutJam;
    doc["sudut_menit"] = sudutMenit;

    doc["jam_value"] = jamValue;
    doc["menit_value"] = menitValue;

    doc["jumlah_koreksi"] = jumlahKoreksi;

    String json;

    serializeJson(doc, json);

    int httpCode = http.POST(json);

    if (httpCode > 0)
    {
        Serial.printf(
            "Update -> %02d:%02d | HTTP %d\n",
            jamValue,
            menitValue,
            httpCode
        );
    }

    http.end();
}
void submitJawaban()
{
    if (WiFi.status() != WL_CONNECTED)
        return;

    HTTPClient http;

    http.begin(String(SERVER_URL) + "/api/sesi/");

    http.addHeader("Content-Type", "application/json");

    float waktuRespons =
        (millis() - startTime) / 1000.0;

    StaticJsonDocument<256> doc;

    doc["siswa_id"] = siswaId;

    doc["soal_id"] = soalId;

    doc["jawaban_jam"] = jamValue;

    doc["jawaban_menit"] = menitValue;

    doc["waktu_respons"] = waktuRespons;

    doc["jumlah_koreksi"] = jumlahKoreksi;

    doc["jumlah_ulang_audio"] = 0;

    String json;

    serializeJson(doc, json);

    int httpCode = http.POST(json);

    if (httpCode > 0)
    {
        Serial.println();

        Serial.println("===== HASIL =====");

        String response = http.getString();

        Serial.println(response);

        Serial.println("=================");

        // Mulai timer baru
        startTime = millis();

        jumlahKoreksi = 0;
    }
    else
    {
        Serial.printf(
            "Submit gagal (%d)\n",
            httpCode
        );
    }

    http.end();
}

void resetJam()
{
    totalMinutes = 0;

    jumlahKoreksi = 0;

    startTime = millis();

    updateClock();

    Serial.println("Reset ke 12:00");
}