import 'package:flutter/material.dart';
import 'package:eszaworker/class/MensajesChatClass.dart';
import 'package:eszaworker/src/pantalla_chat_interno.dart';

class PTProxima extends StatefulWidget {
  @override
  _PTProximaState createState() => new _PTProximaState();
 }
class _PTProximaState extends State<PTProxima> {
  @override
  Widget build(BuildContext context) {
   return new Container(
     child: Center(
       child: Icon(Icons.settings, size: 100.0, color: Colors.blue,)
     ),
   );
  }
}