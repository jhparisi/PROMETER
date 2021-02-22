import 'dart:io';

import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:eszaworker/class/ControlHourDateClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/src/pantalla_editarhoras.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'menu.dart';

Menu _menu = new Menu();
List<ControlHourDateClass> _dataLT = new List<ControlHourDateClass>();
var colorIcono = Colors.blue;
bool mostrarBoton = false;
String tiempoTotal = "00:00:00";
String textoBoton = "Editar";

class PTResumenLT extends StatefulWidget {
  final ControlHour data;
  PTResumenLT({Key key, this.data}) : super(key: key);
  @override
  _PTResumenLTState createState() => new _PTResumenLTState();
}

class _PTResumenLTState extends State<PTResumenLT> {
  @override
  void initState() {
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
    List<Widget> accion = new List<Widget>();

    // set up the buttons
    Widget botonCancelar = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget botonAceptar = FlatButton(
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
            textAlign: TextAlign.center),
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
            Visibility(
                visible: mostrarBoton,
                child: RaisedButton(
                  onPressed: () {
                    Future.delayed(Duration(seconds: 3)).then((value) {
                      exit(0);
                    });
                  },
                  child: Text('Terminar'),
                  color: Colors.blue,
                  textColor: Colors.white,
                )),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Text(
              "Tiempo total: $tiempoTotal",
              style: TextStyle(fontSize: 20.0, color: Colors.blue),
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
                    style: TextStyle(color: colorIcono),
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
                  trailing: Text(fecha),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Column llenarLinea() {
      Iterable inReverse = _dataLT.reversed;
      var dataList = inReverse.toList();
      return Column(
        children: List.generate(dataList.length, (index) {
          return lineaTiempo(
              Icon(
                Icons.access_alarm,
                color: colorIcono,
              ),
              dataList[index].evento,
              dataList[index]
                  .fechaHora
                  .toString()
                  .split("T")[1]
                  .substring(0, 8));
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
    var data = await HttpHandler().fetchControlHorasFecha(idUsuario, fecha);
    Iterable inReverse = data.reversed;
    var dataList = inReverse.toList();
    //data = data.reversed;
    var existe = 0;
    setState(() {
      if (comentario != null && comentario != "") {
        mostrarBoton = true;
        textoBoton = "Editar";
        existe = 1;
      } else {
        mostrarBoton = false;
        textoBoton = "Editar";
      }
      if (dataList.length > 0) {
        _dataLT = [];
        for (var i = 0; i < dataList.length; i++) {
          if (dataList[i].modificadoManual == true) {
            _dataLT.add(dataList[i]);
            existe = 1;
            colorIcono = Colors.red;
            textoBoton = "Editar";
          }
          if (dataList[i].modificadoManual == false && existe == 0) {
            _dataLT.add(dataList[i]);
            colorIcono = Colors.blue;
            textoBoton = "Crear Nuevo";
          }
        }
        var diferenciaHoras = 0; //fecha1.difference(fecha2).inMinutes;
        var fecha1 = DateTime.now();
        var fecha2 = DateTime.now();
        for (var item in _dataLT) {
          if (item.evento.indexOf("Fin") != -1) {
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
          }
        }
        /* int horas = (diferenciaHoras / 3600).truncate();
        String minutesStr = (horas % 60).toString().padLeft(2, '0'); */
        //Cambiar para horario de verano a 7200000 y para horario invierno 3600000
        int restaMilisegundos = 3600000;
        DateTime durationDate = DateTime.fromMillisecondsSinceEpoch(
            diferenciaHoras - restaMilisegundos);
        String duration = DateFormat('HH:mm:ss').format(durationDate);
        tiempoTotal = duration.toString();
      }
    });
  }
}
