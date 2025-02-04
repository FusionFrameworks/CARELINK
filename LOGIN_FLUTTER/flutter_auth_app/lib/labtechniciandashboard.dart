import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'technician_profile.dart';

class LabTechnicianDashboard extends StatefulWidget {
  const LabTechnicianDashboard({super.key});

  @override
  _LabTechnicianDashboardState createState() => _LabTechnicianDashboardState();
}

class _LabTechnicianDashboardState extends State<LabTechnicianDashboard> {
  List<Map<String, dynamic>> reports = [];

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/userTypeSelection', 
          (route) => false,
        );
      }
    }
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('https://l7xqlqhl-3000.inc1.devtunnels.ms/reports')); //replace with ipadress to run on local
      if (response.statusCode == 200) {
        final List fetchedReports = jsonDecode(response.body);
        setState(() {
          reports = fetchedReports
              .map((report) => {
                    'id': report['_id'],
                    'fileName': report['fileName'] ?? 'No file name available',
                    'filePath': report['filePath'] ?? '',
                    'uploadDate': report['uploadDate'] ?? '',
                  })
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch reports. Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e')),
      );
    }
  }

  Future<void> _uploadLabReport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://l7xqlqhl-3000.inc1.devtunnels.ms/upload'),  //replace with ipadress to run on local
        );
        request.files.add(await http.MultipartFile.fromPath('labReport', file.path));

        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File "$fileName" uploaded successfully')),
          );
          _fetchReports(); // Refresh reports after uploading
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload "$fileName"')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading "$fileName": $e')),
        );
      }
    }
  }

  Future<void> _deleteReport(String id) async {
    try {
      final response = await http.delete(Uri.parse('https://l7xqlqhl-3000.inc1.devtunnels.ms/reports/$id'));  //replace with ipadress to run on local
      if (response.statusCode == 200) {
        setState(() {
          reports.removeWhere((report) => report['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete report. Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e')),
      );
    }
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/LabTechnicianProfile');
  }

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Technician Dashboard'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _uploadLabReport,
            child: const Text('Upload Lab Report'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  child: ListTile(
                    title: Text(report['fileName']),
                    subtitle: Text('Uploaded on: ${report['uploadDate']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteReport(report['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
              onTap: () => _editProfile(context),
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

