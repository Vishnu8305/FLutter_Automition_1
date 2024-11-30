import 'package:flutter/material.dart';
import 'bluetooth_devices_page.dart'; // Import your BluetoothDevicesPage here.

class NewDeviceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BluetoothDevicesPage()),
            );
          },
          child: const Text("Find and Connect to ESP32"),
        ),
      ),
    );
  }
}
