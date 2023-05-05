// To parse this JSON data, do
//
//     final markerModel = markerModelFromMap(jsonString);

import 'dart:convert';

MarkerModel markerModelFromMap(String str) =>
    MarkerModel.fromMap(json.decode(str));

String markerModelToMap(MarkerModel data) => json.encode(data.toMap());

class MarkerModel {
  // Marker modelimiz işaretlediğin yerin bilgileri bu model içerisinde tutuluyor yine çekerken bundan çekiyoruz
  MarkerModel({
    required this.marker,
  });

  final List<Markers> marker;

  factory MarkerModel.fromMap(Map<String, dynamic> json) => MarkerModel(
        marker:
            List<Markers>.from(json["marker"].map((x) => Markers.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "marker": List<dynamic>.from(marker.map((x) => x.toMap())),
      };
}

class Markers {
  Markers({
    required this.ilce,
    required this.lat,
    required this.long,
  });

  final String ilce;
  final double lat;
  final double long;

  factory Markers.fromMap(Map<String, dynamic> json) => Markers(
        ilce: json["ilce"],
        lat: json["lat"].toDouble(),
        long: json["long"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "ilce": ilce,
        "lat": lat,
        "long": long,
      };
}
