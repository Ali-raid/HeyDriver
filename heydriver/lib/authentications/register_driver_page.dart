import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heydriver/components/button.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterDriverPage extends StatefulWidget {
  const RegisterDriverPage({Key? key}) : super(key: key);

  @override
  RegisterDriverPageState createState() => RegisterDriverPageState();
}

class RegisterDriverPageState extends State<RegisterDriverPage> {
  // Sürücü kayıt sayfası
  final formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController(),
      _passwordVerifyController = TextEditingController(),
      _phoneController = TextEditingController();
  String phoneNumber = '';
  final _auth = FirebaseAuth.instance;
  DateTime datetime = DateTime.now();
  String formattedDate = '';
  String email = '';
  String password = '';
  String fullName = '';
  String taxNo = '';
  bool obscurePassword = true, obscureVerifyPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordVerifyController.dispose();
    super.dispose();
  }

  var maskFormatter = MaskTextInputFormatter(
      mask: '+90 (###) ### ## ##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text("Hey! Driver", style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 36),
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
                      autofillHints: const [AutofillHints.name],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Lütfen Vergi Nonuzu giriniz";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        taxNo = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Vergi Numaranızı giriniz',
                        labelText: 'Vergi No',
                        prefixIcon: Icon(
                          Icons.file_copy_rounded,
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
                          return "Lütfen Email adresinizi giriniz";
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
                      inputFormatters: [maskFormatter],
                      controller: _phoneController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Lütfen telefon numaranızı giriniz";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        //phoneNumber = maskFormatter.getUnmaskedText();
                        phoneNumber = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Telefon No',
                        labelText: 'Telefon No',
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                      ),
                      keyboardAppearance: Brightness.dark,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      autofillHints: const [AutofillHints.newPassword],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        hintText: 'Parolanızı oluşturunuz',
                        labelText: 'Parola',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                obscurePassword = !obscurePassword;
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
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                            right: 4,
                            top: 12,
                          ),
                          child: Text(
                            "Parola en az 6 karakterden oluşmalıdır.",
                            style: TextStyle(color: Color(0x61ffffff)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      autofillHints: const [AutofillHints.newPassword],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _passwordVerifyController,
                      obscureText: obscureVerifyPassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Lütfen parolanızı tekrar giriniz";
                        } else if (value != password) {
                          return "Parolalar eşleşmiyor";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Type password again',
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                obscureVerifyPassword = !obscureVerifyPassword;
                              });
                            }
                          },
                          child: Icon(
                            obscureVerifyPassword
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
                            text: 'Kayıt',
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (formKey.currentState!.validate()) {
                                await _signUp();
                              }
                              _passwordController.clear();
                              _passwordVerifyController.clear();
                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    try {
      // burasınında androidden çok bir farkı yok gibi yine firebase authdan aldığımız nesne ile email kayıt olma
      // işlemnini yapıyoruz ve sonrasında kullanıcı bilgileriyle beraber firesbase kayıt işlemini yapıyoruz.
      //

      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _auth.currentUser!.updateDisplayName(fullName);
      _auth.currentUser!.updatePhotoURL(
          'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60');

      String userId = _auth.currentUser!.uid;
      FirebaseDatabase.instance.ref().child("Driver/$userId").set({
        'id': userId,
        'fullName': fullName,
        'emailAddress': email,
        'taxNo': taxNo,
        'phoneNumber': phoneNumber,
        'image':
            'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
      });
      if (mounted) {
        CardWidgets.sweetAlert(context, mounted, "Successfully registered.");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Parola çok zayıf.';
      } else if (e.code == 'invalid-email') {
        message = 'Email adresi geçersiz.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu email adresi zaten kullanılıyor.';
      } else {
        message = 'Uyarı, bir hata oluştu.';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(message),
          content: Text('${e.message}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Uyarı, bir hata oluştu.'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    }
  }
}
