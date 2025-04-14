import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // For animations (add to pubspec.yaml)

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header with futuristic animation
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Choose Your Role',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
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
                // Doctor Button
                FadeInLeft(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildFuturisticButton(
                    context,
                    label: 'Doctor',
                    icon: Icons.medical_services,
                    route: '/login',
                  ),
                ),
                const SizedBox(height: 20),
                // Lab Technician Button
                FadeInRight(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildFuturisticButton(
                    context,
                    label: 'Lab Technician',
                    icon: Icons.science,
                    route: '/labtechnicianlogin',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 300,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.7),
                  Colors.purpleAccent.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushNamed(context, route);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
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
}