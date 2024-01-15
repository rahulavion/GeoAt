// ignore_for_file: camel_case_types

import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance/main.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class captureFace extends StatefulWidget {
  const captureFace({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<captureFace> createState() => _captureFaceState();
}

class _captureFaceState extends State<captureFace> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? name, rollNo;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoAt',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(' GeoAt: Attendance Tracking'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return CameraPreview(_controller);
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
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

              // Button 1
              SizedBox(
                height: MediaQuery.of(context).size.height / 8,
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();
                      //File imageFile = File(image.path);

                      //var request = http.MultipartRequest("GET", Uri.parse("http://localhost:5000/geoat"));
                      final bytes = await image.readAsBytes();
                      var img = base64Encode(bytes);
                      String myurl = 'http://localhost:5000/geoat';
                      final url = Uri.parse(myurl);
                      final body = {
                        'face': img,
                        'rollNumber': "12",
                      };
                      var res = await http.post(url, body: body);
                      final regex =
                          RegExp(r'"([^"]*)"'); // Matches single-quoted words
                      final matches = regex.allMatches(res.body);

                      List<String> quotedWords = [];
                      for (Match match in matches) {
                        quotedWords
                            .add(match.group(1)!); // Extract the matched word
                        
                      }
                      // ignore: unnecessary_null_comparison
                      if (quotedWords[1] != null) {
                        name = quotedWords[1];
                        rollNo = quotedWords[3];
                      }

                      if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Attendance'),
                              content: Text('$name\n$rollNo'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    _controller.dispose();
                                    Navigator.pop(context); // Close the popup
                                    Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => const HomeScreen(),
                                                  )
                                                  ); // Navigate to the home page
                                  },
                                  child: Text('Close and Go Home'),
                                ),
                              ],
                            );
                            },
                        );
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Text(
                    'Capture Face',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaleFactor * 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}