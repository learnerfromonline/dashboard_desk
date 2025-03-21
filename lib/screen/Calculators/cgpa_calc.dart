import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CgpaCalculator extends StatefulWidget {
  @override
  _CgpaCalculatorState createState() => _CgpaCalculatorState();
}

class _CgpaCalculatorState extends State<CgpaCalculator> {
  int subjectCount = 0;
  List<TextEditingController> gpaControllers = [];
  double cgpa = 0.0;
  bool showResult = false;

  void calculateCGPA() {
    double totalGPA = 0.0;
    int validSubjects = 0;

    for (var controller in gpaControllers) {
      double? gpa = double.tryParse(controller.text);
      if (gpa != null && gpa >= 0.0 && gpa <= 10.0) {
        totalGPA += gpa;
        validSubjects++;
      }
    }

    if (validSubjects > 0) {
      setState(() {
        cgpa = totalGPA / validSubjects;
        showResult = true;
      });
    } else {
      setState(() {
        showResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Enter valid GPA values (0 - 10).",textAlign: TextAlign.center,style: GoogleFonts.adventPro(color: Colors.white,)),)
      );
    }
  }

  void setSubjectCount(String value) {
    int? count = int.tryParse(value);
    if (count != null && count > 0) {
      setState(() {
        subjectCount = count;
        gpaControllers = List.generate(count, (index) => TextEditingController());
        showResult = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in gpaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actionsIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        
        title: Text("CGPA Calculator", style: GoogleFonts.adventPro(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      ),
      backgroundColor: const Color.fromARGB(37, 15, 15, 15),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter number of subjects",
                labelStyle: GoogleFonts.adventPro(color: Colors.black),
                border: OutlineInputBorder(),
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
                    child: TextField(
                      controller: gpaControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter GPA for Semister ${index + 1}",
                        labelStyle: GoogleFonts.adventPro(color: Colors.black),

                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: calculateCGPA,
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 121, 121, 121)),
              child: Text("Calculate", style: GoogleFonts.adventPro(fontSize: 18, color: Colors.white)),
            ),
            if (showResult)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Your CGPA: ${cgpa.toStringAsFixed(2)}",
                  style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple[900]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
