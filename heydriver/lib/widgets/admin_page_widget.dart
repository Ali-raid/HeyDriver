import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/models/requests.dart';

class AdminPageWidget extends StatefulWidget {
  final int index;
  final Requests requests;
  final List<String> items;
  final String dropdownvalue;
  final void Function(Object?)? updateDropdownValue;
  final void Function(String)? price;
  final void Function()? onPressed;
  final void Function()? onPressedReject;

  const AdminPageWidget({
    super.key,
    required this.index,
    required this.requests,
    required this.updateDropdownValue,
    required this.items,
    required this.dropdownvalue,
    required this.price,
    required this.onPressed,
    required this.onPressedReject,
  });

  @override
  State<AdminPageWidget> createState() => _AdminPageWidgetState();
}

class _AdminPageWidgetState extends State<AdminPageWidget> {
  late TextEditingController textEditingController =
      TextEditingController(text: widget.requests.price.toString());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.offWhite,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.transparent,
              title: Text(
                widget.requests.locationStartName,
                style: const TextStyle(color: ThemeColors.black),
              ),
              subtitle: Text(
                widget.requests.userName,
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
                widget.requests.locationEndName,
                style: const TextStyle(color: ThemeColors.black),
              ),
              subtitle: Text(
                '${widget.requests.totalDistanceValue}km',
                style: const TextStyle(color: ThemeColors.black),
              ),
              leading: const FaIcon(
                FontAwesomeIcons.locationDot,
                color: Colors.red,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Sürücü:'),
                DropdownButton(
                  // Initial Value
                  value: widget.requests.driverName == '' ||
                          widget.requests.driverName == 'null'
                      ? widget.dropdownvalue
                      : widget.requests.driverName,

                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),

                  // Array list of items
                  items: widget.items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: widget.updateDropdownValue,
                ),
              ],
            ),
            const Divider(
              color: ThemeColors.grayPrimary,
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.handHoldingDollar,
                        color: ThemeColors.graySecondary,
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: 120,
                          child: TextField(
                            controller: textEditingController,
                            readOnly: widget.requests.price == 150,
                            onChanged: widget.price,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Fiyat",
                              hintStyle: TextStyle(
                                color: ThemeColors.graySecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Text('TL',
                          style: TextStyle(
                              color: ThemeColors.graySecondary, fontSize: 16)),
                    ],
                  ),
                  InkWell(
                    onTap: widget.onPressed,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Onayla",
                          style:
                              Theme.of(context).textTheme.headline4?.copyWith(
                                    color: ThemeColors.green,
                                  ),
                        ),
                        const FaIcon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8.0,
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.requests.state == 'pending'
                        ? 'Onay Bekliyor'
                        : 'Onaylandı',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  InkWell(
                    onTap: widget.onPressedReject,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Reddet",
                          style:
                              Theme.of(context).textTheme.headline4?.copyWith(
                                    color: ThemeColors.red,
                                  ),
                        ),
                        const FaIcon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
