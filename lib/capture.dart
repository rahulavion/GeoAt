// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class Attendace extends StatelessWidget {
  const Attendace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GeoAt",
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const captureFace(),
    );
  }
}

class captureFace extends StatefulWidget {
  const captureFace({super.key});

  @override
  State<captureFace> createState() => _captureFaceState();
}

class _captureFaceState extends State<captureFace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' GeoAt: Attendance Tracking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Empty container for the map
            Container(
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 10.0),
            const Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quick tip title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.yellow,
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'Quick tip',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Quick tip 1
                  Text(
                    'Be in a well-lit area.',
                    textAlign: TextAlign.left,
                  ),
                  // Quick tip 2
                  Text(
                    'Face the camera directly.',
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'Remove any hats, sunglasses, or other accessories that may obscure your face.',
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
                // Button 1
          ElevatedButton(
                  onPressed: () => {},
                  child: Text('Capture Face'),
                ), 
          ],
        ),
      ),
    );
  }
}