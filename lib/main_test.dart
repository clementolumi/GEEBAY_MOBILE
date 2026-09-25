import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("=== MINIMAL TEST APP STARTING ===");
  
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("MINIMAL TEST", style: TextStyle(fontSize: 32, color: Colors.white)),
              SizedBox(height: 20),
              Text("If you see this, Flutter works!", style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    ),
  );
  
  print("=== MINIMAL TEST APP STARTED ===");
}
