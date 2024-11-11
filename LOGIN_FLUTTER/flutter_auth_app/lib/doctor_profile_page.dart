//UPDATED DOCTOR-PROFILE CODE

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  String email = '';
  String doctorName = '';
  String specialization = '';
  int experience = 0;
  String hospitalName = '';
  bool isEditMode = false;

  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      doctorName = prefs.getString('doctorName') ?? '';
      specialization = prefs.getString('specialization') ?? '';
      experience = prefs.getInt('experience') ?? 0;
      hospitalName = prefs.getString('hospitalName') ?? '';

      // Initialize the text controllers with current profile data
      doctorNameController.text = doctorName;
      specializationController.text = specialization;
      experienceController.text = experience.toString();
      hospitalNameController.text = hospitalName;
    });
  }

  Future<void> _updateUserProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/profile'), // Adjust URL as needed
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'doctorName': doctorNameController.text,
          'specialization': specializationController.text,
          'experience': int.parse(experienceController.text),
          'hospitalName': hospitalNameController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Update SharedPreferences with new data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('doctorName', doctorNameController.text);
        prefs.setString('specialization', specializationController.text);
        prefs.setInt('experience', int.parse(experienceController.text));
        prefs.setString('hospitalName', hospitalNameController.text);

        setState(() {
          doctorName = doctorNameController.text;
          specialization = specializationController.text;
          experience = int.parse(experienceController.text);
          hospitalName = hospitalNameController.text;
          isEditMode = false; // Exit edit mode
        });
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
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateUserProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditMode = true;
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
        _buildProfileRow('Doctor Name', doctorName),
        _buildProfileRow('Email', email),
        _buildProfileRow('Specialization', specialization),
        _buildProfileRow('Experience', '$experience years'),
        _buildProfileRow('Hospital', hospitalName),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableRow('Doctor Name', doctorNameController),
        _buildEditableRow('Specialization', specializationController),
        _buildEditableRow('Experience', experienceController),
        _buildEditableRow('Hospital', hospitalNameController),
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
