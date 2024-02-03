import 'package:flutter/material.dart';

class Logs extends StatefulWidget {
  const Logs({super.key, required this.attendance_logs});
  final List attendance_logs;

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {

  List log=[];
  @override
  void initState(){
    super.initState();
    modifyLog();
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
        backgroundColor: const Color.fromARGB(255, 218, 167, 223),
        body:log.length!=0? ListView.builder(
          itemCount: log.length,
          itemBuilder: (context,index){
            final day=log[index];
            return ListTile(
              title: Text("${day[0]} = ${day[1]}"),
              trailing: Icon(getIconForStatus( day[1] )),
            );
        }):const Center(child: CircularProgressIndicator())
      ),
    );
  }
  
  void modifyLog() {
    for (int i = 0; i < widget.attendance_logs.length; i+=2) {
      List temp=[widget.attendance_logs[i],widget.attendance_logs[i+1]];
      log.add(temp);
    }
  }
  
  IconData getIconForStatus(status) {
    if(status=="1"){
      return Icons.hourglass_bottom;
    }
    else if(status=="2"){
      return Icons.hourglass_full;
    }
    return Icons.hourglass_empty;
  }
}


