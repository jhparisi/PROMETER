class ResponseAPICLass{
  String respuesta;

  factory ResponseAPICLass(Map jsonMap, MediaTypeRes mediaType) {
    try {
      return new ResponseAPICLass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  ResponseAPICLass.deserialize(Map json, MediaTypeRes mediaType): 
        respuesta = json["respuesta"];
}

enum MediaTypeRes { content, show }