import 'dart:async';
import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_configuracion.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:eszaworker/utilities/funciones_generales.dart';
import 'package:flutter/material.dart';

Widget paginaIniciaApp = PTConfiguracion();
DBProvider _dbprovider = DBProvider.get();
class PTCargando extends StatefulWidget {
  static const String routeName = "/pantalla_cargando";
  PTCargando({Key key}) : super(key: key);
  _PTCargandoState createState() => _PTCargandoState();
}

class _PTCargandoState extends State<PTCargando> {
  @override
  initState() {
    inicializarBDLocal();
    super.initState();
    Timer(Duration(seconds: 3), () {
      getConfiguracion();      
    });
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: 
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF73AEF5),
                Color(0xFF61A4F1),
                Color(0xFF478DE0),
                Color(0xFF398AE5)
              ],
              stops: [
                0.1,
                0.4,
                0.7,
                0.9
              ]
            )
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 150.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                    ),
                    Image.asset(
                      'logoPrometer2.png',
                      width: 180,
                      height: 180,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                    ),
                    CircularProgressIndicator(
                      backgroundColor: Colors.cyanAccent,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                    ),
                    Text("Cargando la aplicación...", style: TextStyle(color: Colors.white, fontFamily: 'HeeboSemiBold', fontSize: 14.0),)
            ],
          ),
        ),
      )),
    ));
  }

  getConfiguracion() async {     
    try {
      //await _dbprovider.init();
      
      List<Configuracion> configuracion = await _dbprovider.getConfiguracion();
      //print(configuracion[0].dominio);
      if(configuracion.length>0){
        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PTInicial()));        
      }
      else{
        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PTConfiguracion()));
      }
    } catch (ex) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PTConfiguracion()));
    }
  }
}