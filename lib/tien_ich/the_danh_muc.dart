import 'package:do_an/giao_dien/chu_de.dart';
import 'package:flutter/material.dart';

class TheDanhMuc extends StatelessWidget {
  final String nhan;
  final bool daDuocChon;
  final VoidCallback onTap;

  const TheDanhMuc({
    super.key,
    required this.nhan,
    required this.daDuocChon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: daDuocChon ? ChuDe.mauChinh : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: daDuocChon ? ChuDe.mauChinh : Colors.grey.shade300,
          ),
          boxShadow: daDuocChon
              ? [
                  BoxShadow(
                    color: ChuDe.mauChinh.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          nhan,
          style: TextStyle(
            color: daDuocChon ? Colors.white : Colors.black,
            fontWeight: daDuocChon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
