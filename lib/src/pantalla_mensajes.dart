import 'package:eszaworker/class/MensajesChatClass.dart';
import 'package:eszaworker/class/MensajesClass.dart';
import 'package:eszaworker/resources/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/src/pantalla_chat_list.dart';
import 'package:eszaworker/src/pantalla_contactos.dart';
import 'menu.dart';
//import 'menu.dart';

//Menu _menu = new Menu();

DBProvider _dbprovider = DBProvider.get();
MensajesChatClass _mensaChat = new MensajesChatClass();
Menu _menu = new Menu();

class PTMensajes extends StatefulWidget {
  static const String routeName = "/pantalla_mensajes";
  PTMensajes({Key key}) : super(key: key);
  @override
  _PTMensajesState createState() => new _PTMensajesState();
}

class _PTMensajesState extends State<PTMensajes>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Mensajes> _mensaje = new List.empty();

  @override
  void initState() {
    super.initState();
    loadMensajes();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 3);
  }

  void loadMensajes() async {
    await _dbprovider.init();
    var mensajes = await _dbprovider.fethMensajesAll();
    setState(() {
      if(mensajes!= null){
         _mensaje.addAll(mensajes.reversed);
      }     
    });
    _mensaChat.obtenerMensaje(_mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Mensajes", textAlign: TextAlign.center),
        bottom: new TabBar(
          controller: _tabController,
          tabs: <Widget>[
            new Tab(text: "CHATS"),
            new Tab(text: "PROXIMAMENTE"),
            new Tab(
              text: "PROXIMAMENTE",
            )
          ],
        ),
      ),
      drawer: _menu.getDrawer(context),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new PTChatList(),
          new PTChatList(),
          new PTChatList(),
          /* new PTProxima(),
         new PTProxima(), */
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: new Icon(
          Icons.message,
          color: Colors.white,
        ),
        onPressed: () {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) => new PTContactos());
          Navigator.of(context).push(route);
        },
      ),
    );
  }

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mensajes Recibidos", textAlign: TextAlign.center),
      ),
      //drawer: _menu.getDrawer(context),
      body: new Container(
        child: new ListView.builder(
          itemCount: _mensaje.length,
          itemBuilder: (BuildContext context, int index) {
            return new MensajesListItem(_mensaje[index]);
          },
        ),
      )
    );
  } */
}
