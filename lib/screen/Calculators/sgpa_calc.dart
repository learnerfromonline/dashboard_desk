import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SgpaCalculator extends StatefulWidget {
  @override
  _SgpaCalculatorState createState() => _SgpaCalculatorState();
}

class _SgpaCalculatorState extends State<SgpaCalculator> {
  int subjectCount = 0;
  List<TextEditingController> gpaControllers = [];
  List<TextEditingController> creditControllers = [];
  double sgpa = 0.0;
  bool showResult = false;

  void calculateSGPA() {
    double totalWeightedGPA = 0.0;
    int totalCredits = 0;

    for (int i = 0; i < subjectCount; i++) {
      double? gpa = double.tryParse(gpaControllers[i].text);
      int? credits = int.tryParse(creditControllers[i].text);

      if (gpa != null && credits != null && gpa >= 0.0 && gpa <= 10.0 && credits > 0) {
        totalWeightedGPA += gpa * credits;
        totalCredits += credits;
      }
    }

    if (totalCredits > 0) {
      setState(() {
        sgpa = totalWeightedGPA / totalCredits;
        showResult = true;
      });
    } else {
      setState(() {
        showResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter valid GPA (0-10) and credit values!")),
      );
    }
  }

  void setSubjectCount(String value) {
    int? count = int.tryParse(value);
    if (count != null && count > 0) {
      setState(() {
        subjectCount = count;
        gpaControllers = List.generate(count, (index) => TextEditingController());
        creditControllers = List.generate(count, (index) => TextEditingController());
        showResult = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in gpaControllers) {
      controller.dispose();
    }
    for (var controller in creditControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SGPA Calculator", style: GoogleFonts.satisfy(color: Colors.white, fontSize: 24)),
        backgroundColor: const Color.fromARGB(255, 10, 10, 10),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.purple[50],
      body: Stack(
        children: [
          // Positioned(
          //   top: -30,
          //   right: -30,
          //   child: Image.asset('assets/anime01.jpg', width: 180), // Add an anime-style background
          // ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter number of subjects",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.book, color: const Color.fromARGB(150, 7, 7, 7)),
                  ),
                  onChanged: setSubjectCount,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: subjectCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: creditControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Credits (Sub ${index + 1})",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: GoogleFonts.adventPro(color: Colors.black),
                                  prefixIcon: Icon(Icons.menu_book_outlined, color: const Color.fromARGB(255, 75, 209, 13)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: gpaControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "GPA (Sub ${index + 1})",
                                  labelStyle: GoogleFonts.adventPro(color: Colors.black),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.grade, color: const Color.fromARGB(255, 196, 121, 8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: calculateSGPA,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  ),
                  child: Text("Calculate", style: GoogleFonts.satisfy(fontSize: 18, color: Colors.white)),
                ),
                if (showResult)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Your SGPA: ${sgpa.toStringAsFixed(2)}",
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
