import 'dart:async';
import 'package:eszaworker/class/AcompananteAPIClass.dart';
import 'package:eszaworker/class/MatriculasApiClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eszaworker/class/UserByPhoneAPIClass.dart'; 

class HttpHandler {
  static final _httpHandler = new HttpHandler();
  final String _baseUrl = "apidatos.pre.erp.avanzadi.com";//"apidatos.erp.avanzadi.com";//
  final String _urlWorkingDay = "/api/EszaWorkers/InsertWorkingDay/";
  final String _urlUsuarioPhone = "/api/EszaWorkers/UserByPhone";
  final String _urlTrackingData = "/api/EszaWorkers/InsertTrackingData/";
  final String _urlRepostear ="/api/EszaWorkers/InsertRefuel/";
  final String _urlMatriculas ="/api/EszaWorkers/getDameVehiculos";
  final String _urlAcompanante ="/api/EszaWorkers/getAcompanante";
  static HttpHandler get() {
    return _httpHandler;
  }

  Future<dynamic> getJson(Uri uri) async {
    http.Response response = await http.get(uri, headers: {"Content-Type": "application/json"});
    //print("respondio ");
    return json.decode(response.body);
  }


  //SE CONECTA CON LA API Y TRAE LOS VALORES DEL USUARIO SEGUN EL NUMERO TELEFONICO
  Future<List<UserByPhoneAPIClass>> fetchUserByPhone(telefono, token) {
    var uri = new Uri.http(_baseUrl, _urlUsuarioPhone, {"telefono": telefono, "token": token});
    //print(uri);
    return getJson(uri).then(((data) => data.map<UserByPhoneAPIClass>((item) => new UserByPhoneAPIClass(item, MediaType.content)).toList()));
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE REFUEL
  Future postRefuel(idTipoCombustible,kms,plate,price,litre,refuelDate,userId) {
    var uri = new Uri.http(_baseUrl, _urlRepostear, {"idTipoCombustible": idTipoCombustible,"kms":kms,"plate":plate,"price":price,"litre":litre,"refuelDate":refuelDate,"userId":userId});
    //print(uri);
    return getJson(uri);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE WORKINGDAY
  Future postWorkingDay(carPlate,endingDate,kmsBeginning,kmsTheEnd,startingDate,userId) {
    var uri = new Uri.http(_baseUrl, _urlWorkingDay, {"carPlate": carPlate,"endingDate":endingDate,"kmsBeginning":kmsBeginning,"kmsTheEnd":kmsTheEnd,"startingDate":startingDate,"userId":userId});
    return getJson(uri);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE TRACKINGDATA
  Future postTrackingData(altitude,date,latitude,longitude,userId) {
    var uri = new Uri.http(_baseUrl, _urlTrackingData, {"altitude": altitude,"date":date,"latitude":latitude,"longitude":longitude,"userId":userId});
    //print(uri);
    return getJson(uri);
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DE LAS MATRICULAS POR EL DNI DEL USUARIO
  Future<List<MatriculasApiClass>> fetchMatriculas(dni) {
    var uri = new Uri.http(_baseUrl, _urlMatriculas, {"dniUsuario": dni, "domain": "ezsaworker"});
    print(uri);
    return getJson(uri).then(((data) => data.map<MatriculasApiClass>((item) => new MatriculasApiClass(item, MediaTypeMatricula.content)).toList()));
  }

  //SE CONECTA CON LA API Y TRAE SI EL USUARIO ES ACOMPAÑANTE O NO
  Future<List<AcompananteAPIClass>> fetchAcompanante(userId) {
    var uri = new Uri.http(_baseUrl, _urlAcompanante, {"userId": userId, "domain": "ezsaworker"});
    print(uri);
    return getJson(uri).then(((data) => data.map<AcompananteAPIClass>((item) => new AcompananteAPIClass(item, MediaTypeAcompanante.content)).toList()));
  }

}
