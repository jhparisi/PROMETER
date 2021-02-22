import 'dart:async';
import 'package:eszaworker/class/ControlHourAllClass.dart';
import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_editarhoras.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:eszaworker/src/pantalla_resumenLT.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
//import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;

ProgressDialog prd;
Menu _menu = new Menu();
int _idUser = _menu.getuserId();
final fechaInicio = new DateTime.now();
String userId = _menu.getuserId().toString();
final txtHoraInicialMController = TextEditingController();
final txtHoraFinalMController = TextEditingController();
final txtHoraInicialTController = TextEditingController();
final txtHoraFinalTController = TextEditingController();
final txtHoraInicialNController = TextEditingController();
final txtHoraFinalNController = TextEditingController();
final txtComentarioMController = TextEditingController();
final txtComentarioTController = TextEditingController();
final txtComentarioNController = TextEditingController();
var checkedM = false;
var checkedT = false;
var checkedN = false;
var mostrarBoton = false;
final DateTime now = DateTime.now();
String fechaHoy = now.toString();
var fechaHoySplit = fechaHoy.split(" ");
var fecha = fechaHoySplit[0].split("-");
var ano = int.parse(fecha[0]);
var mes = int.parse(fecha[1]);
var dia = int.parse(fecha[2]);
var colorEvento = Colors.green[600];
Flushbar fbar;

class PTControlHoras extends StatefulWidget {
  static const String routeName = "/pantalla_controlhoras";
  PTControlHoras({Key key}) : super(key: key);
  _PTControlHorasState createState() => _PTControlHorasState();
}

class _PTControlHorasState extends State<PTControlHoras> {
  //***************************AlertDialog*************************************************//
  showAlertDialog(BuildContext context, String pregunta, String datos,
      Color color, int btnAceptar) {
    List<Widget> accion = new List<Widget>();
    var fecha = datos.split(" ");
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
        final data =
            ControlHour(idUsuario: _idUser.toString(), fecha: fecha[9]);
        /*var fechaRegistro = fecha[9].split("-");
         var freg =
            fechaRegistro[2] + "-" + fechaRegistro[1] + "-" + fechaRegistro[0];
        postControlHour(_idUser.toString(), freg, "1", "Inicio",
            "Registro Manual", freg + " 08:00");
        postControlHour(_idUser.toString(), freg, "1", "Fin", "Registro Manual",
            freg + " 17:30"); */
        Timer(Duration(milliseconds: 500), () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PTEditarHoras(data: data)));
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

  DateTime _currentDate = DateTime(ano, mes, dia);
  DateTime _currentDate2 = DateTime(ano, mes, dia);
  String currentMonth = DateFormat.yMMM().format(DateTime(ano, mes, dia));
  DateTime _targetDateTime = DateTime(ano, mes, dia);

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  CalendarCarousel _calendarCarouselNoHeader;

