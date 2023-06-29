import 'dart:convert';

import 'package:attendance_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class FormValue extends StatefulWidget {
final Function screenClose;
final String studentName;
final String studentID;
final String email;

const FormValue({ 
  Key? key,
  required this.screenClose,
  required this.studentName,
  required this.studentID,
  required this.email 
}) : super(key: key);

  @override
  State<FormValue> createState() => _FormValueState();
}

class _FormValueState extends State<FormValue> {
  Future<String> getEventId() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('event_id') ?? '';
  }

  Future<void> stockIn()async{
    String eventId = await getEventId();
    final studentId = studentIDcontrol.text;
    final name = nameControl.text;
    final email = emailcontrol.text;

    final body = {
      'name': name,
      'email' : email,
      'studentId' : int.parse(studentId),
    };
    final response = await http.post(
      Uri.parse('$postAttendance$eventId'),
      body: jsonEncode(body),
      headers: {
        'Content-type' : 'application/json'
      }
    );
    //final data = jsonEncode(body);
    for (int i = 0; i < 2; i++) {
      if (response.statusCode == 200) {
        print('Success');
        Navigator.pop(context);
      }
    }
    if (response.statusCode == 200) {
        print('Success');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log Successfully')),
        );
      }
    print(response.body);
  }
  var formKey = GlobalKey<FormState>();
  TextEditingController nameControl = TextEditingController();
  TextEditingController studentIDcontrol = TextEditingController();
  TextEditingController emailcontrol = TextEditingController();
  @override
  Widget build(BuildContext context){
    String _studentName = widget.studentName;
    String _studentID = widget.studentID;
    String _email = widget.email;
    //int parsedQuantity = int.tryParse(quantityControl.text) ?? 0;
    //int parsedPrice = int.tryParse(priceProduct) ?? 0;
    nameControl.text = _studentName;
    studentIDcontrol.text = _studentID;
    emailcontrol.text = _email;
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: const Text('Attendance Form'),
      ), 
      body: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: nameControl,
              decoration: const InputDecoration(
              labelText: 'Student Name',
              border: OutlineInputBorder(),
              enabled: false
            ),
          ),
          const SizedBox(height: 12.0),
          TextFormField(
            controller: studentIDcontrol,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'ID NUMBER',
              border: OutlineInputBorder(),
              //hintText: quantityProduct,
            ),
          ),
          const SizedBox(height: 12.0),
          TextFormField(
            controller: emailcontrol,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Supplier Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12.0),
          // ElevatedButton(
          //   onPressed: (){
          //     //int totalValue = parsedQuantity * parsedPrice;
          //     //print(parsedQuantity);
          //    // print(parsedPrice);
          //     //print(totalValue);
          //     //totalControl.text = totalValue.toString();
          //     setState(() {});
          //   },
          //   child: const Text('Calculate Total'),
          //   style: ElevatedButton.styleFrom(
          //     primary: Colors.blue,
          //     onPrimary: Colors.white,
          //   ),
          // ),
          // SizedBox(height: 12.0),
          // TextFormField(
          //   controller: totalControl,
          //   decoration: InputDecoration(
          //     labelText: 'Total',
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: (){
              stockIn();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
          ],
        )
      ),
    );
  }
}