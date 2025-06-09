import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:path/path.dart' as path;

class ManHinhThemCongThuc extends StatefulWidget {
  const ManHinhThemCongThuc({super.key});

  @override
  State<ManHinhThemCongThuc> createState() => _ManHinhThemCongThucState();
}

class _ManHinhThemCongThucState extends State<ManHinhThemCongThuc> {
  final _formKey = GlobalKey<FormState>();
  final _tenMonController = TextEditingController();
  final _thoiGianNauController = TextEditingController();
  final _khauPhanController = TextEditingController();
  final _moTaController = TextEditingController();

  String _loaiDuocChon = 'Món Bắc';
  final List<String> _danhSachLoai = [
    'Món Bắc',
    'Món Trung',
    'Món Nam',
    'Món Chay',
    'Món Tráng Miệng',
    'Đồ Uống',
  ];

  final List<TextEditingController> _nguyenLieuControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _buocThucHienControllers = [
    TextEditingController()
  ];

  File? _hinhAnh;
  bool _dangXuLy = false;
  int _buocHienTai = 0;
  final PageController _pageController = PageController();
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();

  // Danh sách hình ảnh mặc định cho các loại món ăn
  final Map<String, String> _hinhAnhMacDinh = {
    'Món Bắc': 'assets/images/mon_bac.jpg',
    'Món Trung': 'assets/images/mon_trung.jpg',
    'Món Nam': 'assets/images/mon_nam.jpg',
    'Món Chay': 'assets/images/mon_chay.jpg',
    'Món Tráng Miệng': 'assets/images/trang_mieng.jpg',
    'Đồ Uống': 'assets/images/do_uong.jpg',
  };

  @override
  void dispose() {
    _tenMonController.dispose();
    _thoiGianNauController.dispose();
    _khauPhanController.dispose();
    _moTaController.dispose();
    _pageController.dispose();

    for (var controller in _nguyenLieuControllers) {
      controller.dispose();
    }

    for (var controller in _buocThucHienControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _chonHinhAnh() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Hiển thị dialog để chọn nguồn hình ảnh
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn hình ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          final file = File(image.path);
          final exists = await file.exists();

          if (exists) {
            setState(() {
              _hinhAnh = file;
            });
          } else {
            _hienThiThongBao(
              'Hình ảnh không tồn tại trên thiết bị. (Máy ảo có thể không hỗ trợ camera)',
              Colors.red,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi chọn hình ảnh: $e');
      _hienThiThongBao(
          'Không thể chọn hình ảnh. Vui lòng thử lại!', Colors.red);
    }
  }

  Future<String?> _uploadHinhAnhToFirebase(File hinhAnh, String uid) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${hinhAnh.path.split('/').last}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cong_thuc_images/$uid/$fileName');

      final uploadTask = await storageRef.putFile(hinhAnh);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Lỗi upload hình ảnh: $e');
      return null;
    }
  }

  void _themNguyenLieu() {
    setState(() {
      _nguyenLieuControllers.add(TextEditingController());
    });
  }

  void _xoaNguyenLieu(int index) {
    if (_nguyenLieuControllers.length > 1) {
      setState(() {
        _nguyenLieuControllers[index].dispose();
        _nguyenLieuControllers.removeAt(index);
      });
    }
  }

  void _themBuocThucHien() {
    setState(() {
      _buocThucHienControllers.add(TextEditingController());
    });
  }

  void _xoaBuocThucHien(int index) {
    if (_buocThucHienControllers.length > 1) {
      setState(() {
        _buocThucHienControllers[index].dispose();
        _buocThucHienControllers.removeAt(index);
      });
    }
  }

