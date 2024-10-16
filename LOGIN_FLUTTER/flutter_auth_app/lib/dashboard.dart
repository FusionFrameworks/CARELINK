// import 'package:flutter/material.dart';

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   int _selectedIndex = 0;

//   static List<Widget> _pages = <Widget>[
//     DashboardPage(),
//     AppointmentsPage(),
//     PrescriptionsPage(),
//     VideoCallsPage(),
//     ProfilePage(), // Add the Profile page to the list of pages
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     Navigator.pop(context); // Close the drawer after selecting an item
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Doctor Dashboard'),
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer(); // Open the drawer
//               },
//             );
//           },
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: const Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text('Dashboard'),
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.calendar_today),
//               title: const Text('Appointments'),
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.receipt),
//               title: const Text('Prescriptions'),
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.video_call),
//               title: const Text('Video Calls'),
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () => _onItemTapped(4), // Navigate to Profile
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 // Implement logout functionality here
//                 _logout();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//     );
//   }

//   void _logout() {
//     // Add your logout logic here, such as clearing user session or redirecting to login page
//     print("Logged out"); // Placeholder for logout action
//   }
// }

// class DashboardPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size; // Get screen size for dynamic layout

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(child: _buildStatCard('Patient', '654', Colors.purple, '18% Last 7 days')),
//                 SizedBox(width: 10), // Space between cards
//                 Expanded(child: _buildStatCard('Consultation', '556', Colors.orange, '25% Last 7 days')),
//                 SizedBox(width: 10),
//                 Expanded(child: _buildStatCard('Prescription', '328', Colors.pink, '45% Last 7 days')),
//               ],
//             ),
//             SizedBox(height: 20),
//             _buildTodayAppointments(size),
//             SizedBox(height: 20),
//             _buildPatientDetails(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to build the Stat cards with dynamic width for mobile screens
//   Widget _buildStatCard(String title, String count, Color color, String change) {
//     return Card(
//       elevation: 2,
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black54,
//               ),
//             ),
//             Text(
//               count,
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               change,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to build the "Today's Appointments" section
//   Widget _buildTodayAppointments(Size size) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Today's Appointments",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 2,
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             title: Text('Paul Rauley'),
//             subtitle: Text('Medical Consultation'),
//             trailing: Text('03:00 PM'),
//           ),
//         ),
//         Card(
//           elevation: 2,
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             title: Text('Clifford Day'),
//             subtitle: Text('Medical Consultation'),
//             trailing: Text('03:20 PM'),
//           ),
//         ),
//         Card(
//           elevation: 2,
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             title: Text('Ella Thompson'),
//             subtitle: Text('Drug Prescription'),
//             trailing: Text('03:40 PM'),
//           ),
//         ),
//       ],
//     );
//   }

//   // Function to build the "Patient Details" section
//   Widget _buildPatientDetails() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.person, size: 40, color: Colors.white),
//                 ),
//                 SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Paul Rauley',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '1322 Lost Round, Madison, Portland, ID 36067',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Text('Date of Birth: 03 February 1989'),
//             Text('Sex: Male'),
//             Text('Weight: 55 kg'),
//             Text('Height: 165 cm'),
//             Text('Register Date: 02 March 2020'),
//             Text('Last Appointment: 23 June 2021'),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {},
//                   child: Text('Make a Video Call'),
//                 ),
//                 SizedBox(width: 10),
//                 OutlinedButton(
//                   onPressed: () {},
//                   child: Text('Chat'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AppointmentsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Appointments Page', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class PrescriptionsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Prescriptions Page', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class VideoCallsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Video Calls Page', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Profile Page', style: TextStyle(fontSize: 24)),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'login_page.dart'; // Import LoginPage if needed

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    DashboardPage(),
    AppointmentsPage(),
    PrescriptionsPage(),
    VideoCallsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer after selecting an item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
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
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appointments'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Prescriptions'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Video Calls'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout, // Call the logout method
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate back to the LoginPage
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }
}

// Pages defined below

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class AppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Appointments Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class PrescriptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Prescriptions Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class VideoCallsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Video Calls Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
    );
  }
}
