import 'dart:io';

import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:eszaworker/class/ControlHourDateClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_editarhoras.dart';
import 'package:eszaworker/utilities/funciones_generales.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'menu.dart';
DBProvider _dbprovider = DBProvider.get();
Menu _menu = new Menu();
List<ControlHourDateClass> _dataLT = [];
var colorIcono = Colors.blue;
bool mostrarBoton = false;
String tiempoTotal = "00:00:00";
String textoBoton = "Editar";
var zona = DateTime.now().timeZoneName;
String _dominio;
String _semilla;

class PTResumenLT extends StatefulWidget {
  final ControlHour data;
  PTResumenLT({Key key, this.data}) : super(key: key);
  @override
  _PTResumenLTState createState() => new _PTResumenLTState();
}

class _PTResumenLTState extends State<PTResumenLT> {
  @override
  void initState() {
    getConfiguracion();
    print("ZONA HORARIA");
    getConfiguracion();
    getControlHorasDate(
        widget.data.idUsuario, widget.data.fecha, widget.data.comentario);
    super.initState();
  }

  Flushbar fbar = new Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.red,
    message:
        "En esta pantalla no se puede ir atrás! \nPara regresar pinche en el menú.",
    duration: Duration(seconds: 5),
  );

//***************************AlertDialog*************************************************//
  showAlertDialog(BuildContext context, String pregunta, String datos,
      Color color, int btnAceptar) {
    List<Widget> accion = [];

    // set up the buttons
    Widget botonCancelar = TextButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget botonAceptar = TextButton(
      child: Text("Aceptar"),
      onPressed: () {
        final data = ControlHour(
            idUsuario: widget.data.idUsuario, fecha: widget.data.fecha);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PTEditarHoras(data: data)));
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
  @override
  Widget build(BuildContext context) {
    var fec = widget.data.fecha.split("-");
    String fechaFormateadaES =
        fec[2].split(" ")[0] + "-" + fec[1] + "-" + fec[0];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Resumen jornada " + fechaFormateadaES,
            textAlign: TextAlign.center, style: TextStyle(fontFamily: 'HeeboSemiBold'),),
      ),
      drawer: _menu.getDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getLineaTiempo(),
            Visibility(
              visible: mostrarBoton,
              child: WillPopScope(
                child: Container(),
                onWillPop: () {
                  fbar.show(context);
                  return new Future(() => false);
                },
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 25.0)),
            Visibility(
                visible: mostrarBoton,
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(Duration(seconds: 3)).then((value) {
                      exit(0);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFF2eac6b),
                      shape: new RoundedRectangleBorder(
                        borderRadius:
                            new BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                          top: 10,
                          bottom: 10.0),
                      child: Text(
                        "Terminar",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HeeboSemiBold'),
                      ),
                    )
                )),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Text(
              "Tiempo total: $tiempoTotal",
              style: TextStyle(fontSize: 20.0, color: Colors.blue,fontFamily: 'HeeboSemiBold'),
            ),
            Padding(padding: EdgeInsets.only(top: 70.0)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAlertDialog(
              context,
              "Alerta!",
              "¿Está seguro de querer editar manualmente las horas de trabajo?",
              Colors.red,
              1);
        },
        label: Text(textoBoton),
        icon: Icon(Icons.edit),
        backgroundColor: Colors.blue,
      ),
    );
  }

  SingleChildScrollView getLineaTiempo() {
    Column lineaTiempo(Icon icono, String evento, String fecha) {
      if(fecha !=null){
        return Column(
          children: <Widget>[
            TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.3,
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 60,
                ),
                color: Colors.transparent,
                child: Container(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    leading: icono,
                    title: Text(
                      evento,
                      style: TextStyle(color: colorIcono,fontFamily: 'HeeboSemiBold'),
                    ),
                  ),
                ),
              ),
              startChild: Container(
                color: Colors.transparent,
                child: Container(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    trailing: Text(fecha, style: TextStyle(fontFamily: 'HeeboSemiBold', fontSize: 12.0),),
                  ),
                ),
              ),
            ),
          ],
        );
      }
      else{
        return Column();
      }
    }

    Column llenarLinea() {
      Iterable inReverse = _dataLT.reversed;
      var dataList = inReverse.toList();
      return Column(
        children: List.generate(dataList.length, (index) {
          var fechaHoraItem = int.parse(dataList[index].fechaHora.toString().split('.')[0].replaceAll('-', '').replaceAll('T', '').replaceAll(':',''));
          var fechaItemStr = dataList[0].fecha.toString().split('T')[0] + "03:59:59";
          var fechaItem = int.parse(fechaItemStr.replaceAll('-', '').replaceAll('T', '').replaceAll(':',''));
          if(fechaHoraItem > fechaItem){
            if(dataList[index].evento == "TotalTramo"){
              return lineaTiempo(
                Icon(
                  Icons.calculate,
                  color: Colors.green,
                ),
                dataList[index].evento,
                dataList[index].tiempoTotal.toString());
            }
            else{
              return lineaTiempo(
                Icon(
                  Icons.access_alarm,
                  color: colorIcono,
                ),
                dataList[index].evento,
                dataList[index].fechaHora.toString().split("T")[0].split("-")[2] + "-" +dataList[index].fechaHora.toString().split("T")[0].split("-")[1] +"-" +dataList[index].fechaHora.toString().split("T")[0].split("-")[0]  + "\n" + dataList[index].fechaHora.toString().split("T")[1]);
            }
          } 
          else{
            return lineaTiempo(
                Icon(
                  Icons.calculate,
                  color: Colors.green,
                ),
                "",
                null);
          }
        }),
      );
    }

    return SingleChildScrollView(child: llenarLinea());
  }

  void getControlHorasDate(
      String idUsuario, String fecha, String comentario) async {
    if (fecha == "") {
      setState(() {
        fecha = new DateTime.now().toString().substring(0, 19);
      });
    }
    //await _dbprovider.init();
    var dameDom = await dameDominio();
    var dameSemi = await dameSemilla();
    _dominio = dameDom;
    _semilla = dameSemi;
    var data = await HttpHandler().fetchControlHorasFecha(idUsuario, fecha, _dominio, _semilla);
    Iterable inReverse = data.reversed;
    var dataList = inReverse.toList();
    //data = data.reversed;
    var existe = 0;
    setState(() {
      if (comentario != null && comentario != "") {
        mostrarBoton = true;
        textoBoton = "Editar";
        //existe = 1;
      } else {
        mostrarBoton = false;
        textoBoton = "Editar";
      }
      if (dataList.length > 0) {
        _dataLT = [];
        var tieneModManual = false;
        for (var i = 0; i < dataList.length; i++){
          if (dataList[i].modificadoManual == true){
            tieneModManual = true;
            break;
          }
        }
        for (var i = 0; i < dataList.length; i++) {
          if (dataList[i].modificadoManual == true && tieneModManual==true) {
            _dataLT.add(dataList[i]);
            existe = 1;
            colorIcono = Colors.red;
            textoBoton = "Editar";
          }
          if (dataList[i].modificadoManual == false && existe == 0 && tieneModManual==false) {
            _dataLT.add(dataList[i]);
            colorIcono = Colors.blue;
            textoBoton = "Crear Nuevo";
          }
        }
        /* var diferenciaHoras = 0; //fecha1.difference(fecha2).inMinutes;
        var fecha1 = DateTime.now();
        var fecha2 = DateTime.now(); */
        
        var hor = 0;
        var min = 0;
        var seg = 0;
        
        var numDataList = dataList.length-1;
        var fechaItemStr = dataList[numDataList].fecha.toString().split('T')[0] + "03:59:59";
        var fechaItem = int.parse(fechaItemStr.replaceAll('-', '').replaceAll('T', '').replaceAll(':',''));
        for (var item in _dataLT) {
          /* if (item.evento.indexOf("Fin") != -1) {
            var fechaHo = item.fechaHora;
            if (fechaHo.indexOf(".") != -1) {
              var splitH = fechaHo.split(".");
              fechaHo = splitH[0];
            }
            fecha1 = DateTime.parse(fechaHo);
          }
          if (item.evento.indexOf("Inic") != -1) {
            fecha2 = DateTime.parse(item.fechaHora);
            diferenciaHoras += fecha1.difference(fecha2).inMilliseconds;
            //reseteo las fechas
            fecha1 = DateTime.now();
            fecha2 = DateTime.now();
          } */
          var xYx = item.fechaHora.split('.')[0];
          var fechaHoraItem = int.parse(xYx.toString().replaceAll('-', '').replaceAll('T', '').replaceAll(':',''));
          if(fechaHoraItem>fechaItem){
            if(item.evento.indexOf("Total") != -1){
              var fech = item.tiempoTotal.split(":");
              hor += int.parse(fech[0]);
              min += int.parse(fech[1]);
              seg += int.parse(fech[2]);
            }
          }
          
        }
        String segundosString = (seg % 60).toString().padLeft(2, '0');
        int segundoResi = seg ~/ 60;
        min += segundoResi;
        String minutosString = (min % 60).toString().padLeft(2, '0');
        int minutoResi = min ~/ 60;
        hor += minutoResi;
        //String horaString = hor.toString().padLeft(2,'0');

        tiempoTotal = hor.toString() + ":" + minutosString + ":" + segundosString;
        /* /* int horas = (diferenciaHoras / 3600).truncate();
        String minutesStr = (horas % 60).toString().padLeft(2, '0'); */
        //Cambiar para horario de verano a 7200000 y para horario invierno 3600000
        int restaMilisegundos = 3600000;
        if(zona =="WEST"){
          restaMilisegundos = 0;
        }
        else if(zona == "CEST"){
          restaMilisegundos = 3600000;
        }
        DateTime durationDate = DateTime.fromMillisecondsSinceEpoch(
            diferenciaHoras - restaMilisegundos);
        String duration = DateFormat('HH:mm:ss').format(durationDate);
        tiempoTotal = duration.toString(); */
      }
    });
  }

  getConfiguracion() async {     
    try {
      List<Configuracion> configuracion = await _dbprovider.getConfiguracion();
      //print(configuracion[0].dominio);
      if(configuracion.length>0){
         setState(() {
          _dominio = configuracion[0].dominio;
          _semilla = configuracion[0].semilla;      
        });
      }
      else{
        _dominio = null;
        _semilla = null;
      }
    } catch (ex) {
      _dominio = null;
        _semilla = null;
    }
  }
}
