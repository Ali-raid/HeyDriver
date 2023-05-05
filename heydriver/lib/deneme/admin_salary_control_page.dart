import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/models/driver.dart';
import 'package:heydriver/models/requests.dart';
import 'package:heydriver/widgets/card_widget.dart';

class AdminSalaryWidget extends StatefulWidget {
  const AdminSalaryWidget({super.key});

  @override
  State<AdminSalaryWidget> createState() => _AdminSalaryWidgetState();
}

class _AdminSalaryWidgetState extends State<AdminSalaryWidget> {
  // Bilanço sayfası
  late DatabaseReference databaseReferenceDrivers =
      FirebaseDatabase.instance.ref().child("Driver");
  List<Driver> driverList = [];

  late StreamSubscription _requestsStream, _driverStream;
  late DatabaseReference databaseReferenceRequest =
      FirebaseDatabase.instance.ref().child("Request");
  bool isReady = false;
  List<Requests> requestListRejected = [];
  List<Requests> requestListapproved = [];
  List<Requests> requestListcompleted = [];
  List<Requests> requestListpending = [];

  int earnedMoney = 0;

  @override
  void initState() {
    getAllDriver();
    getDriverRequest();
    super.initState();
  }

  @override
  void dispose() {
    _requestsStream.cancel();
    _driverStream.cancel();
    super.dispose();
  }

  // tüm sürücüleri çek
  // kaç sürücü var öğren
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
        });
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  // tüm verileri çekip tamamlanmış olanları filtreliyoruz
  // tamamlanmış olanlardan toplam kazanılan parayı buluyoruz
  // tamamlanmamış olanların ve istekte duranlarında sayılarını yazıyoruz
  void getDriverRequest() {
    earnedMoney = 0;
    requestListRejected.clear();
    requestListapproved.clear();
    requestListcompleted.clear();
    _driverStream = databaseReferenceRequest.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) async {
          Map<dynamic, dynamic> responseValue =
              response as Map<dynamic, dynamic>;

          responseValue.forEach((key, value) {
            Requests driverRequest = Requests(
              value['id'],
              value['userId'],
              value['userName'],
              value['userPhone'],
              value['locationEndName'],
              value['locationStartName'],
              value['time'],
              value['driverName'],
              value['driverId'],
              double.parse(value['totalDistanceValue'].toString()),
              value['totalDurationValue'],
              value['destinationLatitude'],
              value['destinationLongitude'],
              value['latitude'],
              value['longitude'],
              value['price'],
              value['isComplete'],
              value['state'],
            );

            if (driverRequest.state == 'completed') {
              requestListcompleted.add(driverRequest);
              earnedMoney = earnedMoney + driverRequest.price;
            } else if (driverRequest.state == "approve") {
              requestListapproved.add(driverRequest);
            } else if (driverRequest.state == 'pending') {
              requestListpending.add(driverRequest);
            } else {
              requestListRejected.add(driverRequest);
            }
          });
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
          if (requestListRejected.isEmpty &&
              requestListapproved.isEmpty &&
              requestListcompleted.isEmpty) {
            CardWidgets.sweetAlert(
                context, mounted, "Gösterilecek value bulunamamıştır.");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.grayPrimary,
        title: const Text('Bilanço'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: isReady
              ? Column(children: [
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: ThemeColors.grayPrimary,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          height: 100,
                          width: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Kazanılan TL'),
                              Text('$earnedMoney'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 100,
                          width: 180,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: ThemeColors.purple,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Tamamlanan Sürüşler'),
                              Text(requestListcompleted.length.toString()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 100,
                          width: 180,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: ThemeColors.blue,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Şöför Sayısı'),
                              Text(driverList.length.toString()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 100,
                          width: 180,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: ThemeColors.green,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Bekleyen Sürüşler'),
                              Text(requestListpending.length.toString()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ])
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
