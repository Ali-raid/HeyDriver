// ignore_for_file: non_constant_identifier_names
// lokasyonları search ederken kullandığımız model bu mesela istanbul şişli yazıyorsun arama sonuçları bu modelde
// dönüt veriyor sana
class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? secondary_text;

  PredictedPlaces({
    this.place_id,
    this.main_text,
    this.secondary_text,
  });

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    place_id = jsonData["place_id"];
    main_text = jsonData["structured_formatting"]["main_text"];
    secondary_text = jsonData["structured_formatting"]["secondary_text"];
  }
}
