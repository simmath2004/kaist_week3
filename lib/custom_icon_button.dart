import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String iconPath; // PNG 이미지 경로
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(iconPath,
              color: color, width: 30, height: 30), // PNG 이미지를 사용
          Text(label, style: TextStyle(color: color)), // Text style
        ],
      ),
    );
  }
}
