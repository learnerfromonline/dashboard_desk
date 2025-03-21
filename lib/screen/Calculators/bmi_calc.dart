import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class AdvancedBMICalculator extends StatefulWidget {
  @override
  _AdvancedBMICalculatorState createState() => _AdvancedBMICalculatorState();
}

class _AdvancedBMICalculatorState extends State<AdvancedBMICalculator> {
  double height = 170;
  double weight = 70;
  int age = 25;
  String gender = "Male";
  double bmi = 0;
  String category = "";
  double bmr = 0;
  double waist = 80;
  List<String> bmiHistory = [];

  @override
  void initState() {
    super.initState();
    loadBMIHistory();
  }

  Future<void> loadBMIHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bmiHistory = prefs.getStringList('bmiHistory') ?? [];
    });
  }

  Future<void> saveBMIHistory(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bmiHistory.add(value);
    await prefs.setStringList('bmiHistory', bmiHistory);
  }

  Future<void> clearBMIHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('bmiHistory');
    setState(() {
      bmiHistory.clear();
    });
  }

  void deleteHistoryItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bmiHistory.removeAt(index);
    });
    await prefs.setStringList('bmiHistory', bmiHistory);
  }

  void calculateBMI() {
    setState(() {
      bmi = weight / ((height / 100) * (height / 100));
      category = getBMICategory(bmi);
      bmr = calculateBMR(weight, height, age, gender);
    });
    saveBMIHistory("BMI: ${bmi.toStringAsFixed(2)} ($category)");
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 24.9) return "Normal";
    if (bmi < 29.9) return "Overweight";
    return "Obese";
  }

  double calculateBMR(double weight, double height, int age, String gender) {
    if (gender == "Male") {
      return 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
    } else {
      return 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
    }
  }

  double waistToHeightRatio() {
    return waist / height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(32, 25, 25, 27),
      appBar: AppBar(
        title: Text("Advanced BMI Calculator", style: GoogleFonts.adventPro(fontSize: 22, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 18, 18, 19),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: const Color.fromARGB(134, 0, 0, 0),
                
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Height: ${height.toInt()} cm", style: GoogleFonts.adventPro(fontSize: 18,color: Colors.white)),
                      Slider(
                        value: height,
                        min: 100,
                        max: 250,
                        activeColor: const Color.fromARGB(255, 188, 185, 185),
                        onChanged: (value) => setState(() => height = value),
                      ),
                      
                      Text("Weight: ${weight.toInt()} kg", style: GoogleFonts.adventPro(fontSize: 18,color: Colors.white)),
                      Slider(
                        value: weight,
                        min: 30,
                        max: 200,
                        activeColor: const Color.fromARGB(255, 187, 179, 179),
                        onChanged: (value) => setState(() => weight = value),
                      ),
                      
                      Text("Age: $age", style: GoogleFonts.adventPro(fontSize: 18,color: Colors.white)),
                      Slider(
                        value: age.toDouble(),
                        min: 10,
                        max: 100,
                        activeColor: const Color.fromARGB(255, 165, 172, 172),
                        onChanged: (value) => setState(() => age = value.toInt()),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 21, 22, 21)),
                child: Text("Calculate BMI", style: GoogleFonts.adventPro(fontSize: 20, color: Colors.white)),
              ),
              
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("BMI", style: GoogleFonts.adventPro(fontSize: 18, fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("Category", style: GoogleFonts.adventPro(fontSize: 18, fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text("BMR", style: GoogleFonts.adventPro(fontSize: 18, fontWeight: FontWeight.bold))),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text(bmi.toStringAsFixed(2))),
                    Padding(padding: EdgeInsets.all(8), child: Text(category)),
                    Padding(padding: EdgeInsets.all(8), child: Text(bmr.toStringAsFixed(2))),
                  ]),
                ],
              ),
              
              Divider(),
              Text("BMI History", style: GoogleFonts.adventPro(fontSize: 22)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bmiHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(bmiHistory[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteHistoryItem(index),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}