import 'package:eszaworker/resources/db_provider.dart';
import 'package:eszaworker/utilities/funciones_generales.dart';
import 'package:flutter/material.dart';
import 'package:eszaworker/class/MensajesChatClass.dart';

DBProvider _dbprovider = DBProvider.get();

class PTChatInterno extends StatefulWidget {
  final String name;
  PTChatInterno({this.name});
  @override
  _PTChatInternoState createState() => new _PTChatInternoState();
}

class _PTChatInternoState extends State<PTChatInterno>
    with TickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isTyped = false;

  void _listadoMensaje() async {
    //await _dbprovider.init();
    inicializarBDLocal();
    var mensajes = await _dbprovider.fethMensajesAll();
    if(mensajes!=null){
      mensajes.reversed.forEach((element) {
        _handledSubmit(element.mensaje.replaceAll("\n", " "),
            element.fecha.substring(5, 16));
      });
    }
    
  }

  void _handledSubmit(String text, String tiempo) {
    _textController.clear();
    setState(() {
      _isTyped = false;
    });
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
          duration: new Duration(milliseconds: 700), vsync: this),
      name: widget.name,
      tiempo: tiempo,
    );

    setState(() {
      _messages.insert(0, message);
      var data = messageData.firstWhere((t) => t.name == widget.name);
      data.message = message.text;
    });
    message.animationController.forward();
    print(text);
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Colors.white),
        child: new Container(
          child: new Row(children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isTyped = text.length > 0;
                  });
                },
                decoration:
                    new InputDecoration.collapsed(hintText: "Enviar mensaje"),
              ),
            ),
            new Container(
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isTyped
                    ? () => _handledSubmit(
                        _textController.text, DateTime.now().toString())
                    : null,
              ),
            )
          ]),
        ));
  }

  @override
  void initState() {
    super.initState();
    _listadoMensaje();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.name),
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController, this.name, this.tiempo});
  final String text;
  final String tiempo;
  final AnimationController animationController;
  final String name;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      child: Card(
        child: ListTile(
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                name,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.blue),
              ),
              new Text(
                tiempo,
                style: new TextStyle(color: Colors.grey, fontSize: 10.0),
              )
            ],
          ),
          subtitle: new Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              text,
              style: new TextStyle(color: Colors.black87, fontSize: 15.0),
            ),
          ),
        ),
      ),
      /* child: new Container(
     margin: const EdgeInsets.symmetric(vertical:10.0),
     child: new Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         /* new Container(
          margin: const EdgeInsets.only(right: 16.0),  
           child: new CircleAvatar(child: new Text(name[0]))
         ), */
         new Expanded(
           child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              )
             ],
           ),
         )
       ],
     ),
   ), */
    );
  }
}
