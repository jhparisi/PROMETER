import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:flutter/material.dart';

//Menu _menu = new Menu();

class PTPrueba extends StatefulWidget {
  static const String routeName = "/pantalla_prueba";
  final ControlHour data;
  PTPrueba({Key key, this.data}) : super(key: key);
  @override
  _PTPruebaState createState() => new _PTPruebaState();
}

class _PTPruebaState extends State<PTPrueba> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("PRUEBA", textAlign: TextAlign.center),
        ),
        //drawer: _menu.getDrawer(context),
        body: new Container(
          padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
          alignment: new FractionalOffset(0.5, 0.0),
          child: Container(
              child: ListView(children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
            Text(
              widget.data.fecha,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Text(
              widget.data.idUsuario,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Text(
              widget.data.comentario,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Padding(
                padding:
                    EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
          ])),
        ));
  }
}
