import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'avatar_selection_screen.dart';
import 'name_update_screen.dart';
import 'theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this

class SettingsScreen extends StatelessWidget {
  final String currentAvatar;
  final String currentName;

  SettingsScreen({required this.currentAvatar, required this.currentName});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Change Avatar Button
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(
                "Change Avatar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                final updatedAvatar = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvatarSelectionScreen(
                      currentAvatar: currentAvatar,
                    ),
                  ),
                );

                if (updatedAvatar != null) {
                  Navigator.pop(
                      context, {'avatar': updatedAvatar, 'name': currentName});
                }
              },
            ),
            Divider(),

            // Change Name Button
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text(
                "Change Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                final updatedName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NameUpdateScreen(currentName: currentName),
                  ),
                );

                if (updatedName != null) {
                  Navigator.pop(
                      context, {'avatar': currentAvatar, 'name': updatedName});
                }
              },
            ),
            Divider(),

            // Wi-Fi Settings Button
            ListTile(
              leading: Icon(Icons.wifi, color: Colors.blue),
              title: Text(
                "Wi-Fi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wi-Fi settings coming soon!')),
                );
              },
            ),
            Divider(),

            // Toggle Theme
            SwitchListTile(
              title: Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('isDarkMode', value);
                });
              },
            ),
            Divider(),
            // Logout Button
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text(
                "Logout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout functionality coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
