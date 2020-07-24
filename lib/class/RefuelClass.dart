class Refuel {
  String idTipoCombustible;
  String kms;
  String plate;
  String price;
  String litre;
  String refuelDate;
  String userId;

  Refuel({this.idTipoCombustible, this.kms, this.plate,this.price,this.litre,this.refuelDate,this.userId});

  Map<String, dynamic> toMap() {
    return {
      'idTipoCombustible': idTipoCombustible,
      'kms': kms,
      'plate': plate,
      'price' : price,
      'litre' : litre,
      'refuelDate' : refuelDate,
      'userId' : userId
    };
  }

  @override
  String toString() {
    return 'Refuel{idTipoCombustible: $idTipoCombustible, kms: $kms, plate: $plate, price:$price, litre:$litre refuelDate:$refuelDate, userId:$userId}';
  }

  Refuel.fromDb(Map<String, dynamic> parsedJson) :
    idTipoCombustible = parsedJson["idTipoCombustible"],
    kms = parsedJson["kms"],
    plate = parsedJson["plate"],
    price = parsedJson["price"],
    litre = parsedJson["litre"],
    refuelDate = parsedJson["refuelDate"],
    userId = parsedJson["userId"];
}
