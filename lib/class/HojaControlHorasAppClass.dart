class HojaControlHorasAppClass {
  String fecha;
  String observacionAdministrador;
  String horasARealizarSeg;
  String horasTrabajadasSeg;
  String horasExtrasSeg;
  int estado;
  String tramos;

  factory HojaControlHorasAppClass(
      Map jsonMap, MediaTypeHojaControlHorasDate mediaType) {
    try {
      return new HojaControlHorasAppClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  HojaControlHorasAppClass.deserialize(
      Map json, MediaTypeHojaControlHorasDate mediaType)
      : fecha = json["fecha"],
        observacionAdministrador = json["observacionAdministrador"],
        horasARealizarSeg = json["horasARealizarSeg"],
        horasTrabajadasSeg = json["horasTrabajadasSeg"],
        horasExtrasSeg = json["horasExtrasSeg"],
        estado = json["estado"].toInt();
}

enum MediaTypeHojaControlHorasDate { content, show }
