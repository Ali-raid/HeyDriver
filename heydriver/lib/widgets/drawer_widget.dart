import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/authentications/choosing_page.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/user_history_page.dart';
import 'package:heydriver/deneme/user_profile_page.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  final BuildContext context;
  const DrawerWidget({super.key, required this.context});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final _auth = FirebaseAuth.instance;
  launchMailto() async {
    final mailtoLink = Mailto(
      to: ['to@example.com'],
      cc: ['cc1@example.com', 'cc2@example.com'],
    );
    // Convert the Mailto instance into a string.
    // Use either Dart's string interpolation
    // or the toString() method.
    Uri uri = Uri.parse('$mailtoLink');

    await launchUrl(uri);
  }

  makePhoneCall() async {
    const phoneNumberLink = 'tel:+905423932562';

    Uri uri = Uri.parse(phoneNumberLink);

    await launchUrl(uri);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChoosingPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ThemeColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 48, // Image radius
                    backgroundImage: _auth.currentUser?.photoURL == null
                        ? const NetworkImage(
                            'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1331&q=80')
                        : NetworkImage(_auth.currentUser!.photoURL!),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _auth.currentUser!.displayName!.toUpperCase(),
                        style: const TextStyle(color: ThemeColors.white),
                      ),
                      Text(_auth.currentUser!.phoneNumber ?? 'Unknown',
                          style: const TextStyle(color: ThemeColors.lightGrey)),
                    ],
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Ana Sayfa'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => const UserProfilePage()),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.car_rental_rounded),
            title: const Text('Önceki Sürüşlerim'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const UserHistoryPage())));
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_mark_rounded),
            title: const Text('Hakkımızda'),
            onTap: () {
              showDialog(
                context: widget.context,
                builder: (context) => AlertDialog(
                  title: const Text('Hakkımızda'),
                  content:
                      const Text('Lorem ipsum dolor sit amet, consectetur'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tamam'),
                    )
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.outgoing_mail),
            title: const Text('Bize Ulaşın'),
            onTap: () {
              showDialog(
                context: widget.context,
                builder: (context) => AlertDialog(
                  title: const Text('Bize Buradan Ulaşın'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: const Text(
                          'heydriveraltinbas@gmail.com',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          launchMailto();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      /* InkWell(
                        child: const Text(
                          '+90 542 393 25 62',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          makePhoneCall();
                        },
                      ), */
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tamam'),
                    )
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Çıkış Yap'),
            onTap: () async {
              await _signOut();
            },
          ),
        ],
      ),
    );
  }
}
