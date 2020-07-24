class MatriculasApiClass{
  String matricula;
  String tipo;

  factory MatriculasApiClass(Map jsonMap, MediaTypeMatricula mediaType) {
    try {
      return new MatriculasApiClass.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  MatriculasApiClass.deserialize(Map json, MediaTypeMatricula mediaType): 
        matricula = json["matricula"],
        tipo = json["tipo"];
}


enum MediaTypeMatricula { content, show }