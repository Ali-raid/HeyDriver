import 'dart:ui' as ui;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heydriver/asistants/request_assistant.dart';
import 'package:heydriver/global.dart';
import 'package:heydriver/helper/app_info.dart';
import 'package:heydriver/models/direction_details_info.dart';
import 'package:heydriver/models/directions_model.dart';
import 'package:heydriver/models/user_model.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    // apiyi buraya veriyoruz addres çekmekte kullanıcaz
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAvm9A0g-b9ytVu6YCFKcBnwZ6NlnCXQtY";

    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      print(requestResponse);
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      //burda kendi adresimizi alıyoruz
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    //kullanıcının bilgilerini alıyoruz firebaseden aynı androiddeki gibi
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
    });
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&language=tr&key=AIzaSyAvm9A0g-b9ytVu6YCFKcBnwZ6NlnCXQtY";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    //Urlin bağlı olduğu apiye istek atıyoruz ve cevabı alıyoruz
    //cevabı decode ediyoruz
    //cevabı modelimize atıyoruz
    //cevabı return ediyoruz
    //origin ile destination araındaki bilgileri alyırouz oraya yol çizerken ve ekranda gösterirken kullanıcaz
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  // declared method to get Images
  static Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
