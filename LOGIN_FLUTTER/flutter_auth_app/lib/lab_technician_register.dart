import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart'; // For animations
import 'lab_technician_login.dart'; // Import the LoginPage

class LabTechnicianRegistrationPage extends StatefulWidget {
  const LabTechnicianRegistrationPage({super.key});

  @override
  _LabTechnicianRegistrationPageState createState() =>
      _LabTechnicianRegistrationPageState();
}

class _LabTechnicianRegistrationPageState
    extends State<LabTechnicianRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController technicianNameController = TextEditingController();
  bool _isLoading = false; // Track loading state

  Future<void> submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();
      String technicianName = technicianNameController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(
              'https://l7xqlqhl-3000.inc1.devtunnels.ms/labtechnicians/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
            'technicianName': technicianName,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          var jsonResponse = json.decode(response.body);

          if (jsonResponse['message'] ==
              "Lab technician registered successfully") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful'),
                backgroundColor: Colors.greenAccent,
              ),
            );

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LabTechnicianLoginPage(),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${jsonResponse['message']}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Server Error (${response.statusCode}): ${response.reasonPhrase}',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not connect to server'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    technicianNameController.dispose();
    super.dispose();
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Lab Technician Registration',
                        style: TextStyle(
                          fontSize: 32,
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
                    ),
                    const SizedBox(height: 40),
                    // Technician Name Field
                    FadeInLeft(
                      duration: const Duration(milliseconds: 1000),
                      child: _buildTextField(
                        controller: technicianNameController,
                        label: 'Technician Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    FadeInRight(
                      duration: const Duration(milliseconds: 1000),
                      child: _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    FadeInLeft(
                      duration: const Duration(milliseconds: 1200),
                      child: _buildTextField(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirm Password Field
                    FadeInRight(
                      duration: const Duration(milliseconds: 1200),
                      child: _buildTextField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Register Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: _buildFuturisticButton(
                        context,
                        label: 'Register',
                        icon: Icons.app_registration,
                        isLoading: _isLoading,
                        onTap: submitRegistration,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 1600),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LabTechnicianLoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 250,
        height: 60,
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
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 18,
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