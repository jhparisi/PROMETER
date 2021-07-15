import 'package:eszaworker/class/ConfiguracionClass.dart';
import 'package:eszaworker/resources/HttpHandler.dart';
import 'package:eszaworker/resources/repository.dart';
import 'package:eszaworker/src/pantalla_inicial.dart';
import 'package:flutter/material.dart';

String _selectedEmpresa;
List<String> _listEmpresas = ["ezsa.erp.avanzadi.com","GoGroup","alexpress"];
Repository _repository = Repository.get();

class PTConfiguracion extends StatefulWidget {
  static const String routeName = "/pantalla_configuracion";
  PTConfiguracion({Key key}) : super(key: key);
  _PTConfiguracionState createState() => _PTConfiguracionState();
}

class _PTConfiguracionState extends State<PTConfiguracion> {
  
   @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: 
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF73AEF5),
                Color(0xFF61A4F1),
                Color(0xFF478DE0),
                Color(0xFF398AE5)
              ],
              stops: [
                0.1,
                0.4,
                0.7,
                0.9
              ]
            )
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 0.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                    ),
                    Image.asset(
                      'logoPrometer2.png',
                      width: 180,
                      height: 180,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: SizedBox(
                        width: 350,
                        height: 450,
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0, bottom: 25.0),
                          child: Column(
                            children: [
                              Text(
                                "Configuración",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.blue[400],
                                    fontFamily: 'HeeboSemiBold'),
                              ),
                              Padding(padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0, bottom: 25.0)),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: 'Empresa',
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
                                    Icons.car_repair,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue[100],
                                ),
                                isExpanded: true,
                                value: _selectedEmpresa,                                  
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedEmpresa = newValue;
                                  });
                                },
                                items: _listEmpresas.map((_empresa) {
                                  return DropdownMenuItem(
                                    child: new Text(_empresa),
                                    value: _empresa,
                                  );
                                }).toList(),
                              ),
                              Padding(padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0, bottom: 25.0)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF2eac6b),
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(left: 50.0, right: 50.0, top:10, bottom: 10.0),
                                  child: Text(
                                    "Guardar",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'HeeboSemiBold'),
                                  ),
                                ),
                                onPressed: () {
                                  print("_selectedEmpresa = " +_selectedEmpresa);
                                  if(_selectedEmpresa!=null){
                                    guardarConfiguracion(_selectedEmpresa);                                    
                                  }                                  
                                }
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Text(
                      "Desarrollado por EZSA Sanidad Ambiental",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontFamily: 'HeeboSemiBold'),
                    ),
              /* Text(
                "Versión: B" +
                    versionDB.toString() +
                    ".0.0 - A" +
                    versionApp.toString(),
                style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                    fontFamily: 'HeeboSemiBold'),
              ), */
              
            ],
          ),
        ),
      )),
    ));
  }

  void guardarConfiguracion (String empresa) async{
    List<ConfiguracionAPI> config = new List<ConfiguracionAPI>.empty();
    try{
      config = await HttpHandler().fetchConfiguracionAPI(empresa);
      if(config.length>0){
        //print(config[0].dominio+"***"+config[0].semilla);
        _repository.fetchConfiguracion(empresa,config[0].dominio,config[0].semilla);
        if(config[0].dominio!=""){
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => PTInicial())
          ); 
        }
      }
    }
    catch(Ex){
      print(Ex);
    }
    
  }
}