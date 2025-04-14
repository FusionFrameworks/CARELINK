import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // For animations

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
  bool _isLoading = false; // Track loading state

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

      doctorNameController.text = doctorName;
      specializationController.text = specialization;
      experienceController.text = experience.toString();
      hospitalNameController.text = hospitalName;
    });
  }

  Future<void> _updateUserProfile() async {
    if (doctorNameController.text.isEmpty ||
        specializationController.text.isEmpty ||
        experienceController.text.isEmpty ||
        hospitalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (int.tryParse(experienceController.text) == null ||
        int.parse(experienceController.text) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid experience value'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('https://l7xqlqhl-3000.inc1.devtunnels.ms/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'doctorName': doctorNameController.text.trim(),
          'specialization': specializationController.text.trim(),
          'experience': int.parse(experienceController.text),
          'hospitalName': hospitalNameController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('doctorName', doctorNameController.text.trim());
        await prefs.setString('specialization', specializationController.text.trim());
        await prefs.setInt('experience', int.parse(experienceController.text));
        await prefs.setString('hospitalName', hospitalNameController.text.trim());

        setState(() {
          doctorName = doctorNameController.text.trim();
          specialization = specializationController.text.trim();
          experience = int.parse(experienceController.text);
          hospitalName = hospitalNameController.text.trim();
          isEditMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.greenAccent,
          ),
        );
      } else {
        print('Failed to update profile: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Doctor Profile',
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
                        icon: Icon(
                          isEditMode ? Icons.check : Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: isEditMode ? _updateUserProfile : () {
                          setState(() {
                            isEditMode = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isEditMode ? _buildEditMode() : _buildViewMode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard('Email', email, Icons.email),
          const SizedBox(height: 20),
          _buildProfileCard('Doctor Name', doctorName, Icons.person),
          const SizedBox(height: 20),
          _buildProfileCard('Specialization', specialization, Icons.medical_services),
          const SizedBox(height: 20),
          _buildProfileCard('Experience', '$experience years', Icons.work_history),
          const SizedBox(height: 20),
          _buildProfileCard('Hospital', hospitalName, Icons.local_hospital),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditableField(
            label: 'Doctor Name',
            controller: doctorNameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Specialization',
            controller: specializationController,
            icon: Icons.medical_services,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Experience (years)',
            controller: experienceController,
            icon: Icons.work_history,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: 'Hospital',
            controller: hospitalNameController,
            icon: Icons.local_hospital,
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String label, String value, IconData icon) {
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
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}