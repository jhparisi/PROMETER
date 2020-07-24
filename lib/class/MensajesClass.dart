class Mensajes {
  int id;
  String fecha;
  String titulo;
  String mensaje;
  String url;

  Mensajes({this.id, this.fecha, this.titulo,this.mensaje,this.url});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fecha': fecha,
      'titulo': titulo,
      'mensaje' : mensaje,
      'url' : url
    };
  }

  @override
  String toString() {
    return 'Mensajes{id: $id, fecha: $fecha, titulo: $titulo, mensaje:$mensaje, url:$url}';
  }

  Mensajes.fromDb(Map<String, dynamic> parsedJson) :
    fecha = parsedJson["fecha"],
    titulo = parsedJson["titulo"],
    mensaje = parsedJson["mensaje"],
    url = parsedJson["url"];
}
