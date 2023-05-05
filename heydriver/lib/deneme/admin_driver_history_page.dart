import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/models/driver_requests.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:intl/intl.dart';

class AdminDriverHistoryPage extends StatefulWidget {
  final String id;
  const AdminDriverHistoryPage({super.key, required this.id});

  @override
  State<AdminDriverHistoryPage> createState() => _AdminDriverHistoryPageState();
}

class _AdminDriverHistoryPageState extends State<AdminDriverHistoryPage> {
  // driverın geçmiş sürüşlerinin tutulduğu sayfa
  late String userId = widget.id;
  late DatabaseReference databaseReferenceDriversRequest =
      FirebaseDatabase.instance.ref().child("RequestDriver/$userId");
  bool isReady = false;
  DriverRequest? activerdriverRequest;
  List<DriverRequest> driverRequestListPast = [];
  // ignore: unused_field
  late StreamSubscription _driverStream;

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

  // tüm istekleri çekiyoruz active olanları active listesine geçmiş olanları geçmiş listesine alıyoruz
  void getDriverRequest() {
    _driverStream = databaseReferenceDriversRequest.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) async {
          if (response['state'] == 'approve') {
            activerdriverRequest = DriverRequest(
              response['id'],
              response['userId'],
              response['userName'],
              response['userPhone'],
              response['locationEndName'],
              response['locationStartName'],
              response['time'],
              response['driverName'],
              response['driverId'],
              response['destinationLatitude'],
              response['destinationLongitude'],
              response['latitude'],
              response['longitude'],
              response['price'],
              response['isComplete'],
              response['state'],
            );
          } else {
            driverRequestListPast.add(DriverRequest(
              response['id'],
              response['userId'],
              response['userName'],
              response['userPhone'],
              response['locationEndName'],
              response['locationStartName'],
              response['time'],
              response['driverName'],
              response['driverId'],
              response['destinationLatitude'],
              response['destinationLongitude'],
              response['latitude'],
              response['longitude'],
              response['price'],
              response['isComplete'],
              response['state'],
            ));
          }
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
          if (driverRequestListPast.isEmpty) {
            CardWidgets.sweetAlert(
                context, mounted, "Geçmiş Sürüşü bulunmamaktadır.");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: isReady
              ? Column(
                  //direction: Axis.vertical,
                  children: [
                    ListView.builder(
                        itemCount: 2,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text("Aktif"),
                                subtitle: Text("Aktif istekleri"),
                              ),
                            );
                          } else {
                            return activerdriverRequest != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: ThemeColors.offWhite,
                                      borderRadius: BorderRadius.circular(24.0),
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
                                            FontAwesomeIcons.locationCrosshairs,
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                          hintStyle: TextStyle(
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
                                                    "Etkin",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                          color:
                                                              ThemeColors.green,
                                                        ),
                                                  ),
                                                  const FaIcon(
                                                      Icons.arrow_forward_ios),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const ListTile(
                                    title:
                                        Text("Aktif Sürüşü bulunmamaktadır."),
                                  );
                          }
                        }),
                    ListView.builder(
                        itemCount: driverRequestListPast.length + 1,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text("Geçmiş"),
                                    subtitle: Text("Geçmiş sürüşleri"),
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
                                                    .userName,
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
                                                  Row(
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
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .headlineMedium
                                                                ?.copyWith(
                                                                  color: driverRequestListPast[index - 1]
                                                                              .state ==
                                                                          'completed'
                                                                      ? ThemeColors
                                                                          .green
                                                                      : ThemeColors
                                                                          .red,
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
                                          "Geçmiş Sürüşü bulunmamaktadır."),
                                    );
                        }),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  // tarihi formatlıyoruz bu webde de buna benzerdir sanıyorum
  String formatDate(String stringDate) {
    var date = DateTime.parse(stringDate);
    String datetime = DateFormat("dd/MM/yyyy").format(date);
    String time = DateFormat.Hm().format(date);
    return '$datetime       $time';
  }
}
