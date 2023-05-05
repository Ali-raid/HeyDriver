import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/deneme/main_screen.dart';
import 'package:heydriver/widgets/card_widget.dart';

class ControlInfoPage extends StatefulWidget {
  const ControlInfoPage({super.key});

  @override
  State<ControlInfoPage> createState() => _ControlInfoPageState();
}

class _ControlInfoPageState extends State<ControlInfoPage> {
  // userin ilk giriş yaptığında yönlendiği sayfa burda eğer kayıtlı değilse kayıt olması için yönlendiriyor

  //---- 184. satıra inin orda da kod var
  final formKey = GlobalKey<FormState>();

  final auth = FirebaseAuth.instance;
  late String id = auth.currentUser!.uid;
  String email = '';
  String fullName = '';
  String certificateNo = '';
  bool isLoading = false;
  bool isAccepted = false;

  late DatabaseReference userRef = FirebaseDatabase.instance
      .ref()
      .child("User/${FirebaseAuth.instance.currentUser!.uid}");

  // ignore: unused_field
  late StreamSubscription _usersStream;
  // sözleşmeyi kabul ettiği dialog
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Accept"),
      onPressed: () {
        setState(() {
          isAccepted = true;
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        onChanged: (() {
          setState(() {});
          formKey.currentState!.validate();
        }),
        key: formKey,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  autofillHints: const [AutofillHints.name],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.name,
                  maxLength: 70,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Lütfen adınızı giriniz";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    fullName = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Tam adınızı giriniz',
                    labelText: 'Tam Ad',
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                  ),
                  keyboardAppearance: Brightness.dark,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  autofillHints: const [AutofillHints.email],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value.trim();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Lütfen e-posta adresinizi giriniz";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email adresinizi giriniz',
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                  keyboardAppearance: Brightness.dark,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    certificateNo = value.trim();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Lütfen plakanızı giriniz";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Plakanızı giriniz',
                    labelText: 'Plakanız',
                    prefixIcon: Icon(
                      FontAwesomeIcons.fileSignature,
                    ),
                  ),
                  keyboardAppearance: Brightness.dark,
                ),
                const SizedBox(
                  height: 18.0,
                ),
                TextButton(
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    child: const Text('Okudum kabul ediyorum')),
                const SizedBox(
                  height: 18.0,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() &&
                          FirebaseAuth.instance.currentUser!.displayName ==
                              null) {
                        if (isAccepted == false) {
                          CardWidgets.sweetAlert(context, mounted,
                              'Lütfen sözleşmeyi kabul ediniz');
                        } else {
                          try {
                            // kişinin tüm bilgilerini günceleldiğimiz kısım burası
                            await FirebaseAuth.instance.currentUser!
                                .updateEmail(email);
                            await FirebaseAuth.instance.currentUser!
                                .updateDisplayName(fullName);
                            await FirebaseDatabase.instance
                                .ref()
                                .child("User/$id")
                                .set({
                              'id': id,
                              'fullName': fullName,
                              'emailAddress': email,
                              'role': 'user',
                              'hasRequest': false,
                              'userPhone': FirebaseAuth
                                  .instance.currentUser!.phoneNumber,
                              'locationLatitude': '',
                              'locationLongitude': '',
                              'image':
                                  'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
                              'certificateNo': certificateNo,
                              'isAccepted': isAccepted,
                            }).whenComplete(() {
                              CardWidgets.sweetAlert(context, mounted,
                                  'Kayıt işlemi başarılı bir şekilde gerçekleşti');
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen()));
                            });
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        }
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ));
                      }
                    },
                    child: Text(
                        FirebaseAuth.instance.currentUser!.displayName != null
                            ? 'Çık'
                            : 'Kaydet')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
