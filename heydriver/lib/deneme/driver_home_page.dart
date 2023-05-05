import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heydriver/global.dart';
import 'package:heydriver/models/directions_model.dart';
import 'package:heydriver/repository/direction_repository.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:heydriver/widgets/driver_drawer_widget.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  // TODO bound ekle
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? mtoken = " ";
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(_rnd.nextInt(chars.length))));
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  GoogleMapController? newGoogleMapController;
  bool iconState = false;
  bool markerState = false;
  bool directionDetailsFull = false;
  bool isReady = false;
  String totalDistance = "";
  String totalDuration = "";
  int? totalDistanceValue = 0;
  int? totalDurationValue = 0;
  late DatabaseReference databaseReferenceDriversRequest =
      FirebaseDatabase.instance.ref().child("RequestDriver/$userId");

  late StreamSubscription _driverStream;

  void getDriverRequest() {
    int i = 0;
    _driverStream = databaseReferenceDriversRequest.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) async {
          if (response['state'] == 'approve') {
            i++;
            _origin = Marker(
                markerId: MarkerId(response["id"] + i.toString()),
                infoWindow: InfoWindow(
                  title: response["locationStartName"],
                ),
                position: LatLng(response["latitude"], response["longitude"]),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen));

            _destination = Marker(
                markerId:
                    MarkerId(response["id"] + i.toString() + 1.toString()),
                infoWindow: InfoWindow(
                  title: response["locationEndName"],
                ),
                position: LatLng(response["destinationLatitude"],
                    response["destinationLongitude"]),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue));

            final directions = await DirectionsRepository().getDirections(
                origin: _origin!.position, destination: _destination!.position);

            setState(() => _info = directions!);
          }
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
          // Get directions
        });
      }
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.766666, 29.916668),
    zoom: 8,
  );
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  Position? userCurrentPosition;
  bool openNavigationDrawer = true;

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle(mapType);
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference dbRefRequestDrive =
      FirebaseDatabase.instance.ref().child("Request/$userId");
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
    debugPrint('userCurrentPosition: ${userCurrentPosition!.latitude}');
    debugPrint('userCurrentPosition: ${userCurrentPosition!.longitude}');

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 8);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    if (mounted) {}
    try {
      FirebaseDatabase.instance.ref().child("Driver/$userId").update({
        'locationLatitude': userCurrentPosition!.latitude,
        'locationLongitude': userCurrentPosition!.longitude,
      });
    } catch (e) {
      CardWidgets.sweetAlert(context, mounted, "Error updating profile.");
    }
    /*   String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context); */
  }

  @override
  void initState() {
    getDriverRequest();
    requestPermission();

    loadFCM();

    listenFCM();

    getToken();
    super.initState();
  }

  @override
  void dispose() {
    _driverStream.cancel();
    super.dispose();
  }

  bool isBrought = false;

  late DatabaseReference userRef = FirebaseDatabase.instance
      .ref()
      .child("Driver/${FirebaseAuth.instance.currentUser!.uid}/isAccepted");

  late DatabaseReference userRefUpdate = FirebaseDatabase.instance
      .ref()
      .child("Driver/${FirebaseAuth.instance.currentUser!.uid}");

  // ignore: unused_field
  late StreamSubscription _usersStream;

  Future<void> chechUserAccepted() async {
    userRef.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          showAlertDialog(context);
        });
      }
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("Reddet"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Kabul Et"),
      onPressed: () {
        userRefUpdate.update({
          'isAccepted': true,
        });
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Sözleşme"),
      content: const Text("Lorem Ipsum dolar lorem ipsum"),
      icon: const Icon(Icons.file_copy_rounded),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void didChangeDependencies() {
    chechUserAccepted();
    super.didChangeDependencies();
  }

  void getTokenFromRealtimeDatabase() async {
    FirebaseDatabase.instance
        .ref()
        .child("Driver/$userId")
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
    await FirebaseDatabase.instance.ref().child("Driver/$userId").update({
      "token": token,
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 285,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: const DriverDrawerWidget(),
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
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 3,
                    points: _info!.polylinePoints!
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!
              },
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) async {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});
                blackThemeGoogleMap();
                locateUserPosition();
              },
            ),
            Positioned(
              top: 52,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  sKey.currentState!.openDrawer();
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
            if (_info != null)
              Positioned(
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
              ),
          ],
        ),
      ),
    );
  }
}