  @override
  void initState() {
    getControlHorasAll(_idUser.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Example Calendar Carousel without header and custom prev & next button
    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      todayBorderColor: Colors.blue,
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate2 = date);
        String fechaFormateadaES = DateFormat('dd-MM-yyyy').format(date);
        int numEventos = events.length;
        var diaSeleccionado = date.day.toString();
        var mesSeleccionado = date.month.toString();
        if (diaSeleccionado.length == 1) {
          diaSeleccionado = "0" + diaSeleccionado;
        }
        if (mesSeleccionado.length == 1) {
          mesSeleccionado = "0" + mesSeleccionado;
        }
        var fechaSeleccionadaFormateada =
            date.year.toString() + mesSeleccionado + diaSeleccionado;
        var diaActual = now.day.toString();
        var mesActual = now.month.toString();
        if (diaActual.length == 1) {
          diaActual = "0" + diaActual;
        }
        if (mesActual.length == 1) {
          mesActual = "0" + mesActual;
        }
        var fechaActualFormateada = now.year.toString() + mesActual + diaActual;
        if (numEventos == 1) {
          var tituloSplit = events[0].title.split("*");
          String idusu = tituloSplit[1];
          String fec = tituloSplit[0];
          String mod = tituloSplit[2];
          final data =
              ControlHour(idUsuario: idusu, fecha: fec, modificadoManual: mod);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PTResumenLT(data: data)));
        } else if (numEventos > 1) {
          var tituloSplit = events[numEventos - 1].title.split("*");
          String idusu = tituloSplit[1];
          String fec = tituloSplit[0];
          String mod = tituloSplit[2];
          final data =
              ControlHour(idUsuario: idusu, fecha: fec, modificadoManual: mod);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PTResumenLT(data: data)));
        } else if (numEventos == 0 &&
            int.parse(fechaSeleccionadaFormateada) <=
                int.parse(fechaActualFormateada)) {
          showAlertDialog(
              context,
              "Alerta!",
              "¿Quieres agregar un horario de trabajo para esta fecha: $fechaFormateadaES ?",
              Colors.red,
              1);
        }
      },
      locale: "ES",
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: TextStyle(color: Colors.red[900], fontSize: 18.0),
      thisMonthDayBorderColor: Colors.transparent,
      weekFormat: false,
      //firstDayOfWeek: 2,
      markedDatesMap: _markedDateMap,
      height: 470.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: Colors.blue)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 22,
        color: Colors.blue,
      ),
      showHeader: true,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      todayButtonColor: Colors.yellow,
      selectedDayTextStyle: TextStyle(
        color: Colors.white,
      ),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('fecha presionada $date');
      },
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Control de horas de trabajo"),
        ),
        drawer: _menu.getDrawer(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarouselNoHeader,
              ),
              Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.0),
                              color: Colors.green[600],
                              height: 15.0,
                              width: 15.0,
                            ),
                            Text(
                                " Horas registradas automáticamente por la App.")
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 10.0)),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.0),
                              color: Colors.red,
                              height: 15.0,
                              width: 15.0,
                            ),
                            Text(
                                " Horas registradas por el usuario (Horario modificado).")
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
              //
            ],
          ),
        ));
  }

  Future<List<ControlHourAllClass>> getControlHorasAll(String idUsuario) async {
    List<ControlHourAllClass> retunn = new List<ControlHourAllClass>();
    try {
      List<ControlHourAllClass> list =
          await HttpHandler().fetchControlHorasTodas(idUsuario);
      setState(() {
        if (list != null) {
          for (var i = 0; i < list.length; i++) {
            if (list[i].modificadoManual == true) {
              colorEvento = Colors.red;
            } else {
              colorEvento = Colors.green[600];
            }
            // AGREGO LOS EVENTOS
            var fechaEvento = list[i].fecha.split("-");
            var anoEvento = int.parse(fechaEvento[0]);
            var mesEvento = int.parse(fechaEvento[1]);
            var dia = fechaEvento[2].split("T");
            String fechaFormateada =
                fechaEvento[0] + "-" + fechaEvento[1] + "-" + dia[0];
            var diaEvento = int.parse(dia[0]);
            _markedDateMap.add(
                new DateTime(anoEvento, mesEvento, diaEvento),
                new Event(
                  date: new DateTime(anoEvento, mesEvento, diaEvento),
                  title: fechaFormateada +
                      "*" +
                      userId +
                      "*" +
                      list[i].modificadoManual.toString(),
                  //icon: _eventIcon,
                  dot: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    color: colorEvento,
                    height: 10.0,
                    width: 10.0,
                  ),
                ));
          }
        }
        return list;
      });
    } catch (Ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTInicial()));
    }
    return retunn;
  }

  Future<bool> postControlHour(
      idUsuario, fecha, modificadoManual, evento, comentario, hora) async {
    var respuesta = false;
    var control = await HttpHandler().postControlHour(
        idUsuario, fecha, modificadoManual, evento, comentario, hora);
    if (control == "OK") {
      respuesta = true;
    }
    return respuesta;
  }
}
