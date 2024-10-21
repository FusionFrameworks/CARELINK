import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Import the LoginPage

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>(); // New key for Step 2

  String email = '';
  String password = '';
  String confirmPassword = '';
  String doctorName = '';
  String specialization = '';
  String experience = '';
  String hospitalName = '';

  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();

 Future<void> submitRegistration() async {
  if (_formKey2.currentState!.validate()) {
    // Validate that passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Prepare data to send to the server
    doctorName = doctorNameController.text;
    specialization = specializationController.text;
    experience = experienceController.text;
    hospitalName = hospitalNameController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/register'), // Update this with your server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'doctorName': doctorName,
          'specialization': specialization,
          'experience': experience,
          'hospitalName': hospitalName,
        }),
      );

      // Debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the response from the server
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] == "User registered successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful')),
          );

          // Navigate to the Login Page after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
    }
  }
}

  void nextPage() {
    if (_formKey1.currentState!.validate()) {
      // Validate Step 1 form
      email = emailController.text;
      password = passwordController.text;
      confirmPassword = confirmPasswordController.text;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    doctorNameController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    hospitalNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          Step1(
            onNext: nextPage,
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            formKey: _formKey1, // Pass the form key for Step 1
          ),
          Step2(
            onNext: submitRegistration,
            onBack: previousPage,
            doctorNameController: doctorNameController,
            specializationController: specializationController,
            experienceController: experienceController,
            hospitalNameController: hospitalNameController,
            formKey: _formKey2, // Pass the form key for Step 2
          ),
        ],
      ),
    );
  }
}

class Step1 extends StatelessWidget {
  final Function onNext;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey; // Add formKey parameter

  Step1({
    required this.onNext,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey, // Accept formKey
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey, // Assign the form key
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm your password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 221, 243), // Change to your desired color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class Step2 extends StatelessWidget {
  final Function onNext;
  final Function onBack;
  final TextEditingController doctorNameController;
  final TextEditingController specializationController;
  final TextEditingController experienceController;
  final TextEditingController hospitalNameController;
  final GlobalKey<FormState> formKey; // Add formKey parameter

  Step2({
    required this.onNext,
    required this.onBack,
    required this.doctorNameController,
    required this.specializationController,
    required this.experienceController,
    required this.hospitalNameController,
    required this.formKey, // Accept formKey
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey, // Assign the form key
        child: Column(
          children: [
            TextFormField(
              controller: doctorNameController,
              decoration: InputDecoration(
                labelText: 'Doctor Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: specializationController,
              decoration: InputDecoration(
                labelText: 'Specialization',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your specialization';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: experienceController,
              decoration: InputDecoration(
                labelText: 'Experience (years)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your experience';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: hospitalNameController,
              decoration: InputDecoration(
                labelText: 'Hospital Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your hospital name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onBack(); // Call the back function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Change to your desired color
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onNext(); // Call the next function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 221, 243), // Change to your desired color
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
