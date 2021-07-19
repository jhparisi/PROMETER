import 'package:eszaworker/resources/db_provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;
DBProvider _dbprovider = DBProvider.get();

void mostrarFlushBar(BuildContext context, String mensaje){
  print(mensaje);
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: Colors.red,
    message: mensaje,
    duration: Duration(seconds: 5),
    icon: Icon(
      Icons.report,
      size: 28,
      color: Colors.white,
    ),
  )..show(context);  
}

void mostrarProgressDialog(BuildContext context, String mensaje){
  pr = new ProgressDialog(context);
  pr.style(
      message: mensaje,
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
  pr.show();
}

void ocultarProgressDialog(){
  pr.hide();
}

void ocultarProgressDialogAlCompletar(BuildContext context, Widget paginaNavegacion){
  pr.hide().whenComplete(() {                                            
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                paginaNavegacion));
  });
}
