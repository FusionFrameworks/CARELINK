import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:animate_do/animate_do.dart'; // For animations
import 'doctor_profile_page.dart';
import 'login_page.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add GlobalKey

  @override
  void initState() {
    super.initState();
    _updateTime();
    _connectWebSocket();
    _fetchInitialReports();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WebSocket error: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      onDone: () {
        print("WebSocket connection closed.");
      },
    );
  }

  Future<void> _fetchInitialReports() async {
    try {
      final response = await http.get(Uri.parse('https://l7xqlqhl-3000.inc1.devtunnels.ms/reports'));
      if (response.statusCode == 200) {
        final List<dynamic> reports = jsonDecode(response.body);
        setState(() {
          _labReports = reports;
        });
      } else {
        print('Failed to fetch reports: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch reports: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (error) {
      print('Error fetching reports: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching reports: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
      key: _scaffoldKey, // Assign GlobalKey to Scaffold
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade800,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer(); // Use GlobalKey to open drawer
                        },
                      ),
                      Text(
                        'Doctor Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.blueAccent.withOpacity(0.5),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.black.withOpacity(0.8),
                            builder: (BuildContext context) {
                              return _patientPayments.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _patientPayments.length,
                                      itemBuilder: (context, index) {
                                        final patientId = _patientPayments.keys.elementAt(index);
                                        final payments = _patientPayments[patientId]!;
                                        return _buildNotificationTile(
                                          patientId: patientId,
                                          paymentCount: payments.length,
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'No new notifications.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Time Display
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: _buildTimeCard(),
                      ),
                      const SizedBox(height: 20),
                      // Appointments Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: _buildAppointmentsCard(),
                      ),
                      const SizedBox(height: 20),
                      // Lab Reports Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: _buildLabReportsCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 24),
          const SizedBox(width: 10),
          Text(
            'Current Time: $_formattedTime',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 24),
              const SizedBox(width: 10),
              Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Total: $_appointmentCount',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
            ),
            dropdownColor: Colors.black.withOpacity(0.8),
            hint: Text(
              'Select an Appointment',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            value: _selectedAppointmentDetails?['patientId'],
            items: _patientPayments.keys.map<DropdownMenuItem<String>>((patientId) {
              final name = _patientPayments[patientId]?[0]['patientDetails']['name'] ?? 'Unknown';
              return DropdownMenuItem<String>(
                value: patientId,
                child: Text(
                  'Patient ID: $patientId - Name: $name',
                  style: const TextStyle(color: Colors.white),
                ),
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
            _buildFuturisticButton(
              label: _showAppointmentDetails ? 'Hide Details' : 'Show Details',
              icon: _showAppointmentDetails ? Icons.visibility_off : Icons.visibility,
              onTap: () {
                setState(() {
                  _showAppointmentDetails = !_showAppointmentDetails;
                });
              },
            ),
            if (_showAppointmentDetails)
              FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (_selectedAppointmentDetails!['payments'] as List).map((payment) {
                    final name = payment['patientDetails']['name'] ?? 'Unknown';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient Name: $name', style: const TextStyle(color: Colors.white)),
                            Text('Payment ID: ${payment['paymentId']}', style: const TextStyle(color: Colors.white)),
                            Text('Status: ${payment['status']}', style: const TextStyle(color: Colors.white)),
                            Text('Created At: ${payment['createdAt']}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabReportsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.white70, size: 24),
              const SizedBox(width: 10),
              Text(
                'Lab Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              prefixIcon: const Icon(Icons.file_copy, color: Colors.white70),
            ),
            dropdownColor: Colors.black.withOpacity(0.8),
            hint: Text(
              'Select a Lab Report',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            value: _selectedLabReport?['_id'],
            items: _labReports.map<DropdownMenuItem<String>>((report) {
              return DropdownMenuItem<String>(
                value: report['_id'],
                child: Text(
                  report['fileName'],
                  style: const TextStyle(color: Colors.white),
                ),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details for: ${_selectedLabReport!['fileName']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Path: ${_selectedLabReport!['filePath']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Uploaded: ${DateFormat.yMMMd().add_jm().format(
                      DateTime.parse(_selectedLabReport!['uploadDate']),
                    )}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.8),
                  Colors.purpleAccent.withOpacity(0.8),
                ],
              ),
            ),
            child: FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.blueAccent.withOpacity(0.5),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorProfile()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 1000),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String patientId,
    required int paymentCount,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient ID: $patientId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Payments: $paymentCount',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturisticButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.8),
              Colors.purpleAccent.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}