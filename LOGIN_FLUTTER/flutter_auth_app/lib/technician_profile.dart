import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LabTechnicianProfile extends StatefulWidget {
  const LabTechnicianProfile({super.key});

  @override
  _LabTechnicianProfileState createState() => _LabTechnicianProfileState();
}

class _LabTechnicianProfileState extends State<LabTechnicianProfile> {
  String email = '';
  String password = '';
  bool isEditMode = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      password = prefs.getString('password') ?? '';

      // Initialize the text controllers with current profile data
      emailController.text = email;
      passwordController.text = password;
    });
  }

  Future<void> _updateUserProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/labtechnician/profile'), // Ensure the URL is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      print("API Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Update SharedPreferences with new data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);

        setState(() {
          email = emailController.text;
          password = passwordController.text;
          isEditMode = false; // Exit edit mode
        });

        // Navigate back to the previous screen
        Navigator.pop(context);
      } else {
        print('Failed to update profile: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Technician Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateUserProfile, // Update profile and navigate back
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditMode = true; // Enter edit mode
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditMode ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileRow('Email', email),
        _buildProfileRow('Password', password),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableRow('Email', emailController),
        _buildEditableRow('Password', passwordController),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
