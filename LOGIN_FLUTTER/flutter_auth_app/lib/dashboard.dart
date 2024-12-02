// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting time
// import 'doctor_profile_page.dart'; // Import your profile page here
// import 'login_page.dart'; // Import your login page here

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//   }

//   // Function to update the current time
//   void _updateTime() {
//     setState(() {
//       _formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
//     });
//     Future.delayed(
//         const Duration(seconds: 1), _updateTime); // Update every second
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Doctor Dashboard'),
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu), // 3-bar menu icon
//               onPressed: () {
//                 Scaffold.of(context).openDrawer(); // Open the drawer
//               },
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               // Handle notification icon tap
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('No new notifications.')),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: const BoxDecoration(
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
//               onTap: () {
//                 Navigator.pop(context); // Close drawer and stay on Dashboard
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => DoctorProfile()),
//                 ); // Navigate to the Profile Page
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 ); // Navigate to Login Page
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Real-time Clock
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Current Time: ',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   _formattedTime,
//                   style: const TextStyle(fontSize: 18, color: Colors.blue),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             // Active/Inactive Toggle Button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Status:',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(width: 10),
//                 Switch(
//                   value: _isActive,
//                   activeColor: Colors.green,
//                   inactiveThumbColor: Colors.red,
//                   inactiveTrackColor: Colors.redAccent[100],
//                   onChanged: (value) {
//                     setState(() {
//                       _isActive = value;
//                     });
//                   },
//                 ),
//                 Text(
//                   _isActive ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: _isActive ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//                       ],
//         ),
//       ),
//     );
//   }

//   // Method to build each card
//   Widget _buildCard(BuildContext context, String title, String count,
//       IconData icon, Color color) {
//     return Card(
//       elevation: 4.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Icon(
//               icon,
//               size: 50.0,
//               color: color,
//             ),
//             const SizedBox(height: 20.0),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style:
//                   const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10.0),
//             Text(
//               count,
//               textAlign: TextAlign.center,
//               style:
//                   const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   List<dynamic> _notifications = []; // Holds notifications data

//   @override
//   void initState() {
//     super.initState();
//     _fetchNotifications(); // Fetch notifications on load
//   }

