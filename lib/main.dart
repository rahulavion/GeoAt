// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geo_attendance/help.dart';
import 'package:geo_attendance/logs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'capture.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;


Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

String encode(data) {
  String encryptedData = base64Encode(utf8.encode('$data'));
  return encryptedData;
}

Future<List> sendRequest(url, body) async {
  final myurl = Uri.parse(url);
  var res = await http.post(myurl, body: body);
  final regex = RegExp(r'"([^"]*)"'); // Matches single-quoted words
  final matches = regex.allMatches(res.body);
  List<String> quotedWords = [];
  for (Match match in matches) {
    quotedWords.add(match.group(1)!); // Extract the matched word
  }
  return quotedWords;
}
List response = [];
String roll = '';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GeoAt",
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasLocationPermission = false;
  bool _isButtonEnabled = false;
  late List<CameraDescription> cameras;
  List<String> pos = [];
  

  @override
  void initState() {
    super.initState();
    getLatLng();
  }

  void getLatLng() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    cameras = await availableCameras();
    pos.add(currentPosition.latitude.toString());
    pos.add(currentPosition.longitude.toString());
  }

  Future<int> getReturnValue() async {    
    final body = {  
      "lat": encode(pos[0]),
      "lng": encode(pos[1])
    };
    response = await sendRequest('http://localhost:5000/locate',body);
    return int.parse(response[1]);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> body;
    return MaterialApp(
      title: 'GeoAt',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(' GeoAt: Attendance Tracking'),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 167, 223),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Empty container for the map
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width,
                child: pos.length != 0 ? Card(
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                            side: const BorderSide(color: Colors.purple, width: 5.0),
                          ),
                  child: FlutterMap(
                    options: MapOptions(
                      center:LatLng(double.parse(pos[0]),double.parse(pos[1])),
                    ),
                    layers: [
                      TileLayerOptions(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/rahuljha1908/clmol74e6004601nsh41pgf8n/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmFodWxqaGExOTA4IiwiYSI6ImNsbW5vbGx6bjA3ZXAyc285OTY3aGpnNmQifQ.44Kn_Nrp5dPZETJUlEuEFA',
                          additionalOptions: {
                            'accessToken':
                                'pk.eyJ1IjoicmFodWxqaGExOTA4IiwiYSI6ImNsbW5vcXk3dTBwYnMya3IyY3ZjNHdwdWIifQ.u0YQI5lNMbnB-Lh7tmPy_Q',
                            'id': 'mapbox.mapbox-bathymetry-v2'
                          },
                          minZoom: 12
                          ),

                    ],
                  ),
                ): const Center(child: CircularProgressIndicator()),
              ),

              const Card(
                color: Color.fromARGB(255, 218, 167, 223),
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
                        'Click locate me to track your location.',
                        textAlign: TextAlign.left,
                      ),
                      // Quick tip 2
                      Text(
                        'Click Face log to register your Biometric.',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Button 1
                  SizedBox(
                    child: IconButton (
                      onPressed: _isButtonEnabled
                          ? () async {
                              int val = await getReturnValue();
                              int isGeo = val.toInt();
                              if (isGeo > 100) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                      child: AlertDialog(
                                        title: const Text(
                                            'Wow! You are in campus!'),
                                        content: const Text(
                                            'Please click the "Face log" button to register your attendance.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        captureFace(
                                                      // Pass the appropriate camera to the TakePictureScreen widget.
                                                      camera: cameras.length > 1
                                                          ? cameras.last
                                                          : cameras.first,
                                                    ),
                                                  ));
                                            },
                                            child: const Text('Face log'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Sorry You are not in campus!'),
                                      content: const Text(
                                          'Please retry after you reach the campus.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.location_history),
                      iconSize: 40,
                      tooltip: "Locate me",
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 8,
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Roll Number',
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          roll = value;
                          _isButtonEnabled = value.isNotEmpty;
                        });
                        },
                    ),
                  ),
                  SizedBox(
                    child: IconButton(
                      onPressed: _isButtonEnabled
                          ? () async => {
                            body = {  
                              "rollNumber": encode(roll),
                            },
                            response = await sendRequest('http://localhost:5000/logs',body),
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Logs(attendance_logs: response)))
                          }:null,
                      icon: const Icon(Icons.save), 
                      iconSize: 40,
                      tooltip: "Attendance logs",
                      ),
                  )
                ],
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          tooltip: "Get Help",
          child: const Icon(Icons.question_answer),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const Help()));
          },
          
        ),
      ),
    );
  }
}



