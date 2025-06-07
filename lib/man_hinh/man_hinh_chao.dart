import 'package:flutter/material.dart';
import 'package:do_an/man_hinh/man_hinh_gioi_thieu.dart';
import 'package:do_an/giao_dien/chu_de.dart';

class ManHinhChao extends StatefulWidget {
  const ManHinhChao({super.key});

  @override
  State<ManHinhChao> createState() => _ManHinhChaoState();
}

class _ManHinhChaoState extends State<ManHinhChao> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _animationController.forward();
    _chuyenManHinh();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  _chuyenManHinh() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ManHinhGioiThieu(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChuDe.mauChinh,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Sử dụng hình ảnh từ assets
            Image.asset(
              'assets/images/anh_nen.png',
              width: 400,
              height: 400,
            ),
            const SizedBox(height: 20),
            Text(
              'Ẩm Thực Việt',
              style: ChuDe.kieuChuTieuDe.copyWith(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Hương Vị Quê Hương',
              style: ChuDe.kieuChuNoiDungPhu.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}