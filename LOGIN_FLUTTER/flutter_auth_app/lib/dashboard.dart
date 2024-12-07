// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart'; // For formatting time
// import 'doctor_profile_page.dart'; // Import your profile page here
// import 'login_page.dart'; // Import your login page here
// import 'dart:async'; // Import Timer for periodic updates

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state
//   List<dynamic> _notifications = []; // Holds notifications data
//   late Timer _timer; // Timer for periodic notifications refresh

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//     _fetchNotifications(); // Fetch notifications on load
//     _timer = Timer.periodic(Duration(seconds: 10), (timer) {
//       _fetchNotifications(); // Periodically fetch notifications
//     });
//   }

//   // Function to update the current time
//   void _updateTime() {
//     setState(() {
//       _formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
//     });
//     Future.delayed(
//         const Duration(seconds: 1), _updateTime); // Update every second
//   }

//   // Fetch notifications from the API
//   Future<void> _fetchNotifications() async {
//     final url = 'http://192.168.228.37:5000/api/auth/notifications'; // API URL
//     try {
//       final response = await http.get(Uri.parse(url));
//       print("Response Status: ${response.statusCode}");
//       print("Response Body: ${response.body}"); // Log response body

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data.containsKey('notifications')) {
//           setState(() {
//             _notifications =
//                 data['notifications']; // Update notifications state
//           });
//         } else {
//           print("No 'notifications' key in the response");
//         }
//       } else {
//         print(
//             "Failed to fetch notifications. Status code: ${response.statusCode}");
//       }
//     } catch (error) {
//       print("Error fetching notifications: $error");
//     }
//   }

//   // Add a new notification to the list
//   void _addNotification() {
//     setState(() {
//       _notifications.add({
//         'name': 'New Patient',
//         'patientId': 'P-${_notifications.length + 1}',
//         'message': 'This is a new notification',
//       });
//     });
//   }

//   // Remove the last notification from the list
//   Future<void> _removeNotification(String patientId) async {
//     final url =
//         'http://192.168.228.37:5000/api/auth/notifications/delete'; // Backend API URL
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'patientId': patientId}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _notifications.removeWhere(
//               (notification) => notification['patientId'] == patientId);
//         });
//       } else {
//         print(
//             'Failed to delete notification. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error deleting notification: $error');
//     }
//   }

//   @override
//   void dispose() {
//     _timer.cancel(); // Stop the timer when the widget is disposed
//     super.dispose();
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
//                               subtitle: Text(
//                                   'Patient ID: ${notification['patientId']}'),
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
//             // Add/Remove Notifications Button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _addNotification,
//                   child: const Text('Add Notification'),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_notifications.isNotEmpty) {
//                       final lastNotification = _notifications.last;
//                       _removeNotification(
//                           lastNotification['patientId']); // Pass the patientId
//                     }
//                   },
//                   child: const Text('Remove Notification'),
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
//                       subtitle:
//                           Text('Patient ID: ${notification['patientId']}'),
//                     );
//                   },
//                 ),
//               )
//             else
//               const Center(
//                   child: CircularProgressIndicator()), // Show loading indicator
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
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'dart:async'; // Import Timer for periodic updates
// import 'doctor_profile_page.dart'; // Import your profile page here
// import 'login_page.dart'; // Import your login page here

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state
//   List<dynamic> _notifications = []; // Holds notifications data
//   late WebSocketChannel _channel; // WebSocket channel

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//     _connectWebSocket(); // Connect to WebSocket for real-time updates

//     // Set up a Timer to update the time every second
//     Timer.periodic(Duration(seconds: 1), (timer) {
//       _updateTime(); // Update the time every second
//     });
//   }

//   // Method to update the current time
//   void _updateTime() {
//     final String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
//     setState(() {
//       _formattedTime = formattedTime; // Update the time
//     });
//   }

//   // WebSocket connection function
//   void _connectWebSocket() {
//     _channel = WebSocketChannel.connect(
//       Uri.parse('ws://192.168.173.155:5000'), // Replace with your WebSocket server URL
//     );

//     _channel.stream.listen(
//       (data) {
//         // Parse JSON data received from the server
//         final payment = jsonDecode(data);
//         setState(() {
//           _notifications.add({
//             'name': 'Payment Update',
//             'patientId': payment['patientId'],
//             'message':
//                 "Payment ID: ${payment['paymentId']}\nName: ${payment['name']}\nAmount: ${payment['amount']}\nStatus: ${payment['status']}\nCreated At: ${payment['createdAt']}",
//           });
//         });
//       },
//       onError: (error) {
//         print("WebSocket error: $error");
//       },
//       onDone: () {
//         print("WebSocket connection closed.");
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _channel.sink.close(); // Close WebSocket connection
//     super.dispose();
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
//                               subtitle: Text(notification['message']),
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
//                 Navigator.pop(context); // Close drawer
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => DoctorProfile()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
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
//                   'Status: ',
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
//             // Notifications List
//             if (_notifications.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _notifications.length,
//                   itemBuilder: (context, index) {
//                     final notification = _notifications[index];
//                     return ListTile(
//                       leading: const Icon(Icons.person),
//                       title: Text(notification['name']),
//                       subtitle: Text(notification['message']),
//                     );
//                   },
//                 ),
//               )
//             else
//               const Center(child: Text('No notifications yet.')),
//           ],
//         ),
//       ),
//     );
//   }
// }





// working code but need to add above features


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _formattedTime = '';
  bool _isActive = true;
  List<dynamic> _notifications = [];
  int _appointmentCount = 0; // Holds appointment count
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _connectWebSocket();

    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
    setState(() {
      _formattedTime = formattedTime;
    });
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.173.155:5000'),
    );

    _channel.stream.listen(
      (data) {
        final message = jsonDecode(data);

        switch (message['type']) {
          case 'latestPayment':
            _handleLatestPayment(message);
            break;
          case 'appointmentCount':
            _handleAppointmentCount(message);
            break;
          case 'patientsWithPayments':
            _handlePatientsWithPayments(message);
            break;
        }
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
      onDone: () {
        print("WebSocket connection closed.");
      },
    );
  }

  void _handleLatestPayment(dynamic message) {
    setState(() {
      _notifications.add({
        'name': 'Payment Update',
        'patientId': message['patientId'],
        'message': "Payment ID: ${message['paymentId']}\n"
            "Status: ${message['status']}\n"
            "Created At: ${message['createdAt']}",
      });
    });
  }

  void _handleAppointmentCount(dynamic message) {
    setState(() {
      _appointmentCount = message['count'];
    });
  }

  void _handlePatientsWithPayments(dynamic message) {
    setState(() {
      _notifications.add({
        'name': 'Patients Update',
        'message': 'Updated patient list received.',
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _notifications.isNotEmpty
                      ? ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return ListTile(
                              leading: Icon(Icons.info),
                              title: Text(notification['name']),
                              subtitle: Text(notification['message']),
                            );
                          },
                        )
                      : Center(child: Text('No new notifications.'));
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Time: $_formattedTime',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Appointments: $_appointmentCount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_notifications.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      title: Text(notification['name']),
                      subtitle: Text(notification['message']),
                    );
                  },
                ),
              )
            else
              Center(child: Text('No notifications yet.')),
          ],
        ),
      ),
    );
  }
}