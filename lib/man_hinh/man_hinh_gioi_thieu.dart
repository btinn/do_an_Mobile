import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/man_hinh/xac_thuc/man_hinh_dang_nhap.dart';
import 'package:do_an/man_hinh/xac_thuc/man_hinh_dang_ky.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chinh.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/tien_ich/thanh_phan_mang_xa_hoi.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ManHinhGioiThieu extends StatefulWidget {
  const ManHinhGioiThieu({super.key});

  @override
  State<ManHinhGioiThieu> createState() => _ManHinhGioiThieuState();
}

class _ManHinhGioiThieuState extends State<ManHinhGioiThieu> {
  final PageController _pageController = PageController();
  bool _dangXuLy = false;

  final List<Map<String, dynamic>> _trangGioiThieu = [
    {
      'tieuDe': 'Khám Phá Ẩm Thực Việt',
      'moTa': 'Hàng ngàn công thức nấu ăn đặc sắc từ khắp ba miền đất nước',
      'hinhAnh': 'assets/images/anh_1.jpg',
    },
    {
      'tieuDe': 'Chia Sẻ Công Thức',
      'moTa': 'Chia sẻ bí quyết nấu ăn của bạn với cộng đồng yêu ẩm thực',
      'hinhAnh': 'assets/images/anh_2.jpg',
    },
    {
      'tieuDe': 'Kết Nối Cộng Đồng',
      'moTa':
          'Tham gia thảo luận, đánh giá và học hỏi từ những đầu bếp tài năng',
      'hinhAnh': 'assets/images/anh_3.jpg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Xử lý đăng nhập Google
  void _xuLyDangNhapGoogle() async {
    setState(() {
      _dangXuLy = true;
    });

    try {
      final thanhCong =
          await Provider.of<DangKiDangNhapEmail>(context, listen: false)
              .signInWithGoogle();

      if (mounted) {
        if (thanhCong != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ManHinhChinh()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập Google thất bại. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString();
        if (message.contains('account-exists-with-different-credential')) {
          message =
              'Tài khoản này đã được đăng ký bằng phương thức khác. Hãy đăng nhập bằng email và mật khẩu.';
        } else {
          message = message.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _trangGioiThieu.length,
                itemBuilder: (context, index) {
                  return _xayDungTrangGioiThieu(
                    _trangGioiThieu[index]['tieuDe'],
                    _trangGioiThieu[index]['moTa'],
                    _trangGioiThieu[index]['hinhAnh'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _trangGioiThieu.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: ChuDe.mauChinh,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManHinhDangNhap()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Đăng Nhập Với Email'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManHinhDangKy()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ChuDe.mauChinh,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: ChuDe.mauChinh),
                    ),
                    child: const Text('Tạo Tài Khoản'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hoặc đăng nhập bằng tài khoản mạng xã hội',
                    style: ChuDe.kieuChuNoiDungPhu,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThanhPhanMangXaHoi(
                        bieuTuong: 'assets/icons/google.png',
                        onPressed: _dangXuLy ? null : _xuLyDangNhapGoogle,
                      ),
                      const SizedBox(width: 16),
                      ThanhPhanMangXaHoi(
                        bieuTuong: 'assets/icons/facebook.png',
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      ThanhPhanMangXaHoi(
                        bieuTuong: 'assets/icons/apple.png',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ManHinhChinh()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungTrangGioiThieu(String tieuDe, String moTa, String hinhAnh) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              hinhAnh,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            tieuDe,
            style: ChuDe.kieuChuTieuDe,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            moTa,
            style: ChuDe.kieuChuNoiDungPhu,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
