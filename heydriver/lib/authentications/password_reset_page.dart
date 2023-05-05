import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heydriver/components/button.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen(this.email, {Key? key}) : super(key: key);

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  // Parola sıfırlama sayfası
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String email = widget.email.trim();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text("Hey! Driver"),
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
                      "Şifremi Unuttum",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      autofillHints: const [AutofillHints.email],
                      initialValue: email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value.trim();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Lütfeen e-posta adresinizi giriniz";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Lütfen e-posta adresinizi giriniz',
                        labelText: 'E-Mail',
                        prefixIcon: Icon(
                          Icons.email,
                        ),
                      ),
                      keyboardAppearance: Brightness.dark,
                    ),
                    const SizedBox(height: 36),
                    isLoading
                        ? const CircularProgressIndicator()
                        : LoginSignupButton(
                            text: 'Parolamı Sıfırla',
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (formKey.currentState!.validate()) {
                                await _resetPassword();
                              }
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

  Future<void> _resetPassword() async {
    try {
      // reset password için firebase in hazır kodu emailini göndermen yeterli
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {}
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Email Gönderildi"),
          content:
              Text("Parola sıfırlama bağlantısı $email adresine gönderildi"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi';
      } else {
        message = 'Oops! Bir şeyler ters gitti';
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
          title: const Text('Ops! Bir şeyler ters gitti'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }
}
