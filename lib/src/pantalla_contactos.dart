import 'package:flutter/material.dart';

class PTContactos extends StatefulWidget {
  @override
  _PTContactosState createState() => new _PTContactosState();
 }
class _PTContactosState extends State<PTContactos> {
  @override
  Widget build(BuildContext context) {
   return new Scaffold(
     appBar: new AppBar(
       title: new Text("Seleccionar Contactos"),
     ),
   );
  }
}