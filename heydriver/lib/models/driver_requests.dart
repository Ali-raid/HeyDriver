class DriverRequest {
  String id;
  String userId;
  String userName;
  String userPhone;
  String locationEndName;
  String locationStartName;
  String time;
  String driverName;
  String driverId;
  double destinationLatitude;
  double destinationLongitude;
  double latitude;
  double longitude;
  int price;
  bool isComplete;
  String state;

  DriverRequest(
    this.id,
    this.userId,
    this.userName,
    this.userPhone,
    this.locationEndName,
    this.locationStartName,
    this.time,
    this.driverName,
    this.driverId,
    this.destinationLatitude,
    this.destinationLongitude,
    this.latitude,
    this.longitude,
    this.price,
    this.isComplete,
    this.state,
  );
}
