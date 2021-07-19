import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

ProgressDialog prd;
WorkingDay _wd = new WorkingDay();
DBProvider _dbprovider = DBProvider.get();
final kmsBeginningController = TextEditingController();
final dateBeginningController = TextEditingController();
int userId = _menu.getuserId();
Menu _menu = new Menu();
DateTime date1;
String evento = "";
int kilometrajeInicio = 0;
String _dominio;
String _semilla;

class PTIniciarRuta extends StatefulWidget {
  static const String routeName = "/pantalla_iniciar_trayecto";
  PTIniciarRuta({Key key}) : super(key: key);
  _PTIniciarRutaState createState() => _PTIniciarRutaState();
}

class NoKeyboardEditableTextFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}

class _PTIniciarRutaState extends State<PTIniciarRuta> {
  final _formKey = GlobalKey<FormState>();
  final fechaInicio = new DateTime.now();

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
          _dbprovider.deleteWorkingDay(userId);
          _dbprovider.deletePlayPause(userId);
          insertWorkingDayLocal(
              carPlate,
              '',
              kmsBeginningController.text,
              '',
              DateTime.now().toString(),
              userId.toString());
          postDataWorkingDay(
              carPlate,
              '',
              kmsBeginningController.text,
              '',
              DateTime.now().toString(),
              userId.toString());
          prd.show();
          Future.delayed(Duration(seconds: 3)).then((value) {
            prd.hide().whenComplete(() {
              final data = PlayPauseTracking(
                  trackingPLay: 0,
                  userId: userId,
                  dateBeginning: DateTime.now().toString());
              _getCurrentLocationPausaReanudar("ComienzaJornada");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PTCerrarRuta(
                            data: data,
                            registraControlHora: 1,
                          )));
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
    //
    _menu.getVerifyDataLocal(userId);
    prd = new ProgressDialog(context);
    prd.style(
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
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("PRO-METER APP", textAlign: TextAlign.center),
        ),
        drawer: _menu.getDrawer(context),
        body: new Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 0.0),
              child: Column(
                children: <Widget>[                  
                  /* DateTimePickerFormField(
                    controller: dateBeginningController,
                    focusNode: NoKeyboardEditableTextFocusNode(),
                    inputType: InputType.both,
                    format: DateFormat("yyyy-MM-dd H:mm:ss"),
                    editable: true,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                        enabled: false, labelText: 'Fecha de comienzo:'
                        //hasFloatingPlaceholder: true
                        ),
                    onChanged: (dt) {
                      setState(() => date1 = dt);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Debes indicar la fecha de inicio';
                      }
                      return null;
                    },
                  ), */
                  DateTimeField(
                    format: DateFormat("yyyy-MM-dd H:mm:ss"),
                    controller: dateBeginningController,
                    style: TextStyle(color: Colors.grey),
                    readOnly: true,
                    decoration: InputDecoration(
                      enabled: true, 
                      labelText: 'Fecha de comienzo:'
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
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Matrícula:'),
                    readOnly: true,
                    enabled: false,
                    initialValue: _menu.getCarPlate(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextFormField(
                    controller: kmsBeginningController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Kms al empezar:'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Debes indicar los Km al empezar';
                      }
                      if (kilometrajeInicio > 0) {
                        if (int.parse(value) > kilometrajeInicio + 100) {
                          showAlertDialog(
                            context,
                            "Advertencia!",
                            "El kilometraje inicial("+kmsBeginningController.text+"),\nno puede superar por mas de 100km \nal kilometraje anterior($kilometrajeInicio).\n¿Estas seguro de querer guardar estos valores?",
                            Colors.red,
                            1);
                          return 'El kilometraje inicial,\nno puede superar por mas de 100km \nal kilometraje anterior';
                        }
                      }

                      return null;
                    },
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        //ENVIO EL INICIO DE CONTROL DE HORA
                        String fecha = DateTime.now().toString();
                        //var fechaSplit = fecha.split(" ");
                        //var hora = fechaSplit[1].split(":");

                        /* postControlHour(
                            userId.toString(),
                            dateBeginningController.text,
                            "0",
                            "Inicio",
                            "Registro Automatico",
                            dateBeginningController.text); */
                        //FIN CONTROL DE HORA
                        _dbprovider.deleteWorkingDay(userId);
                        insertWorkingDayLocal(
                            carPlate,
                            '',
                            kmsBeginningController.text,
                            '',
                            fecha,
                            userId.toString());
                        postDataWorkingDay(
                            carPlate,
                            '',
                            kmsBeginningController.text,
                            '',
                            fecha,
                            userId.toString());

                        prd.show();
                        Future.delayed(Duration(seconds: 3)).then((value) {
                          prd.hide().whenComplete(() {
                            final data = PlayPauseTracking(
                                trackingPLay: 0,
                                userId: userId,
                                dateBeginning: fecha);
                            _getCurrentLocationPausaReanudar("ComienzaJornada");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PTCerrarRuta(
                                          data: data,
                                          registraControlHora: 1,
                                        )));
                          });
                        });
                      }
                    },
                    child: Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    )
                  )
                ],
              ),
            ))));
  }

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

  Future postDataWorkingDay(carPlate, endingDate, kmsBeginning, ksmTheEnd,
      startingDate, userId) async {
    var respuesta = "";
    var working = await HttpHandler().postWorkingDay(
        carPlate, endingDate, kmsBeginning, ksmTheEnd, startingDate, userId,_dominio, _semilla);
    if (working == "OK") {
      respuesta = "OK";
    }
    return respuesta;
  }

  Future postControlHour(
      idUsuario, fecha, modificadoManual, evento, comentario, fechaHora) async {
    var respuesta = "";
    var control = await HttpHandler().postControlHour(
        idUsuario, fecha, modificadoManual, evento, comentario, fechaHora,_dominio, _semilla);
    if (control == "OK") {
      respuesta = "OK";
    }
    return respuesta;
  }

  Future<List<WorkingDay>> getWDLocal() async {
    List<WorkingDay> retunn = [];
    List<WorkingDay> list = await _dbprovider.getWorkingDay();
    try {
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            kmsBeginningController.text = list[0].kmsTheEnd;
            kilometrajeInicio = int.parse(list[0].kmsTheEnd);
            dateBeginningController.text = fechaInicio.toString();
          }
        } else {
          dateBeginningController.text = fechaInicio.toString();
        }
        return list;
      });
    } catch (Ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTInicial()));
    }
    return retunn;
  }

  _getCurrentLocationPausaReanudar(String evento) async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position positionn) {
      setState(() {
        var _currentPositionN = positionn;
        var lati = _currentPositionN.latitude.toString();
        var longi = _currentPositionN.longitude.toString();
        var alti = _currentPositionN.altitude.toString();
        var fecha = DateTime.now().toString();
        var uId = userId.toString();
        var tracking = HttpHandler().postTrackingData(
            alti.replaceAll('.', ','),
            fecha,
            lati.replaceAll('.', ','),
            longi.replaceAll('.', ','),
            uId,
            evento,_dominio, _semilla);
        var respuesta = tracking.toString();
        print("SE HA REGISTRADO EL EVENTO:" + respuesta);
      });
    }).catchError((e) {
      print(e);
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
    } catch (Ex) {
      _dominio = null;
        _semilla = null;
    }
  }
}
