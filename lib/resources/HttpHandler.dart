import 'dart:async';
import 'package:eszaworker/class/AcompananteAPIClass.dart';
import 'package:eszaworker/class/ControlHourAllClass.dart';
import 'package:eszaworker/class/ControlHourDateClass.dart';
import 'package:eszaworker/class/HojaControlHorasAppClass.dart';
import 'package:eszaworker/class/MatriculasApiClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eszaworker/class/UserByPhoneAPIClass.dart';

class HttpHandler {
  static final _httpHandler = new HttpHandler();
  final String _baseUrl ="apidatos.erp.avanzadi.com"; //"apidatos.erp.avanzadi.com"
  
  final String _urlWorkingDay = "/api/Prometer/InsertWorkingDay/";
  final String _urlUsuarioPhone = "/api/Prometer/UserByPhone";
  final String _urlTrackingData = "/api/Prometer/InsertTrackingData/";
  final String _urlRepostear = "/api/Prometer/InsertRefuel/";
  final String _urlMatriculas = "/api/Prometer/getDameVehiculos";
  final String _urlAcompanante = "/api/Prometer/getAcompanante";
  final String _urlControlHour = "/api/Prometer/InsertControlHora";
  final String _urlControlHourEliminar = "/api/Prometer/EliminarControlHora";
  final String _urlControlHorasTodas = "/api/Prometer/GetControlHorasTodas";
  final String _urlControlHorasFecha = "/api/Prometer/GetControlHorasFecha";
  final String _urlValidarUsuario = "api/Prometer/ValidarUsuario";
  final String _urlValidarVersion = "api/Prometer/ValidarVersion";
  final String _urlNotificacionGPS = "api/Prometer/NotificacionGPSInactivo";
  final String _urlGetUltimoEvento = "api/Prometer/GetUltimoEvento";
  final String _urlGetModificacionesAdmin = "api/Prometer/GetModificacionesAdmin";
  final String semilla = "415065080244";
  final String dominio = "ezsa.erp.avanzadi.com";
  static HttpHandler get() {
    return _httpHandler;
  }

  Future<dynamic> getJson(Uri uri) async {
    http.Response response =
        await http.get(uri, headers: {"Content-Type": "application/json"});
    //print("respondio ");
    return json.decode(response.body);
  }

