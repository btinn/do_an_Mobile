import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:provider/provider.dart';
import 'package:do_an/dich_vu/dich_vu_cai_dat.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _hinhAnh = File(image.path);
      });
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
        if (_tenMonController.text.isEmpty || _hinhAnh == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Vui lòng điền đầy đủ thông tin và chọn hình ảnh'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return;
        }
      } else if (_buocHienTai == 1) {
        if (_nguyenLieuControllers
            .any((controller) => controller.text.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vui lòng điền đầy đủ thông tin nguyên liệu'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
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

  void _luuCongThuc() async {
    if (_formKey.currentState!.validate() && _hinhAnh != null) {
      // Kiểm tra các bước thực hiện
      if (_buocThucHienControllers
          .any((controller) => controller.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng điền đầy đủ các bước thực hiện'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      setState(() {
        _dangXuLy = true;
      });

      // Giả lập thời gian xử lý
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
        final nguoiDung = dangNhapService.nguoiDungHienTai;

        if (nguoiDung != null) {
          final congThucMoi = CongThuc(
            ma: DateTime.now().millisecondsSinceEpoch.toString(),
            tenMon: _tenMonController.text,
            hinhAnh:
                'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb',
            loai: _loaiDuocChon,
            thoiGianNau: int.parse(_thoiGianNauController.text),
            khauPhan: int.parse(_khauPhanController.text),
            diemDanhGia: 0,
            luotThich: 0,
            luotXem: 0,
            nguyenLieu: _nguyenLieuControllers
                .map((controller) => controller.text)
                .toList(),
            cachLam: _buocThucHienControllers
                .map((controller) => controller.text)
                .toList(),
            tacGia: nguoiDung.hoTen,
            anhTacGia: nguoiDung.anhDaiDien,
            daThich: false,
            danhSachBinhLuan: [],
            danhSachDanhGia: [],
          );

          // dichVuDuLieu.themCongThuc(congThucMoi);

          setState(() {
            _dangXuLy = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Công thức của bạn đã được đăng thành công!'),
              backgroundColor: ChuDe.mauXanhLa,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Xóa form
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
      }
    } else if (_hinhAnh == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn hình ảnh cho công thức'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Công Thức Mới'),
        actions: [
          TextButton.icon(
            onPressed: _dangXuLy ? null : _luuCongThuc,
            icon: _dangXuLy
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Thanh tiến trình
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
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
                ],
              ),
            ),

            // Nội dung các bước
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Bước 1: Thông tin cơ bản
                  _xayDungBuocThongTin(),

                  // Bước 2: Nguyên liệu
                  _xayDungBuocNguyenLieu(),

                  // Bước 3: Cách làm
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
                      onPressed: _dangXuLy ? null : _luuCongThuc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChuDe.mauChinh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _dangXuLy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check),
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
                image: _hinhAnh != null
                    ? DecorationImage(
                        image: FileImage(_hinhAnh!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _hinhAnh == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: ChuDe.mauChuPhu,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Thêm hình ảnh món ăn',
                          style: TextStyle(
                            color: ChuDe.mauChuPhu,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              color: ChuDe.mauChinh,
                              onPressed: _chonHinhAnh,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 24),

          // Tên món
          const Text(
            'Tên Món Ăn',
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
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
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
            ),
            maxLines: 3,
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 16),

          // Loại món ăn
          const Text(
            'Loại Món Ăn',
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
                      'Thời Gian Nấu (phút)',
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
                        hintText: 'Thời gian',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thời gian';
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
                      'Khẩu Phần',
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
                        hintText: 'Số người',
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập khẩu phần';
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
          // Nguyên liệu
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

          // Mẹo
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
                        'Hãy liệt kê đầy đủ nguyên liệu cùng với số lượng cụ thể để người nấu dễ dàng chuẩn bị.',
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
                      decoration: BoxDecoration(
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
                          hintText:
                              'Nguyên liệu ${index + 1} (VD: 200g thịt bò)',
                          suffixIcon: _nguyenLieuControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _xoaNguyenLieu(index),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
          // Các bước thực hiện
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

          // Mẹo
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
                        'Mô tả chi tiết từng bước thực hiện để người nấu dễ dàng làm theo. Bạn có thể thêm mẹo nấu ăn vào mỗi bước.',
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
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
                        hintText: 'Mô tả bước thực hiện',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
