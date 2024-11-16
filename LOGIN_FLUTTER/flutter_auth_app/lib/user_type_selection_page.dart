import 'package:flutter/material.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Type'),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Doctor Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to doctor login page
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.white, // Use backgroundColor instead of primary
                  ),
                  child: const Text('Doctor'),
                ),
              ),
            ),
            // Lab Technician Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to lab technician login page
                    Navigator.pushNamed(context, '/labtechnicianlogin');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.white, // Use backgroundColor instead of primary
                  ),
                  child: const Text('Lab Technician'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
