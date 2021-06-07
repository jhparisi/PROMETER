import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../class/horarioClass.dart';

typedef OnDelete();

//TextEditingController _textFieldController = TextEditingController();
var maskFormatter =
    new MaskTextInputFormatter(mask: '##:##', filter: {"#": RegExp(r'[0-9]')});
var horaIV = [];
var horaFV = [0];
Color colorFondo = Colors.white;
String textoError = "";
bool mostrarErrorHora = false;

class FormularioHora extends StatefulWidget {
  final HorariosInicioFin horariosInicioFin;
  final state = _FormularioHoraState();
  final OnDelete alBorrar;

  FormularioHora({Key key, this.horariosInicioFin, this.alBorrar})
      : super(key: key);
  @override
  _FormularioHoraState createState() => state;
  bool esValido() => state.validarFormulario();
  bool errorHora() => state.errorHoraVal();
  bool sinError() => state.sinErrorHoraVal();
}

class _FormularioHoraState extends State<FormularioHora> {
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    mostrarErrorHora = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        color: colorFondo,
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                leading: Icon(
                  Icons.check,
                  size: 0.0,
                ),
                toolbarHeight: 28.0,
                title: Text(
                  "Bloque de horas ",
                  style: TextStyle(fontSize: 12.0),
                ),
                //backgroundColor: Colors.white,
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.white,
                      iconSize: 15.0,
                      onPressed: widget.alBorrar),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Container(
                    height: 60,
                    width: 150,
                    child: TextFormField(
                      initialValue: widget.horariosInicioFin.horaInicio,
                      inputFormatters: [maskFormatter],
                      // ignore: missing_return
                      validator: (val) {
                        if (val.length < 5) {
                          return 'Indica la hora de fin';
                        }
                      },
                      onSaved: (val) =>
                          widget.horariosInicioFin.horaInicio = val,
                      decoration: InputDecoration(
                          labelText: 'Hora Inicio', hintText: '08:00'),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Container(
                    height: 60,
                    width: 150,
                    child: TextFormField(
                      initialValue: widget.horariosInicioFin.horaFin,
                      inputFormatters: [maskFormatter],
                      // ignore: missing_return
                      validator: (val) {
                        if (val.length < 5) {
                          return 'Indica la hora de fin';
                        }
                      },
                      onSaved: (val) => widget.horariosInicioFin.horaFin = val,
                      decoration: InputDecoration(
                          labelText: 'Hora Fin', hintText: '17:30'),
                    ),
                  ),
                ],
              ),
              Visibility(
                child: Text(
                  textoError,
                  style: TextStyle(color: Colors.red),
                ),
                visible: mostrarErrorHora,
              ),
              Padding(padding: const EdgeInsets.only(bottom: 10.0)),
              
              ],
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  bool validarFormulario() {
    var valido = form.currentState.validate();
    if (form.currentState.validate()) {
      form.currentState.save();
      return valido;
    }
  }

  bool validarHora() {
    var respuesta = false;
    return respuesta;
  }

  bool errorHoraVal() {
    setState(() {
      mostrarErrorHora = true;
      textoError =
          "Este bloque de horario no es correcto.\nVerifique que las horas no se solapen\no intente ordenar los bloques con el botón [Ordenar]";
    });
    return false;
  }

  bool sinErrorHoraVal() {
    setState(() {
      mostrarErrorHora = false;
      textoError = "";
    });
    return false;
  }
}
