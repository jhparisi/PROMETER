import 'dart:async';

import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/HojaControlHorasAppClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:flutter/material.dart';

import 'lista_observacionesAdmin.dart';

DBProvider _dbprovider = DBProvider.get();
String tramos="";
String _semilla;
String _dominio;

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
    getConfiguracion();
    super.initState();
    
    leerObservaciones();
  }

  void leerObservaciones() async{
    String idUsu = widget.isUsuario;
    var fechaSplit = widget.fechas.split("*");
    String fechaDesde = fechaSplit[0];
    String fechaHasta = fechaSplit[1];
    print("IdUsuario: "+idUsu+" FechaDesde: "+fechaDesde+" FechaHasta: "+fechaHasta);
    await _dbprovider.init();
    var data = await HttpHandler().fetchModificacionesAdmin(idUsu,fechaDesde,fechaHasta,_dominio, _semilla);
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
    var data = await HttpHandler().fetchControlHorasFecha(idUsu, fecha,_dominio, _semilla);
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

