//import 'dart:async';
import 'package:eszaworker/class/ControlHourClass.dart';
//import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/src/menu.dart';
//import 'package:eszaworker/src/panatalla_controlhoras.dart';
//import 'package:eszaworker/src/pantalla_principal.dart';
//import 'package:eszaworker/src/pantalla_resumenLT.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'multiform.dart';

ProgressDialog prd;
Menu _menu = new Menu();
final fechaInicio = new DateTime.now();
bool hIValidado = true;
bool hFValidado = true;
var horaI = "";
var horaF = ["00:00"];
var maskFormatter =
    new MaskTextInputFormatter(mask: '##:##', filter: {"#": RegExp(r'[0-9]')});

Flushbar fbar = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message:
      " La hora de inicio no puede ser menor\n o igual que la hora final anterior!",
  duration: Duration(seconds: 5),
);

Flushbar fbarFin = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message: " La hora de fin no puede ser menor\n o igual que la hora inicial!",
  duration: Duration(seconds: 5),
);

Flushbar fbarFormulario = new Flushbar(
  flushbarPosition: FlushbarPosition.TOP,
  backgroundColor: Colors.red,
  message:
      " Error al guardar el control de horas.\n Por favor, verifique las horas esten en el rango permitido.\n Las horas de inicio no pueden ser menores o igual que la hora final anterior",
  duration: Duration(seconds: 5),
);

class PTEditarHoras extends StatefulWidget {
  final ControlHour data;
  static const String routeName = "/pantalla_editarhoras";
  PTEditarHoras({Key key, this.data}) : super(key: key);
  _PTEditarHorasState createState() => _PTEditarHorasState();
}

class _PTEditarHorasState extends State<PTEditarHoras> {
  int idUserr = 0;
  //final _formKey = GlobalKey<FormState>();
  TextEditingController _horaInicialController;
  TextEditingController _horaFinalController;
  //static List<String> hILista = [null];
  //static List<String> hFLista = [null];

  @override
  initState() {
    super.initState();
    idUserr = int.parse(widget.data.idUsuario);
    _horaInicialController = TextEditingController();
    _horaFinalController = TextEditingController();
  }

  @override
  void dispose() {
    _horaInicialController.dispose();
    _horaFinalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400));

    return Scaffold(
        drawer: _menu.getDrawer(context),
        body: MultiForm(
            idUsuario: widget.data.idUsuario,
            fecha: widget.data.fecha.substring(0, 10)));
  }
}
