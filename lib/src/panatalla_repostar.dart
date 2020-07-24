import 'dart:async';

import 'package:eszaworker/class/RefuelClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/resources/repository.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';

ProgressDialog prd;
Menu _menu = new Menu();

String _combustible="";
int _idUser =_menu.getuserId();
String _carPlateRepostar =_menu.getCarPlate();
final carPlateController = TextEditingController();
final priceController = TextEditingController();
final litreController = TextEditingController();
final kmsController = TextEditingController();
String lastCarPlate ="";
Flushbar fbar;
String trackingPlay="0";
Repository _repository = Repository.get();
DBProvider _dbprovider = DBProvider.get();
List<String> _locations = ['Gasolina 98', 'Gasolina 95', 'Bioetanol', 'Diésel Normal','Diésel Plus','Diésel 1D, 2D,4D','Gas Natural']; // Option 2
String _selectedLocation; // Option 2
int lastKM=0;
String _dateBeginning="";

class PTRepostar extends StatefulWidget{
  static const String routeName = "/pantalla_repostar";
  PTRepostar({Key key}): super (key:key);
  _PTRepostarState createState() => _PTRepostarState();

}

class _PTRepostarState extends State<PTRepostar>{   
  
  void loadRefuel(idTipoCombustible,kms,plate,price,litre,refuelDate,userId) async {
    var fuel = await HttpHandler().postRefuel(idTipoCombustible,kms,plate,price,litre,refuelDate,userId);
    setState(() {
      //_response.addAll(fuel);
      if(fuel=="OK"){
        fbar = new Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          message: "Se ha registrado correctamente!",
          duration: Duration(seconds: 5),
        );
        fbar.show(context);
      }
      
    });
  }

  final _formKey = GlobalKey<FormState>();
  
  @override
  initState() {
    super.initState();
     getLastRefuel();
     getWDLocal();
  }

  @override 
  Widget build(BuildContext context){
    //getVerifyDataLocal();
    _menu.getVerifyDataLocal(_idUser);
    
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
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Combustible:'
                        ) ,
                        isExpanded: true,
                        value: _selectedLocation,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue;
                            if(newValue=="Gasolina 98"){
                              _combustible ="1";
                            }
                            else if (newValue=="Gasolina 95"){
                              _combustible="2";
                            }
                            else if (newValue=="Bioetanol"){
                              _combustible="3";
                            }
                            else if (newValue=="Diésel Normal"){
                              _combustible="4";
                            }
                            else if (newValue=="Diésel Plus"){
                              _combustible="5";
                            }
                            else if (newValue=="Diésel 1D, 2D,4D"){
                              _combustible="6";
                            }
                            else if (newValue=="Gas Natural"){
                              _combustible="7";
                            }
                            
                          });
                          print(_combustible);
                        },
                        items: _locations.map((location) {
                          
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        //controller: carPlateController,
                        decoration: InputDecoration(
                          labelText: 'Matrícula:'
                        ),
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color:Colors.grey),
                        initialValue: _carPlateRepostar,
                      ),
                      TextFormField(
                        controller: kmsController,
                        decoration: InputDecoration(
                          labelText: 'Kilometros al repostar:',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Debes indicar los kilometros';
                          }
                          else if(int.parse(kmsController.text) < lastKM && lastCarPlate == _carPlateRepostar){
                            return 'Los Km indicados no pueden ser inferiores \na los valores del último repostaje';
                          }
                          else if(int.parse(kmsController.text)> (lastKM+1500) && lastKM!=0){
                            /* fbar = new Flushbar(
                              flushbarPosition: FlushbarPosition.TOP,
                              message: 'El Kilómetraje, no puede ser superior a los \n1.500km adicionales al último repostaje (' + lastKM.toString() + ' Km)',
                              duration: Duration(seconds: 5),
                            );
                            fbar.show(context);
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              return null;
                            }); */
                            
                            return 'El Kilómetraje, no puede ser superior a los \n1.500km adicionales al último repostaje (' + lastKM.toString() + ' Km)';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Importe:'
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Debes indicar el importe';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: litreController,
                        decoration: InputDecoration(
                          labelText: 'Litros:',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Debes indicar los Litros';
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
                            loadRefuel(_combustible, kmsController.text, _carPlateRepostar, priceController.text, litreController.text, DateTime.now().toString(), _idUser.toString());
                            prd.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              prd.hide().whenComplete(() {
                                _dbprovider.deleteRefuelLocal(_idUser.toString());
                                _repository.fetchRefuelLocal(_combustible, kmsController.text, litreController.text, _carPlateRepostar, priceController.text, DateTime.now().toString(), _idUser.toString());
                                getPlayPause();
                              });
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

  Future<List<PlayPauseTracking>> getPlayPause() async{
    List<PlayPauseTracking> retunn = new List<PlayPauseTracking>();
    try{
      List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
        if(list != null){
          for(var i=0;i<list.length; i++){
            trackingPlay = list[i].trackingPLay.toString();
            //_idUser = list[i].userId;
          }
          //_repository.fetchLocalData('${numPhoneController.text}','${carPlateController.text}',_idUser,_nombreCompleto,_login);
          _menu.getVerifyDataLocal(_idUser);
          print("EL VALOR DE trackingPlay =" + trackingPlay.toString());
          if(trackingPlay!="0" && trackingPlay!=null){
            final data = PlayPauseTracking(trackingPLay: int.parse(trackingPlay), userId: _idUser, dateBeginning: _dateBeginning);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>PTCerrarRuta(
              data:data
            )));
          } 
          
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
        }  
             
      return list; 
    }
    catch(Ex){
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }

  Future<List<Refuel>> getLastRefuel() async{
    String _nameRefuel="";
    List<Refuel> retunn = new List<Refuel>();   
    List<Refuel> list = await _dbprovider.getVerifyRefuel();   
    try{
      setState(() {        
        if(list != null){
          for(var i=0;i<1; i++){
            lastCarPlate = list[0].plate;
            print("LastCarPLate" +list[0].plate);
            //carPlateController.text = list[0].plate;
            priceController.text = list[0].price;
            litreController.text = list[0].litre;
            kmsController.text = list[0].kms;
            lastKM =int.parse(list[0].kms);
            switch(list[0].idTipoCombustible){
              case "":
                _nameRefuel ="Gasolina 98";
                break;
              case "1":
                _nameRefuel ="Gasolina 98";
                break;
              case "2":
                _nameRefuel ="Gasolina 95";
                break;
              case "3":
                _nameRefuel ="Bioetanol";
                break;
              case "4":
                _nameRefuel ="Diésel Normal";
                break;
              case "5":
                _nameRefuel ="Diésel Plus";
                break;
              case "6":
                _nameRefuel ="Diésel 1D, 2D,4D";
                break;
              case "7":
                _nameRefuel ="Gas Natural";
                break;
            }
            _selectedLocation = _nameRefuel;
          }
        }
        return list;
      });
      
    }    
    catch(Ex){
      
    }
    return retunn;
  }

  Future<List<WorkingDay>> getWDLocal() async{
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
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PTPrincipal()));
    }
    return retunn;
  }
}