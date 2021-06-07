class ControlHourAllClass {
  int idUsuario;
  String fecha;
  bool modificadoManual;

  factory ControlHourAllClass(Map jsonMap, MediaTypeControlHorasAll mediaType) {
    try {
      return new ControlHourAllClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  ControlHourAllClass.deserialize(Map json, MediaTypeControlHorasAll mediaType)
      : idUsuario = json["idUsuario"].toInt(),
        fecha = json["fecha"],
        modificadoManual = json["modificadoManual"];
}

enum MediaTypeControlHorasAll { content, show }
