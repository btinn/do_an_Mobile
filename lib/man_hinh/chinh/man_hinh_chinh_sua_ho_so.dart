import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManHinhChinhSuaHoSo extends StatefulWidget {
  final NguoiDung nguoiDung;

  const ManHinhChinhSuaHoSo({super.key, required this.nguoiDung});

  @override
  State<ManHinhChinhSuaHoSo> createState() => _ManHinhChinhSuaHoSoState();
}

class _ManHinhChinhSuaHoSoState extends State<ManHinhChinhSuaHoSo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
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
    _moTaController.dispose();
    _soDienThoaiController.dispose();
    _diaChiController.dispose();
    _ngaySinhController.dispose();
    super.dispose();
  }

  Future<void> _chonAnhDaiDien() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _anhDaiDien = File(image.path);
      });
    }
  }

  Future<void> _luuThongTin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangLuu = true;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection('user')
          .doc(widget.nguoiDung.ma);

      await docRef.update({
        'hoTen': _hoTenController.text,
        'moTa': _moTaController.text,
        'soDienThoai': _soDienThoaiController.text,
        'diaChi': _diaChiController.text,
        'ngaySinh': _ngaySinhController.text,
        'gioiTinh': _gioiTinh,
        'anhDaiDien': _anhDaiDien != null
            ? 'assets/images/avatar_updated.jpg' // bạn nên upload lên Firebase Storage
            : widget.nguoiDung.anhDaiDien,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thông tin hồ sơ đã được cập nhật'),
          backgroundColor: ChuDe.mauXanhLa,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Lỗi cập nhật hồ sơ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi cập nhật'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _dangLuu = false;
      });
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
            style: TextButton.styleFrom(foregroundColor: ChuDe.mauChinh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 47,
                      backgroundImage: _anhDaiDien != null
                          ? FileImage(_anhDaiDien!)
                          : (widget.nguoiDung.anhDaiDien.startsWith('http')
                                  ? NetworkImage(widget.nguoiDung.anhDaiDien)
                                  : AssetImage(widget.nguoiDung.anhDaiDien))
                              as ImageProvider,
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
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _xayDungTextField(
                  'Tên Người Dùng', _hoTenController, Icons.person,
                  required: true),
              _xayDungTextField('Mô Tả', _moTaController, Icons.description,
                  maxLines: 3),
              _xayDungTextField(
                  'Số Điện Thoại', _soDienThoaiController, Icons.phone),
              _xayDungTextField(
                  'Địa Chỉ', _diaChiController, Icons.location_on),
              _xayDungTextField('Ngày Sinh (DD/MM/YYYY)', _ngaySinhController,
                  Icons.calendar_today),
              const SizedBox(height: 16),
              const Text('Giới Tính',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nam'),
                      value: 'Nam',
                      groupValue: _gioiTinh,
                      onChanged: (value) => setState(() => _gioiTinh = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Nữ'),
                      value: 'Nữ',
                      groupValue: _gioiTinh,
                      onChanged: (value) => setState(() => _gioiTinh = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Lưu Thông Tin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _xayDungTextField(
      String label, TextEditingController controller, IconData icon,
      {bool required = false, bool email = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        maxLines: maxLines,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (email && value != null && !value.contains('@')) {
            return 'Email không hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}
