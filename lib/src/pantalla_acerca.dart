import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/utilities/funciones_generales.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:get_version/get_version.dart';
import 'package:eszaworker/class/GetVersionLibrary.dart' as GetVersion;
import 'menu.dart';

DBProvider _dbprovider = DBProvider.get();
Menu _menu = new Menu();
int versionDB = 0;

String appName = "";
String packageName = "";
String versionApp = "";
String buildNumber = "";
String versionOS = "";
String matricula = "";
String nombreUsuario = "";
String numTelefono = "";
var zona = DateTime.now().timeZoneName;
var nombreZona = "";
String _dominio;
//String _semilla;

class PTAcerca extends StatefulWidget {
  static const String routeName = "/pantalla_acerca";
  PTAcerca({Key key}) : super(key: key);
  @override
  _PTAcercaState createState() => new _PTAcercaState();
}

class _PTAcercaState extends State<PTAcerca> {
  @override
  void initState() {
    inicializarBDLocal();
    getConfiguracion();
    super.initState();
    if(zona=="WEST"){
      nombreZona = "Islas Canarias";
    }
    else if(zona=="CEST"){
      nombreZona = "Madrid";
    }
    Future.delayed(const Duration(seconds: 3), () {
      obtenerVersiones();
      getVerifyDataLocal();

      //pr.hide().whenComplete(() => null);
    });
  }

  void obtenerVersiones() async {
    try {
      versionDB = await _dbprovider.db.getVersion();
    } on PlatformException {
      versionOS = 'Error al leer la versión';
    }

    /* try {
      versionOS = await GetVersion.GetVersionLibrary.projectCode;
    } on PlatformException {
      versionOS = 'Error al leer la versión';
    } */

    try {
      versionApp = await GetVersion.GetVersionLibrary.projectVersion;
    } on PlatformException {
      versionApp = 'Error al leer la versión';
    }
    try {
      appName = await GetVersion.GetVersionLibrary.appName;
    } on PlatformException {
      appName = 'Error al leer la versión';
    }
    try {
      packageName = await GetVersion.GetVersionLibrary.appID;
    } on PlatformException {
      packageName = 'Error al leer la versión';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Acerca de", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'HeeboSemiBold'),),
        ),
        drawer: _menu.getDrawer(context),
        body: new Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.perm_device_information,
                  color: Colors.blue,
                ),
                title: Text(
                  "Versión de la Aplicación",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$versionApp'),
              ),
              ListTile(
                leading: Icon(
                  Icons.storage,
                  color: Colors.blue,
                ),
                title: Text(
                  "Versión de la BDD",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$versionDB' + ".0.0"),
              ),
              /* ListTile(
                leading: Icon(
                  Icons.android,
                  color: Colors.blue,
                ),
                title: Text(
                  "Versión del OS",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$versionOS'),
              ), */
              ListTile(
                leading: Icon(
                  Icons.apps,
                  color: Colors.blue,
                ),
                title: Text(
                  "Nombre real de la aplicación",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$appName'),
              ),
              ListTile(
                leading: Icon(
                  Icons.http,
                  color: Colors.blue,
                ),
                title: Text(
                  "Dominio",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$_dominio'),
              ),
              ListTile(
                leading: Icon(
                  Icons.adb,
                  color: Colors.blue,
                ),
                title: Text(
                  "ID de la aplicación",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$packageName'),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                title: Text(
                  "Usuario",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$nombreUsuario'),
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.blue,
                ),
                title: Text(
                  "Número de Teléfono",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$numTelefono'),
              ),
              ListTile(
                leading: Icon(
                  Icons.directions_car,
                  color: Colors.blue,
                ),
                title: Text(
                  "Matrícula",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$matricula'),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time_outlined,
                  color: Colors.blue,
                ),
                title: Text(
                  "Zona Horaria",
                  style: TextStyle(fontSize: 14.0,fontFamily: 'HeeboSemiBold'),
                ),
                subtitle: Text('$nombreZona'),
              ),
            ],
          ),
        ));
  }

  Future<List<DataLocal>> getVerifyDataLocal() async {
    
    List<DataLocal> retunn = new List<DataLocal>.empty();
    try {
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicial();
      setState(() {
        if (list != null) {
          var val = list.length - 1;
          numTelefono = list[val].numPhone;
          matricula = list[val].carPlate;
          nombreUsuario = list[val].nombreCompleto;
          _dbprovider.deleteDataLocal(null);
          //}
        }
        return list;
      });
    } catch (ex) {}
    return retunn;
  }

  getConfiguracion() async {     
    try {
      //await _dbprovider.init();
      List<Configuracion> configuracion = await _dbprovider.getConfiguracion();
      //print(configuracion[0].dominio);
      if(configuracion.length>0){
          setState(() {
          _dominio = configuracion[0].dominio;
          //_semilla = configuracion[0].semilla;      
        });
      }
      else{
        _dominio = null;
        //_semilla = null;
      }
    } catch (ex) {
      _dominio = null;
        //_semilla = null;
    }
  }
}
