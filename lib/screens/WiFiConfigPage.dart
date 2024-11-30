import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class WiFiConfigPage extends StatefulWidget {
  final BluetoothDevice device;

  WiFiConfigPage({required this.device});

  @override
  _WiFiConfigPageState createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late BluetoothCharacteristic statusCharacteristic;
  String connectionStatus = "Waiting for response...";
  bool showPassword = false;

  Timer? timeoutTimer; // Timer for the 20-second timeout
  bool responseReceived = false; // Tracks if a response is received

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  Future<void> discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            "c1f5483e-36e1-4688-b7f5-ea07361b26c0") {
          // Match the status characteristic UUID
          statusCharacteristic = characteristic;

          // Enable notifications
          await statusCharacteristic.setNotifyValue(true);

          // Listen for notifications
          statusCharacteristic.value.listen((value) {
            String statusMessage = String.fromCharCodes(value);

            // Update the UI with the status message
            setState(() {
              responseReceived = true; // Mark that response was received
              connectionStatus = statusMessage;
            });

            // Cancel the timeout timer if a response is received
            timeoutTimer?.cancel();

            showMessageDialog(statusMessage);
          });
        }
      }
    }
  }

  Future<void> sendCredentials() async {
    setState(() {
      connectionStatus = "Waiting for response...";
      responseReceived = false; // Reset response tracker
    });

    // Start the 20-second timeout
    // timeoutTimer = Timer(Duration(seconds: 10), () {
    //   if (!responseReceived) {
    //     // If no response is received within 20 seconds, update the UI
    //     setState(() {
    //       connectionStatus = "Failed to connect: No response from ESP32.";
    //     });
    //     showMessageDialog("Failed to connect: No response from ESP32.");
    //   }
    // });

    // Discover services and send Wi-Fi credentials
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
          await characteristic.write(ssidController.text.codeUnits);
        } else if (characteristic.uuid.toString() ==
            "d7f5483e-36e1-4688-b7f5-ea07361b26b9") {
          await characteristic.write(passwordController.text.codeUnits);
        }
      }
    }
  }

  void showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Wi-Fi Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timeoutTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configure Wi-Fi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: "Wi-Fi SSID"),
            ),
            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: "Wi-Fi Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendCredentials,
              child: const Text("Send to ESP32"),
            ),
            const SizedBox(height: 20),
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
