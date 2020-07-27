import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'menu.dart';

DBProvider _dbprovider = DBProvider.get();
Menu _menu = new Menu();
int versionDB=0;

String appName = "";
String packageName = "";
String versionApp = "";
String buildNumber = "";
String versionOS ="";
String matricula ="";
String nombreUsuario ="";
String numTelefono ="";
ProgressDialog pr; 

class PTAcerca extends StatefulWidget {
  static const String routeName = "/pantalla_acerca";
  PTAcerca({Key key}) : super(key: key);
  @override
  _PTAcercaState createState() => new _PTAcercaState();
}

class _PTAcercaState extends State<PTAcerca> {
  
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 3), () {
      obtenerVersiones();
      getVerifyDataLocal();

      //pr.hide().whenComplete(() => null);
    });
    
  }

  void obtenerVersiones() async{
    try{
      versionDB = await _dbprovider.db.getVersion();
    }on PlatformException{
      versionOS = 'Error al leer la versión';
    }
    
    try {
      versionOS = await GetVersion.platformVersion;
    } on PlatformException {
      versionOS = 'Error al leer la versión';
    }
    try {
      versionApp = await GetVersion.projectVersion;
    } on PlatformException {
      versionApp = 'Error al leer la versión';
    }
    try {
      appName = await GetVersion.appName;
    } on PlatformException {
      appName = 'Error al leer la versión';
    }
    try {
      packageName = await GetVersion.appID;
    } on PlatformException {
      packageName = 'Error al leer la versión';
    }
  }
  

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,isDismissible: true);
    pr.style(
      message: 'Procesando la información...',
      borderRadius: 0.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      progress: 0.0,
      maxProgress: 30.0,
      progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400)
    );
    //pr.show();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Acerca de", textAlign: TextAlign.center),
      ),
      drawer: _menu.getDrawer(context),
      body: new Container(
        child: ListView(
          children: <Widget>[
             ListTile(
                leading: Icon(Icons.perm_device_information,color: Colors.blue,),
                title: Text("Versión de la Aplicación",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$versionApp'
                ),                
              ),
              ListTile(
                leading: Icon(Icons.storage,color: Colors.blue,),
                title: Text("Versión de la BDD",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$versionDB'+".0.0"
                ),
                
              ),
              ListTile(
                leading: Icon(Icons.android,color: Colors.blue,),
                title: Text("Versión del OS",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$versionOS'
                ),
                
              ),
              ListTile(
                leading: Icon(Icons.apps,color: Colors.blue,),
                title: Text("Nombre real de la aplicación",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$appName'
                ),
                
              ),
              ListTile(
                leading: Icon(Icons.adb,color: Colors.blue,),
                title: Text("ID de la aplicación",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$packageName'
                ),
                
              ),
              ListTile(
                leading: Icon(Icons.person,color: Colors.blue,),
                title: Text("Usuario",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$nombreUsuario'
                ),                
              ),
              ListTile(
                leading: Icon(Icons.phone,color: Colors.blue,),
                title: Text("Número de Teléfono",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$numTelefono'
                ),                
              ),
              ListTile(
                leading: Icon(Icons.directions_car,color: Colors.blue,),
                title: Text("Matrícula",style: TextStyle(fontSize: 14.0),),
                subtitle: Text(
                  '$matricula'
                ),                
              ),
          ],
        ),
      )
    );
  }

  Future<List<DataLocal>> getVerifyDataLocal() async{
    List<DataLocal> retunn = new List<DataLocal>();    
    try{
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicial();
      setState(() {
        if(list != null){
          var val = list.length-1;
            numTelefono = list[val].numPhone;
            matricula = list[val].carPlate;  
            nombreUsuario =list[val].nombreCompleto;         
            _dbprovider.deleteDataLocal(null);
          //}         
        }        
        return list;          
      }); 
      
    }
    catch(Ex){
      
    }
    return retunn;
  }

}