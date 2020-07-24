class WorkingDay {
  int id;
  String carPlate;
  String endingDate;
  String kmsBeginning;
  String kmsTheEnd;
  String startingDate;
  String userId;

  WorkingDay({this.id, this.carPlate, this.endingDate,this.kmsBeginning,this.kmsTheEnd,this.startingDate,this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carPlate': carPlate,
      'endingDate': endingDate,
      'kmsBeginning' : kmsBeginning,
      'kmsTheEnd' : kmsTheEnd,
      'startingDate' : startingDate,
      'userId' : userId
    };
  }

  @override
  String toString() {
    return 'WorkingDay{id: $id, carPlate: $carPlate, endingDate: $endingDate, kmsBeginning:$kmsBeginning, kmsTheEnd:$kmsTheEnd, startingDate:$startingDate,userId:$userId}';
  }

  WorkingDay.fromDb(Map<String, dynamic> parsedJson) :
    carPlate = parsedJson["carPlate"],
    endingDate= parsedJson["endingDate"],
    userId = parsedJson["userId"],
    kmsBeginning = parsedJson["kmsBeginning"],
    kmsTheEnd = parsedJson["kmsTheEnd"],
    startingDate = parsedJson["startingDate"]
    ;
}