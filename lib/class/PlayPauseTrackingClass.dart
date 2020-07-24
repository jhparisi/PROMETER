class PlayPauseTracking {
  int id;
  int userId;
  int trackingPLay;
  String dateBeginning;

  PlayPauseTracking({this.id, this.trackingPLay, this.userId, this.dateBeginning});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'trackingPLay': trackingPLay,
      'userId': userId,
      'dateBeginning': dateBeginning
    };
  }

  @override
  String toString() {
    return 'PlayPauseTracking{id: $id, trackingPLay: $trackingPLay, userId:$userId, dateBeginning:$dateBeginning}';
  }

  PlayPauseTracking.fromDb(Map<String, dynamic> parsedJson) :
    userId = parsedJson["userId"],
    trackingPLay = parsedJson["trackingPLay"],
    dateBeginning = parsedJson["dateBeginning"];
}
