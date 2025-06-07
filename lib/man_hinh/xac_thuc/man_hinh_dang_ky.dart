import 'package:flutter/material.dart';
import 'package:do_an/man_hinh/xac_thuc/man_hinh_dang_nhap.dart';
import 'package:do_an/giao_dien/chu_de.dart';
// import 'package:do_an/tien_ich/thanh_phan_mang_xa_hoi.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:provider/provider.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _nhapLaiMatKhauController = TextEditingController();
  bool _anMatKhau = true;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _nhapLaiMatKhauController.dispose();
    super.dispose();
  }

  void _xuLyDangKy() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _dangXuLy = true;
      });

      final dichVuXacThuc =
          Provider.of<DangKiDangNhapEmail>(context, listen: false);

      try {
        final nguoiDung = await dichVuXacThuc.signUpWithEmail(
          _emailController.text.trim(),
          _matKhauController.text,
          _hoTenController.text.trim(),
        );

        if (!mounted) return;

        if (nguoiDung != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thành công! Hãy kiểm tra email và xác minh để đăng nhập.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thất bại. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Tài Khoản'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tham gia cộng đồng ẩm thực!',
                style: ChuDe.kieuChuTieuDe,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Tạo tài khoản để chia sẻ và khám phá công thức nấu ăn',
                style: ChuDe.kieuChuNoiDungPhu,
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              const Text(
                'Tên Người Dùng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hoTenController,
                decoration: const InputDecoration(
                  hintText: 'Tên người dùng của bạn',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
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
                      delay: const Duration(milliseconds: 600))
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
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 800))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
              const Text(
                'Nhập Lại Mật Khẩu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nhapLaiMatKhauController,
                obscureText: _anMatKhau,
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
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
                    return 'Vui lòng nhập lại mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  if (value != _matKhauController.text) {
                    return 'Mật khẩu nhập lại không khớp';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 800))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _dangXuLy ? null : _xuLyDangKy,
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
                    : const Text('Tạo Tài Khoản'),
              )
                  .animate()
                  .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 1000))
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản?',
                    style: ChuDe.kieuChuNoiDungPhu,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManHinhDangNhap(),
                        ),
                      );
                    },
                    child: const Text('Đăng Nhập'),
                  ),
                ],
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 1200)),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Hoặc đăng ký bằng tài khoản mạng xã hội',
                  style: ChuDe.kieuChuNoiDungPhu,
                ),
              ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 1400)),

              const SizedBox(height: 24),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ThanhPhanMangXaHoi(
              //       bieuTuong: 'assets/icons/google.png',
              //       onPressed: _dangXuLy ? null : _xuLyDangNhapGoogle,
              //     ),
              //     const SizedBox(width: 16),
              //     ThanhPhanMangXaHoi(
              //       bieuTuong: 'assets/icons/facebook.png',
              //       onPressed: () {},
              //     ),
              //     const SizedBox(width: 16),
              //     ThanhPhanMangXaHoi(
              //       bieuTuong: 'assets/icons/apple.png',
              //       onPressed: () {},
              //     ),
              //   ],
              // ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 1600)),
            ],
          ),
        ),
      ),
    );
  }
}
