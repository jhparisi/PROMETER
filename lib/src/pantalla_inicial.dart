//import 'dart:convert';

import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/class/MensajesClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_finalizar_trayecto.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:eszaworker/resources/repository.dart';
import 'dart:async';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/class/UserByPhoneAPIClass.dart';
import 'package:flushbar/flushbar.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/src/menu.dart';

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

Menu _menu = new Menu();
ProgressDialog pr; 
Flushbar fbar;
Repository _repository = Repository.get();
DBProvider _dbprovider = DBProvider.get();
Mensajes _mensaje = new Mensajes();
DataLocal dtl;
int _idUser =0;
String _nombreCompleto="";
String _login ="";
String trackingPlay="0";
bool statusPlayPause =false;
String _dateBeginning="";
int versionDB =0;
String deviceToken = "";
String _dni="";
List<String> _listMatriculas = [];
List<String> _newListMatriculas = [];
bool _acompanante =false;
int _acompananteInt = 0;
String _idUsuarioPrincipal= "";
String _matriculaPrincipal="";
String _usuarioPrincipal = "";
bool _matriculaVisible = true;
var checkedValue = false;
String _matriculaUsuario;
String _selectedMatricula;
bool matriculaSeleccionada = false;
Flushbar fbarPDA = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message: "Tienes trabajos pendientes en la PDA por cerrar o pausar!\nSerás redirigido a la PDA!",
  duration: Duration(seconds: 5),
);
Flushbar fbarMatricula = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message: "No tienes vehículos asignados, ponte en contacto con un administrador!",
  duration: Duration(seconds: 5),
);

Flushbar fbarMatriculaSeleccionada = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message: "Debes seleccionar una matrícula para iniciar!",
  duration: Duration(seconds: 5),
);


class PTInicial extends StatefulWidget{
  static const String routeName = "/pantalla_inicial";
  PTInicial({Key key}): super (key:key);
  _PTInicialState createState() => _PTInicialState();
}

class _PTInicialState extends State<PTInicial> {   
  List<UserByPhoneAPIClass> _user = new List();

  /************************************ INICIO NOTIFICACIONES DE FIREBASE ************************************** */
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final  _mensajesStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajes => _mensajesStreamController.stream;

