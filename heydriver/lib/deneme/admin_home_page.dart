import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/models/driver.dart';
import 'package:heydriver/models/requests.dart';
import 'package:heydriver/themes/app_constants.dart';
import 'package:heydriver/widgets/admin_drawer_widget.dart';
import 'package:heydriver/widgets/admin_page_widget.dart';
import 'package:heydriver/widgets/card_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Requests> notificationList = [];
  List<Driver> driverList = [];
  int selectedIndex = 0;
  int price = 0;
  bool isPriceChanged = false;
  bool isAprovedPage = false;
  bool isReady = false;
  late DatabaseReference databaseReferenceRequests =
      FirebaseDatabase.instance.ref().child("Request");

  late DatabaseReference databaseReferenceDrivers =
      FirebaseDatabase.instance.ref().child("Driver");

  late StreamSubscription _requestsStream, _driverStream;

  // driver için requesti güncelliyoruz
  // güncellenen verileri firebase e gönderiyoruz
  Future<void> updateDriverRequest(String driverId, bool accept) async {
    String state = accept ? "approve" : "denied";
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("RequestDriver/$driverId/$requestId")
          .update({
        'state': state,
      });
      if (mounted) {
        CardWidgets.sweetAlert(context, mounted, "Başarıyla güncellendi.");
      }
    } catch (e) {
      debugPrint("sendDriverRequest error: $e");
      CardWidgets.sweetAlert(context, mounted, "Güncelleme Başarısız");
    }
  }

  // sürüş isteğini kabul edip onaylayınca sürücüye de bu bilgileri göndermemiz gerekiyor burda da ona gönderiyoruz
  Future<void> sendDriverRequest(Requests requests) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("RequestDriver/$driverId/$requestId")
          .set({
        'state': 'approve',
        'driverName': dropdownvalue,
        'driverId': driverId,
        'price': isPriceChanged ? price : requests.price,
        'latitude': requests.latitude,
        'longitude': requests.longitude,
        'destinationLatitude': requests.destinationLatitude,
        'destinationLongitude': requests.destinationLongitude,
        'locationStartName': requests.locationStartName,
        'locationEndName': requests.locationEndName,
        'time': requests.time,
        'userId': requests.userId,
        'userName': requests.userName,
        'userPhone': requests.userPhone,
        'id': requests.id,
        'isComplete': false
      });
      if (mounted) {
        CardWidgets.sweetAlert(context, mounted, "Başarıyla güncellendi.");
      }
    } catch (e) {
      debugPrint("sendDriverRequest error: $e");
      CardWidgets.sweetAlert(context, mounted, "Güncelleme Başarısız");
    }
  }

  // gelen sürüş isteğini kabul edip onayladığımız yer burası
  // onayladığımız bilgileri firebase e gönderiyoruz
  Future<void> updateRequests(String userId, bool accept) async {
    String state = accept ? "approve" : "denied";
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("Request/$userId/$requestId")
          .update({
        'state': state,
        'driverName': dropdownvalue,
        'driverId': driverId,
        'price': isPriceChanged ? price : notificationList[selectedIndex].price,
      });
      await FirebaseDatabase.instance.ref('User/$userId').update(
        {
          'hasRequest': accept,
        },
      );
      if (mounted) {
        CardWidgets.sweetAlert(context, mounted, "Başarıyla güncellendi.");
      }
    } catch (e) {
      CardWidgets.sweetAlert(context, mounted, "Error updating profile.");
    }
  }

  String driverId = '';
  // Initial Selected Value
  String dropdownvalue = 'Bir Şöför Atayın';
  String requestId = '';

  // List of items in our dropdown menu
  var items = [
    'Bir Şöför Atayın',
  ];
  // Tüm istekleri çektiğimiz yer
  void getAllRequests(bool isAprovedPage) {
    String state = isAprovedPage ? "approve" : "pending";
    double reciprocal(double d) => 1 / d;
    _requestsStream = databaseReferenceRequests.onValue.listen((event) {
      notificationList.clear();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) {
          response.forEach((key, value) {
            if (value['state'] == state) {
              notificationList.add(Requests(
                value["id"],
                value["userId"],
                value["userName"],
                value["userPhone"],
                value["locationEndName"],
                value["locationStartName"],
                value["time"],
                value["driverName"],
                value["driverId"],
                reciprocal(value['totalDistanceValue'].toDouble()),
                value["totalDurationValue"],
                value["destinationLatitude"],
                value["destinationLongitude"],
                value["latitude"],
                value["longitude"],
                value["price"],
                value["isComplete"],
                value["state"],
              ));
            }
          });
        });
        if (mounted) {
          setState(() {
            isReady = true;
          });
        }
        debugPrint("notificationList: ${notificationList.length}");
      }
    });
  }

  // Tüm şöförleri çektiğimiz yer
  void getAllDriver() {
    _requestsStream = databaseReferenceDrivers.onValue.listen((event) {
      driverList.clear();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) {
          driverList.add(Driver(
            response["id"],
            response["fullName"],
            response["emailAddress"],
            response["locationLatiude"],
            response["locationLangitude"],
            response["image"],
            response["status"],
          ));
          items.add(
            response["fullName"],
          );
        });
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  // adminin bildirim alabilmesi token kaydediyoruz
  Future<void> saveToken(String token) async {
    await FirebaseDatabase.instance.ref().child("Global").update({
      "token": token,
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      saveToken(token!);
    });
  }

  // bildirim göndermek için gereken izinleri alıyoruz
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

  @override
  void dispose() {
    _requestsStream.cancel();
    _driverStream.cancel();

    super.dispose();
  }

  @override
  void initState() {
    getAllRequests(isAprovedPage);
    getAllDriver();
    requestPermission();
    getToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawerWidget(),
      backgroundColor: ThemeColors.grayTertiary,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Sürüş Onay ve Bilgi'),
      ),
      body: isReady
          ? Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingHorizontal,
                  vertical: AppConstants.paddingHorizontal),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: notificationList.length + 1,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    getAllRequests(true);
                                  });
                                },
                                child: const Text('Onaylananlar'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    getAllRequests(false);
                                  });
                                },
                                child: const Text('Bekleyenler'),
                              ),
                            ),
                          ],
                        )
                      : AdminPageWidget(
                          index: index,
                          requests: notificationList[index - 1],
                          updateDropdownValue: (p0) {
                            setState(() {
                              dropdownvalue = p0.toString();
                              driverId = driverList
                                  .where((d) => d.fullName == dropdownvalue)
                                  .first
                                  .id!;
                              selectedIndex = index - 1;
                              CardWidgets.sweetAlert(
                                  context, mounted, "Yeni şöför seçildi");
                            });
                          },
                          items: items,
                          dropdownvalue: dropdownvalue,
                          price: (String? value) {
                            if (value != null && value != '') {
                              if (int.parse(value) != 0) {
                                price = int.parse(value);
                                isPriceChanged = true;
                              } else {
                                price = 0;
                              }
                            } else {
                              price = 0;
                            }

                            setState(() {});
                          },
                          onPressed: () async {
                            if (dropdownvalue != 'Bir Şöför Atayın') {
                              requestId = notificationList[index - 1].id;
                              driverId = driverList
                                  .where((d) => d.fullName == dropdownvalue)
                                  .first
                                  .id!;
                              await sendDriverRequest(
                                  notificationList[index - 1]);
                              await updateRequests(
                                  notificationList[index - 1].userId, true);
                            } else {
                              CardWidgets.sweetAlert(
                                  context, mounted, "Lütfen bir şöför seçin.");
                            }
                            setState(() {});
                          },
                          onPressedReject: () async {
                            requestId = notificationList[index - 1].id;
                            debugPrint(notificationList[index - 1].driverId);
                            if (notificationList[index - 1].driverId != '') {
                              await updateDriverRequest(
                                  notificationList[index - 1].driverId, false);
                              await updateRequests(
                                  notificationList[index - 1].userId, false);
                            }
                            setState(() {});
                          },
                        );
                },
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
