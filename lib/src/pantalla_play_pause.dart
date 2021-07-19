//import 'dart:ffi';
import 'dart:convert';
import 'dart:io';

import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
//import 'package:eszaworker/src/cronometro.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:eszaworker/src/services/background_fetch_service.dart';
import 'package:eszaworker/src/services/location_service.dart';
import 'package:eszaworker/src/services/stoppable_service.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eszaworker/src/pantalla_finalizar_trayecto.dart';
import 'dart:async';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/class/TrackingDataClass.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'locator.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

ProgressDialog prdF;
DBProvider _dbprovider = DBProvider.get();
TrackingData _tracking = new TrackingData();
PlayPauseTracking _playPause = new PlayPauseTracking();
Menu _menu = new Menu();
//Cronometro _cronometro = new Cronometro();
String userId = _menu.getuserId().toString();
String long = "";
String lat = "";
String alt = "";
PTInicial ptinicial = new PTInicial();
Position _currentPosition;
Timer timer;
bool estaPausado = false;
bool actualizoHoraReinicio = false;
String textoPausado = "Pausar";
int timeSendData = 0;
int lastPosition = 0;
String tiempocronometro = "00:00:00";
DateTime tiempoActual;
DateTime tiempoInicio;
String dateBeginning = "";
String tiempoPausado = "0";
String horaPausa = "0";
String tiempoTrabajado;
String horaReinicia = "";
bool _isMoving;
bool enabled;
String motionActivity;
String odometer;
String content;
int acompanante = 0;
bool _first = true;
double _fontSize = 18;
Color _color = Colors.blue;
bool gpsActivo = true;
String textoTrabajandoPausado = "Trabajando";
bool sigueTrabajando = false;
String _semilla;
String _dominio;

JsonEncoder encoder = new JsonEncoder.withIndent("     ");

enum InfoButtons { play, stop }
Flushbar fbar = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message: "En esta pantalla no se puede ir atrás!",
  duration: Duration(seconds: 5),
);

// ignore: must_be_immutable
class PTCerrarRuta extends StatefulWidget {
  final PlayPauseTracking data;
  int registraControlHora;
  static const String routeName = "/pantalla_play_pause";
  PTCerrarRuta({Key key, this.data, this.registraControlHora})
      : super(key: key);
  _PTCerrarRutaState createState() => _PTCerrarRutaState();
}

