import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PercentageCalculator extends StatefulWidget {
  @override
  _PercentageCalculatorState createState() => _PercentageCalculatorState();
}

class _PercentageCalculatorState extends State<PercentageCalculator> {
  TextEditingController obtainedMarksController = TextEditingController();
  TextEditingController totalMarksController = TextEditingController();
  double percentage = 0.0;
  bool showResult = false;

  void calculatePercentage() {
    double? obtainedMarks = double.tryParse(obtainedMarksController.text);
    double? totalMarks = double.tryParse(totalMarksController.text);

    if (obtainedMarks != null && totalMarks != null && totalMarks > 0) {
      setState(() {
        percentage = (obtainedMarks / totalMarks) * 100;
        showResult = true;
      });
    } else {
      setState(() {
        showResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter valid marks!")),
      );
    }
  }

  @override
  void dispose() {
    obtainedMarksController.dispose();
    totalMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Percentage Calculator", style: GoogleFonts.satisfy(color: Colors.white, fontSize: 24)),
        backgroundColor: const Color.fromARGB(255, 16, 15, 15),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.purple[50],
      body: Stack(
        children: [
          // Positioned(
          //   top: -30,
          //   right: -30,
          //   child: Image.asset('assets/anime_bg.png', width: 180), // Anime-style background
          // ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: obtainedMarksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Obtained Marks/Amount",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.grade, color: Colors.blueAccent),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: totalMarksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Total Marks/Amount",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.school, color: Colors.purple),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: calculatePercentage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 38, 23, 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  ),
                  child: Text("Calculate", style: GoogleFonts.satisfy(fontSize: 18, color: Colors.white)),
                ),
                if (showResult)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Your Percentage: ${percentage.toStringAsFixed(2)}%",
                      style: GoogleFonts.satisfy(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple[900]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
