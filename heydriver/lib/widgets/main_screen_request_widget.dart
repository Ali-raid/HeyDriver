import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/constants/theme_colors.dart';

class MainScreenRequestWidget extends StatefulWidget {
  final String origin;
  final String destination;
  final String distance;
  final String duration;
  final void Function()? onPressed;
  const MainScreenRequestWidget(
      {super.key,
      required this.origin,
      required this.destination,
      required this.distance,
      required this.duration,
      required this.onPressed});

  @override
  State<MainScreenRequestWidget> createState() =>
      _MainScreenRequestWidgetState();
}

class _MainScreenRequestWidgetState extends State<MainScreenRequestWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: ThemeColors.grayTertiary,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            tileColor: Colors.transparent,
            title: Text(
              widget.origin,
              style: const TextStyle(color: ThemeColors.black),
            ),
            leading: const FaIcon(
              FontAwesomeIcons.locationCrosshairs,
              color: ThemeColors.green,
            ),
          ),
          ListTile(
            tileColor: Colors.transparent,
            title: Text(
              widget.destination,
              style: const TextStyle(color: ThemeColors.black),
            ),
            leading: const FaIcon(
              FontAwesomeIcons.locationDot,
              color: Colors.red,
            ),
          ),
          const Divider(
            color: ThemeColors.grayPrimary,
            thickness: 2.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FaIcon(
                  FontAwesomeIcons.car,
                  color: ThemeColors.graySecondary,
                ),
                Column(
                  children: [
                    Text(
                      widget.distance,
                      style: const TextStyle(color: ThemeColors.black),
                    ),
                    const Text(
                      'Mesafe',
                      style: TextStyle(color: ThemeColors.graySecondary),
                    ),
                  ],
                ),
                const FaIcon(
                  FontAwesomeIcons.clock,
                  color: ThemeColors.graySecondary,
                ),
                Column(
                  children: [
                    Text(
                      widget.duration,
                      style: const TextStyle(color: ThemeColors.black),
                    ),
                    const Text(
                      'Süre',
                      style: TextStyle(color: ThemeColors.graySecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: widget.onPressed,
            child: const Text('İsteği Onayla'),
          ),
        ],
      ),
    );
  }
}
