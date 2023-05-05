import 'package:firebase_database/firebase_database.dart';

class Requests {
  // burası ilk isteğin modeli
  String id;
  String userId;
  String userName;
  String userPhone;
  String locationEndName;
  String locationStartName;
  String time;
  String driverName;
  String driverId;
  double totalDistanceValue;
  int totalDurationValue;
  double destinationLatitude;
  double destinationLongitude;
  double latitude;
  double longitude;
  int price;
  bool isComplete;
  String state;

  Requests(
    this.id,
    this.userId,
    this.userName,
    this.userPhone,
    this.locationEndName,
    this.locationStartName,
    this.time,
    this.driverName,
    this.driverId,
    this.totalDistanceValue,
    this.totalDurationValue,
    this.destinationLatitude,
    this.destinationLongitude,
    this.latitude,
    this.longitude,
    this.price,
    this.isComplete,
    this.state,
  );
  // isteği databaseden çekme kodu elle çekiyorum genelde ama bunlada çekiliyor
  void fromDatabase(DataSnapshot snapshot) {
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    id = value["id"];
    userName = value["userName"];
    userPhone = value["userPhone"];
    locationEndName = value["locationEndName"];
    locationStartName = value["locationStartName"];
    time = value["time"];
    driverName = value["driverName"];
    driverId = value["driverId"];
    isComplete = value["isComplete"];
    state = value["state"];
    price = value["price"];
    totalDistanceValue = double.parse(value["totalDistanceValue"]);
    totalDurationValue = int.parse(value["totalDurationValue"]);
    destinationLatitude = double.parse(value["destinationLatitude"].toString());
    destinationLongitude =
        double.parse(value["destinationLongitude"].toString());
    latitude = double.parse(value["latitude"].toString());
    longitude = double.parse(value["longitude"].toString());
  }
}
