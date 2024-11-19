// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class LabTechnicianProfile extends StatefulWidget {
//   const LabTechnicianProfile({super.key});

//   @override
//   _LabTechnicianProfileState createState() => _LabTechnicianProfileState();
// }

// class _LabTechnicianProfileState extends State<LabTechnicianProfile> {
//   String email = '';
//   String password = '';
//   bool isEditMode = false;

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       setState(() {
//         email = prefs.getString('email') ?? '';
//         password = prefs.getString('password') ?? '';

//         emailController.text = email;
//         passwordController.text = password;
//       });
//     } catch (error) {
//       print('Error loading user profile: $error');
//     }
//   }

//   Future<void> _updateUserProfile() async {
//   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Email and password cannot be empty.')),
//     );
//     return;
//   }

//   try {
//     print('Updating profile...');
//     print('Email: ${emailController.text}');
//     print('Password: ${passwordController.text}');

//     final response = await http.put(
//       Uri.parse('http://10.0.2.2:3000/labtechnician/profile'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'currentEmail': email, // Pass current email for identification
//         'email': emailController.text,
//         'password': passwordController.text,
//       }),
//     );

//     print("API Response Status Code: ${response.statusCode}");
//     print("API Response Body: ${response.body}");

//     if (response.statusCode == 200) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('email', emailController.text); // Update email
//       prefs.setString('password', passwordController.text); // Update password

//       setState(() {
//         email = emailController.text;
//         password = passwordController.text;
//         isEditMode = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );

//       Navigator.pop(context);
//     } else {
//       print('Failed to update profile. Response: ${response.body}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update profile. Error: ${response.body}')),
//       );
//     }
//   } catch (error) {
//     print('Error updating profile: $error');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error updating profile. Please try again.')),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lab Technician Profile'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           if (isEditMode)
//             IconButton(
//               icon: const Icon(Icons.check),
//               onPressed: _updateUserProfile,
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 setState(() {
//                   isEditMode = true;
//                 });
//               },
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: isEditMode ? _buildEditMode() : _buildViewMode(),
//       ),
//     );
//   }

//   Widget _buildViewMode() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildProfileRow('Email', email),
//         _buildProfileRow('Password', password),
//       ],
//     );
//   }

//   Widget _buildEditMode() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildEditableRow('Email', emailController),
//         _buildEditableRow('Password', passwordController),
//       ],
//     );
//   }

//   Widget _buildProfileRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEditableRow(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







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
  String technicianName = '';
  String report = '';
  bool isEditMode = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController technicianNameController = TextEditingController();
  final TextEditingController reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        email = prefs.getString('email') ?? '';
        password = prefs.getString('password') ?? '';
        technicianName = prefs.getString('technicianName') ?? '';
        report = prefs.getString('report') ?? '';

        emailController.text = email;
        passwordController.text = password;
        technicianNameController.text = technicianName;
        reportController.text = report;
      });
    } catch (error) {
      print('Error loading user profile: $error');
    }
  }

  Future<void> _updateUserProfile() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || technicianNameController.text.isEmpty || reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    try {
      print('Updating profile...');
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');
      print('Technician Name: ${technicianNameController.text}');
      print('Report: ${reportController.text}');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/labtechnician/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentEmail': email, // Pass current email for identification
          'email': emailController.text,
          'password': passwordController.text,
          'technicianName': technicianNameController.text,
          'report': reportController.text,
        }),
      );

      print("API Response Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text); // Update email
        prefs.setString('password', passwordController.text); // Update password
        prefs.setString('technicianName', technicianNameController.text); // Update technician name
        prefs.setString('report', reportController.text); // Update report

        setState(() {
          email = emailController.text;
          password = passwordController.text;
          technicianName = technicianNameController.text;
          report = reportController.text;
          isEditMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context);
      } else {
        print('Failed to update profile. Response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile. Error: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile. Please try again.')),
      );
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
        _buildProfileRow('Email', email),
        _buildProfileRow('Password', password),
        _buildProfileRow('Technician Name', technicianName),
        _buildProfileRow('Report', report),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableRow('Email', emailController),
        _buildEditableRow('Password', passwordController),
        _buildEditableRow('Technician Name', technicianNameController),
        _buildEditableRow('Report', reportController),
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
