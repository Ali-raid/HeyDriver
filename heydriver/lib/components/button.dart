import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';

class LoginSignupButton extends StatelessWidget {
  final String text;
  final dynamic onTap;

  const LoginSignupButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .button
                ?.copyWith(color: ThemeColors.offWhite),
          ),
        ),
      ),
    );
  }
}

class BuyButton extends StatelessWidget {
  final dynamic onPressed;
  final String text;

  const BuyButton({Key? key, required this.onPressed, this.text = "Buy"})
      : super(key: key);

  @override
  ElevatedButton build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.grayPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: Size(MediaQuery.of(context).size.width / 4, 30),
      ),
      onPressed: onPressed,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: ThemeColors.grayPrimary,
        ),
      ),
    );
  }
}

class SellButton extends StatelessWidget {
  final dynamic onPressed;
  final String text;

  const SellButton({Key? key, required this.onPressed, this.text = "Sell"})
      : super(key: key);

  @override
  ElevatedButton build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.grayPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: Size(MediaQuery.of(context).size.width / 4, 30),
      ),
      onPressed: onPressed,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: ThemeColors.white,
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  TextButton build(BuildContext context) {
    return TextButton(
      child: const Text('Cancel'),
      onPressed: () => Navigator.pop(context),
    );
  }
}
