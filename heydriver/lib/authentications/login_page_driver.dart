import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heydriver/authentications/password_reset_page.dart';
import 'package:heydriver/components/button.dart';
import 'package:heydriver/deneme/admin_home_page.dart';
import 'package:heydriver/widgets/pincode_alert_dialog.dart';

class LoginDriverPage extends StatefulWidget {
  const LoginDriverPage({Key? key}) : super(key: key);

  @override
  LoginDriverPageState createState() => LoginDriverPageState();
}

class LoginDriverPageState extends State<LoginDriverPage> {
  //Driverın giriş yapacağı sayfa
  final formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool obscurePassword = true;
  bool isReady = true; // Bunu false yap
  bool isLoading = false;
  bool dontListen = false;
  late String userId = _auth.currentUser!.uid;

  @override
  void dispose() {
    // Dispose u her zaman controllerlar ve streamleri kapatmak için kullanıyoruz eğer kapatmazsan çalışmaya devam edeceklerdir be diğer sayfalarda hata alacaksındır
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: isReady
              ? Form(
                  key: formKey,
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.all(36),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Hey! Driver",
                                        style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 36),
                                      TextFormField(
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: (value) {
                                          email = value.trim();
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Lütfen email adresinizi giriniz";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Email adresiniz',
                                          labelText: 'Email',
                                          prefixIcon: Icon(
                                            Icons.email,
                                          ),
                                        ),
                                        keyboardAppearance: Brightness.dark,
                                      ),
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        controller: _passwordController,
                                        obscureText: obscurePassword,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Lütfen parolanızı giriniz";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          password = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Parolanız',
                                          labelText: 'Parola',
                                          prefixIcon: const Icon(
                                            Icons.lock,
                                          ),
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              if (mounted) {
                                                setState(() {
                                                  obscurePassword =
                                                      !obscurePassword;
                                                });
                                              }
                                            },
                                            child: Icon(
                                              obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                          ),
                                        ),
                                        keyboardAppearance: Brightness.dark,
                                      ),
                                      const SizedBox(height: 36),
                                      isLoading
                                          ? const CircularProgressIndicator()
                                          : LoginSignupButton(
                                              text: 'Giriş Yap',
                                              onTap: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  await _signIn();
                                                }
                                                _passwordController.clear();
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                            ),
                                      const SizedBox(height: 18),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PasswordResetScreen(email),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Şifrenizi mi unuttunuz?",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    // Eğer email adredi adminse direkt admin sayfasına yönlendiriyoruz
    if (email == "admin@gmail.com" && password == "admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminHomePage(),
        ),
      );
    } else {
      try {
        // Eğer email admin değilse firebase auth ile giriş yapıyoruz
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        setState(() {
          isReady = false;
        });
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            setState(() {
              isReady = true;
            });
          } else {
            showDialog(
                context: context,
                builder: (_) {
                  //return PinCodeAlertDialog(verificationId: verificationId);
                  return const PinCodeAlertDialog(
                    verificationId: 'verificationId',
                    isFake: true,
                  );
                });
          }
        });
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Email ile bağlantılı bir kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          message = 'Yanlış parola girdiniz.';
        } else if (e.code == 'invalid-email') {
          message = 'Email adresiniz geçersiz.';
        } else {
          message = 'Uyarı! Giriş Hatası.';
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message),
            content: Text('${e.message}'),
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
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Uyarı! Giriş Hatası.'),
            content: Text('$e'),
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
      }
    }
  }
}
