import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heydriver/deneme/driver_home_page.dart';
import 'package:heydriver/deneme/main_screen.dart';
import 'package:heydriver/widgets/card_widget.dart';
import 'package:pinput/pinput.dart';

class PinCodeAlertDialog extends StatefulWidget {
  final String verificationId;
  final bool isFake;
  const PinCodeAlertDialog({
    Key? key,
    required this.verificationId,
    required this.isFake,
  }) : super(key: key);

  @override
  PinCodeAlertDialogState createState() => PinCodeAlertDialogState();
}

class PinCodeAlertDialogState extends State<PinCodeAlertDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String pinCode = '';

  bool isLoading = false;
  bool isDone = false;
  bool isReady = false;

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(
        color: Colors.black.withOpacity(0.5),
        width: 1.0,
      ),
    ),
  );

  final focusedPinTheme = PinTheme(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(
        color: Colors.green,
        width: 2.0,
      ),
    ),
  );

  Future<void> loginWithSMSCode(String verificationId, String smsCode) async {
//    Navigator.of(context).pop();
    var credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    if (mounted) {}
    await FirebaseAuth.instance.signInWithCredential(credential).whenComplete(
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          ),
        );
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Telefonunuza Gelen Kodu Giriniz"),
            const SizedBox(height: 10),
            Pinput(
              length: 6,
              autofocus: true,
              controller: controller,
              focusNode: focusNode,
              onChanged: (val) {
                if (val.length < 6) {
                  setState(() {
                    isReady = false;
                  });
                }
              },
              onCompleted: (value) {
                setState(() {
                  isReady = true;
                });
              },
              separator: Container(
                width: 5,
                color: Colors.white,
              ),
              defaultPinTheme: defaultPinTheme,
              showCursor: true,
              focusedPinTheme: focusedPinTheme,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: isReady == true
                      ? () {
                          if (widget.isFake) {
                            if (controller.length < 6) {
                              CardWidgets.sweetAlert(context, mounted,
                                  'Gelen Code 6 haneli olmalıdır!');
                              return;
                            }
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const DriverHomePage(),
                              ),
                            );
                          } else {
                            loginWithSMSCode(widget.verificationId, '123456');
                          }
                        }
                      : null,
                  child: const Text('Gönder')),
            ),
          ],
        ),
      ),
      //actions: const [],
    );
  }
}
