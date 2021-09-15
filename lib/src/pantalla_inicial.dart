//import 'dart:convert';

import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/class/MensajesClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_finalizar_trayecto.dart';
import 'package:eszaworker/src/pantalla_mensajes.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:eszaworker/resources/repository.dart';
import 'dart:async';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/class/UserByPhoneAPIClass.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/src/menu.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eszaworker/utilities/funciones_generales.dart' as _funcGeneral;

Menu _menu = new Menu();

Repository _repository = Repository.get();
DBProvider _dbprovider = DBProvider.get();
Mensajes _mensaje = new Mensajes();
DataLocal dtl;
int _idUser = 0;
String _nombreCompleto = "";
String _login = "";
String trackingPlay = "0";
bool statusPlayPause = false;
String _dateBeginning = "";
int versionDB = 0;
String deviceToken = "";
String _dni = "";
List<String> _listMatriculas = [];
List<String> _newListMatriculas = [];
bool _acompanante = false;
int _acompananteInt = 0;
String idUsuarioPrincipal = "";
String matriculaPrincipal = "";
String _usuarioPrincipal = "";
bool _matriculaVisible = true;
var checkedValue = false;
String _matriculaUsuario;
String _selectedMatricula;
bool matriculaSeleccionada = false;
bool usuarioValidado = false;
bool versionValidada = false;
String versionApp = "";
String _semilla ="";
String _dominio = "";

class PTInicial extends StatefulWidget {
  static const String routeName = "/pantalla_inicial";
  PTInicial({Key key}) : super(key: key);
  _PTInicialState createState() => _PTInicialState();
}

class _PTInicialState extends State<PTInicial> {
  List<UserByPhoneAPIClass> _user = [];

  /// ********************************** INICIO NOTIFICACIONES DE FIREBASE ************************************** */
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _mensajesStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajes => _mensajesStreamController.stream;

