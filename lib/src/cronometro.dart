import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String tiempocronometro ="00:00:00";
DateTime tiempoActual;
DateTime tiempoInicio;

class Cronometro extends StatelessWidget {
  const Cronometro({Key key}) : super(key: key);
  
  Container getCronometro(BuildContext context){
    Text getText(){
      return Text("$tiempocronometro", style: TextStyle(fontSize: 40.0),);
    }

    return Container(child: getText());
  } 

  
  @override
  Widget build(BuildContext context) {
    cronometro();
    return Container(
      child: getCronometro(context)
    );
  }
  
  String cronometro(){
    Timer.periodic(Duration(seconds: 1), (timer){
      tiempoInicio = new DateFormat("yyyy-MM-dd H:mm:ss").parse("2020-03-04 08:00:00") ;
      tiempoActual = new DateTime.now();
      //tiempocronometro = tiempoActual.subtract(Duration(seconds: 1));
      Duration dur = tiempoActual.difference(tiempoInicio);
      var dif = (dur.inSeconds).floor();
      var resH = (dif/60/60);
      var _resH = resH.toString();
      var xxH = _resH.indexOf('.')+1;
      var yyH = _resH.length;
      var zzH = "0."+_resH.substring(xxH,yyH);
      var _hour = _resH.substring(0,_resH.indexOf('.'));
      if(_hour.length==1){
        _hour ="0"+_hour;
      }
      var resM = double.parse(zzH)*60;
      var _resM = resM.toString();
      var xxM = _resM.indexOf('.')+1;
      var yyM = _resM.length;
      var zzM = "0."+_resM.substring(xxM,yyM);
      var _min = _resM.substring(0,_resM.indexOf('.'));
      if(_min.length==1){
        _min ="0"+_min;
      }

      var resS = double.parse(zzM)*60;
      var _resS = resS.toString();
      var _sec = _resS.substring(0,_resS.indexOf('.'));
      if(_sec.length==1){
        _sec ="0"+_sec;
      }
      
      tiempocronometro = _hour+":"+_min+":"+_sec;
      print(tiempocronometro);

    
    
    });
    return tiempocronometro;
  } 
}