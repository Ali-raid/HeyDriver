import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/main_screen.dart';
import 'package:heydriver/themes/app_constants.dart';
import 'package:heydriver/widgets/pincode_alert_dialog.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Müşterinin giriş yapacağı sayfa
  final formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String phoneNumber = '';
  String pinCode = '';
  bool isLoading = false;
  bool isDone = false;
  bool isReady = false;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  // bu pin theme kodu yazdığımız yerin dekorasyonunu belrliyor
  final defaultPinTheme = const PinTheme(
    width: 60,
    height: 64,
    decoration: BoxDecoration(color: Color.fromRGBO(159, 132, 193, 0.8)),
  );

  @override
  void dispose() {
    _phoneController.dispose();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  loginWithSMSCode(String verificationId, String smsCode) {
    //Smscode ile giriş yapma
    Navigator.of(context).pop();
    var credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    FirebaseAuth.instance.signInWithCredential(credential).whenComplete(
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const MainScreen(),
            )));
  }

  // bu kısım telefon numarasını yazdığında direkt olarak 5 ten başlamasını sağlayan maskeleme
  var maskFormatter = MaskTextInputFormatter(
      mask: '+90 (###) ### ## ##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  void _loginWithPhone() async {
    //Telefon numarası ile giriş yapma hazır kod içini biz dolduruyoruz
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('verification completed tetiklendi');
        debugPrint(credential.toString());
        // Onaylama kodu otomatik olarak alındığında burası tetiklenir
        //doğru yazdıysan eğer giriş yapmanı sağlayan yönlendirme kodu seni ana sayfaya götürür
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .whenComplete(() => Navigator.of(context).push(MaterialPageRoute(
                  //builder: (context) => const MainScreen(),
                  builder: (context) => const MainScreen(),
                )));
      },
      verificationFailed: (FirebaseAuthException e) {
        // Do something when verification fails
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        // Do something when code is sent
        // Kod gönderildiğinde pincode yazdığımız sayfaya yönlendirme yapıyor
        debugPrint("CODE SENT");
        showDialog(
            context: context,
            builder: (_) {
              //return PinCodeAlertDialog(verificationId: verificationId);
              return PinCodeAlertDialog(
                verificationId: verificationId,
                isFake: false,
              );
            });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('code auto retrieval timeout');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.black,
      body: Form(
        key: formKey,
        onChanged: () {
          setState(() {
            isDone = _phoneController.text.isNotEmpty;
          });
        },
        child: SafeArea(
          maintainBottomViewPadding: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: AppConstants.paddingHorizontal,
                    right: AppConstants.paddingHorizontal,
                    top: 36.0,
                    bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kayıtlı\nTelefon Numaranızı\ngiriniz',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: ThemeColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      'Telefon numaran ile giriş yap',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ThemeColors.white,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingHorizontal,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
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
                          hintStyle: TextStyle(
                            color: ThemeColors.white,
                          ),
                          hintText: 'Telefon No',
                          labelStyle: TextStyle(
                            color: ThemeColors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: ThemeColors.white,
                          ),
                        ),
                        keyboardAppearance: Brightness.dark,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Flex(
                mainAxisSize: MainAxisSize.max,
                direction: Axis.horizontal,
                children: [
                  /*  Expanded(
                      flex: 1,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'YENİ KULLANICI',
                            style: TextStyle(color: ThemeColors.white),
                          ))), */
                  Expanded(
                      flex: 1,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: ThemeColors.white),
                          onPressed: () {
                            _loginWithPhone();
                          },
                          child: const Text(
                            'GİRİŞ YAP',
                            style: TextStyle(
                              color: ThemeColors.black,
                            ),
                          ))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
