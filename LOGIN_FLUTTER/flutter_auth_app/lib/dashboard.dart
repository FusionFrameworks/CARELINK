import 'package:flutter/material.dart';
import 'doctor_profile_page.dart'; // Import your profile page here
import 'login_page.dart'; // Import your login page here

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // 3-bar menu icon
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer and stay on Dashboard
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorProfile()),
                ); // Navigate to the Profile Page
              },
            ),
            // Logout Button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Navigate to the Login Page and remove Dashboard from stack
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 cards per row
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                children: [
                  _buildCard(
                    context,
                    'Patients Visited',
                    '120',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildCard(
                    context,
                    'Upcoming Appointments',
                    '15',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                  _buildCard(
                    context,
                    'Follow-ups Due',
                    '8',
                    Icons.alarm,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each card
  Widget _buildCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              icon,
              size: 50.0,
              color: color,
            ),
            const SizedBox(height: 20.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              count,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}




