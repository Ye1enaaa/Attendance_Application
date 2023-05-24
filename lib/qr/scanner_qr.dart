import 'dart:convert';
import 'package:attendance_app/qr/form_value.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ScannerQr extends StatefulWidget {
  const ScannerQr({ Key? key }) : super(key: key);

  @override
  _ScannerQrState createState() => _ScannerQrState();
}

class _ScannerQrState extends State<ScannerQr> {
  Future<void> getDataFromBarcode(data)async{
    final response = await http.get(Uri.parse('$qrcodeData$data'));
    final decoded = jsonDecode(response.body); 
    if(decoded.isNotEmpty){
      final user = decoded['user'];
      final studentName = user['name'] as String;
      final studentID = user['studentId'].toString();
      final email = user['email'] as String;
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          content: Container(
            height: 500,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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