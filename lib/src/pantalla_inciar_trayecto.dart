import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

ProgressDialog prd;
WorkingDay _wd =new WorkingDay();
DBProvider _dbprovider = DBProvider.get();
final kmsBeginningController = TextEditingController();
final dateBeginningController = TextEditingController();
int userId = _menu.getuserId();
Menu _menu = new Menu();
DateTime date1;
class PTIniciarRuta extends StatefulWidget{
  static const String routeName = "/pantalla_iniciar_trayecto";
  PTIniciarRuta({Key key}): super (key:key);
  _PTIniciarRutaState createState() => _PTIniciarRutaState();

}
class NoKeyboardEditableTextFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    // prevents keyboard from showing on first focus
    return false;
  }
}

class _PTIniciarRutaState extends State<PTIniciarRuta>{   
  final _formKey = GlobalKey<FormState>();
  final fechaInicio = new DateTime.now();
 
 @override
  void initState() {
    super.initState();
    getWDLocal();
  }

  @override 
  Widget build(BuildContext context){
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
          child: SingleChildScrollView( 
                child: Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0,top: 0.0),           
                  child: Column(
                    children: <Widget>[                      
                      /* TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Fecha de comienzo:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.grey),
                        initialValue: "$fechaInicio",
                        /* onTap: () async{
                      DateTime date = DateTime(1900);
                      FocusScope.of(context).requestFocus(new FocusNode());

                      date = await showDatePicker(
                                    context: context, 
                                    initialDate:DateTime.now(),
                                    firstDate:DateTime(1900),
                                    lastDate: DateTime(2100));

                      dateCtl.text = date.toIso8601String();} */
                      ), */
                      DateTimePickerFormField(   
                        controller: dateBeginningController,
                        focusNode: NoKeyboardEditableTextFocusNode(),
                        inputType: InputType.both,
                        format: DateFormat("yyyy-MM-dd H:mm:ss"),
                        editable: false,                        
                        decoration: InputDecoration(
                            labelText: 'Fecha de comienzo:',
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
                      ),
                      
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Matrícula:'
                        ),
                        readOnly: true,
                        enabled: false,
                        initialValue: _menu.getCarPlate(),
                        style: TextStyle(color:Colors.grey),
                      ),
                      TextFormField(
                        controller: kmsBeginningController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kms al empezar:'
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Debes indicar los Km al empezar';
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
                            _dbprovider.deleteWorkingDay(userId);
                            insertWorkingDayLocal(carPlate,'',kmsBeginningController.text,'',dateBeginningController.text,userId.toString());
                            postDataWorkingDay(carPlate,'',kmsBeginningController.text,'',dateBeginningController.text,userId.toString());
                            prd.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              prd.hide().whenComplete(() {
                                final data = PlayPauseTracking(trackingPLay: 0, userId: userId, dateBeginning: dateBeginningController.text);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PTCerrarRuta(data:data)));
                              });
                            });
                          }
                        },
                        child: Text('Iniciar'),
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

  void insertWorkingDayLocal(carPlate,endingDate,kmsBeginning,ksmTheEnd,startingDate,userId){
    _wd.carPlate =carPlate;
    _wd.endingDate = endingDate;
    _wd.kmsBeginning =kmsBeginning;
    _wd.kmsTheEnd = ksmTheEnd;
    _wd.startingDate =startingDate;
    _wd.userId = userId;
    _dbprovider.addWorkingDay(_wd);
  }


  Future postDataWorkingDay(carPlate,endingDate,kmsBeginning,ksmTheEnd,startingDate,userId) async{
    var respuesta ="";
    var working = await HttpHandler().postWorkingDay(carPlate,endingDate,kmsBeginning,ksmTheEnd,startingDate,userId);
    if(working=="OK"){
        respuesta="OK";
    }
    return respuesta;
  }
  
  Future<List<WorkingDay>> getWDLocal() async{
    List<WorkingDay> retunn = new List<WorkingDay>();
    List<WorkingDay> list = await _dbprovider.getWorkingDay();
    try{
      setState(() {
        if(list != null){
          for(var i=0;i<1; i++){
            kmsBeginningController.text = list[0].kmsTheEnd;
            dateBeginningController.text = fechaInicio.toString();
          }
        }
        else{
          dateBeginningController.text = fechaInicio.toString();
        }
        return list;
      });      
    }    
    catch(Ex){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }
}