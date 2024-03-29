import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/RefuelClass.dart';
import 'package:eszaworker/class/WorkingDayClass.dart';
import 'package:eszaworker/src/menu.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_principal.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/class/PlayPauseTrackingClass.dart';
import 'package:eszaworker/resources/repository.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:image_picker/image_picker.dart';

ProgressDialog prd;
Menu _menu = new Menu();
String _combustible = "";
int _idUser = _menu.getuserId();
String _carPlateRepostar = _menu.getCarPlate();
final carPlateController = TextEditingController();
final priceController = TextEditingController();
final fotoController = TextEditingController();
final priceOnDayController = TextEditingController();
final litreController = TextEditingController();
final kmsController = TextEditingController();
var isFirst = false;
String lastCarPlate = "";
Flushbar fbar;
String trackingPlay = "0";
Repository _repository = Repository.get();
DBProvider _dbprovider = DBProvider.get();
List<String> _locations = [
  'Gasolina 98',
  'Gasolina 95',
  'Bioetanol',
  'Diésel Normal',
  'Diésel Plus',
  'Diésel 1D, 2D,4D',
  'Gas Natural',
  'Eléctrico (Kw)',
  'AdBlue'
]; // Option 2
String _selectedLocation; // Option 2
int lastKM = 0;
String _dateBeginning = "";
String unidadMedida = "Litros";
String _semilla;
String _dominio;

Future<File> file;
String status = '';
String base64Image;
File tmpFile;
File sampleImage;
String errMessage = 'Error subiendo imagen';
bool msgExito = false;
List<int> imageBytes = [];
bool btnAceptarVisible = false;
var maskFormatter = new MaskTextInputFormatter(mask: '##,###', filter: {"#": RegExp(r'[0-9]')});
var maskFormatterPrice = new MaskTextInputFormatter(mask: '#,###', filter: {"#": RegExp(r'[0-9]')});
class PTRepostar extends StatefulWidget {
  static const String routeName = "/pantalla_repostar";
  PTRepostar({Key key}) : super(key: key);
  _PTRepostarState createState() => _PTRepostarState();
}

class _PTRepostarState extends State<PTRepostar> {  

