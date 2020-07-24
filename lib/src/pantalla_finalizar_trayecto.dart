import 'dart:async';
import 'dart:io';

import 'package:eszaworker/class/TrackingDataClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_inciar_trayecto.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

ProgressDialog prd;
Menu _menu = new Menu();
DBProvider _dbprovider = new DBProvider();
WorkingDay _wd =new WorkingDay();
//WorkingDay _wd = new WorkingDay();
DateTime date2;

int userId = _menu.getuserId();

class PTFinalizarRuta extends StatefulWidget{
  static const String routeName = "/pantalla_finalizar_trayecto";
  PTFinalizarRuta({Key key}): super (key:key);
  _PTFinalizarRutaState createState() => _PTFinalizarRutaState();

}

class NoKeyboardEditableTextFocusNodeFin extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}

class _PTFinalizarRutaState extends State<PTFinalizarRuta>{   
  final _formKey = GlobalKey<FormState>();
  final fechaInicio = new DateTime.now();
  String userId = _menu.getuserId().toString();
  final carPlateController = TextEditingController();
  final endingDateController = TextEditingController();
  final kmsBeginningController = TextEditingController();
  final kmsTheEndController = TextEditingController();
  final startingDateController = TextEditingController();
  Flushbar fbar;

  
 @override
  void initState() {
    super.initState();
    getWDLocal();
  }
  @override 
  Widget build(BuildContext context){
    _menu.getVerifyDataLocal(int.parse(userId));
    //getWDLocal();    
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
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400)
    );
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("PRO-METER APP", textAlign: TextAlign.center),
      ),
      drawer: _menu.getDrawer(context),
      body: new Form( 
        key: _formKey,
          //child: Container( 
            child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0,top: 0.0),           
                  child: Column(
                    children: <Widget>[                      
                      TextFormField(
                        controller: startingDateController,
                        decoration: InputDecoration(
                          labelText: 'Fecha de comienzo:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextFormField(
                        controller: carPlateController,
                        decoration: InputDecoration(
                          labelText: 'Matrícula:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextFormField(
                        controller: kmsBeginningController,
                        decoration: InputDecoration(
                          labelText: 'Kms al empezar:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.grey),
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
                      DateTimePickerFormField(   
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
                      ),
                      TextFormField(
                        controller: kmsTheEndController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kms al terminar:'
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Debes indicar los Km al terminar';
                          }
                          if(int.parse(value) < int.parse(kmsBeginningController.text)){
                            return 'Los kilometros al terminar, deben \nser mayores que los de inicio';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:20.0)
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            getSendLocalDataToAPI();
                            _dbprovider.deleteTrackingData(userId);
                            _dbprovider.deleteWorkingDay(userId);
                            _dbprovider.deletePlayPause(userId);                            
                            insertWorkingDayLocal(carPlateController.text,endingDateController.text,kmsBeginningController.text,kmsTheEndController.text,dateBeginningController.text,userId.toString());
                            getWDLocal();
                            prd.show();
                            Future.delayed(Duration(seconds: 5)).then((value) {
                              prd.hide().whenComplete(() {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
                              });
                            });
                            Future.delayed(Duration(seconds: 15)).then((value){
                              exit(0);
                            });
                          }
                        },
                        child: Text('Terminar'),
                        color: Colors.blue,
                        textColor: Colors.white,
                      )
                    ],
                ),
              )
            )
      )
    );

    
  }

  Future<List<WorkingDay>> getWDLocal() async{
    List<WorkingDay> retunn = new List<WorkingDay>();
    try{
      List<WorkingDay> list = await _dbprovider.getWorkingDay();
      setState(() {
        if(list != null){
        for(var i=0;i<1; i++){
          carPlateController.text = list[0].carPlate;
          endingDateController.text = DateTime.now().toString();
          kmsBeginningController.text = list[0].kmsBeginning;
          startingDateController.text = list[0].startingDate.toString();
          userId = list[0].userId.toString();
        }
      }
      return list;
      });
    }    
    catch(Ex){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PTFinalizarRuta()));
    }
    return retunn;
  }

  Future postDataWorkingDay() async{
    var respuesta ="";
    var working = await HttpHandler().postWorkingDay( carPlateController.text, endingDateController.text, kmsBeginningController.text, kmsTheEndController.text, startingDateController.text, userId);
    if(working=="OK"){
        respuesta="OK";
    }
    return respuesta;
  }

  Future<List<TrackingData>> getSendLocalDataToAPI() async{
    String respuesta= postDataWorkingDay().toString();
    List<TrackingData> list = await _dbprovider.getTrackingAll();
        if(list != null){
          for(var i=0;i<list.length; i++){
            var tracking = await HttpHandler().postTrackingData(list[i].altitude.replaceAll('.',','), list[i].date, list[i].latitude.replaceAll('.',','), list[i].longitude.replaceAll('.',','), list[i].userId);
            respuesta = tracking.toString();
          }
          if(respuesta=="OK"){
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
  
  void insertWorkingDayLocal(carPlate,endingDate,kmsBeginning,ksmTheEnd,startingDate,userId){
    _wd.carPlate =carPlate;
    _wd.endingDate = endingDate;
    _wd.kmsBeginning =kmsBeginning;
    _wd.kmsTheEnd = ksmTheEnd;
    _wd.startingDate =startingDate;
    _wd.userId = userId;
    _dbprovider.addWorkingDay(_wd);
  }
}