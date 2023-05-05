class Driver {
  // sürücü modelimiz sürücünün bilgilerini tutuyor her zaman bunu kullanmıyorum
  // ekrana sürücülerin lokasyonlarını yerleştirirken kullanıyorum
  String? id;
  String? fullName;
  String? emailAddress;
  String? locationLatitude;
  String? locationLongitude;
  String? image;
  String? status;

  Driver(
    this.id,
    this.fullName,
    this.emailAddress,
    this.locationLatitude,
    this.locationLongitude,
    this.image,
    this.status,
  );
}
