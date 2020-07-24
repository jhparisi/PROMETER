class DataLocal {
  int id;
  String carPlate;
  String date;
  int userId;
  String numPhone;
  String nombreCompleto;
  String login;
  String dni;
  int acompanante;

  DataLocal({this.id, this.carPlate, this.date,this.userId,this.numPhone,this.login,this.nombreCompleto, this.dni, this.acompanante});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'carPlate': carPlate,
      'date': date,
      'userId' : userId,
      'numPhone' : numPhone,
      'nombreCompleto' : nombreCompleto,
      'login' : login,
      "dni" : dni,
      "acompanante" : acompanante
    };
  }

  @override
  String toString() {
    return 'DataLocal{id: $id, carPlate: $carPlate, date: $date, userId:$userId, numPhone:$numPhone, nombreCompleto:$nombreCompleto,login:$login,dni:$dni, acompanante:$acompanante}';
  }

  DataLocal.fromDb(Map<String, dynamic> parsedJson) :
    carPlate = parsedJson["carPlate"],
    date = parsedJson["date"],
    userId = parsedJson["userId"].toInt(),
    numPhone = parsedJson["numPhone"],
    nombreCompleto = parsedJson["nombreCompleto"],
    login = parsedJson["login"],
    dni = parsedJson["dni"],
    acompanante = parsedJson["acompanante"];
}
