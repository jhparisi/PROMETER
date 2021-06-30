import 'package:eszaworker/src/locator.dart';
import 'package:eszaworker/src/panatalla_repostar.dart';
import 'package:eszaworker/src/panatalla_controlhoras.dart';
import 'package:eszaworker/src/pantalla_acerca.dart';
import 'package:eszaworker/src/pantalla_ayuda.dart';
import 'package:eszaworker/src/pantalla_cerrar.dart';
//import 'package:eszaworker/src/pantalla_geolocalizacion.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:eszaworker/src/pantalla_seguridad.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:eszaworker/src/pantalla_mensajes.dart';
//import 'package:stream_channel/stream_channel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  setupLocator();
  runApp(MaterialApp(
    localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('es')
      ],
    home: PTInicial(), routes: <String, WidgetBuilder>{
    PTRepostar.routeName: (BuildContext context) => PTRepostar(),
    PTInicial.routeName: (BuildContext context) => PTInicial(),
    PTPrincipal.routeName: (BuildContext context) => PTPrincipal(),
    PTMensajes.routeName: (BuildContext context) => PTMensajes(),
    PTAcerca.routeName: (BuildContext context) => PTAcerca(),
    PTAyuda.routeName: (BuildContext context) => PTAyuda(),
    PTSeguridad.routeName: (BuildContext context) => PTSeguridad(),
    PTCerrarSesion.routeName: (BuildContext context) => PTCerrarSesion(),
    PTControlHoras.routeName: (BuildContext context) => PTControlHoras(),
  }));
}
