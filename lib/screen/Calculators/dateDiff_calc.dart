import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateDifferenceCalculator extends StatefulWidget {
  @override
  _DateDifferenceCalculatorState createState() => _DateDifferenceCalculatorState();
}

class _DateDifferenceCalculatorState extends State<DateDifferenceCalculator> {
  DateTime? startDate;
  DateTime? endDate;
  String differenceText = "";

  void calculateDifference() {
    if (startDate == null || endDate == null) {
      setState(() {
        differenceText = "Please select both dates!";
      });
      return;
    }

    Duration difference = endDate!.difference(startDate!);
    int days = difference.inDays;
    int years = days ~/ 365;
    int months = (days % 365) ~/ 30;
    int remainingDays = (days % 365) % 30;

    setState(() {
      differenceText =
          "$years Years, $months Months, $remainingDays Days";
    });
  }

  Future<void> selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        title: Text("Date Difference Calculator",
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Dates",
                style: GoogleFonts.fredoka(fontSize: 26, color: Colors.purple[900]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.all(15),
                    ),
                    child: Text(
                      startDate == null
                          ? "Pick Start Date"
                          : DateFormat("yyyy-MM-dd").format(startDate!),
                      style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.all(15),
                    ),
                    child: Text(
                      endDate == null
                          ? "Pick End Date"
                          : DateFormat("yyyy-MM-dd").format(endDate!),
                      style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: calculateDifference,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text(
                  "Calculate Difference",
                  style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 30),
              Text(
                differenceText,
                style: GoogleFonts.fredoka(fontSize: 24, color: Colors.purple[900]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