  void _chuyenBuocTiepTheo() {
    if (_buocHienTai < 2) {
      // Kiểm tra dữ liệu trước khi chuyển bước
      if (_buocHienTai == 0) {
        if (_tenMonController.text.isEmpty) {
          _hienThiThongBao('Vui lòng điền tên món ăn', Colors.red);
          return;
        }
      } else if (_buocHienTai == 1) {
        if (_nguyenLieuControllers
            .any((controller) => controller.text.isEmpty)) {
          _hienThiThongBao(
              'Vui lòng điền đầy đủ thông tin nguyên liệu', Colors.red);
          return;
        }
      }

      setState(() {
        _buocHienTai++;
      });
      _pageController.animateToPage(
        _buocHienTai,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _chuyenBuocTruocDo() {
    if (_buocHienTai > 0) {
      setState(() {
        _buocHienTai--;
      });
      _pageController.animateToPage(
        _buocHienTai,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _hienThiThongBao(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _luuCongThuc() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra các bước thực hiện
    if (_buocThucHienControllers.any((controller) => controller.text.isEmpty)) {
      _hienThiThongBao('Vui lòng điền đầy đủ các bước thực hiện', Colors.red);
      return;
    }

    // Hiển thị dialog loading
    _hienThiDialogLoading();

    try {
      final dangNhapService =
          Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung == null) {
        _dongDialogLoading();
        _hienThiThongBao(
            'Không thể xác định người dùng. Vui lòng đăng nhập lại!',
            Colors.red);
        return;
      }

      // Xử lý hình ảnh trong background
      String hinhAnhPath;
      if (_hinhAnh != null) {
        final uploadedUrl =
            await _uploadHinhAnhToFirebase(_hinhAnh!, nguoiDung.ma);
        hinhAnhPath = uploadedUrl ??
            _hinhAnhMacDinh[_loaiDuocChon] ??
            'assets/images/default_food.jpg';
      } else {
        hinhAnhPath =
            _hinhAnhMacDinh[_loaiDuocChon] ?? 'assets/images/default_food.jpg';
      }

      final congThucMoi = CongThuc(
        ma: DateTime.now().millisecondsSinceEpoch.toString(),
        tenMon: _tenMonController.text.trim(),
        hinhAnh: hinhAnhPath,
        loai: _loaiDuocChon,
        thoiGianNau: int.tryParse(_thoiGianNauController.text) ?? 30,
        khauPhan: int.tryParse(_khauPhanController.text) ?? 2,
        diemDanhGia: 0,
        luotThich: 0,
        luotXem: 0,
        nguyenLieu: _nguyenLieuControllers.map((c) => c.text.trim()).toList(),
        cachLam: _buocThucHienControllers.map((c) => c.text.trim()).toList(),
        tacGia: nguoiDung.hoTen,
        anhTacGia: nguoiDung.anhDaiDien,
        uid: nguoiDung.ma,
        daThich: false,
        danhSachBinhLuan: [],
        danhSachDanhGia: [],
      );

      // Lưu vào Firebase
      final thanhCong = await _dichVuCongThuc.themCongThuc(congThucMoi);

      _dongDialogLoading();

      if (thanhCong) {
        _hienThiDialogThanhCong();
      } else {
        _hienThiThongBao(
            'Có lỗi xảy ra khi đăng công thức. Vui lòng thử lại!', Colors.red);
      }
    } catch (e) {
      _dongDialogLoading();
      debugPrint('Lỗi khi lưu công thức: $e');
      _hienThiThongBao('Lỗi: ${e.toString()}', Colors.red);
    }
  }

  void _hienThiDialogLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ChuDe.mauChinh),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đang lưu công thức...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đợi trong giây lát',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dongDialogLoading() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _hienThiDialogThanhCong() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: ChuDe.mauXanhLa,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Công thức của bạn đã được đăng thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ChuDe.mauChuPhu,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        _resetForm(); // Reset form để tạo công thức mới
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ChuDe.mauChinh,
                        side: const BorderSide(color: ChuDe.mauChinh),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tạo thêm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        Navigator.of(context)
                            .pop(true); // Quay về màn hình trước
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChuDe.mauChinh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Xem công thức'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _tenMonController.clear();
    _thoiGianNauController.clear();
    _khauPhanController.clear();
    _moTaController.clear();

    for (var controller in _nguyenLieuControllers) {
      controller.clear();
    }

    for (var controller in _buocThucHienControllers) {
      controller.clear();
    }

    setState(() {
      _hinhAnh = null;
      _loaiDuocChon = 'Món Bắc';
      _buocHienTai = 0;
      _nguyenLieuControllers.clear();
      _nguyenLieuControllers.add(TextEditingController());
      _buocThucHienControllers.clear();
      _buocThucHienControllers.add(TextEditingController());
    });

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Công Thức Mới'),
        backgroundColor: ChuDe.mauChinh,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _dangXuLy ? null : _luuCongThuc,
            icon: _dangXuLy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Thanh tiến trình
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _xayDungBuocTienTrinh(0, 'Thông tin'),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _buocHienTai >= 1
                          ? ChuDe.mauChinh
                          : Colors.grey.shade300,
                    ),
                  ),
                  _xayDungBuocTienTrinh(1, 'Nguyên liệu'),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _buocHienTai >= 2
                          ? ChuDe.mauChinh
                          : Colors.grey.shade300,
                    ),
                  ),
                  _xayDungBuocTienTrinh(2, 'Cách làm'),
                ],
              ),
            ),

            // Nội dung các bước
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _xayDungBuocThongTin(),
                  _xayDungBuocNguyenLieu(),
                  _xayDungBuocCachLam(),
                ],
              ),
            ),

            // Nút điều hướng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_buocHienTai > 0)
                    ElevatedButton.icon(
                      onPressed: _chuyenBuocTruocDo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ChuDe.mauChinh,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: ChuDe.mauChinh),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                    )
                  else
                    const SizedBox(),
                  if (_buocHienTai < 2)
                    ElevatedButton.icon(
                      onPressed: _chuyenBuocTiepTheo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChuDe.mauChinh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tiếp theo'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _luuCongThuc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChuDe.mauChinh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Hoàn thành'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungBuocTienTrinh(int buoc, String nhan) {
    final daDuocChon = _buocHienTai >= buoc;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (buoc < _buocHienTai) {
              setState(() {
                _buocHienTai = buoc;
              });
              _pageController.animateToPage(
                buoc,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: daDuocChon ? ChuDe.mauChinh : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: daDuocChon ? ChuDe.mauChinh : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${buoc + 1}',
                style: TextStyle(
                  color: daDuocChon ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nhan,
          style: TextStyle(
            fontSize: 12,
            color: daDuocChon ? ChuDe.mauChinh : Colors.grey.shade600,
            fontWeight: daDuocChon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _xayDungBuocThongTin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh công thức
          GestureDetector(
            onTap: _chonHinhAnh,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _hinhAnh != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _hinhAnh!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                              onPressed: _chonHinhAnh,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thêm hình ảnh món ăn',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(Tùy chọn - sẽ dùng ảnh mặc định nếu không chọn)',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 24),

          // Tên món
          const Text(
            'Tên Món Ăn *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _tenMonController,
            decoration: const InputDecoration(
              hintText: 'Nhập tên món ăn',
              prefixIcon: Icon(Icons.restaurant_menu),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên món ăn';
              }
              return null;
            },
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Mô tả
          const Text(
            'Mô Tả',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _moTaController,
            decoration: const InputDecoration(
              hintText: 'Mô tả ngắn về món ăn',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 16),

          // Loại món ăn
          const Text(
            'Loại Món Ăn *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _loaiDuocChon,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            items: _danhSachLoai.map((loai) {
              return DropdownMenuItem<String>(
                value: loai,
                child: Text(loai),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _loaiDuocChon = value;
                });
              }
            },
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 16),

          // Thời gian nấu và khẩu phần
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời Gian Nấu (phút) *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _thoiGianNauController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'VD: 30',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập thời gian';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Vui lòng nhập số';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khẩu Phần *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _khauPhanController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'VD: 4',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập khẩu phần';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Vui lòng nhập số';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _xayDungBuocNguyenLieu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nguyên Liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _themNguyenLieu,
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: ChuDe.mauChinh,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChuDe.mauPhu,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: ChuDe.mauChinh,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mẹo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChinh,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hãy liệt kê đầy đủ nguyên liệu cùng với số lượng cụ thể (VD: 200g thịt bò, 2 quả trứng)',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nguyenLieuControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: ChuDe.mauChinh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _nguyenLieuControllers[index],
                        decoration: InputDecoration(
                          hintText: 'VD: 200g thịt bò',
                          border: const OutlineInputBorder(),
                          suffixIcon: _nguyenLieuControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _xoaNguyenLieu(index),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nguyên liệu';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms + (index * 100).ms);
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _themNguyenLieu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ChuDe.mauChinh,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: ChuDe.mauChinh),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Nguyên Liệu'),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _xayDungBuocCachLam() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Các Bước Thực Hiện',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _themBuocThucHien,
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: ChuDe.mauChinh,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChuDe.mauPhu,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: ChuDe.mauChinh,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mẹo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChinh,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mô tả chi tiết từng bước thực hiện để người nấu dễ dàng làm theo.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _buocThucHienControllers.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: ChuDe.mauChinh,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bước ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_buocThucHienControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _xoaBuocThucHien(index),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _buocThucHienControllers[index],
                      decoration: const InputDecoration(
                        hintText: 'Mô tả chi tiết bước thực hiện...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập bước thực hiện';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms + (index * 100).ms);
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _themBuocThucHien,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ChuDe.mauChinh,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: ChuDe.mauChinh),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Bước Thực Hiện'),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
        ],
      ),
    );
  }
}
