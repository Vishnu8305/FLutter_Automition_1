#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ArduinoJson.h>

// BLE Service and Characteristic UUIDs
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define SSID_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define PASSWORD_CHARACTERISTIC_UUID "d7f5483e-36e1-4688-b7f5-ea07361b26b9"
#define STATUS_CHARACTERISTIC_UUID "c1f5483e-36e1-4688-b7f5-ea07361b26c0"

// Wi-Fi Credentials
String ssid = "";
String password = "";
bool deviceConnected = false;

// BLE server and characteristics
BLEServer *pServer = nullptr;
BLECharacteristic *ssidCharacteristic;
BLECharacteristic *passwordCharacteristic;
BLECharacteristic *statusCharacteristic;

// HTTP Server on Port 80
WebServer server(80);

// Notify Wi-Fi status to app
void sendStatusToApp(const String &status) {
  if (deviceConnected) {
    statusCharacteristic->setValue(status.c_str());
    statusCharacteristic->notify();
    Serial.println("Status sent to app: " + status);
  }
}

// Connect to Wi-Fi
void connectToWiFi() {
  ssid.trim();
  password.trim();
  Serial.println("\nAttempting to connect to Wi-Fi...");
  WiFi.disconnect(true);  // Clear previous credentials
  delay(1000);
  WiFi.begin(ssid.c_str(), password.c_str());

  int timeout = 10; // Timeout after 20 seconds
  while (WiFi.status() != WL_CONNECTED && timeout > 0) {
    delay(1000);
    Serial.print(".");
    timeout--;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nConnected to Wi-Fi!");
    Serial.print("SSID: ");
    Serial.println(ssid);
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

    // Notify app of successful connection
    sendStatusToApp("Connected");

    // Start HTTP server
    startHTTPServer();
  } else {
    Serial.println("\nFailed to connect to Wi-Fi. Restarting Bluetooth for new configuration...");
    sendStatusToApp("Failed");

    // Restart BLE advertising for new configuration
    restartBLE();
  }
}

// Start HTTP Server
void startHTTPServer() {
  server.on("/", []() {
    server.send(200, "text/plain", "ESP32 is online and communicating over Wi-Fi!");
  });

  server.on("/status", []() {
    String message = "Connected to Wi-Fi\n";
    message += "SSID: " + ssid + "\n";
    message += "IP Address: " + WiFi.localIP().toString();
    server.send(200, "text/plain", message);
  });

  server.begin();
  Serial.println("HTTP server started.");
}

// Restart BLE for new configuration
void restartBLE() {
  // Stop current BLE advertising
  BLEDevice::stopAdvertising();

  // Reset SSID and Password
  ssid = "";
  password = "";

  // Restart BLE advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->start();
  Serial.println("BLE advertising restarted. Waiting for new credentials...");
}

// BLE server callbacks
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
  }

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
  }
};

// BLE characteristic callbacks
class WiFiConfigCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = String(pCharacteristic->getValue().c_str());
    if (value.length() > 0) {
      if (pCharacteristic == ssidCharacteristic) {
        ssid = value;
        Serial.println("Received SSID: " + ssid);
      } else if (pCharacteristic == passwordCharacteristic) {
        password = value;
        Serial.println("Received Password: " + password);
        connectToWiFi();
      }
    }
  }
};

void setup() {
  Serial.begin(115200);

  // Initialize BLE
  BLEDevice::init("ESP32-WiFi-Setup");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Create BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create BLE Characteristics
  ssidCharacteristic = pService->createCharacteristic(
      SSID_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_WRITE);
  passwordCharacteristic = pService->createCharacteristic(
      PASSWORD_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_WRITE);
  statusCharacteristic = pService->createCharacteristic(
      STATUS_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_NOTIFY);

  ssidCharacteristic->setCallbacks(new WiFiConfigCallbacks());
  passwordCharacteristic->setCallbacks(new WiFiConfigCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->start();
  Serial.println("BLE server is ready and advertising.");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    server.handleClient(); // Handle HTTP requests
  }
}