  initNotifications(){
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token){
      deviceToken = token;
      print("El token es: $deviceToken");
      //ekmLCN7WVHU:APA91bEo70AVqCNdS1DAb_ItwqYdy3IsTVP1MBnQlOLfC78EIQm6UHQ_xXpXqhtfQTcG8-eF8UjdUK7n3e5W3jSLf_Nx-8Ofxtacq5Q6X_PXdUihD_-GDdISKYuXdKCnvmiGnDo1KYj9
    });

    _firebaseMessaging.configure(

      onMessage: (info) async{
        print("====== OnMessage ======");
        print(info);
        String data = 'no-data';
        if(Platform.isAndroid){
          data = info['data']['aplicacion'] ?? 'no-data';
        }
        _mensaje.fecha = new DateTime.now().toString();
        _mensaje.titulo = info['data']['titulo'];
        _mensaje.mensaje = info['data']['mensaje'];
        _mensaje.url = "";
        _dbprovider.addMensajes(_mensaje);
        _mensajesStreamController.sink.add(data);
      },

       onLaunch: (info) async{
        print("====== OnLaunch ======");
        print(info);
        String data = 'no-data';
        if(Platform.isAndroid){
          data = info['data']['aplicacion'] ?? 'no-data';
        }
        _mensaje.fecha = new DateTime.now().toString();
        _mensaje.titulo = info['data']['titulo'];
        _mensaje.mensaje = info['data']['mensaje'];
        _mensaje.url = "";
        _dbprovider.addMensajes(_mensaje);
        _mensajesStreamController.sink.add(data);
      },

       onResume: (info) async{
        print("====== OnResume ======");
        print(info);
        String data = 'no-data';
        if(Platform.isAndroid){
          data = info['data']['aplicacion'] ?? 'no-data';
        }
        _mensaje.fecha = new DateTime.now().toString();
        _mensaje.titulo = info['data']['titulo'];
        _mensaje.mensaje = info['data']['mensaje'];
        _mensaje.url = "";
        _dbprovider.addMensajes(_mensaje);
        _mensajesStreamController.sink.add(data);
      }
    );
    
    dispose() {
      _mensajesStreamController?.close();
    }
  }
  /************************************ FIN NOTIFICACIONES DE FIREBASE ************************************** */

  void loadUser() async {
    var user = await HttpHandler().fetchUserByPhone(numPhoneController.text, deviceToken);    
    setState(() {
      _user.addAll(user);
      if(user.length!=0){
        _idUser= _user[0].idUsuario;
        _nombreCompleto = _user[0].nombre.toString() + ' ' + _user[0].apellido1.toString();
        _login = _user[0].login;
        _dni = user[0].dni;        
        print("USUARIO QUE VIENE DE LA API ES: " + _idUser.toString() + " DNI: " + _dni);
      }
      else{
        _idUser=0;
      }
    });    
    try{      
      var matriculas = await HttpHandler().fetchMatriculas(_dni);
      setState(() {
        if(matriculas.length!=0){
          _listMatriculas.clear();
          for(var i=0; i<matriculas.length; i++){          
            _listMatriculas.add(matriculas[i].matricula);
            _newListMatriculas.add(matriculas[i].matricula);
          }
          print(_listMatriculas);
        }
      });

      loadAcompanante();
      
    }
    catch(ex){
      fbarMatricula.show(context);
    }
    
  }

  void loadAcompanante() async{
    var acompanante = await HttpHandler().fetchAcompanante(_idUser.toString());
      if(acompanante.length!=0){        
       _acompanante =true;
       _idUsuarioPrincipal = acompanante[0].idUsuarioPrincipal.toString();
       _usuarioPrincipal = acompanante[0].nombrePrincipal.toUpperCase();
       _matriculaPrincipal = acompanante[0].matricula;
      _listMatriculas.add("");
      }
  }
  final _formKeyNum = GlobalKey<FormState>();
  final numPhoneController = TextEditingController();
  final carPlateController = TextEditingController();
  
  @override
  initState() {
    super.initState();
    getVerifyDataLocal();  
    getWDLocal();   
    initNotifications();  
    mensajes.listen((event) {
      if(event.indexOf("PDA") > -1){ 
        fbarPDA.show(context);
        const url = 'https://pda.ezsa.es/';
        Future.delayed(const Duration(seconds: 5), () {
            launch(url);
        });
      }
      else if(event == "EZSAWORKER"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>PTFinalizarRuta()));
      }
    });
  }

  @override 
  Widget build(BuildContext context) {
    
    _dbprovider.init(); 
    pr = new ProgressDialog(context);
    fbar = new Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      message: "El número ingresado, no existe en la BD!",
      duration: Duration(seconds: 3),
    );
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

    
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("PRO-METER APP", textAlign: TextAlign.center),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0,top: 50.0),
              child: Column(
              children: <Widget>[
                /* Text("Por favor indica tu número de teléfono", textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                ), */
                Image.asset('logoezsa.png', width: 180, height: 70,),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Form(
                  key: _formKeyNum,
                  
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          onChanged: (text) {
                            if(text.length==9){
                              loadUser();                                                  
                            }                        
                          },
                          controller: numPhoneController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            labelText: "Número de teléfono",
                          ),
                          maxLength: 9,
                          maxLengthEnforced: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Debes indicar tu número de teléfono';
                            }
                            if(value.length<9){
                              return 'Tu número de teléfono está incompleto!';
                            }
                            return null;
                          }
                        ),
                        Visibility(
                          visible: _acompanante,
                          child: 
                          CheckboxListTile(
                            title: Text("Voy a acompañar",style: TextStyle(fontSize: 12.0)),
                            value: checkedValue,
                            onChanged: (newValue) { 
                                        setState(() {
                                          checkedValue = newValue; 
                                          _matriculaVisible = false;
                                          if(checkedValue){
                                            _acompananteInt =1;
                                          }
                                          else{
                                            _acompananteInt=0;
                                          }
                                        }); 
                                      },
                            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                          )
                        ), 
                        Visibility(
                          visible: checkedValue,
                          child: Text("Voy a acompañar a: " +_usuarioPrincipal,style: TextStyle(fontSize: 10.0, color: Colors.grey))
                        ), 
                        Visibility(
                          visible: false,
                          child: TextFormField(
                            controller: carPlateController,
                            
                            decoration: InputDecoration(
                              labelText: 'Matrícula:'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Debes indicar la Matrícula';
                              }
                              return null;
                            },
                          ),
                        ),
                        Visibility(
                          visible: _matriculaVisible,
                          child:
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: 'Matrícula:'
                            ) ,
                            isExpanded: true,
                            value: _selectedMatricula,
                            validator: (value) {                              
                              if (matriculaSeleccionada==false && _matriculaVisible==true) {
                                //fbarMatriculaSeleccionada.show(context);
                                return 'Debes indicar una matrícula para iniciar';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              setState(() {                          
                                _selectedMatricula = newValue;
                                carPlateController.text = newValue;
                                matriculaSeleccionada =true;
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
                          padding: EdgeInsets.only(top: 10.0),
                        ), 
                                       
                    MaterialButton(
                      child: Text('INICIAR'),
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      color:  Colors.blueAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        if (_formKeyNum.currentState.validate()) { 
                          print("VALOR DE IDUSER: $_idUser"); 
                          if(_idUser==0){
                            fbar.show(context);
                          } 
                          else{                            
                            _repository.fetchLocalData('${numPhoneController.text}','${carPlateController.text}',_idUser,_nombreCompleto,_login,_dni,_acompananteInt);
                            _repository.fetchHistorico(DateTime.now().toString(), _nombreCompleto, '${carPlateController.text}');
                            print("AQUI MANDA EL VALOR DE: " + _idUser.toString());
                            _menu.getVerifyDataLocal(_idUser);
                            pr.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              pr.hide().whenComplete(() {
                                //Navigator.of(context).push(MaterialPagaRoute( builder: (BuildContext context)=>PTPrincipal()));
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
                              });
                            });
                          }                         
                          
                        }
                      }
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    Text("Versión BDD: "+versionDB.toString() + ".0.0",style: TextStyle(fontSize: 8),)
                  ],
                ),
                
              
            ),                
            
          ],
        ),
        ),
      ),
    );
  }
  
  Future<List<DataLocal>> getVerifyDataLocal() async{
    List<DataLocal> retunn = new List<DataLocal>();    
    try{
      List<DataLocal> list = await _dbprovider.getVerifyPantallaInicial();
      setState(() {
        if(list != null){
          var val = list.length-1;
          //for(var i=0;i<list.length; i++){
            numPhoneController.text = list[val].numPhone;
            carPlateController.text = list[val].carPlate;
            _matriculaUsuario = list[val].carPlate;
            _idUser = list[val].userId;
            _dni = list[val].dni; 
            if(list[val].carPlate!=""){
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
      if(list != null ){
        var matriculas = await HttpHandler().fetchMatriculas(_dni);
        setState(() {
          if(matriculas.length!=0){
            _listMatriculas.clear();
            for(var i=0; i<matriculas.length; i++){          
              _listMatriculas.add(matriculas[i].matricula);
            }       
          }
          var estaDentroDeLaLista =false;
          _listMatriculas.forEach((element) {
            if(element == _matriculaUsuario){
              estaDentroDeLaLista = true;
            }
          });
          if(_matriculaUsuario!="" && estaDentroDeLaLista==true){
            _selectedMatricula = _matriculaUsuario;
          }
          
        });  
      }
    }
    catch(Ex){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }

  Future<List<PlayPauseTracking>> getPlayPause() async{
    List<PlayPauseTracking> retunn = new List<PlayPauseTracking>();    
    try{
      List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
      setState(() {
        if(list != null){
          for(var i=0;i<list.length; i++){
            trackingPlay = list[i].trackingPLay.toString();
            //_idUser = list[i].userId;
          }
          _repository.fetchLocalData('${numPhoneController.text}','${carPlateController.text}',_idUser,_nombreCompleto,_login, _dni,_acompananteInt);
          _repository.fetchHistorico(DateTime.now().toString(), _nombreCompleto, '${carPlateController.text}');
          _menu.getVerifyDataLocal(_idUser);
          print("EL VALOR DE trackingPlay =" + trackingPlay.toString());
          if(trackingPlay!="0" && trackingPlay!=null){
            final data = PlayPauseTracking(trackingPLay: int.parse(trackingPlay), userId: _idUser, dateBeginning: _dateBeginning);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>PTCerrarRuta(
              data:data
            )));
          } 
        }  
             
        return list;         
      });
        
    }
    catch(Ex){
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }

  int getIdUsuario(){
    return _idUser;
  }


  Future<List<WorkingDay>> getWDLocal() async{
    versionDB = await _dbprovider.db.getVersion();
    print("VERSION BD: " + versionDB.toString());
    List<WorkingDay> retunn = new List<WorkingDay>();
    try{
      List<WorkingDay> list = await _dbprovider.getWorkingDay();       
      setState(() {
        if(list != null){
        for(var i=0;i<1; i++){
          _dateBeginning = list[0].startingDate.toString();
        }
      }
      return list;
      });
    }    
    catch(Ex){
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
      _dateBeginning = new DateTime.now().toString();
    }
    return retunn;
  }
  
}
  
