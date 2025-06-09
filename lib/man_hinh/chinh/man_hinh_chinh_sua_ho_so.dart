import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class ManHinhChinhSuaHoSo extends StatefulWidget {
  final NguoiDung nguoiDung;

  const ManHinhChinhSuaHoSo({super.key, required this.nguoiDung});

  @override
  State<ManHinhChinhSuaHoSo> createState() => _ManHinhChinhSuaHoSoState();
}

class _ManHinhChinhSuaHoSoState extends State<ManHinhChinhSuaHoSo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController = TextEditingController();
  late TextEditingController _moTaController = TextEditingController();
  late TextEditingController _soDienThoaiController = TextEditingController();
  late TextEditingController _diaChiController = TextEditingController();
  late TextEditingController _ngaySinhController = TextEditingController();
  String _gioiTinh = 'Nam';
  File? _anhDaiDien;
  bool _dangLuu = false;

  @override
  void initState() {
    super.initState();
    _layThongTinTuFirebase();
    // _taiNguoiDung();
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

  Future<void> _taiNguoiDung() async {
    final dichVu = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    dichVu.layNguoiDungHienTai(); // cập nhật từ Firebase
    final nguoiDung = dichVu.nguoiDungHienTai!;

    setState(() {
      _hoTenController = TextEditingController(text: nguoiDung.hoTen);
      _moTaController = TextEditingController(text: nguoiDung.moTa);
      _soDienThoaiController =
          TextEditingController(text: nguoiDung.soDienThoai);
      _diaChiController = TextEditingController(text: nguoiDung.diaChi);
      _ngaySinhController = TextEditingController(text: nguoiDung.ngaySinh);
      _gioiTinh = nguoiDung.gioiTinh;
    });
  }

  Future<void> _layThongTinTuFirebase() async {
    try {
      final uid = widget.nguoiDung.ma;
      final snap =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (!snap.exists) return;

      final data = snap.data()!;
      setState(() {
        _hoTenController = TextEditingController(text: data['hoTen'] ?? '');
        _moTaController = TextEditingController(text: data['moTa'] ?? '');
        _soDienThoaiController =
            TextEditingController(text: data['soDienThoai'] ?? '');
        _diaChiController = TextEditingController(text: data['diaChi'] ?? '');
        _ngaySinhController =
            TextEditingController(text: data['ngaySinh'] ?? '');
        _gioiTinh = data['gioiTinh'] ?? 'Nam';
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu người dùng: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải thông tin người dùng')),
      );
    }
  }

  void _hienThiThongBao(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _chonAnhDaiDien() async {
    final picker = ImagePicker();

    // Hiển thị dialog chọn nguồn ảnh
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh bằng Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ Thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage == null) return;

    final file = File(pickedImage.path);
    final exists = await file.exists();
    if (!exists) {
      _hienThiThongBao("Không thể sử dụng ảnh đã chọn.", Colors.red);
      return;
    }

    setState(() {
      _anhDaiDien = file;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _hienThiThongBao("Chưa đăng nhập, không thể upload ảnh.", Colors.red);
      return;
    }

    final url = await uploadAnhDaiDien(file, user.uid);

    if (url != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatarUrl': url});
        _hienThiThongBao("Ảnh đại diện đã được cập nhật!", Colors.green);
      } catch (e) {
        print('Lỗi cập nhật Firestore: $e');
        _hienThiThongBao(
            "Upload ảnh xong nhưng lỗi khi cập nhật.", Colors.orange);
      }
    } else {
      _hienThiThongBao("Lỗi khi upload ảnh đại diện.", Colors.red);
    }
  }

  Future<String?> uploadAnhDaiDien(File file, String userId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final ref =
          FirebaseStorage.instance.ref().child('avatars/$userId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi upload ảnh đại diện: $e');
      return null;
    }
  }

  Future<void> _luuThongTin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _dangLuu = true;
    });

    try {
      String anhDaiDienUrl = widget.nguoiDung.anhDaiDien;

      if (_anhDaiDien != null) {
        final url = await uploadAnhDaiDien(_anhDaiDien!, widget.nguoiDung.ma);
        if (url != null) {
          anhDaiDienUrl = url;
        }
      }

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
        'anhDaiDien': anhDaiDienUrl,
      });
      // Cập nhật lại thông tin người dùng trong ứng dụng
      await Provider.of<DangKiDangNhapEmail>(context, listen: false)
          .layNguoiDungHienTai();

      if (!mounted) return;
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
            onPressed: _dangLuu ? null : () => _luuThongTin(context),
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
                  onPressed: _dangLuu ? null : () => _luuThongTin(context),
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
