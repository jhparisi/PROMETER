import 'package:eszaworker/class/MensajesClass.dart';
import 'package:flutter/material.dart';

class MensajesListItem extends StatelessWidget {
  final Mensajes mensajes;
  MensajesListItem(this.mensajes);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When the child is tapped, show a snackbar
      onTap: () => {
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text(mensajes.titulo),
              content: Text(mensajes.mensaje + "\n" + mensajes.fecha.substring(0,16)),
              actions: <Widget>[
                new FlatButton(
                  child: Text("Cerrar"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        )
      },
      child: new Card(
        child: new Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            new Container(
                child: new Stack(
              children: <Widget>[                  
                new FadeInImage.assetNetwork(
                  placeholder: "assets/logoEzsaMensajes2.jpg",
                  image: "logoEzsaMensajes2.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 100.0,
                  fadeInDuration: new Duration(milliseconds: 40),
                ),
                new Positioned(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.grey[900].withOpacity(0.7),
                    ),
                    constraints: new BoxConstraints.expand(height: 100.0),
                  ),
                ),
                new Positioned(
                  left: 5.0,
                  bottom: 20.0,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        child: new Row( 
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Text(
                              mensajes.titulo,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                            ),
                            new Text(
                              mensajes.fecha.substring(0,16),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12.0),
                            ),                            
                          ]
                        )
                      ),
                      new Container(
                        width: 360.0,
                        height: 60.0,
                        padding: const EdgeInsets.only(top: 4.0),
                        child: new Text(
                          mensajes.mensaje,
                          style: new TextStyle(color: Colors.white, fontSize: 12),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                new Positioned(
                  right: 0.0,
                  bottom: 5.0,
                  child: new Column(
                    children: <Widget>[
                      
                    ],
                  ),
                )
              ],
            )),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
          ],
        ),
      )
    );      
  }
  
}
