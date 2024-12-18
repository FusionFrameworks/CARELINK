import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'doctor_profile_page.dart';
import 'login_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  String _formattedTime = ''; // Holds the current time
  bool _isActive = true; // Toggle button state
  Map<String, List<dynamic>> _patientPayments = {}; // Map to group payments by patient ID
  int _appointmentCount = 0; // Holds appointment count
  Map<String, dynamic>? _selectedAppointmentDetails; // Details for the selected appointment
  late WebSocketChannel _channel; // WebSocket channel
  bool _isExpanded = false; // Toggle for animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _updateTime(); // Initialize time updating
    _connectWebSocket(); // Connect to WebSocket for real-time updates

    // Set up a Timer to update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
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
      final patientId = message['patientId'];
      if (_patientPayments.containsKey(patientId)) {
        // Append the new payment to the existing list
        _patientPayments[patientId]!.add(message);
      } else {
        // Create a new entry for this patient ID
        _patientPayments[patientId] = [message];
      }
    });
  }

  void _handleAppointmentCount(dynamic message) {
    setState(() {
      _appointmentCount = message['count'];
    });
  }

  void _toggleDetails() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _animationController.dispose();
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
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _patientPayments.isNotEmpty
                      ? ListView.builder(
                          itemCount: _patientPayments.length,
                          itemBuilder: (context, index) {
                            final patientId = _patientPayments.keys.elementAt(index);
                            final payments = _patientPayments[patientId]!;
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text('Patient ID: $patientId'),
                              subtitle: Text('Payments: ${payments.length}'),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
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
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Total: $_appointmentCount',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Appointment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Patient'),
                      value: _selectedAppointmentDetails?['patientId'],
                      items: _patientPayments.keys.map((patientId) {
                        final patientName = _patientPayments[patientId]![0]['patientDetails']['name'];
                        final paymentCount = _patientPayments[patientId]!.length;
                        return DropdownMenuItem<String>(
                          value: patientId,
                          child: Text('$patientName (Payments: $paymentCount)'),
                        );
                      }).toList(),
                      onChanged: (patientId) {
                        setState(() {
                          _selectedAppointmentDetails = {
                            'patientId': patientId,
                            'payments': _patientPayments[patientId],
                          };
                          _isExpanded = false; // Reset expansion
                        });
                      },
                    ),
                    SizeTransition(
                      sizeFactor: _animation,
                      child: _selectedAppointmentDetails != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payments for ${_selectedAppointmentDetails!['patientId']}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  ...(_selectedAppointmentDetails!['payments'] as List).map((payment) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Payment ID: ${payment['paymentId']}'),
                                        Text('Status: ${payment['status']}'),
                                        Text('Created At: ${payment['createdAt']}'),
                                        const Divider(),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    ElevatedButton(
                      onPressed: _toggleDetails,
                      child: Text(_isExpanded ? 'Hide Details' : 'Show Details'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Status: ',
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
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'dart:async';
// import 'doctor_profile_page.dart';
// import 'login_page.dart';

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state
//   Map<String, List<dynamic>> _patientPayments = {}; // Group payments by patient ID
//   Map<String, List<dynamic>> _labReports = {}; // Group lab reports by patient ID
//   int _appointmentCount = 0; // Holds appointment count
//   Map<String, dynamic>? _selectedAppointmentDetails; // Selected appointment details
//   Map<String, dynamic>? _selectedLabReportDetails; // Selected lab report details
//   late WebSocketChannel _channel; // WebSocket channel
//   bool _isExpanded = false; // Toggle for payments animation
//   bool _isLabExpanded = false; // Toggle for lab report animation
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//     _connectWebSocket(); // Connect to WebSocket for updates

//     Timer.periodic(Duration(seconds: 1), (timer) {
//       _updateTime();
//     });

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//   }

//   void _updateTime() {
//     final String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
//     setState(() {
//       _formattedTime = formattedTime;
//     });
//   }

//   void _connectWebSocket() {
//     _channel = WebSocketChannel.connect(
//       Uri.parse('ws://192.168.173.155:5000'),
//     );

//     _channel.stream.listen(
//       (data) {
//         final message = jsonDecode(data);

//         switch (message['type']) {
//           case 'latestPayment':
//             _handleLatestPayment(message);
//             break;
//           case 'appointmentCount':
//             _handleAppointmentCount(message);
//             break;
//           case 'labReports':
//             _handleLabReports(message);
//             break;
//         }
//       },
//       onError: (error) {
//         print("WebSocket error: $error");
//       },
//       onDone: () {
//         print("WebSocket connection closed.");
//       },
//     );
//   }

//   void _handleLatestPayment(dynamic message) {
//     setState(() {
//       final patientId = message['patientId'];
//       if (_patientPayments.containsKey(patientId)) {
//         _patientPayments[patientId]!.add(message);
//       } else {
//         _patientPayments[patientId] = [message];
//       }
//     });
//   }

//   void _handleAppointmentCount(dynamic message) {
//     setState(() {
//       _appointmentCount = message['count'];
//     });
//   }

//   void _handleLabReports(dynamic message) {
//     setState(() {
//       final patientId = message['patientId'];
//       if (_labReports.containsKey(patientId)) {
//         _labReports[patientId]!.add(message);
//       } else {
//         _labReports[patientId] = [message];
//       }
//     });
//   }

//   void _toggleDetails() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   void _toggleLabDetails() {
//     setState(() {
//       _isLabExpanded = !_isLabExpanded;
//       if (_isLabExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _channel.sink.close();
//     _animationController.dispose();
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
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _patientPayments.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: _patientPayments.length,
//                           itemBuilder: (context, index) {
//                             final patientId = _patientPayments.keys.elementAt(index);
//                             final payments = _patientPayments[patientId]!;
//                             return ListTile(
//                               leading: const Icon(Icons.person),
//                               title: Text('Patient ID: $patientId'),
//                               subtitle: Text('Payments: ${payments.length}'),
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
//                 Navigator.pop(context);
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
//             Card(
//               color: Colors.blue[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text('Total: $_appointmentCount', style: const TextStyle(fontSize: 16)),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select Appointment'),
//                       value: _selectedAppointmentDetails?['appointmentId'],
//                       items: _patientPayments.keys.map((patientId) {
//                         return DropdownMenuItem<String>(
//                           value: patientId,
//                           child: Text('Patient ID: $patientId'),
//                         );
//                       }).toList(),
//                       onChanged: (patientId) {
//                         setState(() {
//                           _selectedAppointmentDetails = {
//                             'appointmentId': patientId,
//                             'details': _patientPayments[patientId],
//                           };
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Lab Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select Lab Report'),
//                       value: _selectedLabReportDetails?['patientId'],
//                       items: _labReports.keys.map((patientId) {
//                         return DropdownMenuItem<String>(
//                           value: patientId,
//                           child: Text('Patient ID: $patientId'),
//                         );
//                       }).toList(),
//                       onChanged: (patientId) {
//                         setState(() {
//                           _selectedLabReportDetails = {
//                             'patientId': patientId,
//                             'reports': _labReports[patientId],
//                           };
//                         });
//                       },
//                     ),
//                     _selectedLabReportDetails != null
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               for (var report in _selectedLabReportDetails!['reports'])
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Report ID: ${report['reportId']}'),
//                                     Text('Status: ${report['status']}'),
//                                     const Divider(),
//                                   ],
//                                 )
//                             ],
//                           )
//                         : const SizedBox.shrink(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'dart:async';
// import 'doctor_profile_page.dart';
// import 'login_page.dart';
// import 'package:http/http.dart' as http; // Add this for HTTP requests

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
//   String _formattedTime = ''; // Holds the current time
//   bool _isActive = true; // Toggle button state
//   Map<String, List<dynamic>> _patientPayments = {}; // Group payments by patient ID
//   Map<String, List<dynamic>> _labReports = {}; // Group lab reports by patient ID
//   int _appointmentCount = 0; // Holds appointment count
//   Map<String, dynamic>? _selectedAppointmentDetails; // Selected appointment details
//   Map<String, dynamic>? _selectedLabReportDetails; // Selected lab report details
//   late WebSocketChannel _channel; // WebSocket channel
//   bool _isExpanded = false; // Toggle for payments animation
//   bool _isLabExpanded = false; // Toggle for lab report animation
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _updateTime(); // Initialize time updating
//     _connectWebSocket(); // Connect to WebSocket for updates

//     Timer.periodic(Duration(seconds: 1), (timer) {
//       _updateTime();
//     });

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

//     _fetchReports(); // Fetch lab reports when the dashboard initializes
//   }

//   void _updateTime() {
//     final String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
//     setState(() {
//       _formattedTime = formattedTime;
//     });
//   }

//   void _connectWebSocket() {
//     _channel = WebSocketChannel.connect(
//       Uri.parse('ws://192.168.173.155:3000'),
//     );

//     _channel.stream.listen(
//       (data) {
//         final message = jsonDecode(data);

//         switch (message['type']) {
//           case 'latestPayment':
//             _handleLatestPayment(message);
//             break;
//           case 'appointmentCount':
//             _handleAppointmentCount(message);
//             break;
//           case 'labReports':
//             _handleLabReports(message);
//             break;
//         }
//       },
//       onError: (error) {
//         print("WebSocket error: $error");
//       },
//       onDone: () {
//         print("WebSocket connection closed.");
//       },
//     );
//   }

//   void _handleLatestPayment(dynamic message) {
//     setState(() {
//       final patientId = message['patientId'];
//       if (_patientPayments.containsKey(patientId)) {
//         _patientPayments[patientId]!.add(message);
//       } else {
//         _patientPayments[patientId] = [message];
//       }
//     });
//   }

//   void _handleAppointmentCount(dynamic message) {
//     setState(() {
//       _appointmentCount = message['count'];
//     });
//   }

//   void _handleLabReports(dynamic message) {
//     setState(() {
//       final patientId = message['patientId'];
//       if (_labReports.containsKey(patientId)) {
//         _labReports[patientId]!.add(message);
//       } else {
//         _labReports[patientId] = [message];
//       }
//     });
//   }

//   Future<void> _fetchReports() async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.173.155:3000/reports'));
//       if (response.statusCode == 200) {
//         final List fetchedReports = jsonDecode(response.body);
//         setState(() {
//           _labReports = {}; // Reset existing reports
//           for (var report in fetchedReports) {
//             final patientId = report['patientId'];
//             if (_labReports.containsKey(patientId)) {
//               _labReports[patientId]!.add(report);
//             } else {
//               _labReports[patientId] = [report];
//             }
//           }
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch reports. Error: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching reports: $e')),
//       );
//     }
//   }

//   void _toggleDetails() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   void _toggleLabDetails() {
//     setState(() {
//       _isLabExpanded = !_isLabExpanded;
//       if (_isLabExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _channel.sink.close();
//     _animationController.dispose();
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
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return _patientPayments.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: _patientPayments.length,
//                           itemBuilder: (context, index) {
//                             final patientId = _patientPayments.keys.elementAt(index);
//                             final payments = _patientPayments[patientId]!;

//                             return ListTile(
//                               leading: const Icon(Icons.person),
//                               title: Text('Patient ID: $patientId'),
//                               subtitle: Text('Payments: ${payments.length}'),
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
//                 Navigator.pop(context);
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
//             Card(
//               color: Colors.blue[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text('Total: $_appointmentCount', style: const TextStyle(fontSize: 16)),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select Appointment'),
//                       value: _selectedAppointmentDetails?['appointmentId'],
//                       items: _patientPayments.keys.map((patientId) {
//                         return DropdownMenuItem<String>(
//                           value: patientId,
//                           child: Text('Patient ID: $patientId'),
//                         );
//                       }).toList(),
//                       onChanged: (patientId) {
//                         setState(() {
//                           _selectedAppointmentDetails = {
//                             'appointmentId': patientId,
//                             'details': _patientPayments[patientId],
//                           };
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Lab Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select Lab Report'),
//                       value: _selectedLabReportDetails?['patientId'],
//                       items: _labReports.keys.map((patientId) {
//                         return DropdownMenuItem<String>(
//                           value: patientId,
//                           child: Text('Patient ID: $patientId'),
//                         );
//                       }).toList(),
//                       onChanged: (patientId) {
//                         setState(() {
//                           _selectedLabReportDetails = {
//                             'patientId': patientId,
//                             'reports': _labReports[patientId],
//                           };
//                         });
//                       },
//                     ),
//                     _selectedLabReportDetails != null
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               for (var report in _selectedLabReportDetails!['reports'])
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Report ID: ${report['reportId']}'),
//                                     Text('Status: ${report['status']}'),
//                                     const Divider(),
//                                   ],
//                                 )
//                             ],
//                           )
//                         : const SizedBox.shrink(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
