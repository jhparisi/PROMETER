import 'dart:io';

import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/class/HistoricoClass.dart';
//import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:intl/intl.dart';

DBProvider _dbprovider = DBProvider.get();
String userName ="";
String carPlate ="";
String numPhone="";
int userId = 0;
int versionDB=0;
int acompanante =0;
var mostrarMenu = true;
String ultimoLogin;

class _DatosDelUsuario extends StatelessWidget {
  _DatosDelUsuario({
    Key key,
    this.nombre,
    this.telefono,
    this.vehiculo,
    this.conexion,
    this.fechaConexion,
  }) : super(key: key);

  final String nombre;
  final String telefono;
  final String vehiculo;
  final String conexion;
  final String fechaConexion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$nombre',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Icon(Icons.phone, size: 14, color: Colors.white,),
                  Text(
                    ' $telefono',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.directions_car, size: 14, color: Colors.white,),
                  Text(
                  ' $vehiculo',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
              ],)
              
            ],
          ),
        ),
        
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.phonelink_ring, size: 14, color: Colors.white,),
                  Text(
                    ' $conexion',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ), 
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 14.0),),
                  //Icon(Icons.access_time, size: 14, color: Colors.white,),
                  Text(
                    ' $fechaConexion',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),             
              
            ],
          ),
        ),
      ],
    );
  }
}

class ListItemDatosUsuario extends StatelessWidget {
  ListItemDatosUsuario({
    Key key,
    this.thumbnail,
    this.nombre,
    this.telefono,
    this.vehiculo,
    this.conexion,
    this.fechaConexion,
  }) : super(key: key);

  final Widget thumbnail;
  final String nombre;
  final String telefono;
  final String vehiculo;
  final String conexion;
  final String fechaConexion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
                  child: Icon(Icons.person, size: 50.0, color: Colors.blueGrey,),
                  minRadius: 50.0,
                  backgroundColor: Colors.white,
                ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: _DatosDelUsuario(
                  nombre: nombre,
                  telefono: telefono,
                  vehiculo: vehiculo,
                  conexion: conexion,
                  fechaConexion: fechaConexion
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({Key key, userId}) : super(key: key);
  
  Drawer getDrawer(BuildContext context){
    ListTile getItem(Icon icon, String name, String route){
      
      if(acompanante==1 && name == "Repostar"){
        mostrarMenu =false;
      }
      else{
        mostrarMenu= true;
      }
      return ListTile(
        leading: icon,
        title: Text(name),
        enabled: mostrarMenu,
        onTap: (){
          if(route!=""){
            Navigator.pushNamed(context, route);
          }
          else{
            exit(0);
          }
                    
        },
      );
    }
    ListView getListDrawer(){
      return ListView(                 
        children: <Widget>[ 
          Container(
            padding:  EdgeInsets.all(10.0),
            color: Colors.blue,
            child:
              ListItemDatosUsuario(
                thumbnail: Container(
                  decoration: const BoxDecoration(color: Colors.pink),
                ),
                nombre: userName,
                telefono:numPhone,
                vehiculo:carPlate,                
                conexion: 'Última Conexión',
                fechaConexion: '$ultimoLogin'
              ),
            
          ),   
          getItem(Icon(Icons.local_gas_station),"Repostar","/pantalla_repostar"),
          getItem(Icon(Icons.message),"Mensajes","/pantalla_mensajes"),
          getItem(Icon(Icons.settings),"Configuración","/pantalla_inicial"),
          getItem(Icon(Icons.security),"Seguridad y privacidad","/pantalla_seguridad"),
          getItem(Icon(Icons.help),"Ayuda y FQAs","/pantalla_ayuda"),
          getItem(Icon(Icons.info),"Acerca de","/pantalla_acerca"),
          getItem(Icon(Icons.exit_to_app),"Cerrar Sesión",""),
        ],
      );
    }

    return Drawer(child: getListDrawer());
  } 

  @override
  Widget build(BuildContext context) {
    //print("LLEGA");
    getVerifyDataLocal(userId);
    //getHistorico();
    return Scaffold(
      drawer: getDrawer(context),
    );
  }

  Future<List<DataLocal>> getVerifyDataLocal(int id) async{
    userId = id;
    versionDB = await _dbprovider.db.getVersion();
    try{
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicialMenu(id);
      if(list != null){
        for(var i=0;i<list.length; i++){
          carPlate = list[i].carPlate;
          userName= list[i].nombreCompleto;
          numPhone =list[i].numPhone; 
          userId = list[i].userId;
          acompanante = list[i].acompanante;        
        }
        if(acompanante==1){
          mostrarMenu = false;
        }
      }

      List<Historico> listH = await _dbprovider.getHistorico();
      if(listH != null){
        for(var i=0;i<listH.length-1; i++){
            //print("HISTORICO $i");
            //print(listH[i].fechaUltimoLogin);
            var fecha = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(listH[i].fechaUltimoLogin);
            ultimoLogin = fecha.toString();
        }

      }
    //print(list);
      return list; 
    }   
    catch(Ex){
      return null;
    }
    

  }

  

  String getCarPlate(){
    return carPlate;
  }
  int getuserId(){
    return userId;
  }
  int getAcompanante(){
    return acompanante;
  }
}