import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'contact_us_screen.dart';
import 'new_device_screen.dart';

class WelcomePage extends StatefulWidget {
  final String initialAvatarPath;
  final String initialUserName;

  WelcomePage({required this.initialAvatarPath, required this.initialUserName});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late String avatarPath;
  late String userName;

  @override
  void initState() {
    super.initState();
    avatarPath = widget.initialAvatarPath;
    userName = widget.initialUserName;
  }

  // Save data to SharedPreferences
  Future<void> _saveUserData(String avatar, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', avatar);
    await prefs.setString('userName', name);
  }

  // Open Settings Screen and get updated data
  void openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentAvatar: avatarPath,
          currentName: userName,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        avatarPath = result['avatar'] ?? avatarPath;
        userName = result['name'] ?? userName;
      });
      _saveUserData(avatarPath, userName); // Persist changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Page'),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(avatarPath),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'john.doe@example.com', // Placeholder for email
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Items
              ListTile(
                leading: Icon(Icons.add, color: Colors.blue),
                title: Text(
                  'Add Device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewDeviceScreen()), // Fix here
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.blue),
                title: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail, color: Colors.blue),
                title: Text(
                  'Contact Us',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.blue),
                title: Text(
                  'Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: openSettings,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Center(
        child: const Text(
          'Welcome to IoT App!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
