import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/admin_driver_history_page.dart';
import 'package:heydriver/deneme/admin_user_history_page.dart';
import 'package:heydriver/models/driver.dart';
import 'package:heydriver/models/user_model.dart';
import 'package:heydriver/themes/app_constants.dart';
import 'package:heydriver/widgets/admin_drawer_widget.dart';

class AdminUserInfoPage extends StatefulWidget {
  const AdminUserInfoPage({Key? key}) : super(key: key);

  @override
  State<AdminUserInfoPage> createState() => _AdminUserInfoPageState();
}

class _AdminUserInfoPageState extends State<AdminUserInfoPage> {
  List<Driver> driverList = [];
  List<UserModel> userList = [];
  bool isDriverState = false;
  bool isReady = false;
  late DatabaseReference databaseReferenceRequests =
      FirebaseDatabase.instance.ref().child("User");

  late DatabaseReference databaseReferenceDrivers =
      FirebaseDatabase.instance.ref().child("Driver");

  late StreamSubscription _requestsStream, _driverStream;

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
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
        });
      }
    });
  }

  // Tüm şöförleri çektiğimiz yer
  void getAllUser() {
    _requestsStream = databaseReferenceRequests.onValue.listen((event) {
      userList.clear();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
        value.forEach((key, response) {
          userList.add(UserModel(
            phone: response["userPhone"],
            id: response["id"],
            email: response["emailAddress"],
            name: response["fullName"],
          ));
        });
      }
      if (mounted) {
        setState(() {
          isReady = true;
        });
      }
    });
  }

  @override
  void initState() {
    getAllUser();
    getAllDriver();
    super.initState();
  }

  @override
  void dispose() {
    _requestsStream.cancel();
    _driverStream.cancel();
    super.dispose();
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
                itemCount:
                    isDriverState ? driverList.length + 1 : userList.length + 1,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isDriverState = !isDriverState;
                                  });
                                  debugPrint(isDriverState.toString());
                                },
                                child: Text(isDriverState
                                    ? 'Şöförler'
                                    : 'Kullanıcılar'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        )
                      : ListTile(
                          title: Text(isDriverState
                              ? driverList[index - 1].fullName ??
                                  "isimsiz şöför"
                              : userList[index - 1].name ??
                                  "isimsiz kullanıcı"),
                          subtitle: Text(isDriverState
                              ? driverList[index - 1].emailAddress ??
                                  "email adresi yok"
                              : userList[index - 1].email ??
                                  "email adresi yok"),
                          leading: IconButton(
                            onPressed: () {
                              if (isDriverState) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AdminDriverHistoryPage(
                                          id: driverList[index - 1].id!,
                                        )));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AdminUserHistoryPage(
                                          id: userList[index - 1].id!,
                                        )));
                              }
                            },
                            icon: const Icon(Icons.info),
                          ),
                        );
                },
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
