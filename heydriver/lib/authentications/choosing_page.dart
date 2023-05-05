import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/authentications/login_page.dart';
import 'package:heydriver/authentications/login_page_driver.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/driver_home_page.dart';
import 'package:heydriver/deneme/main_screen.dart';

class ChoosingPage extends StatefulWidget {
  const ChoosingPage({super.key});

  @override
  State<ChoosingPage> createState() => _ChoosingPageState();
}

class _ChoosingPageState extends State<ChoosingPage> {
  final _auth = FirebaseAuth.instance;
  late String userId = _auth.currentUser!.uid;
  StreamSubscription? _onUserAddedSubscription,
      _driverChangedSubscription,
      _userChangedSubscription;

  @override
  void initState() {
    getUserIsAuth();
    // TODO: implement initState
    super.initState();
  }

  // kullanıcı authentice mi diye bakıp direkt main screen e yönlendiriyor eğer authentice ise
  void getUserIsAuth() {
    _onUserAddedSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
      } else {
        DatabaseReference ref = FirebaseDatabase.instance.ref();
        _driverChangedSubscription = ref.child("Driver/$userId").onValue.listen(
          (event) {
            if (event.snapshot.exists) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DriverHomePage()),
                  (Route<dynamic> route) => false);
            } else {
              DatabaseReference ref = FirebaseDatabase.instance.ref();
              _userChangedSubscription =
                  ref.child("User/${user.uid}").onValue.listen(
                (event) {
                  if (event.snapshot.exists) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          // builder: (context) => const MainScreen(),
                          builder: (context) => const MainScreen(),
                        ),
                        (Route<dynamic> route) => false);
                  } else {
                    //Do nothing
                  }
                },
              );
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _onUserAddedSubscription != null
        ? _onUserAddedSubscription!.cancel()
        : null;
    _driverChangedSubscription != null
        ? _driverChangedSubscription!.cancel()
        : null;
    _userChangedSubscription != null
        ? _userChangedSubscription!.cancel()
        : null;
    super.dispose();
  }

  //Burası kullanıcının driver mı yoksa müşteri mi olduğunu seçmesini sağlayan sayfa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.offWhite,
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Siz Hangisisiniz?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false);
                  },
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: ThemeColors.black,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          FontAwesomeIcons.personWalking,
                          color: ThemeColors.offWhite,
                          size: 100,
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          'Yolcuyum',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ThemeColors.offWhite,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginDriverPage()),
                        (Route<dynamic> route) => false);
                  },
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: ThemeColors.black,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          FontAwesomeIcons.car,
                          color: ThemeColors.offWhite,
                          size: 100,
                        ),
                        Text(
                          'Şöförüm',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ThemeColors.offWhite,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*   InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterDriverPage()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                    ),
                    child: Text(
                      'bu kalkıcak şöför kaydetme sayfası',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: ThemeColors.offWhite,
                          ),
                    ),
                  ),
                ), */
              ],
            ),
          ],
        ),
      ),
    );
  }
}
