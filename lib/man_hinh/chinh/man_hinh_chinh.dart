import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_trang_chu.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_tim_kiem.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_them_cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_yeu_thich.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_ho_so.dart';

class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  int _chiSoHienTai = 0;
  
  final List<Widget> _manHinh = [
    const ManHinhTrangChu(),
    const ManHinhTimKiem(),
    const ManHinhThemCongThuc(),
    const ManHinhYeuThich(),
    const ManHinhHoSo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _manHinh[_chiSoHienTai],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _chiSoHienTai,
          onTap: (index) {
            setState(() {
              _chiSoHienTai = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: ChuDe.mauChinh,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang Chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Tìm Kiếm',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ChuDe.mauChinh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              label: 'Thêm',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Yêu Thích',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Hồ Sơ',
            ),
          ],
        ),
      ),
    );
  }
}
