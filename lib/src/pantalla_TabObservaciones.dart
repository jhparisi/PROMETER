import 'dart:async';

import 'package:eszaworker/class/HojaControlHorasAppClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:flutter/material.dart';

import 'lista_observacionesAdmin.dart';

String tramos="";
class PTTabObservaciones extends StatefulWidget{
  final String isUsuario;
  final String fechas;
  PTTabObservaciones(this.isUsuario,this.fechas);

  @override 
  _PTTabObservacionesState createState() => new _PTTabObservacionesState();
  
}

class _PTTabObservacionesState extends State<PTTabObservaciones>{
  List<HojaControlHorasAppClass> _listaObs = [];

  @override 
  void initState(){
    super.initState();
    leerObservaciones();
  }

  void leerObservaciones() async{
    String idUsu = widget.isUsuario;
    var fechaSplit = widget.fechas.split("*");
    String fechaDesde = fechaSplit[0];
    String fechaHasta = fechaSplit[1];
    print("IdUsuario: "+idUsu+" FechaDesde: "+fechaDesde+" FechaHasta: "+fechaHasta);
    var data = await HttpHandler().fetchModificacionesAdmin(idUsu,fechaDesde,fechaHasta);
    if(data.length>0){
      for(var i=0; i<data.length; i++) {
        var formatearFecha = data[i].fecha.substring(0,10).split("/");
        var fech= formatearFecha[2]+"-"+formatearFecha[1]+"-"+formatearFecha[0];
        var tramo  = await leerTramos(idUsu,fech);
        final dat = data.firstWhere((item) => item.fecha == data[i].fecha);
        setState(() {
          dat.tramos = tramo.toString();
          print(tramo.toString());
          _listaObs.add(dat);
        });          
      }      
    }      
  }

  Future<String> leerTramos(String idUsu, String fecha) async{
    var tramo ="";
    var data = await HttpHandler().fetchControlHorasFecha(idUsu, fecha);
    if(data.length>0){
      data.forEach((element) {
        if(element.evento=="TotalTramo"){
          tramo+= element.tiempoTotal + ";";
        }
        else{
          tramo+= element.fechaHora + "*";
        }
      });
    }    
    return tramo;
  }

  @override 
  Widget build(BuildContext context) {
    
    return Expanded(
      child: ListView.builder(
        itemCount: _listaObs.length,
        itemBuilder: (BuildContext context, int index){
          return ListaObsAdmin(_listaObs[index]);
        },
      ),
    );
  }

  
}

