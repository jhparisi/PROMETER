import 'dart:async';
import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:eszaworker/class/TrackingDataClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_inciar_trayecto.dart';
import 'package:eszaworker/src/pantalla_resumenLT.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

ProgressDialog prd;
Menu _menu = new Menu();
DBProvider _dbprovider = new DBProvider();
WorkingDay _wd = new WorkingDay();
//WorkingDay _wd = new WorkingDay();
DateTime date2;
String _dominio;
String _semilla;

int userId = _menu.getuserId();

class PTFinalizarRuta extends StatefulWidget {
  static const String routeName = "/pantalla_finalizar_trayecto";
  PTFinalizarRuta({Key key}) : super(key: key);
  _PTFinalizarRutaState createState() => _PTFinalizarRutaState();
}

class NoKeyboardEditableTextFocusNodeFin extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}

class _PTFinalizarRutaState extends State<PTFinalizarRuta> {
  final _formKey = GlobalKey<FormState>();
  final fechaInicio = new DateTime.now();
  String userId = _menu.getuserId().toString();
  final carPlateController = TextEditingController();
  final endingDateController = TextEditingController();
  final kmsBeginningController = TextEditingController();
  final kmsTheEndController = TextEditingController();
  final startingDateController = TextEditingController();
  Flushbar fbar;

