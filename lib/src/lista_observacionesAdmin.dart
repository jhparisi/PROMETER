import 'package:eszaworker/class/HojaControlHorasAppClass.dart';
import 'package:eszaworker/class/horarioClass.dart';
import 'package:flutter/material.dart';


class ListaObsAdmin extends StatelessWidget{
  final HojaControlHorasAppClass hCH;
  ListaObsAdmin(this.hCH);

  @override   
  Widget build(BuildContext context) {
    return Card(
            child: Padding(
              padding: EdgeInsets.all(0),
              child: 
                ExpansionTile( 
                  onExpansionChanged: (value) {
                    if(value==true){
                      crearTablaTramos(hCH.tramos);
                    }
                  },                 
                  title: Text(hCH.fecha.substring(0,10), style: TextStyle(color: Colors.lightBlue, fontSize: 20, fontWeight: FontWeight.bold,fontFamily: 'HeeboSemiBold'), textAlign: TextAlign.center,),
                  children: [                    
                    crearTablaTramos(hCH.tramos),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                        child: Text("OBSERVACIONES:", style: TextStyle(fontSize: 14,fontFamily: 'HeeboSemiBold'), textAlign: TextAlign.left,)
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                        child: Text(hCH.observacionAdministrador, style: TextStyle(fontSize: 14), textAlign: TextAlign.left,)
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top:10)),
                    Row(
                      children: [
                        Expanded(
                          flex: 3, // 20%
                          child: 
                            Align(
                              alignment: Alignment.center ,
                              child: estadoObservacion(hCH.estado)
                            ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(15)),
                  ],
                ),
            ),
          );
  }
}

@override
estadoObservacion(int estado){
  Color color = Colors.lightBlue;
  Color colorBorde = Colors.lightBlue[600];
  String nombreEstado = "PENDIENTE DE REVISION";

  if(estado==1){
    color = Colors.lightGreen;
    colorBorde = Colors.lightGreen[800];
    nombreEstado = "APROBADO";
  }
  else if(estado==3){
    color = Colors.red;
    colorBorde = Colors.red[800];
    nombreEstado = "RECHAZADO";
  }
  return 
    new Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: colorBorde, width: 2.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: 
          Text(nombreEstado, style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'HeeboSemiBold' ))
      )
    );
}

@override 
crearTablaTramos(String tramos){
  tramos = tramos.substring(0,tramos.length-1);
  List<HorariosInicioFinTotal> listaTramo =[]; 
  var totalTramos =""; 
  var hor =0;
  var min =0;
  var seg =0;
  var tramo = tramos.split(";");
  for(var i=0; i<tramo.length; i++){
    var tramoSplit = tramo[i].split("*");
    var horaInicio = tramoSplit[0].split("T")[1].split(".")[0];
    var horaFin = tramoSplit[1].split("T")[1].split(".")[0];
    var total = tramoSplit[2];

    hor += int.parse(total.split(":")[0]);
    min += int.parse(total.split(":")[1]);
    seg += int.parse(total.split(":")[2]);
    listaTramo.add(HorariosInicioFinTotal(horaInicio: horaInicio, horaFin: horaFin, total: total));
  }
  String segundosString = (seg % 60).toString().padLeft(2, '0');
  int segundoResi = seg ~/ 60;
  min += segundoResi;
  String minutosString = (min % 60).toString().padLeft(2, '0');
  int minutoResi = min ~/ 60;
  hor += minutoResi;
  totalTramos = hor.toString() + ":" + minutosString + ":" + segundosString;
  listaTramo.add(HorariosInicioFinTotal(horaInicio: "", horaFin: "TOTAL:", total: totalTramos));
  return DataTable(
    columns: [
      DataColumn(
        label: Text("Hora Inicio"),
        numeric: false,
      ),
      DataColumn(
        label: Text("Hora Fin"),
        numeric: false,
      ),
      DataColumn(
        label: Text("Total horas tramo"),
        numeric: false,
      ),
    ],
    rows: listaTramo.map((e) => 
      DataRow(
        cells: [
          DataCell(
            Text(e.horaInicio, style: TextStyle(color: Colors.grey[600], fontFamily:'HeeboSemiBold'))
          ),
          DataCell(
            Text(e.horaFin, style: TextStyle(color: Colors.grey[600], fontFamily: 'HeeboSemiBold'))
          ),
          DataCell(
            Text(e.total, style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontFamily: 'HeeboSemiBold'),)
          )
        ]
      )
    ).toList(),
    
  );
}
