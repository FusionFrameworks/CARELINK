import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class LabTechnicianDashboard extends StatefulWidget {
  const LabTechnicianDashboard({Key? key}) : super(key: key);

  @override
  State<LabTechnicianDashboard> createState() => _LabTechnicianDashboardState();
}

class _LabTechnicianDashboardState extends State<LabTechnicianDashboard> {
  List<Map<String, dynamic>> reports = [];

  // Fetch reports from the backend
  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.228.62:3000/reports'));
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

  // Upload Lab report
  Future<void> _uploadLabReport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.228.62:3000/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('labReport', file.path));

        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
          _fetchReports(); // Refresh reports after uploading
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload file')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  // Delete report by ID
  Future<void> _deleteReport(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://192.168.228.62:3000/reports/$id'));
      if (response.statusCode == 200) {
        setState(() {
          reports.removeWhere((report) => report['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report deleted successfully.')),
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
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Upload Button
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: _uploadLabReport,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Lab Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: reports.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 40,
                              ),
                              title: Text(
                                report['fileName'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Uploaded on: ${report['uploadDate']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.teal),
                                    onPressed: report['filePath'].isNotEmpty
                                        ? () {
                                            // Handle download logic
                                            print('Download: ${report['filePath']}');
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteReport(report['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}