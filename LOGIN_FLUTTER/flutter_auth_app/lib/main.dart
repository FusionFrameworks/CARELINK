
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'RegistrationPage.dart';
import 'splashscreen.dart';
import 'lab_technician_login.dart';
import 'lab_technician_register.dart'; 
import 'user_type_selection_page.dart';
import 'technician_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      initialRoute: '/splash', 
      // Set initial route to splash
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/labtechnicianlogin': (context) => LabTechnicianLoginPage(),
        '/labtechnicianRegister': (context) => LabTechnicianRegistrationPage(),
        '/userTypeSelection': (context) => const UserTypeSelectionPage(),
         '/LabTechnicianProfile': (context) => const LabTechnicianProfile(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
              fontSize: 16,
              color: Colors.black), // Replaced bodyText2 with bodyMedium
        ),
      ),
    );
  }
}

// SplashScreen class defined separately in splashscreen.dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller to control the animation duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Animation lasts for 3 seconds
    );

    // Opacity animation from 0 (invisible) to 1 (fully visible)
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Scale animation: starts large, bounces, then settles
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Start the animation
    _controller.forward();

    // Navigate to user type selection after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/userTypeSelection');
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to Care Link',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5), // Adjusted space
                    Image.asset('assets/doc.png',
                        width: 800), // Adjusted logo size
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