  Flushbar fbar2 = new Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.red,
    message:
        "En esta pantalla no se puede ir atrás! \nDebes indicar los Km de finalización.",
    duration: Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    getConfiguracion();
    getWDLocal();
  }

  @override
  Widget build(BuildContext context) {
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
          Navigator.pop(context);
          getSendLocalDataToAPI();
          _dbprovider.deleteTrackingData(userId);
          _dbprovider.deleteWorkingDay(userId);
          _dbprovider.deletePlayPause(userId);
          insertWorkingDayLocal(
              carPlateController.text,
              endingDateController.text,
              kmsBeginningController.text,
              kmsTheEndController.text,
              dateBeginningController.text,
              userId.toString());
          getWDLocal();
          postControlHour(userId.toString(), endingDateController.text, "0",
              "Fin", "Registro automatico", endingDateController.text);
          prd.show();
          Future.delayed(Duration(seconds: 5)).then((value) {
            prd.hide().whenComplete(() {
              final data = ControlHour(
                  idUsuario: userId.toString(),
                  fecha: dateBeginningController.text,
                  comentario: "btnActivar");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PTResumenLT(data: data)));
            });
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
    _menu.getVerifyDataLocal(int.parse(userId));
    //getWDLocal();
    prd = new ProgressDialog(context);
    prd.style(
        message: 'Guardando los datos de fin de jornada',
        borderRadius: 0.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        progress: 0.0,
        maxProgress: 30.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("PRO-METER APP", textAlign: TextAlign.center),
          automaticallyImplyLeading: false,
        ),
        //drawer: _menu.getDrawer(context),
        body: Container(
            height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF)
          ],
              stops: [
            0.1,
            0.9
          ])),
            child: 
              SafeArea(
            child: 
              SingleChildScrollView(
                child: 
                  Padding(padding: EdgeInsets.only(right: 50.0, left: 50.0, top: 25.0),
                  child: new Form(
            key: _formKey,
            //child: Container(
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 0.0),
              child: Column(
                children: <Widget>[
                  WillPopScope(
                  child: Container(),
                  onWillPop: () {
                    fbar2.show(context);
                    return new Future(() => false);
                  },
                ),
                Padding(padding: EdgeInsets.only(top:25.0)),
                  TextFormField(
                    controller: startingDateController,
                    //decoration:InputDecoration(labelText: 'Fecha de comienzo:'),
                    decoration: InputDecoration(
                      labelText: "Fecha de inicio",
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.date_range,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.blue[100],
                    ),
                    readOnly: true,
                    enabled: false,
                    style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                  ),
                  Padding(padding: EdgeInsets.only(top:25.0)),
                  TextFormField(
                    controller: carPlateController,
                    //decoration: InputDecoration(labelText: 'Matrícula:'),
                    decoration: InputDecoration(
                      labelText: "Matrícula",
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.money_sharp,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.blue[100],
                    ),
                    readOnly: true,
                    enabled: false,
                    style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  TextFormField(
                    controller: kmsBeginningController,
                    //decoration: InputDecoration(labelText: 'Kms al empezar:'),
                    decoration: InputDecoration(
                      labelText: "Kms al empezar",
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.local_parking,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.blue[100],
                    ),
                    readOnly: true,
                    enabled: false,
                    style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                  ),
                  /* TextFormField(
                        controller: endingDateController,
                        decoration: InputDecoration(
                          labelText: 'Fecha fin:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.grey),
                      ), */
                  /* DateTimePickerFormField(
                    controller: endingDateController,
                    focusNode: NoKeyboardEditableTextFocusNodeFin(),
                    inputType: InputType.both,
                    format: DateFormat("yyyy-MM-dd H:mm:ss"),
                    editable: false,
                    decoration: InputDecoration(
                      labelText: 'Fecha fin:',
                      //hasFloatingPlaceholder: true
                    ),
                    onChanged: (dt) {
                      setState(() => date2 = dt);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Debes indicar la fecha de fin del trabajo';
                      }
                      return null;
                    },
                  ), */
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  DateTimeField(
                    format: DateFormat("yyyy-MM-dd H:mm:ss"),
                    controller: endingDateController,
                    style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                    readOnly: true,
                    /* decoration: InputDecoration(
                      enabled: true, 
                      labelText: 'Fecha fin:'
                    ), */
                    decoration: InputDecoration(
                      labelText: "Fecha fin",
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.date_range_outlined,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.blue[100],
                    ),
                    
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Localizations.override(
                          context: context,
                          locale: Locale('es'),
                          child: child,
                        ),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          builder: (context, child) => Localizations.override(
                            context: context,
                            locale: Locale('es'),
                            child: child,
                          ),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    },
                  ),
                  Padding(padding: EdgeInsets.only(top:25.0)),
                  TextFormField(
                    controller: kmsTheEndController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    //decoration: InputDecoration(labelText: 'Kms al terminar:'),
                    decoration: InputDecoration(
                      labelText: "Kms al terminar",
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(70.0)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.local_parking_rounded,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.blue[100],
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Debes indicar los Km al terminar';
                      }
                      if (int.parse(value) <
                          int.parse(kmsBeginningController.text)) {
                        var kmInic = int.parse(kmsBeginningController.text);
                        var kmfin = int.parse(kmsTheEndController.text);
                        showAlertDialog(
                            context,
                            "Advertencia!",
                            "Los Km indicados ($kmfin) no pueden ser inferiores \na los valores del último Kilometraje ($kmInic).\n¿Estas seguro de querer guardar estos valores?",
                            Colors.red,
                            1);
                        return 'Los kilometros al terminar, deben \nser mayores que los de inicio';
                      }
                      return null;
                    },
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        getSendLocalDataToAPI();
                        _dbprovider.deleteTrackingData(userId);
                        _dbprovider.deleteWorkingDay(userId);
                        _dbprovider.deletePlayPause(userId);
                        insertWorkingDayLocal(
                            carPlateController.text,
                            endingDateController.text,
                            kmsBeginningController.text,
                            kmsTheEndController.text,
                            dateBeginningController.text,
                            userId.toString());
                        getWDLocal();
                        postControlHour(
                            userId.toString(),
                            endingDateController.text,
                            "0",
                            "Fin",
                            "Registro automatico",
                            endingDateController.text);
                        prd.show();
                        Future.delayed(Duration(seconds: 5)).then((value) {
                          prd.hide().whenComplete(() {
                            var fecha =
                                new DateTime.now().toString().substring(0, 19);
                            final data = ControlHour(
                                idUsuario: userId.toString(),
                                fecha: fecha,
                                comentario: "btnActivar");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PTResumenLT(data: data)));
                          });
                        });
                        /* Future.delayed(Duration(seconds: 15)).then((value) {
                          exit(0);
                        }); */
                      }
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
                        "Finalizar",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HeeboSemiBold'),
                      ),
                    ),
                    /* color: Colors.blue,
                    textColor: Colors.white, */
                  )
                ],
              ),
            )))))
              ),
          )
              );
  }

  Future<List<WorkingDay>> getWDLocal() async {
    List<WorkingDay> retunn = [];
    try {
      List<WorkingDay> list = await _dbprovider.getWorkingDay();
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            carPlateController.text = list[0].carPlate;
            endingDateController.text = DateTime.now().toString();
            kmsBeginningController.text = list[0].kmsBeginning;
            startingDateController.text = list[0].startingDate.toString();
            userId = list[0].userId.toString();
          }
        }
        return list;
      });
    } catch (Ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTFinalizarRuta()));
    }
    return retunn;
  }

  Future postControlHour(
      idUsuario, fecha, modificadoManual, evento, comentario, fechaHora) async {
    var respuesta = "";
    var control = await HttpHandler().postControlHour(
        idUsuario, fecha, modificadoManual, evento, comentario, fechaHora, _dominio, _semilla);
    if (control == "OK") {
      respuesta = "OK";
    }
    return respuesta;
  }

  Future postDataWorkingDay() async {
    var respuesta = "";
    var working = await HttpHandler().postWorkingDay(
        carPlateController.text,
        endingDateController.text,
        kmsBeginningController.text,
        kmsTheEndController.text,
        startingDateController.text,
        userId, _dominio, _semilla);
    if (working == "OK") {
      respuesta = "OK";
    }
    return respuesta;
  }

  Future<List<TrackingData>> getSendLocalDataToAPI() async {
    String respuesta = postDataWorkingDay().toString();
    List<TrackingData> list = await _dbprovider.getTrackingAll();
    if (list != null) {
      for (var i = 0; i < list.length; i++) {
        var tracking = await HttpHandler().postTrackingData(
            list[i].altitude.replaceAll('.', ','),
            list[i].date,
            list[i].latitude.replaceAll('.', ','),
            list[i].longitude.replaceAll('.', ','),
            list[i].userId,
            "Posicionamiento", _dominio, _semilla);
        respuesta = tracking.toString();
      }
      if (respuesta == "OK") {
        fbar = new Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: "Se ha registrado correctamente!",
          duration: Duration(seconds: 5),
        );
        fbar.show(context);
      }
    }
    return list;
  }
  //

  void insertWorkingDayLocal(
      carPlate, endingDate, kmsBeginning, ksmTheEnd, startingDate, userId) {
    _wd.carPlate = carPlate;
    _wd.endingDate = endingDate;
    _wd.kmsBeginning = kmsBeginning;
    _wd.kmsTheEnd = ksmTheEnd;
    _wd.startingDate = startingDate;
    _wd.userId = userId;
    _dbprovider.addWorkingDay(_wd);
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
    } catch (Ex) {
      _dominio = null;
        _semilla = null;
    }
  }
}
