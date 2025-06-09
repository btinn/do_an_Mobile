import 'package:flutter/material.dart';
import 'package:do_an/man_hinh/xac_thuc/man_hinh_quen_mat_khau.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chinh.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/tien_ich/thanh_phan_mang_xa_hoi.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  bool _anMatKhau = true;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  void _xuLyDangNhap() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _dangXuLy = true);

      // Lấy từ Provider, không tạo mới
      final dichVuXacThuc =
          Provider.of<DangKiDangNhapEmail>(context, listen: false);

      final thanhCong = await dichVuXacThuc.signInWithEmail(
        _emailController.text.trim(),
        _matKhauController.text.trim(),
      );

      if (mounted) {
        if (thanhCong != null) {
          // Đợi lấy người dùng xong
          await dichVuXacThuc.layNguoiDungHienTai();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ManHinhChinh()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() => _dangXuLy = false);
      }
    }
  }

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
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại!',
                style: ChuDe.kieuChuTieuDe,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để khám phá hàng ngàn công thức nấu ăn',
                style: ChuDe.kieuChuNoiDungPhu,
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email của bạn',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              const Text(
                'Mật Khẩu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _matKhauController,
                obscureText: _anMatKhau,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu của bạn',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _anMatKhau ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _anMatKhau = !_anMatKhau;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 600))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManHinhQuenMatKhau(),
                      ),
                    );
                  },
                  child: const Text('Quên Mật Khẩu?'),
                ),
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 800)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _dangXuLy ? null : _xuLyDangNhap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _dangXuLy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Đăng Nhập'),
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 1000))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Hoặc đăng nhập bằng tài khoản mạng xã hội',
                  style: ChuDe.kieuChuNoiDungPhu,
                ),
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 1200)),
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
                    onPressed: () {},
                  ),
                ],
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 1400)),
            ],
          ),
        ),
      ),
    );
  }
}
