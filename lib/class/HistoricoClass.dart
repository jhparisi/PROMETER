class Historico {
  int id;
  String fechaUltimoLogin;
  String usuario;
  String matricula;


  Historico({this.id, this.fechaUltimoLogin, this.usuario,this.matricula});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fechaUltimoLogin': fechaUltimoLogin,
      'usuario': usuario,
      'matricula' : matricula,
    };
  }

  @override
  String toString() {
    return 'DataLocal{id: $id, fechaUltimoLogin: $fechaUltimoLogin, usuario: $usuario, matricula:$matricula}';
  }

  Historico.fromDb(Map<String, dynamic> parsedJson) :
    fechaUltimoLogin = parsedJson["fechaUltimoLogin"],
    usuario = parsedJson["usuario"],
    matricula = parsedJson["matricula"];
}
