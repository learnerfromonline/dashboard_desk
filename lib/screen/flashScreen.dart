import 'dart:async';
import 'package:dashboard_desk/screen/ui_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this dependency in your pubspec.yaml file

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Main Screen after 4 seconds
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => UiScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background with gradient colors
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.red.shade700,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Image with animation
              Image.asset(
                'assets/sasi.png', // Replace with your logo
                width: 150,
              )
                  .animate() // Animation chain starts here
                  .scale(
                      duration: 1000.ms, curve: Curves.elasticOut) // Elastic scale animation
                  .fadeIn(duration: 1000.ms, curve: Curves.easeIn), // Fade-in effect
              SizedBox(height: 20),

              // Animated Text with white gradient
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.redAccent,
                      Colors.black,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  "All In One ToolKit",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 13, 13, 13), // Use white as placeholder for gradient
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1200.ms, curve: Curves.easeIn) // Fade-in animation
                    .slideY(begin: 0.5, duration: 1000.ms), // Slide up animation
              ),
              SizedBox(height: 70),

              // Pulsating Circular Progress Indicator
              CircularProgressIndicator(
                color: Colors.red.shade700,
                strokeWidth: 3,
              )
                  .animate()
                  .scale(
                      begin: Offset(1.0, 1.0),
                      end: Offset(1.1, 1.1),
                      duration: 500.ms) // Pulsating scale animation
                  .rotate(),
            ],
          ),
        ),
      ),
    );
  }
}
