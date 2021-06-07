class ControlHourDateClass {
  int idUsuario;
  String fecha;
  bool modificadoManual;
  String evento;
  String comentario;
  String fechaHora;
  String tiempoTotal;

  factory ControlHourDateClass(
      Map jsonMap, MediaTypeControlHorasDate mediaType) {
    try {
      return new ControlHourDateClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  ControlHourDateClass.deserialize(
      Map json, MediaTypeControlHorasDate mediaType)
      : idUsuario = json["idUsuario"].toInt(),
        fecha = json["fecha"],
        modificadoManual = json["modificadoManual"],
        evento = json["evento"],
        comentario = json["comentario"],
        fechaHora = json["fechaHora"],
        tiempoTotal = json["tiempoTotal"];
}

enum MediaTypeControlHorasDate { content, show }
