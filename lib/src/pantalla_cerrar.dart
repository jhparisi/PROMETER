import 'package:flutter/material.dart';


class PTCerrarSesion extends StatefulWidget {
  static const String routeName = "/pantalla_cerrarSesion";
  PTCerrarSesion({Key key}) : super(key: key);
  @override
  _PTCerrarSesionState createState() => new _PTCerrarSesionState();
}

class _PTCerrarSesionState extends State<PTCerrarSesion> {
  @override
  void initState() {
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Cerrar Sesión", textAlign: TextAlign.center),
      ),
      //drawer: _menu.getDrawer(context),
      body: new Container(
        
      )
    );
  }
}