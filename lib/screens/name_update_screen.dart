import 'package:flutter/material.dart';

class NameUpdateScreen extends StatelessWidget {
  final String currentName;

  NameUpdateScreen({required this.currentName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter New Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, nameController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a name')),
                  );
                }
              },
              child: Text('Save Name'),
            ),
          ],
        ),
      ),
    );
  }
}
