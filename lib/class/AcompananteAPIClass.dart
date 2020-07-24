class AcompananteAPIClass{
  int idUsuarioPrincipal;
  String nombrePrincipal;
  String matricula;

  factory AcompananteAPIClass(Map jsonMap, MediaTypeAcompanante mediaType) {
    try {
      return new AcompananteAPIClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  AcompananteAPIClass.deserialize(Map json, MediaTypeAcompanante mediaType): 
        idUsuarioPrincipal = json["idUsuarioPrincipal"],
        nombrePrincipal = json["nombrePrincipal"],
        matricula = json["matricula"];
}


enum MediaTypeAcompanante { content, show }