//   // Fetch notifications from the API
//   Future<void> _fetchNotifications() async {
//     final url = 'http://172.21.13.189:5000/api/auth/notifications'; // API URL
//     try {
//       final response = await http.get(Uri.parse(url));
//       print("Response Status: ${response.statusCode}");
//       print("Response Body: ${response.body}");  // Log response body

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data.containsKey('notifications')) {
//           setState(() {
//             _notifications = data['notifications']; // Update notifications state
//           });
//         } else {
//           print("No 'notifications' key in the response");
//         }
//       } else {
//         print("Failed to fetch notifications. Status code: ${response.statusCode}");
//       }
//     } catch (error) {
//       print("Error fetching notifications: $error");
//     }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Doctor Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               // Open modal bottom sheet when icon is clicked
//               showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   // Return a ListView.builder to show notifications in a bottom sheet
//                   return ListView.builder(
//                     itemCount: _notifications.length,
//                     itemBuilder: (context, index) {
//                       final notification = _notifications[index];
//                       return ListTile(
//                         leading: const Icon(Icons.person),
//                         title: Text(notification['name']),
//                         subtitle: Text('Patient ID: ${notification['patientId']}'),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Dashboard Content Here'),
//             const SizedBox(height: 20),
//             // Display a list of notifications directly in the body of the page
//             if (_notifications.isNotEmpty)
//               ListView.builder(
//                 shrinkWrap: true, // To allow ListView to fit in the available space
//                 itemCount: _notifications.length,
//                 itemBuilder: (context, index) {
//                   final notification = _notifications[index];
//                   return ListTile(
//                     leading: const Icon(Icons.person),
//                     title: Text(notification['name']),
//                     subtitle: Text('Patient ID: ${notification['patientId']}'),
//                   );
//                 },
//               ),
//             if (_notifications.isEmpty)
//               const CircularProgressIndicator(), // Show loading indicator if notifications are empty
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart'; // For formatting time
// import 'doctor_profile_page.dart'; // Import your profile page here
// import 'login_page.dart'; // Import your login page here
// import 'package:intl/intl.dart';

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state
//   List<dynamic> _notifications = []; // Holds notifications data

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//     _fetchNotifications(); // Fetch notifications on load
//   }

//   // Function to update the current time
//   void _updateTime() {
//     setState(() {
//       _formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
//     });
//     Future.delayed(const Duration(seconds: 1), _updateTime); // Update every second
//   }

//   // Fetch notifications from the API
//   Future<void> _fetchNotifications() async {
//     final url = 'http://192.168.225.155:5000/api/auth/notifications'; // API URL
//     try {
//       final response = await http.get(Uri.parse(url));
//       print("Response Status: ${response.statusCode}");
//       print("Response Body: ${response.body}"); // Log response body

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data.containsKey('notifications')) {
//           setState(() {
//             _notifications = data['notifications']; // Update notifications state
//           });
//         } else {
//           print("No 'notifications' key in the response");
//         }
//       } else {
//         print("Failed to fetch notifications. Status code: ${response.statusCode}");
//       }
//     } catch (error) {
//       print("Error fetching notifications: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Doctor Dashboard'),
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu), // 3-bar menu icon
//               onPressed: () {
//                 Scaffold.of(context).openDrawer(); // Open the drawer
//               },
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               // Open modal bottom sheet when icon is clicked
//               showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _notifications.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: _notifications.length,
//                           itemBuilder: (context, index) {
//                             final notification = _notifications[index];
//                             return ListTile(
//                               leading: const Icon(Icons.person),
//                               title: Text(notification['name']),
//                               subtitle: Text('Patient ID: ${notification['patientId']}'),
//                             );
//                           },
//                         )
//                       : const Center(child: Text('No new notifications.'));
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: const BoxDecoration(
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
//               onTap: () {
//                 Navigator.pop(context); // Close drawer and stay on Dashboard
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => DoctorProfile()),
//                 ); // Navigate to the Profile Page
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 ); // Navigate to Login Page
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Real-time Clock
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Current Time: ',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   _formattedTime,
//                   style: const TextStyle(fontSize: 18, color: Colors.blue),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             // Active/Inactive Toggle Button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Status:',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(width: 10),
//                 Switch(
//                   value: _isActive,
//                   activeColor: Colors.green,
//                   inactiveThumbColor: Colors.red,
//                   inactiveTrackColor: Colors.redAccent[100],
//                   onChanged: (value) {
//                     setState(() {
//                       _isActive = value;
//                     });
//                   },
//                 ),
//                 Text(
//                   _isActive ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: _isActive ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             // Notifications List in the main body
//             if (_notifications.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _notifications.length,
//                   itemBuilder: (context, index) {
//                     final notification = _notifications[index];
//                     return ListTile(
//                       leading: const Icon(Icons.person),
//                       title: Text(notification['name']),
//                       subtitle: Text('Patient ID: ${notification['patientId']}'),
//                     );
//                   },
//                 ),
//               )
//             else
//               const Center(child: CircularProgressIndicator()), // Show loading indicator
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting time
import 'doctor_profile_page.dart'; // Import your profile page here
import 'login_page.dart'; // Import your login page here
import 'dart:async'; // Import Timer for periodic updates

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _formattedTime = ''; // Holds the current time
  bool _isActive = true; // Toggle button state
  List<dynamic> _notifications = []; // Holds notifications data
  late Timer _timer; // Timer for periodic notifications refresh

  @override
  void initState() {
    super.initState();
    _updateTime(); // Initialize time updating
    _fetchNotifications(); // Fetch notifications on load
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchNotifications(); // Periodically fetch notifications
    });
  }

  // Function to update the current time
  void _updateTime() {
    setState(() {
      _formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
    Future.delayed(
        const Duration(seconds: 1), _updateTime); // Update every second
  }

  // Fetch notifications from the API
  Future<void> _fetchNotifications() async {
    final url = 'http://192.168.228.37:5000/api/auth/notifications'; // API URL
    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Log response body

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey('notifications')) {
          setState(() {
            _notifications =
                data['notifications']; // Update notifications state
          });
        } else {
          print("No 'notifications' key in the response");
        }
      } else {
        print(
            "Failed to fetch notifications. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching notifications: $error");
    }
  }

  // Add a new notification to the list
  void _addNotification() {
    setState(() {
      _notifications.add({
        'name': 'New Patient',
        'patientId': 'P-${_notifications.length + 1}',
        'message': 'This is a new notification',
      });
    });
  }

  // Remove the last notification from the list
  Future<void> _removeNotification(String patientId) async {
    final url =
        'http://192.168.228.37:5000/api/auth/notifications/delete'; // Backend API URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patientId': patientId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications.removeWhere(
              (notification) => notification['patientId'] == patientId);
        });
      } else {
        print(
            'Failed to delete notification. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting notification: $error');
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Open modal bottom sheet when icon is clicked
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _notifications.isNotEmpty
                      ? ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(notification['name']),
                              subtitle: Text(
                                  'Patient ID: ${notification['patientId']}'),
                            );
                          },
                        )
                      : const Center(child: Text('No new notifications.'));
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ); // Navigate to Login Page
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
            // Real-time Clock
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current Time: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formattedTime,
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Active/Inactive Toggle Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: _isActive,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.redAccent[100],
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                Text(
                  _isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Add/Remove Notifications Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addNotification,
                  child: const Text('Add Notification'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_notifications.isNotEmpty) {
                      final lastNotification = _notifications.last;
                      _removeNotification(
                          lastNotification['patientId']); // Pass the patientId
                    }
                  },
                  child: const Text('Remove Notification'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Notifications List in the main body
            if (_notifications.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(notification['name']),
                      subtitle:
                          Text('Patient ID: ${notification['patientId']}'),
                    );
                  },
                ),
              )
            else
              const Center(
                  child: CircularProgressIndicator()), // Show loading indicator
          ],
        ),
      ),
    );
  }
}
