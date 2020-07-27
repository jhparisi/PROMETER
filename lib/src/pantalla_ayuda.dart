import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'dart:io' as Io;
import 'dart:convert';

import 'menu.dart';

const String telefonoWS="+34651405480";
const String mensajeContacto="Hola, necesito ayuda con la aplicación PRO-METER.\n¿Puedes ayudarme?";
const String telefonoContacto ="900264438";
const String urlPreguntas ="https://www.ezsa.es/";
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

  void launchWhatsApp() async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$telefonoWS/?text=${Uri.parse(mensajeContacto)}";
      } else {
        return "whatsapp://send?   phone=$telefonoWS&text=${Uri.parse(mensajeContacto)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
}     

  @override
  Widget build(BuildContext context) {
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
                leading: Image(image: AssetImage('assets/whatsapp.png',),fit: BoxFit.cover, height: 30.0,),
                title: Text("Mensaje por Whatsapp",style: TextStyle(fontSize: 14.0,color: Colors.black),),
                subtitle: Text('$telefonoWS'),  
                onTap: (){
                  //launchWhatsApp();
                  FlutterOpenWhatsapp.sendSingleMessage(telefonoWS, mensajeContacto);
                } ,              
              ),
              ListTile(
                leading: Icon(Icons.phone,color: Colors.blue,),
                title: Text("Vía telefónica",style: TextStyle(fontSize: 14.0,color: Colors.black),),
                subtitle: Text('$telefonoWS'),  
                onTap: (){
                  //launchWhatsApp();
                  UrlLauncher.launch("tel://$telefonoContacto");
                } ,              
              ),
              ListTile(
                leading: Icon(Icons.info_outline,color: Colors.blue,),
                title: Text("Preguntas frecuentes",style: TextStyle(fontSize: 14.0,color: Colors.black),),  
                onTap: (){
                  //launchWhatsApp();
                  UrlLauncher.launch(urlPreguntas);
                } ,              
              ),
          ],
        ),
      )
    );
  }
}