class _PTCerrarRutaState extends State<PTCerrarRuta>
    with WidgetsBindingObserver {
  List<StoppableService> servicesToManage = [
    locator<LocationService>(),
    locator<BackgroundFetchService>(),
  ];

  @override
  void initState() {
    getConfiguracion();
    super.initState();    
    content = "    Enable the switch to begin tracking.";
    _isMoving = false;
    enabled = false;
    content = '';
    motionActivity = 'UNKNOWN';
    odometer = '0';
    Menu _menu = new Menu();
    estaPausado = false;
    userId = _menu.getuserId().toString();
    
    if (widget.data.dateBeginning != "") {
      dateBeginning = widget.data.dateBeginning;      
    } else {
      getLocalPlayPause();
      print("EL VALOR DE DATEBE ES::::" + dateBeginning.toString());
    }
    if (userId == "0") {
      userId = widget.data.userId.toString();
    }    
    
    print("VALOR CARGADO DEL USERID" + userId);
    addPlayPause(1); //PLAY
    WidgetsBinding.instance.addObserver(this);
    //cronometro();
    _initPlatformState();
    _onClickEnable(true);
    Timer(Duration(seconds: 3), () {
      cronometro();
      enviarNotificacionGPS();
    });

    getEventos(userId, dateBeginning);
  }

  Future<Null> _initPlatformState() async {
    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
    bg.BackgroundGeolocation.onHttp(_onHttp);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
            reset: true,
            debug: false,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 10.0,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true))
        .then((bg.State state) {
      print("[ready] ${state.toMap()}");
      setState(() {
        enabled = state.enabled;
        _isMoving = state.isMoving;
      });
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    servicesToManage.forEach((service) {
      if (state == AppLifecycleState.resumed) {
        service.start();
        print("VIENE DEL RESUMED");
        print("TIEMPO DEL CRONOMETRO: " + tiempocronometro);
        //cronometro();
      } else {
        service.stop();
        print("EL STATE ES: " + state.toString());
        //cronometro();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("SE ACTUALIZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    acompanante = _menu.getAcompanante();
    prdF = new ProgressDialog(context);
    prdF.style(
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
      body: new Container(
          child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  WillPopScope(
                    child: Container(),
                    onWillPop: () {
                      fbar.show(context);
                      return new Future(() => false);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                  ),
                  Image.asset(
                    'logoPrometer.png',
                    width: 150,
                    height: 150,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  Text('Tiempo de trabajo', style: TextStyle(fontSize: 12.0)),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  Text(
                    "$tiempocronometro",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: _color,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(textoTrabajandoPausado),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Column(
                        children: <Widget>[
                          MaterialButton(
                              onPressed: () {
                                setState(() {
                                  if (estaPausado == false) {
                                    estaPausado = true;
                                    addPlayPause(2); //PAUSE
                                    textoTrabajandoPausado = "Pausado";
                                  } else {
                                    estaPausado = false;
                                    addPlayPause(1); //PLAY
                                    textoTrabajandoPausado = "Trabajando";
                                  }
                                });
                              },
                              minWidth: 120.0,
                              height: 120.0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 20),
                              child: Column(
                                children: <Widget>[
                                  _pausado(),
                                  Text("$textoPausado")
                                ],
                              ))
                        ],
                      )),
                      Expanded(
                          child: Column(
                        children: <Widget>[
                          MaterialButton(
                              onPressed: () {
                                estaPausado = true;
                                addPlayPause(0); //STOP
                                _onClickEnable(false);
                                _getCurrentLocationPausaReanudar("FinJornada");
                                if (acompanante == 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PTFinalizarRuta()));
                                } else {
                                  getSendLocalDataToAPI();
                                  _dbprovider.deleteTrackingData(userId);
                                  _dbprovider.deleteWorkingDay(userId);
                                  _dbprovider.deletePlayPause(userId);
                                  prdF.show();
                                  Future.delayed(Duration(seconds: 5))
                                      .then((value) {
                                    prdF.hide().whenComplete(() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PTPrincipal()));
                                    });
                                  });
                                  Future.delayed(Duration(seconds: 10))
                                      .then((value) {
                                    exit(0);
                                  });
                                }
                              },
                              minWidth: 120.0,
                              height: 120.0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 20),
                              child: Tooltip(
                                  message:
                                      "Fin de la jornada de trabajo.\nSolo darlo una vez al día,\ny en la finalización de la jornada",
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.stop,
                                          size: 100.0, color: Colors.red),
                                      Text("Terminar!"),
                                    ],
                                  ))
                              /* child: Column(
                                        children: <Widget>[
                                          Icon(Icons.stop, size: 100.0, color: Colors.red),
                                          Text("Terminar!")
                                        ],
                                      ) */
                              ),
                        ],
                      )),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Visibility(
              visible: sigueTrabajando,
              child: 
                ClipRRect(                  
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFF42A5F5),
                                Color(0xFF42A5F5),
                                Color(0xFF42A5F5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          //AQUI ACTUALIZAR EL WORKING DAY
                        },
                        child:
                          Column(children: [
                            Icon(Icons.more_time),
                             const Text('Sigo trabajando', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'HeeboSemiBold'))
                          ],),
                      )
                    ],
                  ),
                ),
            ),
            Container(
                height: 40.0,
                width: 300.0,
                child: Align(
                  alignment: Alignment(1, 0),
                  child: PopupMenuButton<InfoButtons>(
                    onSelected: (InfoButtons result) {},
                    icon: Icon(Icons.info, size: 30, color: Colors.blue),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<InfoButtons>>[
                      const PopupMenuItem<InfoButtons>(
                        child: Text(
                            'Pausar: Tiempo para una parada (comida),\neste tiempo no es computable como jornada de trabajo.',
                            style: TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.bold)),
                      ),
                      const PopupMenuItem<InfoButtons>(
                        child: Text(
                            'Terminar: Fin de la jornada de trabajo.\nSolo darlo una vez al día,\ny en la finalización de la jornada.',
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ),
                      const PopupMenuItem<InfoButtons>(
                        child: Text(
                            'Reiniciar: Continua el contador de tiempo \nde trabajo después de la parada realizada',
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      )
                    ],
                  ),
                ))
          ],
        ),
      )),
    );
  }

  Widget _pausado() {
    if (estaPausado == false) {
      textoPausado = "Pausar";
      if (actualizoHoraReinicio) {
        horaReinicia = new DateTime.now().toString();
      }
      actualizoHoraReinicio = false;
      return Icon(Icons.pause, size: 100.0, color: Colors.black);
    } else {
      textoPausado = "Reiniciar";
      horaPausa = new DateTime.now().toString();
      tiempoTrabajado = tiempocronometro;
      actualizoHoraReinicio = true;
      print("TIEMPO PAUSADO A LAS: " + horaPausa);
      print("TIEMPO TRABAJADO: " + tiempoTrabajado);
      return Icon(Icons.play_arrow, size: 100.0, color: Colors.green);
    }
  }

  _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        lat = _currentPosition.latitude.toString();
        long = _currentPosition.longitude.toString();
        alt = _currentPosition.altitude.toString();
        if (_currentPosition != null) {
          _tracking.longitude = long;
          _tracking.altitude = alt;
          _tracking.latitude = lat;
          _tracking.date = DateTime.now().toString();
          _tracking.userId = userId.toString();
          _dbprovider.addTracking(_tracking);
          print("LAT: " + lat + "/ LON: " + long + " / T:" + tiempocronometro);
        }
      });
    }).catchError((e) {
      print(e);
    });

    /* Position position =  await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      _currentPosition = position;
      lat = _currentPosition.latitude.toString();
      long =_currentPosition.longitude.toString();
      alt = _currentPosition.altitude.toString();
      if (_currentPosition != null){
          _tracking.longitude = long;
          _tracking.altitude = alt;
          _tracking.latitude =lat;
          _tracking.date = DateTime.now().toString();
          _tracking.userId = userId.toString();
          _dbprovider.addTracking(_tracking);
          print("LAT: " + lat + "/ LON: " + long + " / T:" + tiempocronometro);
        }
    }); */
  }

  Future<List<TrackingData>> getSendLocalDataToAPI() async {
    print("HAN PASADO 1 minuto y 1 segundos");
    List<TrackingData> list = await _dbprovider.getTrackingAll();
    try {
      var respuesta = "";
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
          print(
              "SE HAN REGISTRADO LOS DATOS DE TRACKING DAY, Y SE HAN BORRADO DE LA BD LOCAL");
          _dbprovider.deleteTrackingData(userId);
          //timeSendData=65;
        }
      }
    } catch (Ex) {
      //timeSendData=30;
      //startTimerSendData();
    }
    return list;
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
            evento, _dominio, _semilla);
        var respuesta = tracking.toString();
        print("SE HA REGISTRADO EL EVENTO:" + respuesta);
      });
    }).catchError((e) {
      print(e);
    });
  }

  void addPlayPause(int status) {
    var evento = "Posicionamiento";
    _playPause.userId = int.parse(userId);
    _playPause.trackingPLay = status;
    _playPause.dateBeginning = dateBeginning;
    _dbprovider.addPlayPause(_playPause);
    print("SE HA REGISTRADO EN LOCAL EL PLAYPAUSE CON VALOR=" +
        status.toString());
    _dbprovider.getPlayAndPause();
    if (status == 3) {
      //reanuda
      evento = "ComienzoJornada";
    } else if (status == 1) {
      //reanuda
      evento = "ReanudaTrayecto";
      if (widget.registraControlHora == 1) {
        postControlHour(userId.toString(), DateTime.now().toString(), "0",
            "Inicio", "Registro automatico", DateTime.now().toString());
      }
    } else if (status == 2) {
      //pausado
      evento = "PausaTrayecto";
      postControlHour(userId.toString(), DateTime.now().toString(), "0", "Fin",
          "Registro automatico", DateTime.now().toString());
    }
    widget.registraControlHora = 1;
    _getCurrentLocationPausaReanudar(evento);
  }

  void cronometro() {
    var horaInicial = dateBeginning;

    Timer.periodic(Duration(seconds: 1), (timer) {
      _fontSize = _first ? 18 : 12;
      _color = _first ? Colors.blue : Colors.green;
      _first = !_first;
      if (estaPausado == false) {
        if (horaPausa != "0") {
          horaInicial = horaReinicia;
        }
        tiempoInicio = new DateFormat("yyyy-MM-dd H:mm:ss").parse(horaInicial);
        tiempoActual = new DateTime.now();
        //tiempocronometro = tiempoActual.subtract(Duration(seconds: 1));
        Duration dur = tiempoActual.difference(tiempoInicio);
        var dif = (dur.inSeconds).floor();
        print("dif= " + dif.toString());
        var resH = (dif / 60 / 60);

        if (horaPausa != "0") {
          var splitHT = tiempoTrabajado.split(':');
          Duration trabajadoDif = new Duration(
              hours: int.tryParse(splitHT[0]),
              minutes: int.tryParse(splitHT[1]),
              seconds: int.tryParse(splitHT[2]));
          print("dif= " + dif.toString());
          var nuevoTiempoCronometro = (trabajadoDif.inSeconds + dif).floor();
          resH = (nuevoTiempoCronometro / 60 / 60);
        }

        var _resH = resH.toString();
        var xxH = _resH.indexOf('.') + 1;
        var yyH = _resH.length;
        var zzH = "0." + _resH.substring(xxH, yyH);
        var _hour = _resH.substring(0, _resH.indexOf('.'));
        if (_hour.length == 1) {
          _hour = "0" + _hour;
        }
        var resM = double.parse(zzH) * 60;
        var _resM = resM.toString();
        var xxM = _resM.indexOf('.') + 1;
        var yyM = _resM.length;
        var zzM = "0." + _resM.substring(xxM, yyM);
        var _min = _resM.substring(0, _resM.indexOf('.'));
        if (_min.length == 1) {
          _min = "0" + _min;
        }

        var resS = double.parse(zzM) * 60;
        var _resS = resS.toString();
        var _sec = _resS.substring(0, _resS.indexOf('.'));
        if (_sec.length == 1) {
          _sec = "0" + _sec;
        }

        setState(() {
          tiempocronometro = _hour + ":" + _min + ":" + _sec;
          lastPosition++;
          timeSendData++;
          if(int.parse(_hour)>=10){
            sigueTrabajando = true;
          }
          else if(int.parse(_hour)<10){
            sigueTrabajando = false;
          }
          if (estaPausado == false) {
            //SI HAN PASADO 20 SEGUNDOS TOMO LA POSICION
            if (lastPosition >= 20) {
              //_getCurrentLocation();
              _onClickChangePace();
              lastPosition = 0;
            }
            //SI HAN PASADO 61 SEGUNDOS, ENVIO LA DATA A LA API
            if (timeSendData >= 61) {
              getSendLocalDataToAPI();
              timeSendData = 0;
            }
            print("Count lastPosition: " +
                lastPosition.toString() +
                "-- Count SendData: " +
                timeSendData.toString());
          }
        });
        print(tiempocronometro);
      } else {}
    });
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

  Future getEventos(idUsuario, fecha) async{
    await _dbprovider.init();
    var eventos = await HttpHandler().fetchUltimoEvento(idUsuario, fecha.toString().substring(0,10), _dominio, _semilla);
    if(eventos.length>0){  
      if(eventos[0].evento == "Fin"){
        postControlHour(idUsuario, fecha.toString().substring(0,10), '0', 'Inicio', 'Registro automatico', DateTime.now().toString());
      } 
    }
  }
  void _onClickEnable(enabled) {
    if (enabled) {
      // Reset odometer.
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      }).catchError((error) {
        print('[start] ERROR: $error');
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');

        setState(() {
          enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    }
  }

  // Manually toggle the tracking state:  moving vs stationary
  void _onClickChangePace() {
    setState(() {
      _isMoving = !_isMoving;
    });
    print("[onClickChangePace] -> $_isMoving");

    bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
      _getCurrentLocation();
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ' + e.code.toString());
    });
  }

  void _onLocation(bg.Location location) {
    print('[location] - $location');

    String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);

    setState(() {
      content = encoder.convert(location.toMap());
      odometer = odometerKM;
    });
  }

  void _onLocationError(bg.LocationError error) {
    print('[location] ERROR - $error');
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }

  void _onActivityChange(bg.ActivityChangeEvent event) {
    print('[activitychange] - $event');
    setState(() {
      motionActivity = event.activity;
    });
  }

  void _onHttp(bg.HttpEvent event) async {
    print('[${bg.Event.HTTP}] - $event');
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    print('$event');
    setState(() {
      if (event.network == false) {
        gpsActivo = false;
      } else {
        gpsActivo = true;
      }
      content = encoder.convert(event.toMap());
    });
  }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    print('$event');
  }

  Future<List<PlayPauseTracking>> getLocalPlayPause() async {
    List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
    if (list != null) {
      dateBeginning = list[0].dateBeginning;
    }
    return list;
  }

  enviarNotificacionGPS() {
    Timer.periodic(Duration(minutes: 30), (timer) async {
      if (gpsActivo == false) {
        var usuario = userId;
        await HttpHandler().postNotificacionGPSInactivo(usuario, _dominio, _semilla);
        print("ENVIAR NOTIFICACION");
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
    } catch (Ex) {
      _dominio = null;
        _semilla = null;
    }
  }
}
