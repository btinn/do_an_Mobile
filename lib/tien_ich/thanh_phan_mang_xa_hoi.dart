import 'package:flutter/material.dart';

class ThanhPhanMangXaHoi extends StatelessWidget {
  final String bieuTuong;
  final VoidCallback? onPressed;

  const ThanhPhanMangXaHoi({
    super.key,
    required this.bieuTuong,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Center(
          child: Image.asset(
            bieuTuong,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
