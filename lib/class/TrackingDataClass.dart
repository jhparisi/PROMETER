class TrackingData {
  int id;
  String altitude;
  String date;
  String latitude;
  String longitude;
  String userId;

  TrackingData({this.id, this.altitude, this.date,this.latitude,this.longitude,this.userId});

  Map<String, dynamic> toMap() {
    return {
      'altitude': altitude,
      'date': date,
      'latitude' : latitude,
      'longitude' : longitude,
      'userId' : userId
    };
  }

  @override
  String toString() {
    return 'TrackingData{id: $id, altitude: $altitude, date: $date, latitude:$latitude, longitude:$longitude, userId:$userId}';
  }

  TrackingData.fromDb(Map<String, dynamic> parsedJson) :
    altitude = parsedJson["altitude"],
    date = parsedJson["date"],
    userId = parsedJson["userId"],
    latitude = parsedJson["latitude"],
    longitude = parsedJson["longitude"];

}