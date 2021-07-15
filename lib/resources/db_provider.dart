import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/HistoricoClass.dart';
import 'package:eszaworker/class/MensajesClass.dart';
import 'package:eszaworker/class/TrackingDataClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/class/RefuelClass.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:eszaworker/class/DataLocalClass.dart';

class DBProvider {
  static final DBProvider _dbProvider = new DBProvider();
  Database db;

  DBProvider() {
    init();
  }

  var versionDB = 0;
  static DBProvider get() {
    return _dbProvider;
  }

  void init() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "EszaWorker.db");
    db = await openDatabase(path, version: 7,
        onCreate: (Database newDb, int version) {
      newDb.execute("""
            CREATE TABLE WorkingDay(
              id ROWID, 
              carPlate TEXT,
              endingDate TEXT, 
              kmsBeginning TEXT, 
              kmsTheEnd TEXT, 
              startingDate TEXT, 
              userId TEXT
            ); """);
      newDb.execute("""
          CREATE TABLE TrackingData(
            id ROWID, 
            altitude TEXT,
            date TEXT,
            latitude TEXT, 
            longitude TEXT, 
            userId TEXT
          );""");
      newDb.execute("""
          CREATE TABLE DataLocal(
            id ROWID,
            carPlate TEXT, 
            date TEXT, 
            userId INTEGER, 
            numPhone TEXT,
            nombreCompleto TEXT,
            login TEXT,
            dni TEXT,
            acompanante INTEGER
          );""");
      newDb.execute("""
          CREATE TABLE PlayPauseTracking(
            id ROWID,
            userId INTEGER,
            trackingPLay INTEGER,
            dateBeginning TEXT
          );""");
      newDb.execute("""
          CREATE TABLE RefuelLocal(
            id ROWID,
            userId TEXT,
            idTipoCombustible TEXT,
            kms TEXT,
            litre TEXT,
            plate TEXT,
            price TEXT,
            refuelDate TEXT
          );""");
      newDb.execute("""
          CREATE TABLE Mensajes(
            id ROWID,
            fecha TEXT,
            titulo TEXT,
            mensaje TEXT,
            url TEXT
          );""");
      newDb.execute("""
          CREATE TABLE Historico(
            id ROWID,
            fechaUltimoLogin TEXT,
            usuario TEXT,
            matricula TEXT
          );""");
      newDb.execute("""
          CREATE TABLE Configuracion(
            id ROWID,
            empresa TEXT,
            dominio TEXT,
            semilla TEXT
          );""");
    });
  }

  //METODO QUE RETORNA LA VERSION DE LA BDD
  Future<int> getVersionDatabase() async {
    var version = db.getVersion();
    return version;
  }

  //Metodo para verificar si ya existe un usario logueado para mostrar o no la pantalla de inicio
  Future<List<DataLocal>> getVerifyPantallaInicial() async {
    var maps = await db.query("DataLocal", columns: null);
    if (maps.length > 0) {
      return maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList();
    }

    return null;
  }

  Future<List<DataLocal>> getVerifyPantallaInicialMenu(int userId) async {
    //print(' $numPhone - Lectura de Base de datos local');
    var maps = await db.query("DataLocal",
        columns: null, where: "userId = ?", whereArgs: [userId]);

    if (maps.length > 0) {
      print(maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList());
      return maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList();
    }

    return null;
  }

  //Metodo para traer si existe un tracking iniciado o no
  Future<List<PlayPauseTracking>> getPlayAndPause() async {
    var maps = await db.query("PlayPauseTracking", columns: null);
    if (maps.length > 0) {
      //print(maps.map<PlayPauseTracking>((item) => new PlayPauseTracking.fromDb(item)).toList());
      return maps
          .map<PlayPauseTracking>((item) => new PlayPauseTracking.fromDb(item))
          .toList();
    }

    return null;
  }

  //Buscar dentro de la tabla Datalocal los datos por numero y matricula
  Future<List<DataLocal>> fethLocalData(String numPhone) async {
    //print(' $numPhone - Lectura de Base de datos local');
    var maps = await db.query("DataLocal",
        columns: null, where: "numPhone = ?", whereArgs: [numPhone]);

    if (maps.length > 0) {
      print(maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList());
      return maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList();
    }

    return null;
  }

  //Buscar dentro de la tabla Datalocal todos los datos
  Future<List<DataLocal>> fethLocalDataAll() async {
    //print(' $numPhone - Lectura de Base de datos local');
    var maps = await db.query("DataLocal", columns: null);

    if (maps.length > 0) {
      //print(maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList());
      return maps.map<DataLocal>((item) => new DataLocal.fromDb(item)).toList();
    }

    return null;
  }

  //Buscar dentro de la tabla Mensajes todos los datos
  Future<List<Mensajes>> fethMensajesAll() async {
    var maps = await db.query("Mensajes", columns: null, orderBy: "fecha DESC");

    if (maps.length > 0) {
      print("MENSAJES");
      print(maps.map<Mensajes>((item) => new Mensajes.fromDb(item)).toList());
      return maps.map<Mensajes>((item) => new Mensajes.fromDb(item)).toList();
    }

    return null;
  }

  //Buscar dentro de la tabla Historico todos los datos
  Future<List<Historico>> getHistorico() async {
    //print(' $numPhone - Lectura de Base de datos local');
    var maps = await db.query("Historico", columns: null);

    if (maps.length > 0) {
      print("historico");
      print(maps.map<Historico>((item) => new Historico.fromDb(item)).toList());
      return maps.map<Historico>((item) => new Historico.fromDb(item)).toList();
    } else {
      return null;
    }
  }

  //Metodo para la informacion del ultimo repostaje
  Future<List<Refuel>> getVerifyRefuel() async {
    var maps = await db.query("RefuelLocal", columns: null);
    if (maps.length > 0) {
      //print("DATOS REFUEL");
      print(maps.map<Refuel>((item) => new Refuel.fromDb(item)).toList());
      return maps.map<Refuel>((item) => new Refuel.fromDb(item)).toList();
    }

    return null;
  }

  //Metodo para agregar los datos de mensajes en la base de datos local
  void addMensajes(Mensajes data) {
    //print("Insertar en la BD local - $data");
    db.insert("Mensajes", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para agregar los datos de usuario en la base de datos local
  void addDataLocal(DataLocal data) {
    //print("Insertar en la BD local - $data");
    db.insert("DataLocal", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para agregar los datos a historico
  void addHistorico(Historico data) {
    //print("Insertar en la BD local - $data");
    db.insert("Historico", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para agregar los datos de repostaje en la base de datos local
  void addRefuelLocal(Refuel data) {
    //print("Insertar en la BD local - $data");
    db.insert("RefuelLocal", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para agregar los datos de Tracking en la base de datos local
  void addTracking(TrackingData data) {
    //print("Insertar en la BD local - $data");
    db.insert("TrackingData", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para traer todos los puntos guardados
  Future<List<TrackingData>> getTrackingAll() async {
    var maps = await db.query("TrackingData", columns: null);
    if (maps.length > 0) {
      print(maps
          .map<TrackingData>((item) => new TrackingData.fromDb(item))
          .toList());
      return maps
          .map<TrackingData>((item) => new TrackingData.fromDb(item))
          .toList();
    }

    return null;
  }

  //Metodo para agregar los datos de Working Day en la base de datos local
  void addWorkingDay(WorkingDay data) {
    //print("Insertar en la BD local - $data");
    db.insert("WorkingDay", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para traer el Working Day
  Future<List<WorkingDay>> getWorkingDay() async {
    var maps = await db.query("WorkingDay", columns: null);
    if (maps.length > 0) {
      print(
          maps.map<WorkingDay>((item) => new WorkingDay.fromDb(item)).toList());
      return maps
          .map<WorkingDay>((item) => new WorkingDay.fromDb(item))
          .toList();
    }

    return null;
  }

  //Metodo para agregar play o pause
  void addPlayPause(PlayPauseTracking data) {
    //print("Insertar en la BD local - $data");
    db.insert("PlayPauseTracking", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  //Metodo para eliminar los datos de Working Day en la base de datos local
  void deleteWorkingDay(userId) {
    //print("Insertar en la BD local - $data");
    db.delete("WorkingDay", where: 'userId = ?', whereArgs: [userId]);
  }

  //Metodo para eliminar los datos de TrackingData en la base de datos local
  void deleteTrackingData(userId) {
    //print("Insertar en la BD local - $data");
    db.delete("TrackingData", where: 'userId = ?', whereArgs: [userId]);
  }

  //Metodo para eliminar los datos de TrackingData en la base de datos local
  void deleteDataLocal(id) {
    //print("Insertar en la BD local - $data");
    db.delete("DataLocal", where: 'id = ?', whereArgs: [id]);
  }

  void deletePlayPause(id) {
    //print("Insertar en la BD local - $data");
    db.delete("PlayPauseTracking", where: 'userId = ?', whereArgs: [id]);
  }

  //Metodo para eliminar los datos de Refuel en la base de datos local
  void deleteRefuelLocal(userId) {
    //print("Insertar en la BD local - $data");
    db.delete("RefuelLocal", where: 'userId = ?', whereArgs: [userId]);
  }

  //Metodo para actualizar los datos de Working Day en la base de datos local
  void updateWorkingDay(WorkingDay data) {
    //print("Insertar en la BD local - $data");
    db.update("WorkingDay", data.toMap(),
        where: 'userId = ?', whereArgs: [data.userId]);
  }

  //Metodo para actualizar los datos la base de datos local por usuario
  void updateDataLocal(DataLocal data) {
    print("ACTUALIZO en la BD local - $data");
    db.update("DataLocal", data.toMap(),
        where: 'userId = ?', whereArgs: [data.userId]);
  }

  //Buscar dentro de la tabla Configuracion todos los datos
  Future<List<Configuracion>> getConfiguracion() async {
    var maps = await db.query("Configuracion");
    if (maps.length > 0) {
      print(maps.map<Configuracion>((item) => new Configuracion.fromDb(item)).toList());
      return maps.map<Configuracion>((item) => new Configuracion.fromDb(item)).toList();
    } else {
      return null;
    }
  }

//Metodo para agregar los datos a Configuracion
  void addConfiguracion(Configuracion data) {
    //print("Insertar en la BD local - $data");
    db.insert("Configuracion", data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }
}