  void loadRefuel(idTipoCombustible, kms, plate, price, litre, refuelDate, userId, priceOnDay) async {

    String fileName = sampleImage.path.split('/').last;
    imageBytes = sampleImage.readAsBytesSync();
    base64Image = base64Encode(imageBytes);
    if(idTipoCombustible==""){
      idTipoCombustible=1;
    }
    var fuel = await HttpHandler().postRefuel(idTipoCombustible, kms, plate,price, litre, refuelDate, userId, _dominio, _semilla, priceOnDay);

    var refuelIma = await HttpHandler().getUploadImg(sampleImage, fileName, base64Image, _dominio, _semilla, userId, fuel);
    setState(() {
      //_response.addAll(fuel);
      if (fuel != "" && refuelIma !="") {
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
    getConfiguracion();
    getLastRefuel();
    getWDLocal();
  }


  @override
  Widget build(BuildContext context) {
    //***************************AlertDialog*************************************************//
    showAlertDialog(BuildContext context, String pregunta, String datos,
        Color color, int btnAceptar) {
      //List<Widget> accion = new List<Widget>.empty();

      // set up the buttons
      Widget botonCancelar = TextButton(
        child: Text("Cancelar"),
        onPressed: () {
          Navigator.pop(context);
        },
      );
      Widget botonAceptar = TextButton(
        child: Text("Aceptar"),
        onPressed: () {
          Navigator.pop(context);
          loadRefuel(
              _combustible,
              kmsController.text,
              _carPlateRepostar,
              priceController.text,
              litreController.text,
              DateTime.now().toString(),
              _idUser.toString(),
              priceOnDayController.text);
          prd.show();
          Future.delayed(Duration(seconds: 3)).then((value) {
            prd.hide().whenComplete(() {
              _dbprovider.deleteRefuelLocal(_idUser.toString());
              _repository.fetchRefuelLocal(
                  _combustible,
                  kmsController.text,
                  litreController.text,
                  _carPlateRepostar,
                  priceController.text,
                  DateTime.now().toString(),
                  _idUser.toString(),
                  priceOnDayController.text);
              getPlayPause();
            });
          });
        },
      );

      if (btnAceptar == 1) {
        btnAceptarVisible = true;
      } else {
        btnAceptarVisible = false;
      } 
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(pregunta),
        content: Text(
          datos,
          style: TextStyle(color: color),
        ),
        actions: <Widget>[
          Visibility(
            child: botonAceptar, 
            visible: btnAceptarVisible,
          ),
          botonCancelar
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
    //***************************FIN AlertDialog*************************************************//

    //getVerifyDataLocal();
    _menu.getVerifyDataLocal(_idUser);

    prd = new ProgressDialog(context);
    prd.style(
        message: 'Guardando datos del repostaje',
        borderRadius: 0.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        progress: 0.0,
        maxProgress: 30.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("PRO-METER APP", textAlign: TextAlign.center),
        ),
        drawer: _menu.getDrawer(context),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                  stops: [0.1, 0.9])),
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Padding(
                      padding:
                          EdgeInsets.only(right: 25.0, left: 25.0, top: 50.0),
                      child: new Form(
                          key: _formKey,
                          //child: Container(
                          child: SingleChildScrollView(
                              child: Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 0.0),
                            child: Column(
                              children: <Widget>[
                                DropdownButtonFormField(
                                  //decoration: InputDecoration(labelText: 'Combustible:'),
                                  
                                  decoration: InputDecoration(
                                    labelText: "Combustible",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.local_gas_station,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  style: TextStyle(fontFamily: 'HeeboSemiBold', color: Colors.black),
                                  isExpanded: true,
                                  value: _selectedLocation,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedLocation = newValue;
                                      if (newValue == "Gasolina 98") {
                                        _combustible = "1";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Gasolina 95") {
                                        _combustible = "2";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Bioetanol") {
                                        _combustible = "3";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Diésel Normal") {
                                        _combustible = "4";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Diésel Plus") {
                                        _combustible = "5";
                                        unidadMedida = "Litros";
                                      } else if (newValue ==
                                          "Diésel 1D, 2D,4D") {
                                        _combustible = "6";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Gas Natural") {
                                        _combustible = "7";
                                        unidadMedida = "Litros";
                                      } else if (newValue == "Eléctrico (Kw)") {
                                        _combustible = "8";
                                        unidadMedida = "Kw";
                                      } else if (newValue == "AdBlue") {
                                        _combustible = "9";
                                        unidadMedida = "Litros";
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
                                Padding(padding: EdgeInsets.only(top: 25.0)),
                                TextFormField(
                                  //controller: carPlateController,
                                  //decoration:InputDecoration(labelText: 'Matrícula:'),
                                  decoration: InputDecoration(
                                    labelText: "Matrícula",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.car_repair,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  readOnly: true,
                                  enabled: false,
                                  style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                                  initialValue: _carPlateRepostar,
                                ),
                                Padding(padding: EdgeInsets.only(top:25.0)),
                                TextFormField(
                                  controller: kmsController,
                                  style: TextStyle(color: Colors.black, fontFamily: 'HeeboSemiBold'),
                                  decoration: InputDecoration(
                                    labelText: "Kilometros al repostar",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.money_sharp,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Debes indicar los kilometros",
                                          Colors.red,
                                          0);
                                      return "Debes indicar los kilometros";
                                    } 
                                    else if (int.parse(kmsController.text) < lastKM && lastCarPlate == _carPlateRepostar) {
                                      var indicados = kmsController.text;
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Los Km indicados ($indicados) no pueden ser inferiores \na los valores del último repostaje ($lastKM).\n¿Estas seguro de querer guardar estos valores?",
                                          Colors.red,
                                          0);
                                      return 'Los Km indicados no pueden ser inferiores \na los valores del último repostaje';
                                    } 
                                    else if (int.parse(kmsController.text) >(lastKM + 1500) && lastKM != 0) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          'El Kilómetraje, no puede ser superior a los \n1.500km adicionales al último repostaje (' +
                                              lastKM.toString() +
                                              ' Km).\n¿Estas seguro de querer guardar estos valores?',
                                          Colors.red,
                                          0);
                                      /* fbar = new Flushbar(
                              flushbarPosition: FlushbarPosition.TOP,
                              message: 'El Kilómetraje, no puede ser superior a los \n1.500km adicionales al último repostaje (' + lastKM.toString() + ' Km)',
                              duration: Duration(seconds: 5),
                            );
                            fbar.show(context);
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              return null;
                            }); */

                                      return 'El Kilómetraje, no puede ser superior a los \n1.500km adicionales al último repostaje (' +
                                          lastKM.toString() +
                                          ' Km)';
                                    }
                                    return null;
                                  },
                                ),
                                Padding(padding: EdgeInsets.only(top: 25.0)),
                                TextFormField(
                                  textDirection: TextDirection.rtl,
                                  controller: priceOnDayController,
                                  //decoration: InputDecoration(labelText: 'Importe total respostado:'),
                                  style: TextStyle(color: Colors.black, fontFamily: 'HeeboSemiBold'),
                                  decoration: InputDecoration(
                                    hintText: "0,000",
                                    labelText: "Importe del combustible al día",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.euro,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ), 
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [maskFormatterPrice],//[FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),], 
                                  onChanged: (value){
                                    
                                    if(litreController.text!="" && value!=""){
                                      priceController.text = (double.parse(value.replaceAll(',', '.')) * double.parse(litreController.text.replaceAll(',', '.'))).toString().replaceAll(".", ",");
                                    }                                    
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Debes indicar el importe",
                                          Colors.red,
                                          0);
                                      return 'Debes indicar el importe';
                                    }
                                    return null;
                                  },
                                ),
                                
                                Padding(padding: EdgeInsets.only(top: 25.0)),
                                TextFormField(
                                  controller: litreController, 
                                  textDirection: TextDirection.rtl,                                 
                                  //decoration: InputDecoration(labelText: '$unidadMedida:',),
                                  style: TextStyle(color: Colors.black, fontFamily: 'HeeboSemiBold'),
                                  decoration: InputDecoration(
                                    hintText: "00,000",
                                    labelText: "$unidadMedida",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.local_drink,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [maskFormatter],//[FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),],                                  
                                  onChanged: (value){
                                    if(priceOnDayController.text!="" && value!=""){
                                      priceController.text = (double.parse(value.replaceAll(',', '.')) * double.parse(priceOnDayController.text.replaceAll(',', '.'))).toString().replaceAll(".", ",");
                                    }                                    
                                  },
                                  
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Debes indicar los $unidadMedida",
                                          Colors.red,
                                          0);
                                      return 'Debes indicar los $unidadMedida';
                                    }
                                    return null;
                                  },
                                ),
                                Padding(padding: EdgeInsets.only(top:25.0)),
                                TextFormField(
                                  controller: priceController,
                                  textDirection: TextDirection.rtl,
                                  //decoration: InputDecoration(labelText: 'Importe total respostado:'),
                                  readOnly: true,
                                  enabled: false,
                                  style: TextStyle(color: Colors.black, fontFamily: 'HeeboSemiBold'),
                                  decoration: InputDecoration(
                                    labelText: "Importe total repostado",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.euro,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),],
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Debes indicar el importe",
                                          Colors.red,
                                          0);
                                      return 'Debes indicar el importe';
                                    }
                                    return null;
                                  },
                                ),
                                
                                Padding(padding: EdgeInsets.only(top:25.0)),
                                TextFormField(
                                  //decoration: InputDecoration(labelText: 'Importe total respostado:'),
                                  style: TextStyle(color: Colors.grey, fontFamily: 'HeeboSemiBold'),
                                  controller: fotoController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Foto del ticket",
                                    contentPadding: const EdgeInsets.all(15.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(70.0)),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.photo,
                                      color: Colors.blue,
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[100],
                                  ),
                                  onTap: (){
                                    print("AQUI FUNCION PARA TOMAR LA FOTO");
                                    getImage();
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Error!",
                                          "Debes colocar una foto del ticket",
                                          Colors.red,
                                          0);
                                      return 'Debes colocar una foto del ticket';
                                    }
                                    return null;
                                  },
                                ),
                                Padding(padding: EdgeInsets.only(top:25.0)),
                                Center(
                                  child: sampleImage == null
                                      ? Text('')
                                      : enableUpload(),
                                ),
                                Padding(padding: EdgeInsets.only(top: 25.0)),
                                ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) { 
                                        //_combustible = dameCombustibleSeleccionado(),                                       
                                        loadRefuel(
                                            _combustible,
                                            kmsController.text,
                                            _carPlateRepostar,
                                            priceController.text,
                                            litreController.text,
                                            DateTime.now().toString(),
                                            _idUser.toString(),
                                            priceOnDayController.text);
                                        prd.show();
                                        Future.delayed(Duration(seconds: 3))
                                            .then((value) {
                                          prd.hide().whenComplete(() {
                                            _dbprovider.deleteRefuelLocal(
                                                _idUser.toString());
                                            _repository.fetchRefuelLocal(
                                                _combustible,
                                                kmsController.text,
                                                litreController.text,
                                                _carPlateRepostar,
                                                priceController.text,
                                                DateTime.now().toString(),
                                                _idUser.toString(),
                                                priceOnDayController.text);
                                            getPlayPause();
                                          });
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF2eac6b),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 50.0,
                                        right: 50.0,
                                        top: 10,
                                        bottom: 10.0),
                                    child: Text(
                                      "Repostar",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'HeeboSemiBold'),
                                    ),
                                  ),),
                                  Padding(padding: EdgeInsets.only(top: 25.0)),
                              ],
                            ),
                          )))))),
        ),);
  }

  Future getImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    var tempImage = File(pickedFile.path);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Widget enableUpload() {
    String fileName = sampleImage.path.split('/').last;
    fotoController.text = fileName.toString();
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width: 300.0),          
        ],
      ),
    );
  }

  Future<List<PlayPauseTracking>> getPlayPause() async {
    List<PlayPauseTracking> retunn = new List<PlayPauseTracking>.empty();
    try {
      List<PlayPauseTracking> list = await _dbprovider.getPlayAndPause();
      if (list != null) {
        for (var i = 0; i < list.length; i++) {
          trackingPlay = list[i].trackingPLay.toString();
          //_idUser = list[i].userId;
        }
        //_repository.fetchLocalData('${numPhoneController.text}','${carPlateController.text}',_idUser,_nombreCompleto,_login);
        _menu.getVerifyDataLocal(_idUser);
        print("EL VALOR DE trackingPlay =" + trackingPlay.toString());
        if (trackingPlay != "0" && trackingPlay != null) {
          final data = PlayPauseTracking(
              trackingPLay: int.parse(trackingPlay),
              userId: _idUser,
              dateBeginning: _dateBeginning);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PTCerrarRuta(
                        data: data,
                        registraControlHora: 0,
                      )));
        }
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PTPrincipal()));
      }

      return list;
    } catch (ex) {
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>PTInicial()));
    }
    return retunn;
  }

  Future<List<Refuel>> getLastRefuel() async {
    String _nameRefuel = "";
    List<Refuel> retunn = new List<Refuel>.empty();
    List<Refuel> list = await _dbprovider.getVerifyRefuel();
    try {
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            lastCarPlate = list[0].plate;
            print("LastCarPLate" + list[0].plate);
            //carPlateController.text = list[0].plate;
            priceController.text = list[0].price;
            litreController.text = list[0].litre;
            priceOnDayController.text = list[0].priceOnDay;
            kmsController.text = list[0].kms;
            lastKM = int.parse(list[0].kms);
            switch (list[0].idTipoCombustible) {
              case "":
                _nameRefuel = "Gasolina 98";
                _combustible= "1";
                break;
              case "1":
                _nameRefuel = "Gasolina 98";
                _combustible= "1";
                break;
              case "2":
                _nameRefuel = "Gasolina 95";
                _combustible= "2";
                break;
              case "3":
                _nameRefuel = "Bioetanol";
                _combustible= "3";
                break;
              case "4":
                _nameRefuel = "Diésel Normal";
                _combustible= "4";
                break;
              case "5":
                _nameRefuel = "Diésel Plus";
                _combustible= "5";
                break;
              case "6":
                _nameRefuel = "Diésel 1D, 2D,4D";
                _combustible= "6";
                break;
              case "7":
                _nameRefuel = "Gas Natural";
                _combustible= "7";
                break;
              case "8":
                _nameRefuel = "Eléctrico (Kw)";
                _combustible= "8";
                break;
              case "9":
                _nameRefuel = "AdBlue";
                _combustible= "9";
                break;
            }
            _selectedLocation = _nameRefuel;
          }
        }
        return list;
      });
    } catch (ex) {}
    return retunn;
  }

  Future<List<WorkingDay>> getWDLocal() async {
    List<WorkingDay> retunn = new List<WorkingDay>.empty();
    try {
      List<WorkingDay> list = await _dbprovider.getWorkingDay();
      setState(() {
        if (list != null) {
          for (var i = 0; i < 1; i++) {
            _dateBeginning = list[0].startingDate.toString();
          }
        }
        return list;
      });
    } catch (ex) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PTPrincipal()));
    }
    return retunn;
  }

  getConfiguracion() async {
    try {
      List<Configuracion> configuracion = await _dbprovider.getConfiguracion();
      //print(configuracion[0].dominio);
      if (configuracion.length > 0) {
        setState(() {
          _dominio = configuracion[0].dominio;
          _semilla = configuracion[0].semilla;
        });
      } else {
        _dominio = null;
        _semilla = null;
      }
    } catch (ex) {
      _dominio = null;
      _semilla = null;
    }
  }

  
}

