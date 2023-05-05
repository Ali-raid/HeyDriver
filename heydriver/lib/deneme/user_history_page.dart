import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/models/driver_requests.dart';
import 'package:heydriver/models/requests.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:intl/intl.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference databaseReferenceDriversRequest =
      FirebaseDatabase.instance.ref().child("RequestDriver");
  late DatabaseReference databaseReferenceRequest =
      FirebaseDatabase.instance.ref().child("Request");
  bool isReady = false;
  DriverRequest? activerdriverRequest;
  Requests? pendingRequest;
  List<DriverRequest> driverRequestListPast = [];
  // ignore: unused_field
  late StreamSubscription _driverStream, requestStream;

  @override
  void initState() {
    getDriverRequest();
    super.initState();
  }

  @override
  void dispose() {
    _driverStream.cancel();
    super.dispose();
  }

  Future<void> updateRequests(String userId) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("Request/$userId/${activerdriverRequest!.id}")
          .update({
        'state': 'completed',
        'isComplete': true,
      });
      await FirebaseDatabase.instance
          .ref()
          .child(
              "RequestDriver/${activerdriverRequest!.driverId}/${activerdriverRequest!.id}")
          .update({
        'state': 'completed',
        'isComplete': true,
      });

      await FirebaseDatabase.instance.ref('User/$userId').update({
        'hasRequest': false,
      });

      if (mounted) {
        CardWidgets.sweetAlert(context, mounted, "Başarıyla güncellendi.");
      }
    } catch (e) {
      debugPrint(e.toString());
      CardWidgets.sweetAlert(context, mounted, "Error updating profile.");
    }
  }

  void getDriverRequest() {
    driverRequestListPast.clear();
    activerdriverRequest = null;
    pendingRequest = null;
    double reciprocal(double d) => 1 / d;
    requestStream = databaseReferenceRequest.onValue.listen((event) {
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
              reciprocal(value['totalDistanceValue'].toDouble()),
              value['totalDurationValue'],
              value['destinationLatitude'],
              value['destinationLongitude'],
              value['latitude'],
              value['longitude'],
              value['price'],
              value['isComplete'],
              value['state'],
            );
            if (driverRequest.userId == userId) {
              if (driverRequest.state == "pending") {
                pendingRequest = driverRequest;
              }
            }
          });
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
        });
      }
    });

    _driverStream = databaseReferenceDriversRequest.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) async {
          Map<dynamic, dynamic> responseValue =
              response as Map<dynamic, dynamic>;

          responseValue.forEach((key, value) {
            DriverRequest driverRequest = DriverRequest(
              value['id'],
              value['userId'],
              value['userName'],
              value['userPhone'],
              value['locationEndName'],
              value['locationStartName'],
              value['time'],
              value['driverName'],
              value['driverId'],
              value['destinationLatitude'],
              value['destinationLongitude'],
              value['latitude'],
              value['longitude'],
              value['price'],
              value['isComplete'],
              value['state'],
            );
            if (driverRequest.userId == userId) {
              if (driverRequest.state == "approve") {
                activerdriverRequest = driverRequest;
              } else {
                driverRequestListPast.add(driverRequest);
                debugPrint(driverRequestListPast.length.toString());
              }
            }
          });
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
          if (driverRequestListPast.isEmpty) {
            CardWidgets.sweetAlert(
                context, mounted, "Geçmiş Sürüşünüz bulunmamaktadır.");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geçmiş Sürüşlerim"),
      ),
      body: SingleChildScrollView(
        primary: true,
        child: SafeArea(
          child: isReady
              ? Column(
                  //direction: Axis.vertical,
                  children: [
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text("Bekleyen"),
                                subtitle: Text("Bekleyen Sürüşleriniz"),
                              ),
                            );
                          } else {
                            return pendingRequest != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ThemeColors.offWhite,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            tileColor: Colors.transparent,
                                            title: Text(
                                              pendingRequest!.locationStartName,
                                              style: const TextStyle(
                                                  color: ThemeColors.black),
                                            ),
                                            subtitle: Text(
                                              '${pendingRequest!.latitude},${pendingRequest!.longitude}',
                                              style: const TextStyle(
                                                  color: ThemeColors.black),
                                            ),
                                            leading: const FaIcon(
                                              FontAwesomeIcons
                                                  .locationCrosshairs,
                                              color: ThemeColors.green,
                                            ),
                                          ),
                                          ListTile(
                                            tileColor: Colors.transparent,
                                            title: Text(
                                              pendingRequest!.locationEndName,
                                              style: const TextStyle(
                                                  color: ThemeColors.black),
                                            ),
                                            subtitle: Text(
                                              '${pendingRequest!.destinationLatitude},${pendingRequest!.destinationLongitude}',
                                              style: const TextStyle(
                                                  color: ThemeColors.black),
                                            ),
                                            leading: const FaIcon(
                                              FontAwesomeIcons.locationDot,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                              formatDate(pendingRequest!.time)),
                                          const Divider(
                                            color: ThemeColors.grayPrimary,
                                            thickness: 2.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const FaIcon(
                                                      FontAwesomeIcons
                                                          .handHoldingDollar,
                                                      color: ThemeColors
                                                          .graySecondary,
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        width: 120,
                                                        child: TextField(
                                                          controller:
                                                              TextEditingController(
                                                                  text: pendingRequest!
                                                                      .price
                                                                      .toString()),
                                                          readOnly: true,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              const InputDecoration(
                                                            hintText: "Fiyat",
                                                            hintStyle:
                                                                TextStyle(
                                                              color: ThemeColors
                                                                  .graySecondary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'TL',
                                                      style: TextStyle(
                                                          color: ThemeColors
                                                              .graySecondary,
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Bekliyor",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(
                                                            color: ThemeColors
                                                                .green,
                                                          ),
                                                    ),
                                                    const FaIcon(Icons
                                                        .arrow_forward_ios),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const ListTile(
                                    title: Text(
                                        "Bekleyen Sürüşünüz bulunmamaktadır."),
                                  );
                          }
                        }),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text("Aktif"),
                                subtitle: Text("Aktif Sürüşleriniz"),
                              ),
                            );
                          } else {
                            return activerdriverRequest != null
                                ? InkWell(
                                    onTap: (() => showDialog(
                                          context: context,
                                          builder: ((context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Sürüşü Tamamla"),
                                              content: const Text(
                                                  "Sürüşü tamamlamak istediğinize emin misiniz?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Hayır")),
                                                TextButton(
                                                    onPressed: () async {
                                                      await updateRequests(
                                                          userId);
                                                      getDriverRequest();
                                                      setState(() {});
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: const Text("Evet")),
                                              ],
                                            );
                                          }),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ThemeColors.offWhite,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              tileColor: Colors.transparent,
                                              title: Text(
                                                activerdriverRequest!
                                                    .locationStartName,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              subtitle: Text(
                                                '${activerdriverRequest!.latitude},${activerdriverRequest!.longitude}',
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              leading: const FaIcon(
                                                FontAwesomeIcons
                                                    .locationCrosshairs,
                                                color: ThemeColors.green,
                                              ),
                                            ),
                                            ListTile(
                                              tileColor: Colors.transparent,
                                              title: Text(
                                                activerdriverRequest!
                                                    .locationEndName,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              subtitle: Text(
                                                '${activerdriverRequest!.destinationLatitude},${activerdriverRequest!.destinationLongitude}',
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              leading: const FaIcon(
                                                FontAwesomeIcons.locationDot,
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(formatDate(
                                                activerdriverRequest!.time)),
                                            const Divider(
                                              color: ThemeColors.grayPrimary,
                                              thickness: 2.0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .handHoldingDollar,
                                                        color: ThemeColors
                                                            .graySecondary,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            controller: TextEditingController(
                                                                text: activerdriverRequest!
                                                                    .price
                                                                    .toString()),
                                                            readOnly: true,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText: "Fiyat",
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: ThemeColors
                                                                    .graySecondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        'TL',
                                                        style: TextStyle(
                                                            color: ThemeColors
                                                                .graySecondary,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Etkin",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium
                                                            ?.copyWith(
                                                              color: ThemeColors
                                                                  .green,
                                                            ),
                                                      ),
                                                      const FaIcon(Icons
                                                          .arrow_forward_ios),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const ListTile(
                                    title: Text(
                                        "Aktif Sürüşünüz bulunmamaktadır."),
                                  );
                          }
                        }),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: driverRequestListPast.length + 1,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text("Geçmiş"),
                                    subtitle: Text("Geçmiş sürüşleriniz"),
                                  ),
                                )
                              : driverRequestListPast.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ThemeColors.offWhite,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              tileColor: Colors.transparent,
                                              title: Text(
                                                driverRequestListPast[index - 1]
                                                    .locationStartName,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              subtitle: Text(
                                                driverRequestListPast[index - 1]
                                                    .driverName,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              leading: const FaIcon(
                                                FontAwesomeIcons
                                                    .locationCrosshairs,
                                                color: ThemeColors.green,
                                              ),
                                            ),
                                            ListTile(
                                              tileColor: Colors.transparent,
                                              title: Text(
                                                driverRequestListPast[index - 1]
                                                    .locationEndName,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              subtitle: Text(
                                                driverRequestListPast[index - 1]
                                                    .userPhone,
                                                style: const TextStyle(
                                                    color: ThemeColors.black),
                                              ),
                                              leading: const FaIcon(
                                                FontAwesomeIcons.locationDot,
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(formatDate(
                                                driverRequestListPast[index - 1]
                                                    .time)),
                                            const Divider(
                                              color: ThemeColors.grayPrimary,
                                              thickness: 2.0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const FaIcon(
                                                        FontAwesomeIcons
                                                            .handHoldingDollar,
                                                        color: ThemeColors
                                                            .graySecondary,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: 120,
                                                          child: TextField(
                                                            controller: TextEditingController(
                                                                text: driverRequestListPast[
                                                                        index -
                                                                            1]
                                                                    .price
                                                                    .toString()),
                                                            readOnly: true,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText: "Fiyat",
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: ThemeColors
                                                                    .graySecondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text('TL',
                                                          style: TextStyle(
                                                              color: ThemeColors
                                                                  .graySecondary,
                                                              fontSize: 16)),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {},
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          driverRequestListPast[
                                                                          index -
                                                                              1]
                                                                      .state ==
                                                                  'completed'
                                                              ? "Tamamlanmış"
                                                              : "Tamamlanmamış",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headlineSmall
                                                                  ?.copyWith(
                                                                    color: driverRequestListPast[index - 1].state ==
                                                                            'completed'
                                                                        ? ThemeColors
                                                                            .green
                                                                        : ThemeColors
                                                                            .red,
                                                                  ),
                                                        ),
                                                        const FaIcon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 18.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const ListTile(
                                      title: Text(
                                          "Geçmiş Sürüşünüz bulunmamaktadır."),
                                    );
                        }),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  String formatDate(String stringDate) {
    var date = DateTime.parse(stringDate);
    String datetime = DateFormat("dd/MM/yyyy").format(date);
    String time = DateFormat.Hm().format(date);
    return '$datetime       $time';
  }
}
