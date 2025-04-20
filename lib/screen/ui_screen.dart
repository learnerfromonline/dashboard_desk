
import 'package:dashboard_desk/screen/Calculators/calc_home.dart';
// import 'package:dashboard_desk/screen/floppy_bird.dart';
import 'package:dashboard_desk/screen/game.dart';
import 'package:dashboard_desk/screen/google_meet.dart';
import 'package:dashboard_desk/screen/home_screen.dart';
import 'package:dashboard_desk/screen/image_to_pdf.dart';
import 'package:dashboard_desk/screen/m3u8_video_Screen.dart';


import 'package:dashboard_desk/screen/video_to_audio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_desk/widgets/sidemenuwidget.dart';
import 'package:dashboard_desk/screen/image_compressor.dart';

class UiScreen extends StatefulWidget {
  const UiScreen({super.key});

  @override
  State<UiScreen> createState() => _UiScreenState();
}

class _UiScreenState extends State<UiScreen> {
  int selectedIndex = 0;
  bool isMenuExpanded = true; // Variable to manage menu state

  // Define available screens
  final List<Widget> screens = [
    HomeScreen(),
    // PdfImageExtractor(),
    
    ImageCompressorScreen(),
    ImageToPdf(),
    VideoPlayerScreen(),
    GoogleMeetScreen(),
    CartoonCalculatorHome(),
    // PDFCompressorHome()
    SnakeGameApp(),
    // FloppyBird()
    // Container(color: Colors.yellow), // Placeholder for another screen
  ];

  void updateSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void toggleMenu() {
    setState(() {
      isMenuExpanded = !isMenuExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: isMenuExpanded ? 3 : 1, // Change flex based on menu state
              child: Sidemenuwidget(
                onItemSelected: updateSelectedIndex,
                selectedIndex: selectedIndex,
                onBurgerIconPressed: toggleMenu, // Pass the toggle function
                isMenuExpanded: isMenuExpanded, // Pass the menu state
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                child: screens[selectedIndex],
              ),
            ),
            // Expanded(
            //   flex: 3,
            //   child: Container(color: Color.fromARGB(255, 223, 31, 172)),
            // ),
          ],
        ),
      ),
    );
  }
}
