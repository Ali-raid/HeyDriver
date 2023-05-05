import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heydriver/asistants/assistant_methods.dart';
import 'package:heydriver/deneme/control_info_page.dart';
import 'package:heydriver/global.dart';
import 'package:heydriver/helper/app_info.dart';
import 'package:heydriver/models/directions_model.dart';
import 'package:heydriver/repository/direction_repository.dart';
import 'package:heydriver/search_places_screen.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:heydriver/widgets/drawer_widget.dart';
import 'package:heydriver/widgets/main_screen_request_widget.dart';
import 'package:heydriver/widgets/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? mtoken = " ";
  String? adminToken = " ";

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  bool isTouchable = false;
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(_rnd.nextInt(chars.length))));

  GoogleMapController? newGoogleMapController;
  bool hasRequest = false;
  bool iconState = false;
  bool markerState = false;
  bool directionDetailsFull = false;
  bool isReady = false;
  String totalDistance = "";
  String totalDuration = "";
  int? totalDistanceValue = 0;
  int? totalDurationValue = 0;
  String? originName;
  String? destinationName;
  late DatabaseReference databaseReferenceUsers =
      FirebaseDatabase.instance.ref().child("Driver");
  late DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child("User/$userId");

  // ignore: unused_field
  late StreamSubscription _usersStream;

  void checkUserHasUserName() async {
    if (FirebaseAuth.instance.currentUser!.displayName == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ControlInfoPage(),
        ));
      });
    } else {}
  }

  void getUserHasRequest() async {
    userRef.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, value) {
          if (key == "hasRequest") {
            if (value == true) {
              setState(() {
                hasRequest = true;
              });
            } else {
              setState(() {
                hasRequest = false;
              });
            }
          }
        });
      }
    });
  }

  void getAllDrivers() async {
    int i = 0;
    _usersStream = databaseReferenceUsers.onValue.listen((event) {
      markersSet.clear();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) async {
          i++;
          final Uint8List markIcons =
              await AssistantMethods.getImages(carsList[5 % i], 100);
          markersSet.add(
            Marker(
                markerId: MarkerId(response["id"]),
                infoWindow:
                    InfoWindow(title: response["fullName"], snippet: "driver"),
                position: LatLng(response["locationLatitude"],
                    response["locationLongitude"]),
                icon: BitmapDescriptor.fromBytes(markIcons)),
          );
        });
      }

      if (mounted) {
        setState(() {
          isReady = true;
        });
      }
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.766666, 29.916668),
    zoom: 8,
  );
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 150.0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Marker> driversMarkersSet = {};

  String userName = 'Your Name';
  String userEmail = 'Your Email';

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle(mapType);
  }

  getPositionMarkers() async {
    if (_origin != null && _destination != null) {
      originName = await getPostionName(
          _origin!.position.latitude, _origin!.position.longitude);
      destinationName = await getPostionName(
          _destination!.position.latitude, _destination!.position.longitude);
    }
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference dbRefRequestDrive =
      FirebaseDatabase.instance.ref().child("Request/$userId");

  Future<void> addToDriveRequest() async {
    String randomId = getRandomString(10);
    //make meters to kilometers get first 2 digits as double
    double distance =
        double.parse((totalDistanceValue! / 1000).toStringAsFixed(2));
    //make seconds to minutes
    int durationInMinutes = totalDurationValue! ~/ 60;
    int price = 150;
    if (distance > 15.99) {
      price = 150 + ((distance - 15.99) * 10).toInt();
    } else {
      price = 150;
    }

    await dbRefRequestDrive.child(randomId).set({
      'id': randomId,
      'userId': userId,
      'userName': FirebaseAuth.instance.currentUser!.displayName,
      'userPhone': FirebaseAuth.instance.currentUser!.phoneNumber,
      'driverName': "null",
      'driverId': '',
      'latitude': userCurrentPosition!.latitude,
      'longitude': userCurrentPosition!.longitude,
      'state': 'pending',
      'price': price,
      'time': DateTime.now().toString(),
      'totalDistanceValue': distance,
      'totalDurationValue': durationInMinutes,
      'destinationLatitude': Provider.of<AppInfo>(context, listen: false)
          .userDropOffLocation!
          .locationLatitude,
      'destinationLongitude': Provider.of<AppInfo>(context, listen: false)
          .userDropOffLocation!
          .locationLongitude,
      'locationStartName': Provider.of<AppInfo>(context, listen: false)
          .userPickUpLocation!
          .locationName!,
      'locationEndName': Provider.of<AppInfo>(context, listen: false)
          .userDropOffLocation!
          .locationName!,
      'isComplete': false,
    });

    await userRef.update({
      'hasRequest': true,
    });

    sendPushMessage(
        adminToken!, 'Bir adet sürüş isteği alındı', 'Sürüş İsteği');
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(1.0),
      content: MainScreenRequestWidget(
        origin: isTouchable
            ? originName!
            : Provider.of<AppInfo>(context, listen: false)
                .userPickUpLocation!
                .locationName!,
        destination: isTouchable
            ? destinationName!
            : Provider.of<AppInfo>(context, listen: false)
                .userDropOffLocation!
                .locationName!,
        distance: _info == null ? totalDistance : _info!.totalDistance!,
        duration: _info == null ? totalDuration : _info!.totalDuration!,
        onPressed: () {
          addToDriveRequest().whenComplete(() {
            if (mounted) {
              Navigator.pop(context);
              getUserHasRequest();
            }
          });
        },
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  locateUserPosition() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 8);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    if (mounted) {}
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);
  }

  void getTokenFromRealtimeDatabase() async {
    FirebaseDatabase.instance
        .ref()
        .child("User/$userId")
        .onValue
        .listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, value) {
          if (key == "token") {
            mtoken = value;
          }
        });
      }
    });
  }

  Future<void> saveToken(String token) async {
    await FirebaseDatabase.instance.ref().child("User/$userId").update({
      "token": token,
    });
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key= AAAAGHropVs:APA91bEEz_X2rV4syggApxC5Gu71frDg1fGnMFGBjoToRtUuXIB_qCPtWGft3-yXLeYWY7wy8kDWqabwoUvTRWMlPs4OrLKjkKi3YKdSss2b_uxC7fJCjQdSyIehrVCn3yTStxfGbmuJ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      debugPrint("error push notification");
    }
  }

  void getAdminToken() {
    FirebaseDatabase.instance.ref().child("Global").onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, value) {
          if (key == "token") {
            adminToken = value;
            debugPrint(adminToken);
          }
        });
      }
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });

      saveToken(token!).then((value) => getTokenFromRealtimeDatabase());
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  void dispose() {
    //do something

    super.dispose();
  }

  @override
  void initState() {
    getAllDrivers();
    getUserHasRequest();
    requestPermission();
    getAdminToken();

    loadFCM();

    listenFCM();

    getToken();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      checkUserHasUserName();
    }

    super.didChangeDependencies();
  }

  void resetApp() {
    setState(() {
      _origin = null;
      _destination = null;
      _info = null;
      searchLocationContainerHeight = 150.0;
      openNavigationDrawer = true;
      polyLineSet.clear();
      markersSet.clear();
      pLineCoOrdinatesList.clear();
      driversMarkersSet.clear();
      directionDetailsFull = false;
      getAllDrivers();
    });
    locateUserPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 285,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: DrawerWidget(
            context: context,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              padding: const EdgeInsets.only(bottom: 230),

              //circles: circlesSet,
              markers: markersSet,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) async {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});

                blackThemeGoogleMap();

                locateUserPosition();
              },
              polylines: isTouchable
                  ? {
                      if (_info != null)
                        Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: Colors.red,
                          width: 3,
                          points: _info!.polylinePoints!
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),
                    }
                  : polyLineSet,
              onLongPress: isTouchable ? _addMarker : null,
            ),
            Positioned(
                bottom: 150,
                left: 10,
                child: TextButton(
                  onPressed: () {
                    isTouchable = !isTouchable;

                    setState(() {
                      resetApp();
                    });
                  },
                  child: Text(
                    isTouchable ? "El ile Seç" : "Konumdan Seç",
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
            Positioned(
              top: 52,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  if (openNavigationDrawer) {
                    sKey.currentState!.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: openNavigationDrawer
                      ? const Icon(
                          Icons.menu,
                          color: Colors.black54,
                        )
                      : const Icon(
                          Icons.close,
                        ),
                ),
              ),
            ),
            Visibility(
              visible: _info != null,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    height: searchLocationContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                /*   Provider.of<AppInfo>(context, listen: false);
                                setState(() {}); */
                                hasRequest
                                    ? CardWidgets.sweetAlert(context, mounted,
                                        "Açık bir sürüş isteğiniz bulunmakta")
                                    : showAlertDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              child: const Text(
                                "Şöför İste",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !isTouchable,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    height: searchLocationContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //from
                            GestureDetector(
                              onTap: () async {
                                var responseFromSearchScreen =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const SearchPlacesScreen(
                                                    isOrigin: true)));

                                if (responseFromSearchScreen ==
                                    'obtainedDropoff') {
                                  setState(() {
                                    openNavigationDrawer = false;
                                  });

                                  await drawPolyLineFromOriginToDestination();
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_location_alt_outlined,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    width: 12.0,
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Buradan",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                            Provider.of<AppInfo>(context)
                                                        .userPickUpLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userPickUpLocation!
                                                    .locationName!
                                                : 'Adres getirilemedi',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                overflow: TextOverflow.fade),
                                            softWrap: false),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10.0),

                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey,
                            ),

                            const SizedBox(height: 16.0),

                            //to
                            GestureDetector(
                              onTap: () async {
                                var responseFromSearchScreen =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const SearchPlacesScreen(
                                                    isOrigin: false)));

                                if (responseFromSearchScreen ==
                                    'obtainedDropoff') {
                                  setState(() {
                                    openNavigationDrawer = false;
                                  });

                                  await drawPolyLineFromOriginToDestination();
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_location_alt_outlined,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    width: 12.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Şuraya",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Text(
                                        Provider.of<AppInfo>(context)
                                                    .userDropOffLocation !=
                                                null
                                            ? Provider.of<AppInfo>(context)
                                                .userDropOffLocation!
                                                .locationName!
                                            : 'Nereye gidiyorsunuz?',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            directionDetailsFull == true && isTouchable == false
                ? Positioned(
                    top: 20.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          )
                        ],
                      ),
                      child: Text(
                        '$totalDistance , $totalDuration',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : _info != null
                    ? Positioned(
                        top: 20.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              )
                            ],
                          ),
                          child: Text(
                            '${_info!.totalDistance}, ${_info!.totalDuration}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140.0),
        child: Visibility(
          visible: directionDetailsFull == true && isTouchable == false,
          child: ElevatedButton(
            onPressed: () {
              /*   Provider.of<AppInfo>(context, listen: false);
                                    setState(() {}); */
              hasRequest
                  ? CardWidgets.sweetAlert(
                      context, mounted, "Açık bir sürüş isteğiniz bulunmakta")
                  : showAlertDialog(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            child: const Text(
              "Şöför İste",
            ),
          ),
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          position: pos,
        );
        // Reset destination
        _destination = null;

        // Reset info
        _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: pos,
        );
      });
      markersSet.add(_origin!);
      markersSet.add(_destination!);
      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() => _info = directions!);
      getPositionMarkers();
    }
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    totalDistance = directionDetailsInfo!.distance_text.toString();
    totalDuration = directionDetailsInfo.duration_text.toString();
    totalDistanceValue = directionDetailsInfo.distance_value;
    totalDurationValue = directionDetailsInfo.duration_value;
    directionDetailsFull = true;

    if (mounted) {
      Navigator.pop(context);
    }

    /*  print("These are points = ");
    print(directionDetailsInfo!.e_points); */

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        width: 4,
        color: Colors.blue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });
  }

  Future<String?> getPostionName(double lat, double lon) async {
    // converted the lat from string to double

    // Passed the coordinates of latitude and longitude
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

    setState(() {});
    return '${placemarks.first.name} ${placemarks.first.street}';
  }
}
