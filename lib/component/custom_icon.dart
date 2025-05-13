import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final IconData iconData;
  final GestureTapCallback onPressed;

  const CustomIcon({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(iconData, size: 30.0, color: Colors.white),
    );
  }
}
