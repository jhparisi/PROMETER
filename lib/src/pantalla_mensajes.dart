import 'package:eszaworker/class/MensajesClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:flutter/material.dart';

import 'listitem_mensajes.dart';
//import 'menu.dart';

//Menu _menu = new Menu();

DBProvider _dbprovider = DBProvider.get();

class PTMensajes extends StatefulWidget {
  static const String routeName = "/pantalla_mensajes";
  PTMensajes({Key key}) : super(key: key);
  @override
  _PTMensajesState createState() => new _PTMensajesState();
}

class _PTMensajesState extends State<PTMensajes> {
  List<Mensajes> _mensaje = new List();
  @override
  void initState() {
    super.initState();
    loadMensajes();
  }

  void loadMensajes() async {
    var mensajes = await _dbprovider.fethMensajesAll();
    setState(() {
      _mensaje.addAll(mensajes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mensajes Recibidos", textAlign: TextAlign.center),
      ),
      //drawer: _menu.getDrawer(context),
      body: new Container(
        child: new ListView.builder(
          itemCount: _mensaje.length,
          itemBuilder: (BuildContext context, int index) {
            return new MensajesListItem(_mensaje[index]);
          },
        ),
      )
    );
  }
}