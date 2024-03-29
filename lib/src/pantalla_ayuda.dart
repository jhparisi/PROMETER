import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
//import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:path/path.dart';
import 'menu.dart';
import 'package:eszaworker/utilities/funciones_generales.dart' as _funcGeneral;

const String telefonoWS = "+34651405480";
const String mensajeContacto ="Hola, necesito ayuda con la aplicación PRO-METER.\n¿Puedes ayudarme?";
const String telefonoContacto = "902430715";
const String urlPreguntas = "https://www.ezsa.es/";
Menu _menu = new Menu();

class PTAyuda extends StatefulWidget {
  static const String routeName = "/pantalla_ayuda";
  PTAyuda({Key key}) : super(key: key);
  @override
  _PTAyudaState createState() => new _PTAyudaState();
}

class _PTAyudaState extends State<PTAyuda> {
  @override
  void initState() {
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    
    void launchWhatsApp() async {
    final whatsappURlAndroid = "whatsapp://send?phone=$telefonoWS&text=${Uri.parse(mensajeContacto)}";
    if( await canLaunch(whatsappURlAndroid)){
      await launch(whatsappURlAndroid);
    }
    else{
      _funcGeneral.mostrarFlushBar(context,"No tienes Whatsapp instalado en tu movil");
    }
  }

    //***************************AlertDialog*************************************************//
    showAlertDialog(BuildContext context, String pregunta, String datos,
        Color color, int btnAceptar) {
      List<Widget> accion = [];

      // set up the buttons
      Widget botonCancelar = TextButton(
        child: Text("No"),
        onPressed: () {
          Navigator.pop(context);
        },
      );
      Widget botonAceptar = TextButton(
        child: Text("Sí"),
        onPressed: () {
          _deleteData();
          Future.delayed(Duration(seconds: 1)).then((value) {
            exit(0);
          });
        },
      );

      if (btnAceptar == 1) {
        accion.add(botonAceptar);
        accion.add(botonCancelar);
      } else {
        accion.add(botonCancelar);
      }
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(pregunta),
        content: Text(
          datos,
          style: TextStyle(color: color),
        ),
        actions: accion,
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    //***************************FIN AlertDialog*************************************************//

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Ayuda y FQAs", textAlign: TextAlign.center),
        ),
        drawer: _menu.getDrawer(context),
        body: Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Image(
                  image: AssetImage(
                    'assets/whatsapp.png',
                  ),
                  fit: BoxFit.cover,
                  height: 30.0,
                ),
                title: Text(
                  "Mensaje por Whatsapp",
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$telefonoWS'),
                onTap: () {
                  launchWhatsApp();
                  //FlutterOpenWhatsapp.sendSingleMessage(telefonoWS, mensajeContacto);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.blue,
                ),
                title: Text(
                  "Vía telefónica",
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$telefonoWS'),
                onTap: () {
                  //launchWhatsApp();
                  UrlLauncher.launch("tel://$telefonoContacto");
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                title: Text(
                  "Preguntas frecuentes",
                  style: TextStyle(fontSize: 14.0, color: Colors.black, fontFamily: 'HeeboSemiBold'),
                ),
                onTap: () {
                  //launchWhatsApp();
                  UrlLauncher.launch(urlPreguntas);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.cleaning_services,
                  color: Colors.blue,
                ),
                title: Text(
                  "Borrar datos de la aplicación",
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontFamily: 'HeeboSemiBold'),
                ),
                onTap: () {
                  showAlertDialog(
                      context,
                      "Precaución!",
                      "Se borrarán los datos internos de la aplicación.\nLa aplicación se cerrará al aceptar.\¿Desea continuar con la limpieza de los datos?",
                      Colors.red,
                      1);
                },
              ),
            ],
          ),
        ));
  }

  void _deleteData() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "EszaWorker.db");
    await deleteDatabase(path);
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }
}
