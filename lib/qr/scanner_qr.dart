import 'dart:convert';
import 'package:attendance_app/qr/form_value.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:attendance_app/models';
class ScannerQr extends StatefulWidget {
  const ScannerQr({ Key? key }) : super(key: key);

  @override
  _ScannerQrState createState() => _ScannerQrState();
}

class _ScannerQrState extends State<ScannerQr> {
  Future<String> getEventId() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('event_id') ?? '';
  }
  Future<void> deleteEventId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('event_id');
  String id = await getEventId();
  print(id);
  }
  Future<List<dynamic>> eventModels() async{
    final response = await http.get(Uri.parse(eventToday));
    if(response.statusCode == 200){
      final jsonData = jsonDecode(response.body);
      final events = jsonData['events'];
      print(events);
      return events;
    }else{
      throw Exception();
    }
  }
  Future<void> getDataFromBarcode(data)async{
    final response = await http.get(Uri.parse('$qrcodeData$data'));
    final decoded = jsonDecode(response.body);
    screenClose(){
      _screenOpened = false;
    }
    screenClosed(){
      _screenOpened = true;
    } 
    if(decoded.isNotEmpty){
      final user = decoded['user'];
      final studentName = user['name'] as String;
      final studentID = user['studentId'].toString();
      final email = user['email'] as String;
      showDialog(context: context, builder: (BuildContext context){
        screenClosed();
        return AlertDialog(
          content: Container(
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text('Name: $studentName', style:GoogleFonts.poppins(color: Colors.red, fontSize: 24)),
                const SizedBox(height: 20),
                Text('ID Number: $studentID', style:GoogleFonts.poppins(color: Colors.red, fontSize: 24)),
                const SizedBox(height: 20),
                Text('Email Address: $email', style:GoogleFonts.poppins(color: Colors.red, fontSize: 24)),
                const SizedBox(height: 1),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> FormValue(
                    screenClose: screenClose,
                    studentName: studentName, 
                    studentID: studentID,
                    email: email,
                  )));
                }, child: const Text('Check Attendance'))
              ],
            ),
          ),
        );
      });
    }
  }
  bool _screenOpened = false;
  // late Future<EventScheduleModel> futureModel;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   futureModel = eventModels();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
          child: FutureBuilder<List<dynamic>>(
          future: eventModels(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }else if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else{
              final events = snapshot.data as List<dynamic>;
              return RefreshIndicator(
                onRefresh: eventModels,
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index){
                    final event = events[index];
                    return ListTile(
                      title: Text(event['eventName']),
                      subtitle: Text(event['event_id']),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('event_id', event['event_id']);
                        String eventId = await getEventId();
                        print(eventId);
                      },
                    );
                  }
                ),
              );
            }
          }),
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (){
              deleteEventId();
            }, 
            icon: const Icon(Icons.delete))
        ],
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white54,
        title: Text('SCANNER', style: GoogleFonts.poppins(
          color: Colors.black
        )),
      ),
      body: Column(
        children: [
        const SizedBox(height: 220),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 5
            )
          ),
          child: MobileScanner(     
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
              torchEnabled: false
            ),
            onDetect: (capture){
              String? finalData;
              /*Barcode barcode;
              setState(() {
                final String data = barcode.rawValue ?? '';
                finalData = data;
              });*/
              final List<Barcode> barcodes = capture.barcodes;
              //final Uint8List? image = capture.image;
              for(final barcode in barcodes){
                setState(() {
                  String data = barcode.rawValue!;
                  // getDataFromBarcode(data);
                  // _screenOpened = true;
                  finalData = data;
                  //debugPrint(data);
                });
              }
              if(!_screenOpened){
                getDataFromBarcode(finalData);
                _screenOpened = true;
              }
            }
          ),
        )
        ]
      ),
    );
  }
}