  Future<dynamic> postJson(Uri uri, String body) async {
    http.Response response = await http.post(uri,
        headers: {"Content-Type": "application/json"}, body: body);
    //print("respondio ");
    return json.decode(response.body);
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DEL USUARIO SEGUN EL NUMERO TELEFONICO
  Future<List<UserByPhoneAPIClass>> fetchUserByPhone(telefono, token) {
    var uri = new Uri.http(_baseUrl, _urlUsuarioPhone);
    var body = jsonEncode(<String, String>{
      "telefono": telefono,
      "token": token,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    //print(uri);
    return postJson(uri, body).then(((data) => data
        .map<UserByPhoneAPIClass>(
            (item) => new UserByPhoneAPIClass(item, MediaType.content))
        .toList()));
  }

  //SE CONECTA CON LA API PARA VALIDAR EL USUARIO
  Future fetchValidarUsuario(telefono, pass) {
    var uri = new Uri.http(_baseUrl, _urlValidarUsuario);
    var body = jsonEncode(<String, String>{
      "telefono": telefono,
      "pass": pass,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    //print(uri);
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA VALIDAR LA VERSION
  Future fetchValidarVersion(idUsuario, numVersion) {
    var uri = new Uri.http(_baseUrl, _urlValidarVersion);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario,
      "numVersion": numVersion,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    //print(uri);
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA ENVIAR NOTIFICACION DE GPS INACTIVO
  Future postNotificacionGPSInactivo(idUsuario) {
    var uri = new Uri.http(_baseUrl, _urlNotificacionGPS);
    var body = jsonEncode(<String, String>{
      "dominio": dominio,
      "semilla": semilla,
      "userId": idUsuario.toString()
    });
    //print(uri);
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE REFUEL
  Future postRefuel(
      idTipoCombustible, kms, plate, price, litre, refuelDate, userId) {
    var uri = new Uri.http(_baseUrl, _urlRepostear);
    var body = jsonEncode(<String, String>{
      "idTipoCombustible": idTipoCombustible,
      "kms": kms,
      "plate": plate,
      "price": price,
      "litre": litre,
      "refuelDate": refuelDate,
      "userId": userId.toString(),
      "dominio": dominio,
      "semilla": semilla
    });
    //print(uri);
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE WORKINGDAY
  Future postWorkingDay(
      carPlate, endingDate, kmsBeginning, kmsTheEnd, startingDate, userId) {
    var uri = new Uri.http(_baseUrl, _urlWorkingDay);
    var body = jsonEncode(<String, String>{
      "carPlate": carPlate,
      "endingDate": endingDate,
      "kmsBeginning": kmsBeginning,
      "kmsTheEnd": kmsTheEnd,
      "startingDate": startingDate,
      "userId": userId.toString(),
      "dominio": dominio,
      "semilla": semilla
    });
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE CONTROL DE HORAS
  Future postControlHour(
      idUsuario, fecha, modificadoManual, evento, comentario, fechaHora) {
    var uri = new Uri.http(_baseUrl, _urlControlHour);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario,
      "fecha": fecha,
      "modificadoManual": modificadoManual,
      "evento": evento,
      "comentario": comentario,
      "fechaHora": fechaHora,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA ELIMINAR LOS DATOS DE CONTROL DE HORAS
  Future postControlHourEliminar(idUsuario, fecha, modificadoManual) {
    var uri = new Uri.http(_baseUrl, _urlControlHourEliminar);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario,
      "fecha": fecha,
      "modificadoManual": modificadoManual,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API PARA REGISTRAR LOS DATOS DE TRACKINGDATA
  Future postTrackingData(altitude, date, latitude, longitude, userId, evento) {
    var uri = new Uri.http(_baseUrl, _urlTrackingData);
    var body = jsonEncode(<String, String>{
      "altitude": altitude,
      "date": date,
      "latitude": latitude,
      "longitude": longitude,
      "userId": userId.toString(),
      "evento": evento,
      "dominio": dominio,
      "semilla": semilla
    });
    //print(uri);
    return postJson(uri, body);
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DE LAS MATRICULAS POR EL DNI DEL USUARIO
  Future<List<MatriculasApiClass>> fetchMatriculas(dni) {
    var uri = new Uri.http(_baseUrl, _urlMatriculas);
    var body = jsonEncode(<String, String>{
      "dniUsuario": dni,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<MatriculasApiClass>(
            (item) => new MatriculasApiClass(item, MediaTypeMatricula.content))
        .toList()));
  }

  //SE CONECTA CON LA API Y TRAE SI EL USUARIO ES ACOMPAÑANTE O NO
  Future<List<AcompananteAPIClass>> fetchAcompanante(userId) {
    var uri = new Uri.http(_baseUrl, _urlAcompanante);
    var body = jsonEncode(<String, String>{
      "dominio": dominio,
      "semilla": semilla,
      "userId": userId.toString()
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<AcompananteAPIClass>((item) =>
            new AcompananteAPIClass(item, MediaTypeAcompanante.content))
        .toList()));
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DEL CONTRO DE HORAS DE UN USUARIO
  Future<List<ControlHourAllClass>> fetchControlHorasTodas(String idUsuario) {
    var uri = new Uri.http(_baseUrl, _urlControlHorasTodas);
    var body = jsonEncode(<String, String>{
      "dominio": dominio,
      "semilla": semilla,
      "userId": idUsuario.toString()
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<ControlHourAllClass>((item) =>
            new ControlHourAllClass(item, MediaTypeControlHorasAll.content))
        .toList()));
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DEL CONTRO DE HORAS DE UN USUARIO Y FECHA
  Future<List<ControlHourDateClass>> fetchControlHorasFecha(idUsuario, fecha) {
    var uri = new Uri.http(_baseUrl, _urlControlHorasFecha);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario.toString(),//"9399",//idUsuario.toString()
      "fecha": fecha,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<ControlHourDateClass>((item) =>
            new ControlHourDateClass(item, MediaTypeControlHorasDate.content))
        .toList()));
  }

  //SE CONECTA CON LA API Y TRAE LOS VALORES DEL CONTRO DE HORAS DE UN USUARIO Y FECHA
  Future<List<ControlHourDateClass>> fetchUltimoEvento(idUsuario, fecha) {
    var uri = new Uri.http(_baseUrl, _urlGetUltimoEvento);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario.toString(),//"9399",//idUsuario.toString()
      "fecha": fecha,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<ControlHourDateClass>((item) =>
            new ControlHourDateClass(item, MediaTypeControlHorasDate.content))
        .toList()));
  }

  //SE CONECTA CON LA API Y TRAE EL LISTADO DE MODIFICACIONES HECHAS POR EL ADMINISTRADOR
  Future<List<HojaControlHorasAppClass>> fetchModificacionesAdmin(idUsuario, fechaDesde,fechaHasta) {
    var uri = new Uri.http(_baseUrl, _urlGetModificacionesAdmin);
    var body = jsonEncode(<String, String>{
      "idUsuario": idUsuario.toString(),//"9399",//idUsuario.toString()
      "fechaDesde": fechaDesde,
      "fechaHasta": fechaHasta,
      "dominio": dominio,
      "semilla": semilla,
      "userId": "0"
    });
    print(uri);
    return postJson(uri, body).then(((data) => data
        .map<HojaControlHorasAppClass>((item) =>
            new HojaControlHorasAppClass(item, MediaTypeHojaControlHorasDate.content))
        .toList()));
  }
}
