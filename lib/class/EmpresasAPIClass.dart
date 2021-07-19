class EmpresaAPI {
  String nombre;

  factory EmpresaAPI(
      Map jsonMap, MediaTypeEmpresaAPI mediaType) {
    try {
      return new EmpresaAPI.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  EmpresaAPI.deserialize(
      Map json, MediaTypeEmpresaAPI mediaType)
      : nombre = json["nombre"];
}

enum MediaTypeEmpresaAPI { content, show }