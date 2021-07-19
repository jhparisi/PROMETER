import 'dart:async';

import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/class/ControlHourClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/src/pantalla_resumenLT.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/formularioHoras.dart';
import 'package:eszaworker/class/horarioClass.dart';
import 'package:progress_dialog/progress_dialog.dart';
//import 'package:quiver/iterables.dart';
import 'menu.dart';

DBProvider _dbprovider = DBProvider.get();
Menu _menu = new Menu();
bool mostrarCargado = false;
ProgressDialog prd;
var horaIniV = [];
var horaFinV = [0];
var validaI = [];
var validaF = [];
var horaIReplace = "";
var horaI = 0;
var horaFReplace = "";
var horaF = 0;
var horass = HorariosInicioFin();
final comentarioController = TextEditingController();
String _dominio;
String _semilla;

// ignore: must_be_immutable
class MultiForm extends StatefulWidget {
  String idUsuario = "";
  String fecha = "";

  @override
  MultiForm({Key key, this.idUsuario, this.fecha}) : super(key: key);
  _MultiFormState createState() => _MultiFormState();
}

class _MultiFormState extends State<MultiForm>
    with SingleTickerProviderStateMixin {
  //List<HorariosInicioFin> horasInicioFin = [];
  Animation<double> _animation;
  AnimationController _animationController;
  List<FormularioHora> formularios = [];

  @override
  void initState() {
    getConfiguracion();
    
    super.initState();
    agregarFormularioLectura(widget.idUsuario, widget.fecha);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    var fec = widget.fecha.split("-");
    String fechaFormateadaES =
        fec[2].split(" ")[0] + "-" + fec[1] + "-" + fec[0];

    return Scaffold(
        drawer: _menu.getDrawer(context),
        appBar: AppBar(
          title: Text('Día: ' + fechaFormateadaES, style: TextStyle(fontFamily: 'HeeboSemiBold'),),
          actions: [
            TextButton(
                onPressed: guardarHoras,                
                //textColor: Colors.white,
                style: TextButton.styleFrom(primary: Colors.white),
                child: Column(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Icon(
                      Icons.backup,
                      size: 20.0,
                    ),
                    Text("Guardar")
                  ],
                ))
          ],
        ),
        body: formularios.length <= 0
            ? Center(
                child: Text('Agregar bloque de horas presionando el botón (+)'),
              )
            : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: <Widget>[
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    addAutomaticKeepAlives: true,
                    itemCount: formularios.length,
                    itemBuilder: (_, i) => formularios[i],
                  ),
                  Container(
                    height: 100,
                    width: 520,
                    child: TextFormField(
                      controller: comentarioController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      maxLength: 500,
                      /* decoration: new InputDecoration(
                        border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)
                        ),
                        labelText: 'Comentario',
                      ),  */ 
                      style: TextStyle(color: Colors.black, fontFamily: 'HeebooSemiBold'),
                      decoration: InputDecoration(
                        labelText: 'Comentario',
                        contentPadding: const EdgeInsets.all(15.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(50.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(50.0)),
                            borderSide: BorderSide.none),
                        prefixIcon: Icon(
                          Icons.message,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.blue[100]
                      )                    
                    )                
                  ),
                ]
              ),
            ),
             /* ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: formularios.length,
                itemBuilder: (_, i) => formularios[i],
              ), */
        floatingActionButton: FloatingActionBubble(
            // Menu items
            items: <Bubble>[
              // Floating action menu item
              Bubble(
                title: "Agregar Hora",
                iconColor: Colors.white,
                bubbleColor: Colors.green,
                icon: Icons.plus_one_outlined,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  agregarFormulario();
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Guardar",
                iconColor: Colors.white,
                bubbleColor: Colors.blue,
                icon: Icons.backup,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  guardarHoras();
                  _animationController.reverse();
                },
              ),
              // Floating action menu item
              Bubble(
                title: "Ordenar",
                iconColor: Colors.white,
                bubbleColor: Colors.blue,
                icon: Icons.repeat,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                onPress: () {
                  reordenarFormularios();
                  _animationController.reverse();
                },
              ),
              //Floating action menu item
            ],

            // animation controller
            animation: _animation,

            // On pressed change animation state
            onPress: _animationController.isCompleted
                ? _animationController.reverse
                : _animationController.forward,

            // Floating Action button Icon color
            iconColor: Colors.blue,

            // Flaoting Action button Icon
            icon: AnimatedIcons.add_event));
  }

  void eliminarFormulario(HorariosInicioFin horass) {
    setState(() {
      var buscar = formularios.firstWhere(
        (it) => it.horariosInicioFin == horass,
        orElse: () => null,
      );

      if (buscar != null) {
        formularios.removeAt(formularios.indexOf(buscar));
      }
    });
  }

  void agregarFormulario() {
    setState(() {
      var horasss = HorariosInicioFin();
      formularios.add(FormularioHora(
        key: GlobalKey(),
        horariosInicioFin: horasss,
        alBorrar: () => eliminarFormulario(horasss),
      ));
      //horasInicioFin.add(HorariosInicioFin());
    });
  }

  void agregarFormularioLectura(String idUsuario, String fecha) async {
    formularios.clear();
    var horaIni = [];
    var horaFin = [];
    await _dbprovider.init();
    print("DOMINIO: $_dominio");
    var data = await HttpHandler().fetchControlHorasFecha(idUsuario, fecha, _dominio, _semilla);
    if (data != null) {
      for (var item in data) {
        if (item.evento == "Inicio" && item.modificadoManual == true) {
          horaIni.add(item.fechaHora.split('T')[1].substring(0, 5));
        } else if (item.evento == "Fin" && item.modificadoManual == true) {
          horaFin.add(item.fechaHora.split('T')[1].substring(0, 5));
        }
      }
    }
    print(data);
    setState(() {
      if (horaFin != null) {
        for (var v = 0; v < horaIni.length; v++) {
          List<HorariosInicioFin> _listaHora = [];
          HorariosInicioFin horassIF =
              new HorariosInicioFin(horaFin: null, horaInicio: null);
          horassIF.horaInicio = horaIni[v];
          horassIF.horaFin = horaFin[v];
          _listaHora.add(horassIF);
          print(_listaHora[0].horaInicio);
          for (int i = 0; i < _listaHora.length; i++) {
            formularios.add(FormularioHora(
              key: GlobalKey(),
              horariosInicioFin: _listaHora[i],
              alBorrar: () => eliminarFormulario(_listaHora[i]),
            ));
          }
        }
      }
    });
  }

  void guardarHoras() {
    validaI.clear();
    validaF.clear();
    horaIV.clear();
    horaFV.clear();
    validaF.add(1);
    horaFV.add(0);
    var comentario = "Registro manual";
    if(comentarioController.text !=""){
      comentario = comentarioController.text;
    }
    if (formularios.length > 0) {
      print("ENTRA");
      var todoValidado = true;
      formularios
          .forEach((form) => todoValidado = todoValidado && form.esValido());
      if (todoValidado) {
        var data = formularios.map((e) => e.horariosInicioFin).toList();

        for (var item in data) {
          horaIReplace = item.horaInicio.replaceAll(":", "");
          horaI = int.parse(horaIReplace);
          horaIV.add(horaI);
          horaFReplace = item.horaFin.replaceAll(":", "");
          horaF = int.parse(horaFReplace);
          horaFV.add(horaF);
        }
        //VALIDACION DE HORAS
        var tamanioIni = horaIV.length;
        var tamanioFin = horaFV.length;
        for (var i = 0; i < tamanioIni; i++) {
          if (horaIV[i] > horaFV[i]) {
            validaI.add(1);
          } else {
            validaI.add(0);
          }
        }
        for (var i = 1; i < tamanioFin; i++) {
          if (horaFV[i] > horaIV[i - 1] && horaFV[i] > horaFV[i - 1]) {
            validaF.add(1);
          } else {
            validaF.add(0);
          }
        }
        if (validaI.indexOf(0) == -1 && validaF.indexOf(0) == -1) {
          postControlHourEliminar(widget.idUsuario, widget.fecha, "1");
          for (var item in data) {
            var fechaHoraInicio = widget.fecha + " " + item.horaInicio;
            var fechaHoraFin = widget.fecha + " " + item.horaFin;
            Timer(Duration(milliseconds: 500), () {
              postControlHour(widget.idUsuario, widget.fecha, "1", "Inicio",
                  comentario, fechaHoraInicio);
              postControlHour(widget.idUsuario, widget.fecha, "1", "Fin",
                  comentario, fechaHoraFin);
            });
          }
          mostrarMensaje("Guardando las horas indicadas.");

          Timer(Duration(seconds: 3), () {
            prd.hide();
            final data = ControlHour(
                idUsuario: widget.idUsuario,
                fecha: widget.fecha,
                modificadoManual: "");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PTResumenLT(data: data)));
          });
        } else {
          print("SI HAY CEROS ");
          print(formularios[validaI.indexOf(0)].errorHora());
        }
        //FIN VALIDACION DE HORAS
        print(horaIV);
        print(horaFV);
      }
    }
  }

  void reordenarFormularios() {
    var comentario = "Registro manual";
    if(comentarioController.text !=""){
      comentario = comentarioController.text;
    }
    if (formularios.length > 0) {
      var todoValidado = true;
      formularios
          .forEach((form) => todoValidado = todoValidado && form.esValido());
      if (todoValidado) {
        postControlHourEliminar(widget.idUsuario, widget.fecha, "1");
        var data = formularios.map((e) => e.horariosInicioFin).toList();
        for (var item in data) {
          var fechaHoraInicio = widget.fecha + " " + item.horaInicio;
          var fechaHoraFin = widget.fecha + " " + item.horaFin;
          Timer(Duration(milliseconds: 500), () {
            postControlHour(widget.idUsuario, widget.fecha, "1", "Inicio",
                comentario, fechaHoraInicio);
            postControlHour(widget.idUsuario, widget.fecha, "1", "Fin",
                comentario, fechaHoraFin);
          });
        }
        //print(formularios.length);
        formularios.removeRange(0, formularios.length);

        mostrarMensaje("Ordenando bloques de horas.");
        Timer(Duration(seconds: 3), () {
          agregarFormularioLectura(widget.idUsuario, widget.fecha);
          prd.hide();
        });
      }
    }
  }

  Future<bool> postControlHour(
      idUsuario, fecha, modificadoManual, evento, comentario, hora) async {
    var respuesta = false;
    var control = await HttpHandler().postControlHour(
        idUsuario, fecha, modificadoManual, evento, comentario, hora, _dominio, _semilla);
    if (control == "OK") {
      respuesta = true;
    }
    return respuesta;
  }

  Future postControlHourEliminar(idUsuario, fecha, modificadoManual) async {
    var respuesta = "";
    var control = await HttpHandler()
        .postControlHourEliminar(idUsuario, fecha, modificadoManual, _dominio, _semilla);
    if (control == "OK") {
      respuesta = "OK";
    }
    return respuesta;
  }

  mostrarMensaje(String _mensaje) {
    prd = new ProgressDialog(context);
    prd.style(
        message: _mensaje,
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
    prd.show();
  }

  getConfiguracion() async {     
    try {
      //await _dbprovider.init();
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
