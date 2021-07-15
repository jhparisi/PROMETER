class Configuracion {
  String empresa;
  String dominio;
  String semilla;


  Configuracion({this.dominio, this.empresa,this.semilla});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'empresa': empresa,
      'dominio': dominio,
      'semilla' : semilla,
    };
  }

  @override
  String toString() {
    return 'Configuracion{empresa: $empresa, dominio: $dominio, semilla:$semilla}';
  }

  Configuracion.fromDb(Map<String, dynamic> parsedJson) :
    empresa = parsedJson["empresa"],
    dominio = parsedJson["dominio"],
    semilla = parsedJson["semilla"];
}


class ConfiguracionAPI {
  String dominio;
  String semilla;

  factory ConfiguracionAPI(
      Map jsonMap, MediaTypeConfiguracionAPI mediaType) {
    try {
      return new ConfiguracionAPI.deserialize(jsonMap, mediaType);
    } catch (ex) {
      throw ex;
    }
  }

  ConfiguracionAPI.deserialize(
      Map json, MediaTypeConfiguracionAPI mediaType)
      : dominio = json["dominio"],
        semilla = json["semilla"];
}

enum MediaTypeConfiguracionAPI { content, show }

