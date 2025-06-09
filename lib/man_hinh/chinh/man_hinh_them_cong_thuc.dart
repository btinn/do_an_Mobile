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
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';

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
  final bool _dangXuLy = false;
  int _buocHienTai = 0;
  final PageController _pageController = PageController();
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();
  CongThuc? _congThucDaTao; // Lưu công thức đã tạo để navigate

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
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  ChuDe.mauPhu.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chọn hình ảnh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ChuDe.mauChu,
                  ),
                ),
                const SizedBox(height: 24),
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Chụp ảnh',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Chọn từ thư viện',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.3)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ChuDe.mauChinh.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ChuDe.mauChinh),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ChuDe.mauChu,
              ),
            ),
          ],
        ),
      ),
    );
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
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  color == Colors.red ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          elevation: 8,
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
        // Lưu công thức để sử dụng khi navigate
        _congThucDaTao = congThucMoi;
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
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  ChuDe.mauPhu.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đang lưu công thức...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ChuDe.mauChu,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đợi trong giây lát',
                  style: TextStyle(
                    fontSize: 14,
                    color: ChuDe.mauChuPhu,
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
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                ChuDe.mauPhu.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ChuDe.mauXanhLa, Color(0xFF4CAF50)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ChuDe.mauXanhLa.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ChuDe.mauChu,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Công thức của bạn đã được đăng thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: ChuDe.mauChuPhu,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Tạo thêm',
                      isOutlined: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetForm();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogButton(
                      text: 'Xem công thức',
                      isOutlined: false,
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        Navigator.of(context).pop(); // Quay về màn hình trước
                        // Navigate đến màn hình chi tiết công thức
                        if (_congThucDaTao != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManHinhChiTietCongThuc(
                                congThuc: _congThucDaTao!,
                              ),
                            ),
                          );
                        }
                      },
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

  Widget _buildDialogButton({
    required String text,
    required bool isOutlined,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : LinearGradient(
          colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isOutlined ? Border.all(color: ChuDe.mauChinh, width: 2) : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : Colors.transparent,
          foregroundColor: isOutlined ? ChuDe.mauChinh : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
      _congThucDaTao = null;
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Thêm Công Thức Mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ChuDe.mauChu,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ChuDe.mauPhu.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // Bỏ nút Lưu khỏi AppBar
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Thanh tiến trình với thiết kế mới
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _xayDungBuocTienTrinh(0, 'Thông tin', Icons.info_outline),
                  Expanded(child: _buildProgressLine(0)),
                  _xayDungBuocTienTrinh(1, 'Nguyên liệu', Icons.restaurant_menu),
                  Expanded(child: _buildProgressLine(1)),
                  _xayDungBuocTienTrinh(2, 'Cách làm', Icons.list_alt),
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

            // Nút điều hướng với thiết kế mới - chỉ có nút Hoàn thành ở bên phải
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Nút Tiếp theo hoặc Quay lại (chỉ hiện khi cần)
                  if (_buocHienTai > 0)
                    _buildNavigationButton(
                      text: 'Quay lại',
                      icon: Icons.arrow_back_ios_new,
                      isNext: false,
                      onPressed: _chuyenBuocTruocDo,
                    ),
                  
                  const Spacer(), // Đẩy nút Hoàn thành về bên phải
                  
                  // Nút Tiếp theo hoặc Hoàn thành ở bên phải
                  if (_buocHienTai < 2)
                    _buildNavigationButton(
                      text: 'Tiếp theo',
                      icon: Icons.arrow_forward_ios,
                      isNext: true,
                      onPressed: _chuyenBuocTiepTheo,
                    )
                  else
                    _buildNavigationButton(
                      text: 'Hoàn thành',
                      icon: Icons.check_rounded,
                      isNext: true,
                      onPressed: _luuCongThuc,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressLine(int step) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: _buocHienTai > step
            ? LinearGradient(
                colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
              )
            : null,
        color: _buocHienTai > step ? null : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required bool isNext,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
      decoration: BoxDecoration(
        gradient: isNext ? LinearGradient(
          colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
        ) : null,
        borderRadius: BorderRadius.circular(12),
        border: isNext ? null : Border.all(color: ChuDe.mauChinh, width: 2),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isNext ? Colors.white : ChuDe.mauChinh,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _xayDungBuocTienTrinh(int buoc, String nhan, IconData icon) {
    final daDuocChon = _buocHienTai >= buoc;
    final dangThucHien = _buocHienTai == buoc;
    
    return GestureDetector(
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
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: daDuocChon ? LinearGradient(
                colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
              ) : null,
              color: daDuocChon ? null : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: daDuocChon ? [
                BoxShadow(
                  color: ChuDe.mauChinh.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: dangThucHien && daDuocChon
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  )
                : Icon(
                    daDuocChon ? Icons.check_rounded : icon,
                    color: daDuocChon ? Colors.white : Colors.grey.shade500,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            nhan,
            style: TextStyle(
              fontSize: 12,
              color: daDuocChon ? ChuDe.mauChinh : Colors.grey.shade600,
              fontWeight: daDuocChon ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungBuocThongTin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card hình ảnh công thức
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Hình ảnh món ăn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _chonHinhAnh,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ChuDe.mauPhu.withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        gradient: _hinhAnh == null ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ChuDe.mauPhu.withValues(alpha: 0.05),
                            ChuDe.mauPhu.withValues(alpha: 0.1),
                          ],
                        ) : null,
                      ),
                      child: _hinhAnh != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _hinhAnh!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                                      onPressed: _chonHinhAnh,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: ChuDe.mauChinh.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 32,
                                    color: ChuDe.mauChinh,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Thêm hình ảnh món ăn',
                                  style: TextStyle(
                                    color: ChuDe.mauChu,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tùy chọn - sẽ dùng ảnh mặc định nếu không chọn',
                                  style: TextStyle(
                                    color: ChuDe.mauChuPhu,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),

          // Card thông tin cơ bản
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Thông tin cơ bản',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tên món
                  _buildFormField(
                    label: 'Tên Món Ăn',
                    controller: _tenMonController,
                    hintText: 'Nhập tên món ăn',
                    icon: Icons.restaurant_menu,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  _buildFormField(
                    label: 'Mô Tả',
                    controller: _moTaController,
                    hintText: 'Mô tả ngắn về món ăn',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Loại món ăn
                  const Text(
                    'Loại Món Ăn *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ChuDe.mauChu,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.3)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _loaiDuocChon,
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: ChuDe.mauChinh.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.category, color: ChuDe.mauChinh, size: 16),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: _danhSachLoai.map((loai) {
                        return DropdownMenuItem<String>(
                          value: loai,
                          child: Text(
                            loai,
                            style: const TextStyle(
                              color: ChuDe.mauChu,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _loaiDuocChon = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thời gian nấu và khẩu phần
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Thời Gian Nấu (phút)',
                          controller: _thoiGianNauController,
                          hintText: 'VD: 30',
                          icon: Icons.access_time,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Khẩu Phần',
                          controller: _khauPhanController,
                          hintText: 'VD: 4',
                          icon: Icons.people,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ChuDe.mauChu,
            ),
            children: isRequired ? [
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ] : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.3)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: ChuDe.mauChuPhu),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ChuDe.mauChinh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ChuDe.mauChinh, size: 16),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: isRequired ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập $label';
              }
              if (keyboardType == TextInputType.number && int.tryParse(value.trim()) == null) {
                return 'Vui lòng nhập số hợp lệ';
              }
              return null;
            } : null,
          ),
        ),
      ],
    );
  }

  Widget _xayDungBuocNguyenLieu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ChuDe.mauChinh.withValues(alpha: 0.1),
                  ChuDe.mauChinh.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ChuDe.mauChinh.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mẹo hay:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChinh,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hãy liệt kê đầy đủ nguyên liệu cùng với số lượng cụ thể (VD: 200g thịt bò, 2 quả trứng)',
                        style: TextStyle(
                          fontSize: 14,
                          color: ChuDe.mauChu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          // Danh sách nguyên liệu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Nguyên Liệu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ChuDe.mauChu,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        onPressed: _themNguyenLieu,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Thêm',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _nguyenLieuControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ChuDe.mauPhu.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                hintStyle: TextStyle(color: ChuDe.mauChuPhu),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập nguyên liệu';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_nguyenLieuControllers.length > 1)
                            IconButton(
                              icon: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete, color: Colors.red, size: 18),
                              ),
                              onPressed: () => _xoaNguyenLieu(index),
                            ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 300.ms + (index * 100).ms);
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _xayDungBuocCachLam() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ChuDe.mauChinh.withValues(alpha: 0.1),
                  ChuDe.mauChinh.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ChuDe.mauChinh.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mẹo hay:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChinh,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mô tả chi tiết từng bước thực hiện để người nấu dễ dàng làm theo.',
                        style: TextStyle(
                          fontSize: 14,
                          color: ChuDe.mauChu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          // Danh sách các bước
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nút Thêm ở trên
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton.icon(
                          onPressed: _themBuocThucHien,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Thêm Bước',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tiêu đề ở dưới
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Các Bước Thực Hiện',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ChuDe.mauChu,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _buocThucHienControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            ChuDe.mauPhu.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.7)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ChuDe.mauChinh.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Bước ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ChuDe.mauChu,
                                  ),
                                ),
                              ),
                              if (_buocThucHienControllers.length > 1)
                                IconButton(
                                  icon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  ),
                                  onPressed: () => _xoaBuocThucHien(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ChuDe.mauPhu.withValues(alpha: 0.2)),
                            ),
                            child: TextFormField(
                              controller: _buocThucHienControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Mô tả chi tiết bước thực hiện...',
                                hintStyle: TextStyle(color: ChuDe.mauChuPhu),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập bước thực hiện';
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
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }
}
