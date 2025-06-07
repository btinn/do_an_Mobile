import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:provider/provider.dart';
import 'package:do_an/dich_vu/dich_vu_cai_dat.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManHinhChinhSuaHoSo extends StatefulWidget {
  final NguoiDung nguoiDung;

  const ManHinhChinhSuaHoSo({
    super.key,
    required this.nguoiDung,
  });

  @override
  State<ManHinhChinhSuaHoSo> createState() => _ManHinhChinhSuaHoSoState();
}

class _ManHinhChinhSuaHoSoState extends State<ManHinhChinhSuaHoSo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _emailController;
  late TextEditingController _moTaController;
  late TextEditingController _soDienThoaiController;
  late TextEditingController _diaChiController;
  late TextEditingController _ngaySinhController;
  String _gioiTinh = 'Nam';
  File? _anhDaiDien;
  bool _dangLuu = false;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.nguoiDung.hoTen);
    _emailController = TextEditingController(text: widget.nguoiDung.email);
    _moTaController = TextEditingController(text: widget.nguoiDung.moTa);
    _soDienThoaiController =
        TextEditingController(text: widget.nguoiDung.soDienThoai);
    _diaChiController = TextEditingController(text: widget.nguoiDung.diaChi);
    _ngaySinhController =
        TextEditingController(text: widget.nguoiDung.ngaySinh);
    _gioiTinh = widget.nguoiDung.gioiTinh;
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _moTaController.dispose();
    _soDienThoaiController.dispose();
    _diaChiController.dispose();
    _ngaySinhController.dispose();
    super.dispose();
  }

  Future<void> _chonAnhDaiDien() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _anhDaiDien = File(image.path);
      });
    }
  }

  Future<void> _luuThongTin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _dangLuu = true;
      });

      // Giả lập thời gian xử lý
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // final dichVuDuLieu = Provider.of<DichVuDuLieu>(context, listen: false);

        // Cập nhật thông tin người dùng
        final nguoiDungCapNhat = widget.nguoiDung.copyWith(
          hoTen: _hoTenController.text,
          email: _emailController.text,
          moTa: _moTaController.text,
          soDienThoai: _soDienThoaiController.text,
          diaChi: _diaChiController.text,
          ngaySinh: _ngaySinhController.text,
          gioiTinh: _gioiTinh,
          // Trong thực tế, cần xử lý upload ảnh lên server và lấy URL
          anhDaiDien: _anhDaiDien != null
              ? 'assets/images/avatar_updated.jpg'
              : widget.nguoiDung.anhDaiDien,
        );

        // dichVuDuLieu.capNhatThongTinNguoiDung(nguoiDungCapNhat);

        setState(() {
          _dangLuu = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin hồ sơ đã được cập nhật'),
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
        title: const Text('Chỉnh Sửa Hồ Sơ'),
        actions: [
          TextButton.icon(
            onPressed: _dangLuu ? null : _luuThongTin,
            icon: _dangLuu
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: ChuDe.mauChinh,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check),
            label: const Text('Lưu'),
            style: TextButton.styleFrom(
              foregroundColor: ChuDe.mauChinh,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh đại diện
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _anhDaiDien != null
                          ? FileImage(_anhDaiDien!) as ImageProvider
                          : AssetImage(widget.nguoiDung.anhDaiDien),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _chonAnhDaiDien,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ChuDe.mauChinh,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Thông tin cá nhân
              const Text(
                'Thông Tin Cá Nhân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Họ tên
              TextFormField(
                controller: _hoTenController,
                decoration: const InputDecoration(
                  labelText: 'Tên Người Dùng',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô Tả',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              TextFormField(
                controller: _soDienThoaiController,
                decoration: const InputDecoration(
                  labelText: 'Số Điện Thoại',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Địa chỉ
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(
                  labelText: 'Địa Chỉ',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Ngày sinh
              TextFormField(
                controller: _ngaySinhController,
                decoration: const InputDecoration(
                  labelText: 'Ngày Sinh (DD/MM/YYYY)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),

              // Giới tính
              const Text(
                'Giới Tính',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nam'),
                      value: 'Nam',
                      groupValue: _gioiTinh,
                      onChanged: (value) {
                        setState(() {
                          _gioiTinh = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nữ'),
                      value: 'Nữ',
                      groupValue: _gioiTinh,
                      onChanged: (value) {
                        setState(() {
                          _gioiTinh = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _dangLuu ? null : _luuThongTin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChuDe.mauChinh,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _dangLuu
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Lưu Thông Tin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
