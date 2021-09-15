class Refuel {
  String idTipoCombustible;
  String kms;
  String plate;
  String price;
  String litre;
  String refuelDate;
  String userId;
  String priceOnDay;

  Refuel({this.idTipoCombustible, this.kms, this.plate,this.price,this.litre,this.refuelDate,this.userId,this.priceOnDay});

  Map<String, dynamic> toMap() {
    return {
      'idTipoCombustible': idTipoCombustible,
      'kms': kms,
      'plate': plate,
      'price' : price,
      'litre' : litre,
      'refuelDate' : refuelDate,
      'userId' : userId,
      'priceOnDay' : priceOnDay
    };
  }

  @override
  String toString() {
    return 'Refuel{idTipoCombustible: $idTipoCombustible, kms: $kms, plate: $plate, price:$price, litre:$litre refuelDate:$refuelDate, userId:$userId, priceOnDay:$priceOnDay}';
  }

  Refuel.fromDb(Map<String, dynamic> parsedJson) :
    idTipoCombustible = parsedJson["idTipoCombustible"],
    kms = parsedJson["kms"],
    plate = parsedJson["plate"],
    price = parsedJson["price"],
    litre = parsedJson["litre"],
    refuelDate = parsedJson["refuelDate"],
    userId = parsedJson["userId"],
    priceOnDay = parsedJson["priceOnDay"];
}
