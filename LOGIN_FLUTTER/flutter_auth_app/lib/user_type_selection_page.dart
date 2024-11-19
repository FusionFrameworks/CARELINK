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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Doctor Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MouseRegion(
                onEnter: (_) {
                  // Handle hover enter
                },
                onExit: (_) {
                  // Handle hover exit
                },
                child: SizedBox(
                  width: 200, // Fixed width
                  height: 60, // Fixed height
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to doctor login page
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue[200]; // Hover effect
                        }
                        return Colors.white; // Default color
                      }),
                    ),
                    child: const Text('Doctor'),
                  ),
                ),
              ),
            ),
            // Lab Technician Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MouseRegion(
                onEnter: (_) {
                  // Handle hover enter
                },
                onExit: (_) {
                  // Handle hover exit
                },
                child: SizedBox(
                  width: 200, // Fixed width
                  height: 60, // Fixed height
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to lab technician login page
                      Navigator.pushNamed(context, '/labtechnicianlogin');
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.blue[200]; // Hover effect
                        }
                        return Colors.white; // Default color
                      }),
                    ),
                    child: const Text('Lab Technician'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
