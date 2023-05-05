import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/authentications/choosing_page.dart';
import 'package:heydriver/authentications/register_driver_page.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/admin_home_page.dart';
import 'package:heydriver/deneme/admin_salary_control_page.dart';
import 'package:heydriver/deneme/admin_user_info_page.dart';

class AdminDrawerWidget extends StatefulWidget {
  const AdminDrawerWidget({
    super.key,
  });

  @override
  State<AdminDrawerWidget> createState() => _AdminDrawerWidgetState();
}

class _AdminDrawerWidgetState extends State<AdminDrawerWidget> {
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
                children: const [
                  CircleAvatar(
                      radius: 48, // Image radius
                      backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1331&q=80')),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const AdminHomePage())));
            },
          ),
          ListTile(
            leading: const Icon(Icons.car_crash),
            title: const Text('Sürücü Kayıt'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const RegisterDriverPage())));
            },
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Bilanço'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const AdminSalaryWidget())));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Kullanıcı Bilgileri'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const AdminUserInfoPage())));
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
