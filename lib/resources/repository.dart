import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/DataLocalClass.dart';
import 'package:eszaworker/class/HistoricoClass.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/class/RefuelClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
//import 'package:eszaworker/src/menu.dart';

class Repository{
  static final Repository _repository = new Repository();
  DBProvider _dbProvider = DBProvider.get();
  DataLocal _dataLocal = new DataLocal();
  Refuel _refuelLocal = new Refuel();
  Historico _historico = new Historico();
  Configuracion _configuracion = new Configuracion();
  PlayPauseTracking _trackingPlay = new PlayPauseTracking();
  //WorkingDay _dataWorkin = new WorkingDay();
  static Repository get(){
    return _repository;
  }

  Future<List<DataLocal>> fetchLocalData(String numPhone,String carPlate, int userId, String nombreCompleto, String login, String dni, int acompanante) async{
    String nombre ="";
    String logi = "";
    List<DataLocal> list = await _dbProvider.fethLocalData(numPhone);
    _dbProvider.fethLocalDataAll();
    if(list != null){
      if(nombreCompleto=="" || login==""){
        nombre = list[0].nombreCompleto.toString();
        logi = list[0].login.toString();
      }
      else{
        nombre= nombreCompleto;
        logi = login;
      }
      //AQUI DEBO ACTUALIZAR LOS DATOS
      _dataLocal.userId=userId;
      _dataLocal.carPlate = carPlate;
      _dataLocal.date = DateTime.now().toString();
      _dataLocal.numPhone = numPhone;
      _dataLocal.nombreCompleto=nombre;
      _dataLocal.login = logi;
      _dataLocal.dni = dni;
      _dataLocal.acompanante = acompanante;

      _dbProvider.updateDataLocal(_dataLocal);

      list = await _dbProvider.fethLocalData(numPhone);
      return list;
    }
    else{
      _dataLocal.userId=userId;
      _dataLocal.carPlate = carPlate;
      _dataLocal.date = DateTime.now().toString();
      _dataLocal.numPhone = numPhone;
      _dataLocal.nombreCompleto=nombreCompleto;
      _dataLocal.login = login;
      _dataLocal.dni = dni;
      _dataLocal.acompanante =acompanante;
      _dbProvider.addDataLocal(_dataLocal);
      
      list = await _dbProvider.fethLocalData(numPhone);
      return list;
    }
    //Aqui hacer el metodo de insertar los valores
    //list.forEach((element) => _dbProvider.addDataLocal(elemnt));

    //return list;
  }

  Future<List<Refuel>> fetchRefuelLocal(String idTipoCombustible, String kms, String litre, String plate, String price, String refuelDate, String userId,String priceOnDay) async{

    List<Refuel> list = await _dbProvider.getVerifyRefuel();
    if(list != null){
      return list;
    }
    else{
      _refuelLocal.idTipoCombustible =idTipoCombustible;
      _refuelLocal.kms = kms;
      _refuelLocal.litre = litre;
      _refuelLocal.plate = plate;
      _refuelLocal.price = price;
      _refuelLocal.refuelDate = refuelDate;
      _refuelLocal.userId =userId;
      _refuelLocal.priceOnDay = priceOnDay;
      
      _dbProvider.addRefuelLocal(_refuelLocal);
      
    }
    //Aqui hacer el metodo de insertar los valores
    //list.forEach((element) => _dbProvider.addDataLocal(elemnt));

    return list;
  }

  Future<List<PlayPauseTracking>> fetchPlayPause(int trackingPlay) async{

    List<PlayPauseTracking> list = await _dbProvider.getPlayAndPause();
    if(list != null){
      return list;
    }
    else{
      _trackingPlay.trackingPLay = trackingPlay;
      _dbProvider.addPlayPause(_trackingPlay);
      
    }
    //Aqui hacer el metodo de insertar los valores
    //list.forEach((element) => _dbProvider.addDataLocal(elemnt));

    return list;
  }

  Future<List<Historico>> fetchHistorico(String ultimoLogin, String usuario, String matricula) async{

    _historico.fechaUltimoLogin = ultimoLogin;
    _historico.usuario = usuario;
    _historico.matricula = matricula;
    
    _dbProvider.addHistorico(_historico);
    List<Historico> list = await _dbProvider.getHistorico();

    return list;
  }

  Future<List<Configuracion>> fetchConfiguracion(String empresa, String dominio, String semilla) async{

    _configuracion.empresa = empresa;
    _configuracion.dominio = dominio;
    _configuracion.semilla = semilla;
    
    _dbProvider.addConfiguracion(_configuracion);
    List<Configuracion> list = await _dbProvider.getConfiguracion();

    return list;
  }

}