import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GeoAt",
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(' GeoAt: Attendance Tracking'),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 167, 223),
        body: const Center(
          child: Text(
            "Contact us on 8667864076",
            style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold, fontSize: 30),  
          ),
        ),
      ) ,
    );
  }
}