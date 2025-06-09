import 'dart:io';

import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_them_cong_thuc.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'man_hinh_cai_dat.dart';
import 'package:do_an/dich_vu/dich_vu_luu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_nguoi_dung.dart';
import 'man_hinh_chinh_sua_ho_so.dart';

class ManHinhHoSo extends StatefulWidget {
  const ManHinhHoSo({super.key});

  @override
  State<ManHinhHoSo> createState() => _ManHinhHoSoState();
}

class _ManHinhHoSoState extends State<ManHinhHoSo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CongThuc> _danhSachCongThucCuaToi = [];
  List<CongThuc> _danhSachCongThucYeuThich = [];
  List<CongThuc> _danhSachCongThucDaLuu = [];
  
  bool _dangTai = true;
  bool _dangTaiYeuThich = false;
  bool _dangTaiDaLuu = false;
  
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();
  final DichVuLuuCongThuc _dichVuLuuCongThuc = DichVuLuuCongThuc();
  final DichVuNguoiDung _dichVuNguoiDung = DichVuNguoiDung();

  // Thêm các biến thống kê
  int _soLuongCongThuc = 0;
  int _soLuongNguoiTheoDoi = 0;
  int _soLuongDangTheoDoi = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    Future.microtask(() => _taiTatCaDuLieu());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          if (_danhSachCongThucCuaToi.isEmpty && !_dangTai) {
            _taiCongThucCuaToi();
          }
          break;
        case 1:
          if (_danhSachCongThucYeuThich.isEmpty && !_dangTaiYeuThich) {
            _taiCongThucYeuThich();
          }
          break;
        case 2:
          if (_danhSachCongThucDaLuu.isEmpty && !_dangTaiDaLuu) {
            _taiCongThucDaLuu();
          }
          break;
      }
    }
  }

  Future<void> _taiTatCaDuLieu() async {
    setState(() => _dangTai = true);
    
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    await dangNhapService.layNguoiDungHienTai();

    await _taiCongThucCuaToi();
    await _taiThongKe();
    
    setState(() => _dangTai = false);
  }

  Future<void> _taiCongThucCuaToi() async {
    try {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        final danhSach = await _dichVuCongThuc.layDanhSachCongThucCuaTacGia(
          nguoiDung.ma, 
          nguoiDung.ma
        );
        
        if (mounted) {
          setState(() {
            _danhSachCongThucCuaToi = danhSach;
            _soLuongCongThuc = danhSach.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải công thức: $e');
    }
  }

  Future<void> _taiCongThucYeuThich() async {
    setState(() => _dangTaiYeuThich = true);
    
    try {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        final danhSach = await _dichVuCongThuc.layDanhSachCongThuc(nguoiDung.ma);
        
        if (mounted) {
          setState(() {
            _danhSachCongThucYeuThich = danhSach.where((congThuc) => congThuc.daThich).toList();
            _dangTaiYeuThich = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải công thức yêu thích: $e');
      if (mounted) {
        setState(() => _dangTaiYeuThich = false);
      }
    }
  }

  Future<void> _taiCongThucDaLuu() async {
    setState(() => _dangTaiDaLuu = true);
    
    try {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        final danhSach = await _dichVuLuuCongThuc.layDanhSachCongThucDaLuuChiTiet(nguoiDung.ma);
        
        if (mounted) {
          setState(() {
            _danhSachCongThucDaLuu = danhSach;
            _dangTaiDaLuu = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải công thức đã lưu: $e');
      if (mounted) {
        setState(() => _dangTaiDaLuu = false);
      }
    }
  }

  Future<void> _taiThongKe() async {
    try {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        final thongTin = await _dichVuNguoiDung.layThongTinNguoiDung(nguoiDung.ma);
        
        if (mounted) {
          setState(() {
            _soLuongCongThuc = thongTin['recipes'] ?? _danhSachCongThucCuaToi.length;
            _soLuongNguoiTheoDoi = thongTin['followers'] ?? 0;
            _soLuongDangTheoDoi = thongTin['following'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải thống kê: $e');
    }
  }

  void _moManHinhCaiDat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManHinhCaiDat(),
      ),
    ).then((_) => _taiTatCaDuLieu());
  }

  void _moManHinhThemCongThuc() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManHinhThemCongThuc(),
      ),
    );

    if (result == true) {
      _taiCongThucCuaToi();
      _taiThongKe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    if (nguoiDung == null || _dangTai) {
      return const Scaffold(
        backgroundColor: ChuDe.mauNenTinNhan,
        body: Center(child: CircularProgressIndicator(color: ChuDe.mauChinh)),
      );
    }

    return Scaffold(
      backgroundColor: ChuDe.mauNenTinNhan,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _xayDungSliverAppBar(nguoiDung),
            SliverToBoxAdapter(
              child: _xayDungThongTinNguoiDung(nguoiDung),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ChuDe.mauChinh,
                    unselectedLabelColor: ChuDe.mauChuPhu,
                    indicatorColor: ChuDe.mauChinh,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(text: 'Công Thức ($_soLuongCongThuc)'),
                      const Tab(text: 'Yêu thích'),
                      const Tab(text: 'Đã Lưu'),
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _xayDungTabCongThucCuaToi(),
            _xayDungTabYeuThich(),
            _xayDungTabDaLuu(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moManHinhThemCongThuc,
        backgroundColor: ChuDe.mauChinh,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _xayDungSliverAppBar(NguoiDung nguoiDung) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: ChuDe.shadowCard,
            ),
            child: const Icon(Icons.settings, size: 18),
          ),
          onPressed: _moManHinhCaiDat,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ChuDe.mauChinh, Colors.white],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'avatar_${nguoiDung.ma}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundImage: _layAnhDaiDien(nguoiDung.anhDaiDien),
                  backgroundColor: Colors.grey.shade200,
                  child: _layAnhDaiDien(nguoiDung.anhDaiDien) == null
                      ? Text(
                          nguoiDung.hoTen.isNotEmpty ? nguoiDung.hoTen[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: ChuDe.mauChinh,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? _layAnhDaiDien(String duongDan) {
    if (duongDan.isEmpty) return null;
    
    if (duongDan.startsWith('http')) {
      return NetworkImage(duongDan);
    } else if (duongDan.startsWith('assets/')) {
      return AssetImage(duongDan);
    } else if (File(duongDan).existsSync()) {
      return FileImage(File(duongDan));
    }
    
    return null;
  }

  Widget _xayDungThongTinNguoiDung(NguoiDung nguoiDung) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            nguoiDung.hoTen,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChu,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 8),
          
          Text(
            '@${nguoiDung.hoTen.toLowerCase().replaceAll(' ', '')}',
            style: const TextStyle(
              fontSize: 16,
              color: ChuDe.mauChuPhu,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 24),
          
          _xayDungThongKe().animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Thêm nút chỉnh sửa hồ sơ
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManHinhChinhSuaHoSo(nguoiDung: nguoiDung),
                  ),
                ).then((_) => _taiTatCaDuLieu());
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Chỉnh sửa hồ sơ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ChuDe.mauChinh,
                side: const BorderSide(color: ChuDe.mauChinh),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _xayDungThongKe() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
        boxShadow: ChuDe.shadowCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _xayDungItemThongKe(
            'Công Thức',
            _soLuongCongThuc.toString(),
            Icons.restaurant_menu_rounded,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _xayDungItemThongKe(
            'Người Theo Dõi',
            _soLuongNguoiTheoDoi.toString(),
            Icons.people_rounded,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _xayDungItemThongKe(
            'Đang Theo Dõi',
            _soLuongDangTheoDoi.toString(),
            Icons.person_add_rounded,
          ),
        ],
      ),
    );
  }

  Widget _xayDungItemThongKe(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ChuDe.mauChinh.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
          ),
          child: Icon(icon, color: ChuDe.mauChinh, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ChuDe.mauChu,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ChuDe.mauChuPhu,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _xayDungTabCongThucCuaToi() {
    if (_danhSachCongThucCuaToi.isEmpty) {
      return _xayDungKhongCoDuLieu(
        'Bạn chưa có công thức nào',
        'Hãy bắt đầu chia sẻ công thức nấu ăn của bạn',
        Icons.restaurant_menu,
        'Tạo Công Thức',
        _moManHinhThemCongThuc,
      );
    }

    return RefreshIndicator(
      onRefresh: _taiCongThucCuaToi,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _danhSachCongThucCuaToi.length,
        itemBuilder: (context, index) {
          final congThuc = _danhSachCongThucCuaToi[index];
          return _xayDungTheCongThuc(congThuc, index);
        },
      ),
    );
  }

  Widget _xayDungTabYeuThich() {
    if (_dangTaiYeuThich) {
      return const Center(child: CircularProgressIndicator(color: ChuDe.mauChinh));
    }

    if (_danhSachCongThucYeuThich.isEmpty) {
      return _xayDungKhongCoDuLieu(
        'Bạn chưa yêu thích công thức nào',
        'Hãy khám phá và yêu thích các công thức hay',
        Icons.favorite_border,
        'Khám Phá Ngay',
        () {
          // Chuyển đến màn hình khám phá
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _taiCongThucYeuThich,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _danhSachCongThucYeuThich.length,
        itemBuilder: (context, index) {
          final congThuc = _danhSachCongThucYeuThich[index];
          return _xayDungTheCongThuc(congThuc, index);
        },
      ),
    );
  }

  Widget _xayDungTabDaLuu() {
    if (_dangTaiDaLuu) {
      return const Center(child: CircularProgressIndicator(color: ChuDe.mauChinh));
    }

    if (_danhSachCongThucDaLuu.isEmpty) {
      return _xayDungKhongCoDuLieu(
        'Bạn chưa lưu công thức nào',
        'Hãy khám phá và lưu các công thức yêu thích',
        Icons.bookmark_border,
        'Khám Phá Ngay',
        () {
          // Chuyển đến màn hình khám phá
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _taiCongThucDaLuu,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _danhSachCongThucDaLuu.length,
        itemBuilder: (context, index) {
          final congThuc = _danhSachCongThucDaLuu[index];
          return _xayDungTheCongThuc(congThuc, index);
        },
      ),
    );
  }

  Widget _xayDungTheCongThuc(CongThuc congThuc, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhChiTietCongThuc(congThuc: congThuc),
          ),
        );

        if (result == true) {
          _taiCongThucCuaToi();
          _taiCongThucYeuThich();
          _taiCongThucDaLuu();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _xayDungHinhAnhCongThuc(congThuc),
                    
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(100),
                          ],
                        ),
                      ),
                    ),
                    
                    // Đánh giá
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              congThuc.diemDanhGia.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      congThuc.tenMon,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          congThuc.daThich ? Icons.favorite : Icons.favorite_border,
                          color: congThuc.daThich ? Colors.red : Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${congThuc.luotThich}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        const Icon(Icons.visibility, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${congThuc.luotXem}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
  }

  Widget _xayDungHinhAnhCongThuc(CongThuc congThuc) {
    if (congThuc.hinhAnh.startsWith('http')) {
      return Image.network(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh();
        },
      );
    } else if (congThuc.hinhAnh.startsWith('assets/')) {
      return Image.asset(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh();
        },
      );
    } else if (congThuc.hinhAnh.isNotEmpty) {
      final file = File(congThuc.hinhAnh);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _xayDungHinhAnhMacDinh();
          },
        );
      }
    }
    
    return _xayDungHinhAnhMacDinh();
  }

  Widget _xayDungHinhAnhMacDinh() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Không có hình ảnh',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungKhongCoDuLieu(
    String tieuDe,
    String moTa,
    IconData icon,
    String nhanNut,
    VoidCallback onPressed,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              tieuDe,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              moTa,
              style: const TextStyle(
                fontSize: 14,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ChuDe.mauChinh,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(nhanNut),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
