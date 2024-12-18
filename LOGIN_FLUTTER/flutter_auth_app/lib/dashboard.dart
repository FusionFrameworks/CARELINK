// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'doctor_profile_page.dart';
// import 'login_page.dart';

// class Dashboard extends StatefulWidget {
//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
//   String _formattedTime = '';
//   int _appointmentCount = 0;
//   Map<String, List<dynamic>> _patientPayments = {};
//   Map<String, dynamic>? _selectedAppointmentDetails;
//   List<dynamic> _labReports = [];
//   Map<String, dynamic>? _selectedLabReport;
//   late WebSocketChannel _channel;
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _updateTime();
//     _connectWebSocket();
//     _fetchInitialReports();

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
//           case 'updateReports':
//             _handleUpdateReports(message);
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

//   Future<void> _fetchInitialReports() async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.173.155:3000/reports'));
//       if (response.statusCode == 200) {
//         final List<dynamic> reports = jsonDecode(response.body);
//         setState(() {
//           _labReports = reports;
//         });
//       } else {
//         print('Failed to fetch reports: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching reports: $error');
//     }
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

//   void _handleUpdateReports(dynamic message) {
//     try {
//       setState(() {
//         _labReports = List<Map<String, dynamic>>.from(message['Updated Reports']);
//       });
//     } catch (error) {
//       print('Error handling updated reports: $error');
//     }
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
//             // Appointments Card
//             Card(
//               color: Colors.blue[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Appointments',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text('Total: $_appointmentCount',
//                         style: const TextStyle(fontSize: 16)),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select an Appointment'),
//                       value: _selectedAppointmentDetails?['patientId'],
//                       items: _patientPayments.keys.map<DropdownMenuItem<String>>((patientId) {
//                         return DropdownMenuItem<String>(
//                           value: patientId,
//                           child: Text('Patient ID: $patientId'),
//                         );
//                       }).toList(),
//                       onChanged: (patientId) {
//                         setState(() {
//                           _selectedAppointmentDetails = {
//                             'patientId': patientId,
//                             'payments': _patientPayments[patientId],
//                           };
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // Lab Reports Card
//             Card(
//               color: Colors.green[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Lab Reports',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     DropdownButton<String>(
//                       isExpanded: true,
//                       hint: const Text('Select a Lab Report'),
//                       value: _selectedLabReport?['_id'],
//                       items: _labReports.map<DropdownMenuItem<String>>((report) {
//                         return DropdownMenuItem<String>(
//                           value: report['_id'],
//                           child: Text(report['fileName']),
//                         );
//                       }).toList(),
//                       onChanged: (id) {
//                         setState(() {
//                           _selectedLabReport = _labReports.firstWhere(
//                             (report) => report['_id'] == id,
//                           );
//                         });
//                       },
//                     ),
//                     if (_selectedLabReport != null) ...[
//                       const SizedBox(height: 10),
//                       Text('Details for: ${_selectedLabReport!['fileName']}'),
//                       Text('Path: ${_selectedLabReport!['filePath']}'),
//                       Text('Uploaded: ${DateFormat.yMMMd().add_jm().format(
//                         DateTime.parse(_selectedLabReport!['uploadDate']),
//                       )}'),
//                     ],
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


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'doctor_profile_page.dart';
import 'login_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  String _formattedTime = '';
  int _appointmentCount = 0;
  bool _isActive = true;
  Map<String, List<dynamic>> _patientPayments = {};
  Map<String, dynamic>? _selectedAppointmentDetails;
  bool _showAppointmentDetails = false;
  List<dynamic> _labReports = [];
  Map<String, dynamic>? _selectedLabReport;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _connectWebSocket();
    _fetchInitialReports();

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

  Future<void> _fetchInitialReports() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.173.155:3000/reports'));
      if (response.statusCode == 200) {
        final List<dynamic> reports = jsonDecode(response.body);
        setState(() {
          _labReports = reports;
        });
      } else {
        print('Failed to fetch reports: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reports: $error');
    }
  }

  void _handleLatestPayment(dynamic message) {
    setState(() {
      final patientId = message['patientId'];
      if (_patientPayments.containsKey(patientId)) {
        _patientPayments[patientId]!.add(message);
      } else {
        _patientPayments[patientId] = [message];
      }
    });
  }

  void _handleAppointmentCount(dynamic message) {
    setState(() {
      _appointmentCount = message['count'];
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
            // Appointments Card
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
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select an Appointment'),
                      value: _selectedAppointmentDetails?['patientId'],
                      items: _patientPayments.keys.map<DropdownMenuItem<String>>((patientId) {
                        final name = _patientPayments[patientId]?[0]['patientDetails']['name'] ?? 'Unknown';
                        return DropdownMenuItem<String>(
                          value: patientId,
                          child: Text('Patient ID: $patientId - Name: $name'),
                        );
                      }).toList(),
                      onChanged: (patientId) {
                        setState(() {
                          _selectedAppointmentDetails = {
                            'patientId': patientId,
                            'payments': _patientPayments[patientId],
                          };
                          _showAppointmentDetails = false;
                        });
                      },
                    ),
                    if (_selectedAppointmentDetails != null) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAppointmentDetails = !_showAppointmentDetails;
                          });
                        },
                        child: Text(_showAppointmentDetails ? 'Hide Details' : 'Show Details'),
                      ),
                      if (_showAppointmentDetails)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (
                            _selectedAppointmentDetails!['payments'] as List
                          ).map((payment) {
                            final name = payment['patientDetails']['name'] ?? 'Unknown';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient Name: $name'),
                                  Text('Payment ID: ${payment['paymentId']}'),
                                  Text('Status: ${payment['status']}'),
                                  Text('Created At: ${payment['createdAt']}'),
                                  const Divider(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Lab Reports Card
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lab Reports',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select a Lab Report'),
                      value: _selectedLabReport?['_id'],
                      items: _labReports.map<DropdownMenuItem<String>>((report) {
                        return DropdownMenuItem<String>(
                          value: report['_id'],
                          child: Text(report['fileName']),
                        );
                      }).toList(),
                      onChanged: (id) {
                        setState(() {
                          _selectedLabReport = _labReports.firstWhere(
                            (report) => report['_id'] == id,
                          );
                        });
                      },
                    ),
                    if (_selectedLabReport != null) ...[
                      const SizedBox(height: 10),
                      Text('Details for: ${_selectedLabReport!['fileName']}'),
                      Text('Path: ${_selectedLabReport!['filePath']}'),
                      Text('Uploaded: ${DateFormat.yMMMd().add_jm().format(
                        DateTime.parse(_selectedLabReport!['uploadDate']),
                      )}'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}