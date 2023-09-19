import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'capture.dart';

void main() {
  runApp(const MyApp());
}

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
  

  @override
  void initState() {
    super.initState();
    getLatLng();
  }

  LatLng? ll()  {
    LatLng? latLng=LatLng(10.931620, 76.984920);
    return latLng;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  List pos = [];
  Future<List> getLatLng() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    pos.add(currentPosition.latitude);
    pos.add(currentPosition.longitude);
    return pos;
  }

  Future<double> getReturnValue() async {
    List currentPosition = await getLatLng();
    double distance;
    distance = calculateDistance(
        currentPosition[0], currentPosition[1], 10.931620, 76.984920);
    return distance;
  }

  bool isButtonEnabled = false;

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
              // Empty container for the map
              SizedBox( 
                height: MediaQuery.of(context).size.height/2,
                width: MediaQuery.of(context).size.width,
                child: 
                  FlutterMap(
                  options: MapOptions(
                center: ll(),
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: 'https://api.mapbox.com/styles/v1/rahuljha1908/clmol74e6004601nsh41pgf8n/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmFodWxqaGExOTA4IiwiYSI6ImNsbW5vbGx6bjA3ZXAyc285OTY3aGpnNmQifQ.44Kn_Nrp5dPZETJUlEuEFA',
                  additionalOptions: {
                    'accessToken': 'pk.eyJ1IjoicmFodWxqaGExOTA4IiwiYSI6ImNsbW5vcXk3dTBwYnMya3IyY3ZjNHdwdWIifQ.u0YQI5lNMbnB-Lh7tmPy_Q',
                    'id' : 'mapbox.mapbox-bathymetry-v2'
                  }
                ),
              ],
              ),
              ),
              
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
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Button 1
                  ElevatedButton(
                    onPressed: () async {
                      double val = await getReturnValue();
                      int isGeo = val.toInt();
                      if (isGeo > 100) {
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    },
                    child: Text('Locate me'),
                  ),
                  // Button 2
                  ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Attendace()));
                          }
                        : null,
                    child: Text('Face log'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

