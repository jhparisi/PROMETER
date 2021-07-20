class UserByPhoneAPIClass{
  int idUsuario;
  String nombre;
  String apellido1;
  String apellido2;
  String login;
  String telefono;
  String telefono2;
  String dni;

  factory UserByPhoneAPIClass(Map jsonMap, MediaType mediaType) {
    try {
      return new UserByPhoneAPIClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  UserByPhoneAPIClass.deserialize(Map json, MediaType mediaType): 
        idUsuario = json["idUsuario"],
        nombre = json["nombre"],
        apellido1 = json["apellido1"],
        apellido2 = json["apellido2"],
        login = json["login"],
        telefono = json["telefono"],
        telefono2 = json["telefono2"],
        dni = json["dni"];
}


enum MediaType { content, show }


class FotoUsuarioClass{
  String foto;

  factory FotoUsuarioClass(Map jsonMap, MediaTypeFotoUsuario mediaType) {
    try {
      return new FotoUsuarioClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  FotoUsuarioClass.deserialize(Map json, MediaTypeFotoUsuario mediaType): 
        foto = json["foto"];
}


enum MediaTypeFotoUsuario { content, show }