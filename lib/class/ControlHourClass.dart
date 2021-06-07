class ControlHour {
  String idUsuario;
  String fecha;
  String modificadoManual;
  String evento;
  String comentario;
  String fechaHora;

  ControlHour(
      {this.idUsuario,
      this.fecha,
      this.modificadoManual,
      this.evento,
      this.comentario,
      this.fechaHora});

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'modificadoManual': modificadoManual,
      'evento': evento,
      'comentario': comentario,
      'fechaHora': fechaHora
    };
  }

  @override
  String toString() {
    return 'ControlHour{idUsuario: $idUsuario, fecha: $fecha, modificadoManual: $modificadoManual, evento:$evento, comentario:$comentario, fechaHora:$fechaHora }';
  }

  ControlHour.fromDb(Map<String, dynamic> parsedJson)
      : idUsuario = parsedJson["idUsuario"],
        fecha = parsedJson["fecha"],
        modificadoManual = parsedJson["modificadoManual"],
        evento = parsedJson["evento"],
        comentario = parsedJson["comentario"],
        fechaHora = parsedJson["fechaHora"];
}
