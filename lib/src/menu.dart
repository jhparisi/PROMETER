import 'dart:io';
import 'dart:ui';

import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/class/HistoricoClass.dart';
import 'package:eszaworker/class/UserByPhoneAPIClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/utilities/funciones_generales.dart';
//import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:intl/intl.dart';

DBProvider _dbprovider = DBProvider.get();
String userName = "";
String carPlate = "";
String numPhone = "";
int userId = 0;
int versionDB = 0;
int acompanante = 0;
var mostrarMenu = true;
String ultimoLogin;
String _imagenAvatar = "";

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
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$nombre',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'HeeboSemiBold'),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.phone,
                    size: 12,
                    color: Colors.white,
                  ),
                  Text(
                    ' $telefono',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,fontFamily: 'HeeboSemiBold'
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.directions_car,
                    size: 12,
                    color: Colors.white,
                  ),
                  Text(
                    ' $vehiculo',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,fontFamily: 'HeeboSemiBold'
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.date_range,
                    size: 12,
                    color: Colors.white,
                  ),
                  Text(
                    ' $conexion',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontFamily: 'HeeboSemiBold'
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 14.0),
                  ),
                  //Icon(Icons.access_time, size: 14, color: Colors.white,),
                  Text(
                    ' $fechaConexion',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontFamily: 'HeeboSemiBold'
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
    getFotoUsuario();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(_imagenAvatar),
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
                    fechaConexion: fechaConexion),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<FotoUsuarioClass> getFotoUsuario() async{
    var dameDomi = await dameDominio();
    var dameSemi = await dameSemilla();
    var dominio = dameDomi;
    var semilla = dameSemi;
    var data = await HttpHandler.get().fetchFotoUsuarioAPI(dominio, semilla, userId.toString());
    if(data.length>0){
      var foto = data[0].foto;      
      _imagenAvatar = foto;
    }
    return null;
  }
}

class Menu extends StatelessWidget {
  const Menu({Key key, userId}) : super(key: key);

  Drawer getDrawer(BuildContext context) {
    ListTile getItem(Icon icon, String name, String route) {
      if (acompanante == 1 && name == "Repostar") {
        mostrarMenu = false;
      } else {
        mostrarMenu = true;
      }
      return ListTile(
        leading: icon,
        title: Text(name, style: TextStyle(fontFamily: 'HeeboSemiBold'),),
        enabled: mostrarMenu,
        onTap: () {
          if (route != "") {
            Navigator.pushNamed(context, route);
          } else {
            exit(0);
          }
        },
      );
    }

    ListView getListDrawer() {
      return ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.blue,
            child: ListItemDatosUsuario(
                thumbnail: Container(
                  decoration: const BoxDecoration(color: Colors.pink),
                ),
                nombre: userName,
                telefono: numPhone,
                vehiculo: carPlate,
                conexion: 'Última Conexión',
                fechaConexion: '$ultimoLogin'),
          ),
          getItem(Icon(Icons.local_gas_station, color: Colors.blue,), "Repostar", "/pantalla_repostar"),
          getItem(Icon(Icons.message, color: Colors.blue), "Mensajes", "/pantalla_mensajes"),
          getItem(Icon(Icons.swap_calls, color: Colors.blue), "Actividad", "/pantalla_principal"),
          getItem(Icon(Icons.security, color: Colors.blue), "Seguridad y privacidad","/pantalla_seguridad"),
          getItem(Icon(Icons.help, color: Colors.blue), "Ayuda y FQAs", "/pantalla_ayuda"),
          getItem(Icon(Icons.info, color: Colors.blue), "Acerca de", "/pantalla_acerca"),
          getItem(Icon(Icons.lock_clock, color: Colors.blue), "Propuesta horas trabajadas","/pantalla_controlhoras"),
          getItem(Icon(Icons.exit_to_app, color: Colors.blue), "Cerrar Sesión", ""),
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

  Future<List<DataLocal>> getVerifyDataLocal(int id) async {
    userId = id;
    versionDB = await _dbprovider.db.getVersion();
    try {
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicialMenu(id);
      if (list != null) {
        for (var i = 0; i < list.length; i++) {
          carPlate = list[i].carPlate;
          userName = list[i].nombreCompleto;
          numPhone = list[i].numPhone;
          userId = list[i].userId;
          acompanante = list[i].acompanante;
        }
        if (acompanante == 1) {
          mostrarMenu = false;
        }
      }

      List<Historico> listH = await _dbprovider.getHistorico();
      if (listH != null) {
        for (var i = 0; i < listH.length - 1; i++) {
          //print("HISTORICO $i");
          //print(listH[i].fechaUltimoLogin);
          var fecha = new DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(listH[i].fechaUltimoLogin);
          ultimoLogin = fecha.toString();
        }
      }
      //print(list);
      return list;
    } catch (ex) {
      return null;
    }
  }

  

  String getCarPlate() {
    return carPlate;
  }

  int getuserId() {
    return userId;
  }

  int getAcompanante() {
    return acompanante;
  }
}
