import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManHinhQuenMatKhau extends StatefulWidget {
  const ManHinhQuenMatKhau({super.key});

  @override
  State<ManHinhQuenMatKhau> createState() => _ManHinhQuenMatKhauState();
}

class _ManHinhQuenMatKhauState extends State<ManHinhQuenMatKhau> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _dangXuLy = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _xuLyQuenMatKhau() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _dangXuLy = true;
      });
      
      // Giả lập thời gian xử lý
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đường dẫn đặt lại mật khẩu đã được gửi đến email của bạn'),
            backgroundColor: ChuDe.mauXanhLa,
          ),
        );
        
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên Mật Khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đặt Lại Mật Khẩu',
                style: ChuDe.kieuChuTieuDe,
              ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng nhập địa chỉ email để đặt lại mật khẩu',
                style: ChuDe.kieuChuNoiDungPhu,
              ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 200)).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
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
              ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 400)).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _dangXuLy ? null : _xuLyQuenMatKhau,
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
                    : const Text('Gửi Đường Dẫn Đặt Lại'),
              ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 600)).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
