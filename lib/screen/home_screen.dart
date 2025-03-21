import 'package:dashboard_desk/screen/Calculators/calc_home.dart';
import 'package:dashboard_desk/screen/image_compressor.dart';
import 'package:dashboard_desk/screen/image_to_pdf.dart';
import 'package:dashboard_desk/screen/m3u8_video_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // For animations

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All-In-One Toolkit",style: GoogleFonts.adventPro(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Heading with animation
              Text(
                "Welcome to All-In-One Toolkit",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .slideY(begin: -0.3), // Slide down animation
              SizedBox(height: 20),

              // Video Player Section
              _featureCard(
                nav: VideoPlayerScreen(),
                title: "Video Player",
                description:
                    "Watch videos seamlessly with our integrated video player.",
                imagePath: "assets/videoplayer.gif", // Replace with your image path
              ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.2), // Slide left animation
              SizedBox(height: 16),

              // Image to PDF Converter Section
              _featureCard(
                nav: ImageToPdf(),
                title: "Image to PDF Converter",
                description:
                    "Easily convert your images into high-quality PDF files.",
                imagePath: "assets/imagetopdf.jpg", // Replace with your image path
              ).animate().fadeIn(duration: 1200.ms).slideX(begin: 0.2), // Slide right animation
              SizedBox(height: 16),

              // Image Compressor Section
              _featureCard(
                nav: ImageCompressorScreen(),
                title: "Image Compressor",
                description:
                    "Compress images to save space without losing quality.",
                imagePath: "assets/imagecompress.png", // Replace with your image path
              ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.2), // Slide left animation
              SizedBox(height: 16),

              // Calculator Section
              _featureCard(
                nav: CalcHomeScreen(),
                title: "All Types of Calculators",
                description:
                    "Perform various calculations, from scientific to financial.",
                imagePath: "assets/calculator.png", // Replace with your image path
              ).animate().fadeIn(duration: 1200.ms).slideX(begin: 0.2), // Slide right animation
              SizedBox(height: 20),

              // Footer
              Text(
                "Explore the best tools for your daily needs!",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              )
                  .animate()
                  .fadeIn(duration: 1500.ms)
                  .slideY(begin: 0.3), // Slide up animation
            ],
          ),
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget _featureCard({
    required String title,
    required String description,
    required String imagePath,
    required Widget nav,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nav),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feature Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath, // Replace with actual asset paths
                  height: 180,
                  width: 180,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 16),
      
              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 58),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
