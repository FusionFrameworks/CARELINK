import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart'; // For animations
import 'login_page.dart'; // Import the LoginPage

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String doctorName = '';
  String specialization = '';
  String experience = '';
  String hospitalName = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  bool _isLoading = false; // Track loading state

  Future<void> submitRegistration() async {
    if (_formKey2.currentState!.validate()) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      doctorName = doctorNameController.text.trim();
      specialization = specializationController.text.trim();
      experience = experienceController.text.trim();
      hospitalName = hospitalNameController.text.trim();

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http:10.0.2.2:3000/doctors/register'),
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

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['message'] == "User registered successfully") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful'),
                backgroundColor: Colors.greenAccent,
              ),
            );

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to register: ${jsonResponse['message']}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server Error (${response.statusCode}): ${response.body}'),
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

  void nextPage() {
    if (_formKey1.currentState!.validate()) {
      email = emailController.text.trim();
      password = passwordController.text.trim();
      confirmPassword = confirmPasswordController.text.trim();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    doctorNameController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    hospitalNameController.dispose();
    _pageController.dispose();
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
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
            children: [
              Step1(
                onNext: nextPage,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                formKey: _formKey1,
              ),
              Step2(
                onNext: submitRegistration,
                onBack: previousPage,
                doctorNameController: doctorNameController,
                specializationController: specializationController,
                experienceController: experienceController,
                hospitalNameController: hospitalNameController,
                formKey: _formKey2,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Step1 extends StatelessWidget {
  final Function onNext;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;

  const Step1({
    required this.onNext,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Text(
              'Doctor Registration - Step 1',
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
          FadeInLeft(
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
          FadeInRight(
            duration: const Duration(milliseconds: 1000),
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
          FadeInLeft(
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
          FadeInUp(
            duration: const Duration(milliseconds: 1400),
            child: _buildFuturisticButton(
              context,
              label: 'Continue',
              icon: Icons.arrow_forward,
              onTap: () => onNext(),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 1600),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
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
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const Step2({
    required this.onNext,
    required this.onBack,
    required this.doctorNameController,
    required this.specializationController,
    required this.experienceController,
    required this.hospitalNameController,
    required this.formKey,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Text(
              'Doctor Registration - Step 2',
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
          FadeInLeft(
            duration: const Duration(milliseconds: 1000),
            child: _buildTextField(
              controller: doctorNameController,
              label: 'Doctor Name',
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
          FadeInRight(
            duration: const Duration(milliseconds: 1000),
            child: _buildTextField(
              controller: specializationController,
              label: 'Specialization',
              icon: Icons.medical_services,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your specialization';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          FadeInLeft(
            duration: const Duration(milliseconds: 1200),
            child: _buildTextField(
              controller: experienceController,
              label: 'Experience (years)',
              icon: Icons.work_history,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your experience';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          FadeInRight(
            duration: const Duration(milliseconds: 1200),
            child: _buildTextField(
              controller: hospitalNameController,
              label: 'Hospital Name',
              icon: Icons.local_hospital,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your hospital name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            duration: const Duration(milliseconds: 1400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildFuturisticButton(
                    context,
                    label: 'Back',
                    icon: Icons.arrow_back,
                    onTap: () => onBack(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFuturisticButton(
                    context,
                    label: 'Register',
                    icon: Icons.app_registration,
                    onTap: () => onNext(),
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
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
    )
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