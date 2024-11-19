import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'technician_profile.dart';
class LabTechnicianDashboard extends StatelessWidget {
  const LabTechnicianDashboard({super.key});

 Future<void> _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(context, '/userTypeSelection', (route) => false);
  }
}


  void _uploadLabReport() {
    print("Upload Lab Report clicked");
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/LabTechnicianProfile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Technician Dashboard'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadLabReport,
          child: const Text('Upload Lab Report'),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.person, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Lab Technician',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
               onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LabTechnicianProfile()),
                ); // Navigate to the Profile Page
              },
            
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
