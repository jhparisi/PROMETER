import 'package:flutter/material.dart';
import 'package:eszaworker/class/MensajesChatClass.dart';
import 'package:eszaworker/src/pantalla_chat_interno.dart';

class PTChatList extends StatefulWidget {
  @override
  _PTChatListState createState() => new _PTChatListState();
 }
class _PTChatListState extends State<PTChatList> {
  @override
  Widget build(BuildContext context) {
   return new ListView.builder(
     itemCount: messageData.length,
     itemBuilder: (context, i) => new Column(
       children: <Widget>[
         new Divider(
           height: 10.0,
         ),
         new ListTile(
           leading: new CircleAvatar(
             backgroundImage: AssetImage('assets/miniLogo.jpg',),
             //backgroundImage: NetworkImage(messageData[i].imageUrl),
             ),
           title: new Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
             new Text(
              messageData[i].name,
              style: new TextStyle(fontWeight: FontWeight.bold),
             ),
             new Text(
               messageData[i].time,
               style: new TextStyle(color: Colors.grey, fontSize: 14.0),
             )
           ], 
         ),
         subtitle: new Container(
           padding: const EdgeInsets.only(top: 5.0),
           child: new Text(
             messageData[i].message,
             style: new TextStyle(color: Colors.grey, fontSize: 15.0),
           ),
         ),
         onTap: (){
           var route = new MaterialPageRoute(
             builder: (BuildContext context) => new PTChatInterno(name: messageData[i].name,)
           );
           Navigator.of(context).push(route);
         },
     ),
    ]
   )
   );
  }
}