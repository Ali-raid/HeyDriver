import 'package:flutter/material.dart';
import 'package:heydriver/constants/theme_colors.dart';

class CardWidgets {
  static ScaffoldFeatureController? sweetAlert(
      BuildContext context, bool mounted, String value) {
    if (mounted) {
      final SnackBar snackBar = SnackBar(
        backgroundColor: ThemeColors.grayPrimary,
        content: Text(
          value,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        action: SnackBarAction(
          label: 'Hide',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return null;
  }
}
