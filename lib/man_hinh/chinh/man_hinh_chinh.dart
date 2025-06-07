import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_trang_chu.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_tim_kiem.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_them_cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_hop_thu.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_ho_so.dart';

class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  int _chiSoHienTai = 0;

  late List<Widget> _manHinh;

  @override
  void initState() {
    super.initState();
    _manHinh = [
      ManHinhTrangChu(
        onChuyenSangTimKiem: () {
          setState(() {
            _chiSoHienTai = 1; // Chuyển sang tab tìm kiếm (index 1)
          });
        },
      ),
      const ManHinhTimKiem(),
      const ManHinhThemCongThuc(),
      const ManHinhHopThu(), // Thay đổi từ ManHinhYeuThich thành ManHinhHopThu
      const ManHinhHoSo(),
    ];
  }

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
              icon: Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message),
              label: 'Hộp Thư',
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
