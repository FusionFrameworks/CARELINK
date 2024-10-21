import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // To store and retrieve user data

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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Fetch the user profile from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      doctorName = prefs.getString('doctorName') ?? '';
      specialization = prefs.getString('specialization') ?? '';
      experience = prefs.getInt('experience') ?? 0;
      hospitalName = prefs.getString('hospitalName') ?? '';
    });

    // If you want to fetch the profile from the API instead, uncomment the following code
    /*
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/profile'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> profileData = json.decode(response.body);
      setState(() {
        email = profileData['email'];
        doctorName = profileData['doctorName'];
        specialization = profileData['specialization'];
        experience = profileData['experience'];
        hospitalName = profileData['hospitalName'];
      });
    } else {
      print('Failed to load profile: ${response.statusCode}');
      // Handle error response
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the Dashboard page
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor Name: $doctorName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Specialization: $specialization',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Experience: $experience years',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Hospital: $hospitalName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement edit profile functionality if needed
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
