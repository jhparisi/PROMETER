import 'dart:async';

import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/panatalla_repostar.dart';
import 'package:eszaworker/src/pantalla_inciar_trayecto.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:intl/intl.dart';

Menu _menu = new Menu();
int acompanante = 0;
Color color = Colors.black;
int userId = 0;
DateTime fechaHoy = DateTime.now();
String fecha = DateFormat("yyyy-MM-dd H:mm:ss").format(fechaHoy);
//PTRepostar _respotar = new PTRepostar();
DBProvider _dbprovider = DBProvider.get();
String _dateBeginning = "";

Flushbar fbar = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message:
      "En esta pantalla no se puede ir atrás! \nSi desea cambiar el número de teléfono \no la matrícula, vaya a Configuración en \nel menú izquierdo superior.",
  duration: Duration(seconds: 5),
);

class PTPrincipal extends StatefulWidget {
  static const String routeName = "/pantalla_principal";
  PTPrincipal({Key key}) : super(key: key);
  _PTPrincipalState createState() => _PTPrincipalState();
}

class _PTPrincipalState extends State<PTPrincipal> {
  Position _currentPosition;
  @override
  initState() {
    print("FECHA HOY: " + fecha);
    super.initState();
    _getCurrentLocation();
    getWDLocal();
    getPlayPause();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getColor(String colorPrincipal) {
    if (colorPrincipal == "green") {
      color = Colors.green;
    }
    if (colorPrincipal == "black") {
      color = Colors.black;
    }
    if (acompanante == 1) {
      color = Colors.grey;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    userId = _menu.getuserId();
    _menu.getVerifyDataLocal(userId);
    acompanante = _menu.getAcompanante();
    String long = "";
    String lat = "";
    if (_currentPosition != null) {
      long = "${_currentPosition.longitude}";
      lat = "${_currentPosition.latitude}";
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("PRO-METER APP", textAlign: TextAlign.center),
      ),
      drawer: _menu.getDrawer(context),
      body: new Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Center(
                child: Column(
              children: <Widget>[
                WillPopScope(
                  child: Container(),
                  onWillPop: () {
                    fbar.show(context);
                    return new Future(() => false);
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Image.asset(
                  'logoezsa.png',
                  width: 180,
                  height: 70,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Text(
                  'Tu posición actual es:',
                  style: TextStyle(fontSize: 10.0),
                ),
                Text('Longitud: $long', style: TextStyle(fontSize: 10.0)),
                Text('Latitud: $lat', style: TextStyle(fontSize: 10.0)),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Column(
                      children: <Widget>[
                        MaterialButton(
                            onPressed: () {
                              if (acompanante == 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PTRepostar()));
                              }
                            },
                            minWidth: 120.0,
                            height: 120.0,
                            padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.local_gas_station,
                                    size: 100.0, color: getColor("green")),
                                Text("Repostar",
                                    style: TextStyle(color: getColor("black")))
                              ],
                            ))
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: <Widget>[
                        MaterialButton(
                            onPressed: () {
                              if (acompanante == 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PTIniciarRuta()));
                              } else {
                                final data = PlayPauseTracking(
                                    trackingPLay: 0,
                                    userId: userId,
                                    dateBeginning: fecha);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PTCerrarRuta(
                                              data: data,
                                              registraControlHora: 1,
                                            )));
                              }
                            },
                            minWidth: 120.0,
                            height: 120.0,
                            padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.swap_calls,
                                    size: 100.0, color: Colors.blueAccent),
                                Text("Iniciar Ruta")
                              ],
                            ))
                      ],
                    ))
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        //print("PINTA COOR");
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<List<WorkingDay>> getWDLocal() async {
    List<WorkingDay> retunn = [];
    try {
      List<WorkingDay> list = await _dbprovider.getWorkingDay();
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            _dateBeginning = list[0].startingDate.toString();
          }
        }
        return list;
      });
    } catch (Ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTPrincipal()));
    }
    return retunn;
  }

  Future<List<PlayPauseTracking>> getPlayPause() async {
    List<PlayPauseTracking> retunn = [];
    try {
      List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
      if (list != null) {
        for (var i = 0; i < list.length; i++) {
          trackingPlay = list[i].trackingPLay.toString();
          //_idUser = list[i].userId;
        }
        //_repository.fetchLocalData('${numPhoneController.text}','${carPlateController.text}',_idUser,_nombreCompleto,_login);
        _menu.getVerifyDataLocal(userId);
        print("EL VALOR DE trackingPlay =" + trackingPlay.toString());
        if (trackingPlay != "0" && trackingPlay != null) {
          final data = PlayPauseTracking(
              trackingPLay: int.parse(trackingPlay),
              userId: userId,
              dateBeginning: _dateBeginning);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PTCerrarRuta(
                        data: data,
                        registraControlHora: 0,
                      )));
        }
      }
      /* else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PTPrincipal()));
      } */

      return list;
    } catch (Ex) {
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }
}