  initNotifications() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) {
      deviceToken = token;
      print("El token es: $deviceToken");
    });

    _firebaseMessaging.configure(onMessage: (info) async {
      print("====== OnMessage ======");
      print(info);
      String data = 'no-data';
      if (Platform.isAndroid) {
        data = info['data']['aplicacion'] ?? 'no-data';
      }
      _mensaje.fecha = new DateTime.now().toString();
      _mensaje.titulo = info['data']['titulo'];
      _mensaje.mensaje = info['data']['mensaje'];
      _mensaje.url = "";
      _dbprovider.addMensajes(_mensaje);
      _mensajesStreamController.sink.add(data);
    }, onLaunch: (info) async {
      print("====== OnLaunch ======");
      print(info);
      String data = 'no-data';
      if (Platform.isAndroid) {
        data = info['data']['aplicacion'] ?? 'no-data';
      }
      _mensaje.fecha = new DateTime.now().toString();
      _mensaje.titulo = info['data']['titulo'];
      _mensaje.mensaje = info['data']['mensaje'];
      _mensaje.url = "";
      _dbprovider.addMensajes(_mensaje);
      _mensajesStreamController.sink.add(data);
    }, onResume: (info) async {
      print("====== OnResume ======");
      print(info);
      String data = 'no-data';
      if (Platform.isAndroid) {
        data = info['data']['aplicacion'] ?? 'no-data';
      }
      _mensaje.fecha = new DateTime.now().toString();
      _mensaje.titulo = info['data']['titulo'];
      _mensaje.mensaje = info['data']['mensaje'];
      _mensaje.url = "";
      _dbprovider.addMensajes(_mensaje);
      _mensajesStreamController.sink.add(data);
    });

    // ignore: unused_element
    dispose() {
      _mensajesStreamController?.close();
    }
  }

  /// ********************************** FIN NOTIFICACIONES DE FIREBASE ************************************** */

  void loadUser() async {
    var user = await HttpHandler()
        .fetchUserByPhone(numPhoneController.text, deviceToken, _dominio, _semilla);

    setState(() {
      _user.addAll(user);
      if (user.length != 0) {
        _idUser = _user[0].idUsuario;
        _nombreCompleto =
            _user[0].nombre.toString() + ' ' + _user[0].apellido1.toString();
        _login = _user[0].login;
        _dni = user[0].dni;
        print("USUARIO QUE VIENE DE LA API ES: " +
            _idUser.toString() +
            " DNI: " +
            _dni +
            "login: " +
            _login);
      } else {
        _idUser = 0;
      }
    });
    try {
      var matriculas = await HttpHandler().fetchMatriculas(_dni, _dominio, _semilla);
      setState(() {
        if (matriculas.length != 0) {
          _listMatriculas.clear();
          for (var i = 0; i < matriculas.length; i++) {
            _listMatriculas.add(matriculas[i].matricula);
            _newListMatriculas.add(matriculas[i].matricula);
          }
          print(_listMatriculas);
        }
      });

      loadAcompanante();
    } catch (ex) {
      _funcGeneral.mostrarFlushBar(context, "No tienes vehículos asignados, ponte en contacto con un administrador!");
    }
  }

  void loadAcompanante() async {
    var acompanante = await HttpHandler().fetchAcompanante(_idUser.toString(), _dominio, _semilla);
    if (acompanante.length != 0) {
      _acompanante = true;
      idUsuarioPrincipal = acompanante[0].idUsuarioPrincipal.toString();
      _usuarioPrincipal = acompanante[0].nombrePrincipal.toUpperCase();
      matriculaPrincipal = acompanante[0].matricula;
      _listMatriculas.add("");
    }
  }

  final _formKeyNum = GlobalKey<FormState>();
  final numPhoneController = TextEditingController();
  final carPlateController = TextEditingController();
  final passController = TextEditingController();

  @override
  initState() {
    super.initState();
    getConfiguracion();
    getVerifyDataLocal();
    getWDLocal();
    initNotifications();
    mensajes.listen((event) {
      if (event.indexOf("PDA") > -1) {
        _funcGeneral.mostrarFlushBar(context, "Tienes trabajos pendientes en la PDA por cerrar o pausar!\nSerás redirigido a la PDA!");
        const url = 'https://pda.ezsa.es/';
        Future.delayed(const Duration(seconds: 5), () {
          launch(url);
        });
      } else if (event == "EZSAWORKER") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PTFinalizarRuta()));
      } else if (event == "MENSAJE") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PTMensajes()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _dbprovider.init();
    

    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF73AEF5),
            Color(0xFF61A4F1),
            Color(0xFF478DE0),
            Color(0xFF398AE5)
          ],
              stops: [
            0.1,
            0.4,
            0.7,
            0.9
          ])),
      child: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 60.0),
              ),
              Image.asset(
                'logoPrometer2.png',
                width: 180,
                height: 180,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SizedBox(
                  width: 400,
                  height: 450,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15.0, left: 25.0, right: 25.0, bottom: 25.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKeyNum,
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.blue[400],
                                    fontFamily: 'HeeboSemiBold'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                              ),
                              TextFormField(
                                  onChanged: (text) {
                                    if (text.length == 9) {
                                      loadUser();
                                    }
                                  },
                                  controller: numPhoneController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    labelText: "Número de teléfono",
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
                                      Icons.phone,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  maxLength: 9,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Debes indicar tu número de teléfono';
                                    }
                                    if (value.length < 9) {
                                      return 'Tu número de teléfono está incompleto!';
                                    }
                                    return null;
                                  }),
                              Visibility(
                                  visible: _acompanante,
                                  child: CheckboxListTile(
                                    title: Text("Voy a acompañar",
                                        style: TextStyle(fontSize: 12.0)),
                                    value: checkedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValue = newValue;
                                        _matriculaVisible = false;
                                        if (checkedValue) {
                                          _acompananteInt = 1;
                                        } else {
                                          _acompananteInt = 0;
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  )),
                              Visibility(
                                  visible: checkedValue,
                                  child: Text(
                                      "Voy a acompañar a: " + _usuarioPrincipal,
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.grey))),
                              Padding(
                                padding: EdgeInsets.only(top: 3.0),
                              ),
                              Visibility(
                                visible: _matriculaVisible,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Matrícula',
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.car_repair,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  isExpanded: true,
                                  value: _selectedMatricula,
                                  validator: (value) {
                                    if (matriculaSeleccionada == false &&
                                        _matriculaVisible == true) {
                                      //fbarMatriculaSeleccionada.show(context);                                      
                                      return 'Debes indicar una matrícula para iniciar';
                                    }
                                    return null;
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedMatricula = newValue;
                                      carPlateController.text = newValue;
                                      matriculaSeleccionada = true;
                                    });
                                  },
                                  items: _listMatriculas.map((matricula) {
                                    return DropdownMenuItem(
                                      child: new Text(matricula),
                                      value: matricula,
                                    );
                                  }).toList(),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                              ),
                              TextFormField(
                                  obscureText: true,
                                  controller: passController,
                                  keyboardType: TextInputType.visiblePassword,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(15.0),
                                    labelText: "Contraseña",
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
                                      Icons.pending_sharp,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Debes indicar tu Contraseña';
                                    }

                                    return null;
                                  }),
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF2eac6b),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 50.0, right: 50.0, top:10, bottom: 10.0),
                                    child: Text(
                                      "Entrar",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'HeeboSemiBold'),
                                    ),
                                  ),
                                  onPressed: () {
                                    var pass = _login + passController.text;
                                    validarUsuario(
                                        numPhoneController.text, pass);
                                    validarVersion(
                                        _idUser.toString(), versionApp);
                                    //pr.show();
                                    _funcGeneral.mostrarProgressDialog(context, "Validando sus datos");
                                    Future.delayed(Duration(seconds: 3))
                                        .then((value) {
                                      if (_formKeyNum.currentState.validate() &&
                                          usuarioValidado == true &&
                                          versionValidada == true) {
                                        print("VALOR DE IDUSER: $_idUser");
                                        if (_idUser == 0) {
                                          _funcGeneral.mostrarFlushBar(context, "El número ingresado, no existe en la BD!");
                                        } else {
                                          _repository.fetchLocalData(
                                              '${numPhoneController.text}',
                                              '${carPlateController.text}',
                                              _idUser,
                                              _nombreCompleto,
                                              _login,
                                              _dni,
                                              _acompananteInt);
                                          _repository.fetchHistorico(
                                              DateTime.now().toString(),
                                              _nombreCompleto,
                                              '${carPlateController.text}');
                                          print("AQUI MANDA EL VALOR DE: " +
                                              _idUser.toString());
                                          _menu.getVerifyDataLocal(_idUser);
                                          //pr.show();
                                          Future.delayed(Duration(seconds: 3))
                                              .then((value) {
                                            _funcGeneral.ocultarProgressDialogAlCompletar(context, PTPrincipal());
                                          });
                                        }
                                      } else {
                                        _funcGeneral.ocultarProgressDialog();
                                        if (versionValidada == false) {
                                          _funcGeneral.mostrarFlushBar(context, "La versión de la APP que estas usando es antigüa.\nPor favor, comunicate con el administrador para que\nte proporcione la nueva versión.");
                                          _funcGeneral.ocultarProgressDialog();
                                        }
                                        if (usuarioValidado == false) {
                                          _funcGeneral.mostrarFlushBar(context, "La contraseña ingresada no es correcta. Por favor coloque la contraseña que usa en la PDA");
                                          _funcGeneral.ocultarProgressDialog();
                                        }
                                      }
                                    });
                                  }),
                              Padding(
                                padding: EdgeInsets.only(top: 30.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                "Desarrollado por EZSA Sanidad Ambiental",
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontFamily: 'HeeboSemiBold'),
              ),
              Text(
                "Versión: B" +
                    versionDB.toString() +
                    ".0.0 - A" +
                    versionApp.toString(),
                style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                    fontFamily: 'HeeboSemiBold'),
              ),
              Text(
                "Dominio: $_dominio ",
                style: TextStyle(
                    fontSize: 8.0,
                    color: Colors.white,
                    fontFamily: 'HeeboSemiBold'),
              )
            ],
          ),
        ),
      )),
    ));
  }

  Future<List<DataLocal>> getVerifyDataLocal() async {
    List<DataLocal> retunn = new List<DataLocal>.empty();
    try {
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicial();
      setState(() {
        if (list != null) {
          var val = list.length - 1;
          //for(var i=0;i<list.length; i++){
          numPhoneController.text = list[val].numPhone;
          carPlateController.text = list[val].carPlate;
          _matriculaUsuario = list[val].carPlate;
          _idUser = list[val].userId;
          _dni = list[val].dni;
          _login = list[val].login;
          if (list[val].carPlate != "") {
            _selectedMatricula = list[val].carPlate;
            matriculaSeleccionada = true;
          }
          //_acompananteInt = list[val].acompanante;
          _dbprovider.deleteDataLocal(null);
          //}
          getPlayPause();
        }
        return list;
      });
      loadAcompanante();
      if (list != null) {
        var matriculas = await HttpHandler().fetchMatriculas(_dni, _dominio, _semilla);
        setState(() {
          if (matriculas.length != 0) {
            _listMatriculas.clear();
            for (var i = 0; i < matriculas.length; i++) {
              _listMatriculas.add(matriculas[i].matricula);
            }
          }
          var estaDentroDeLaLista = false;
          _listMatriculas.forEach((element) {
            if (element == _matriculaUsuario) {
              estaDentroDeLaLista = true;
            }
          });
          if (_matriculaUsuario != "" && estaDentroDeLaLista == true) {
            _selectedMatricula = _matriculaUsuario;
          }
        });
      }
    } catch (ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTInicial()));
    }
    return retunn;
  }

  Future<List<PlayPauseTracking>> getPlayPause() async {
    List<PlayPauseTracking> retunn = new List<PlayPauseTracking>.empty();
    try {
      List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
      setState(() {
        if (list != null) {
          for (var i = 0; i < list.length; i++) {
            trackingPlay = list[i].trackingPLay.toString();
            //_idUser = list[i].userId;
          }
          _repository.fetchLocalData(
              '${numPhoneController.text}',
              '${carPlateController.text}',
              _idUser,
              _nombreCompleto,
              _login,
              _dni,
              _acompananteInt);
          _repository.fetchHistorico(DateTime.now().toString(), _nombreCompleto,
              '${carPlateController.text}');
          _menu.getVerifyDataLocal(_idUser);
          print("EL VALOR DE trackingPlay =" + trackingPlay.toString());
          if (trackingPlay != "0" && trackingPlay != null) {
            final data = PlayPauseTracking(
                trackingPLay: int.parse(trackingPlay),
                userId: _idUser,
                dateBeginning: _dateBeginning);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PTCerrarRuta(
                          data: data,
                          registraControlHora: 0,
                        )));
          }
        }

        return list;
      });
    } catch (ex) {
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }

  int getIdUsuario() {
    return _idUser;
  }

  Future<bool> validarUsuario(telefono, pass) async {
    var resultado = await HttpHandler().fetchValidarUsuario(telefono, pass, _dominio, _semilla);
    print("EL VALIDAR USUARIO FUE: " + resultado.toString());
    setState(() {
      usuarioValidado = resultado;
    });
    return resultado;
  }

  Future<bool> validarVersion(idUsuario, numVersion) async {
    var resultado =
        await HttpHandler().fetchValidarVersion(idUsuario, numVersion, _dominio, _semilla);
    print("EL VALIDAR VERSION FUE: " + resultado.toString());
    setState(() {
      versionValidada = resultado;
    });
    return resultado;
  }

  Future<List<WorkingDay>> getWDLocal() async {
    versionDB = await _dbprovider.db.getVersion();
    versionApp = await GetVersion.projectVersion;
    print("VERSION BD: " + versionDB.toString());
    List<WorkingDay> retunn = new List<WorkingDay>.empty();
    try {
      List<WorkingDay> list = await _dbprovider.getWorkingDay();
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            _dateBeginning = list[0].startingDate.toString();
          }
        }
        return list;
      });
    } catch (ex) {
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
      _dateBeginning = new DateTime.now().toString();
    }
    return retunn;
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
