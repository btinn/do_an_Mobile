import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/thong_bao.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/tien_ich/the_cong_thuc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'dart:io';

class ManHinhTrangChu extends StatefulWidget {
  final VoidCallback? onChuyenSangTimKiem;

  const ManHinhTrangChu({
    super.key,
    this.onChuyenSangTimKiem,
  });

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

class _ManHinhTrangChuState extends State<ManHinhTrangChu>
    with TickerProviderStateMixin {
  final List<String> danhMuc = [
    'Tất Cả',
    'Món Bắc',
    'Món Trung',
    'Món Nam',
    'Món Chay',
    'Món Tráng Miệng',
    'Đồ Uống',
  ];

  int _danhMucDuocChon = 0;
  int _chiSoHienTai = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _hienThiAppBarMoRong = true;
  List<CongThuc> danhSachCongThuc = [];

  // Animation controllers
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  // Thêm biến cho thông báo
  final DichVuThongBao _dichVuThongBao = DichVuThongBao();
  List<ThongBao> _danhSachThongBao = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Khởi tạo animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Gọi _taiCongThuc sau khi khởi tạo xong UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taiCongThuc();
      _taiThongBao();
      if (mounted) {
        _headerAnimationController.forward();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100 && _hienThiAppBarMoRong) {
        setState(() {
          _hienThiAppBarMoRong = false;
        });
        HapticFeedback.lightImpact();
      } else if (_scrollController.position.pixels <= 100 &&
          !_hienThiAppBarMoRong) {
        setState(() {
          _hienThiAppBarMoRong = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  bool _dangTai = false;

  Future<void> _taiCongThuc() async {
    if (_dangTai) return;
    setState(() => _dangTai = true);

    try {
      final dichVu = DichVuCongThuc();
      final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
              .nguoiDungHienTai
              ?.ma ??
          '';
      final danhSach = await dichVu.layDanhSachCongThuc(uid);

      if (mounted) {
        setState(() {
          danhSachCongThuc = danhSach;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải công thức: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lỗi tải dữ liệu.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _taiThongBao() async {
    final dangNhapService =
        Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    if (nguoiDung != null) {
      try {
        final danhSach =
            await _dichVuThongBao.layDanhSachThongBao(nguoiDung.ma);

        if (mounted) {
          setState(() {
            _danhSachThongBao = danhSach;
          });
        }

        _dichVuThongBao.langNgheThongBao(nguoiDung.ma).listen((danhSach) {
          if (mounted) {
            setState(() {
              _danhSachThongBao = danhSach;
            });
          }
        });
      } catch (e) {
        debugPrint('Lỗi tải thông báo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    final tenNguoiDung =
        nguoiDung?.hoTen != null ? nguoiDung!.hoTen.split(' ').last : 'Bạn';
    final anhDaiDien =
        nguoiDung?.anhDaiDien ?? 'assets/images/avatar_default.jpg';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _hienThiAppBarMoRong ? 100 : 0, // Giảm từ 100 xuống 85
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ChuDe.mauChinh,
                      ChuDe.mauChinh.withValues(alpha: 0.8),
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ChuDe.mauChinh.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: FlexibleSpaceBar(
                  background: SafeArea(
                    child: AnimatedBuilder(
                      animation: _headerAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
                          child: Opacity(
                            opacity: (_headerAnimation.value).clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 1, 20, 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Hàng chứa avatar và thông báo
                                  Row(
                                    children: [
                                      // Avatar
                                      Hero(
                                        tag: 'user_avatar',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundImage: anhDaiDien.startsWith('http')
                                                ? NetworkImage(anhDaiDien)
                                                : AssetImage(anhDaiDien) as ImageProvider,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Thông tin người dùng
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Xin chào! 👋',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              tenNguoiDung,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Nút thông báo
                                      _xayDungNutThongBao(nguoiDung),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Ô tìm kiếm
                                  if (_hienThiAppBarMoRong)
                                    _xayDungOTimKiem(),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await _taiCongThuc();
            await _taiThongBao();
          },
          color: ChuDe.mauChinh,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Banner carousel
                    _xayDungBannerCarousel(),
                    
                    const SizedBox(height: 20), // Giảm từ 30 xuống 20
                    
                    // Tab Bar
                    _xayDungTabBarMoi(),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _xayDungTabDanhChoBan(danhSachCongThuc),
                    _xayDungTabPhoBien(
                      List.from(danhSachCongThuc)
                        ..sort((a, b) => b.luotThich.compareTo(a.luotThich)),
                    ),
                    _xayDungTabMoiNhat(
                      List.from(danhSachCongThuc)
                        ..sort((a, b) => b.ma.compareTo(a.ma)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _xayDungNutThongBao(nguoiDung) {
    return StreamBuilder<int>(
      stream: nguoiDung != null
          ? _dichVuThongBao.demThongBaoChuaDocStream(nguoiDung.ma)
          : Stream.value(0),
      builder: (context, snapshot) {
        final soChuaDoc = snapshot.data ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8), // Giảm từ 10 xuống 8
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            constraints: BoxConstraints.tight(const Size(28, 28)), // Giảm từ 32 xuống 28
            padding: EdgeInsets.zero,
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 16, // Giảm từ 18 xuống 16
                ),
                if (soChuaDoc > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1), // Giảm từ 1.5 xuống 1
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 0.5, // Giảm từ 1 xuống 0.5
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10, // Giảm từ 12 xuống 10
                        minHeight: 10, // Giảm từ 12 xuống 10
                      ),
                      child: Text(
                        soChuaDoc > 99 ? '99+' : soChuaDoc.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 6, // Giảm từ 7 xuống 6
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            ],
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _hienThiDanhSachThongBao();
          },
        ),
      );
    },
  );
}

Widget _xayDungOTimKiem() {
  return GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      if (widget.onChuyenSangTimKiem != null) {
        widget.onChuyenSangTimKiem!();
      }
    },
    child: Container(
      height: 32, // Giảm từ 36 xuống 32
      padding: const EdgeInsets.symmetric(horizontal: 10), // Giảm từ 12 xuống 10
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Giảm từ 18 xuống 16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6, // Giảm từ 8 xuống 6
            offset: const Offset(0, 1), // Giảm từ 2 xuống 1
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 14, // Giảm từ 16 xuống 14
          ),
          const SizedBox(width: 6), // Giảm từ 8 xuống 6
          Expanded(
            child: Text(
              'Tìm kiếm công thức, nguyên liệu...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12, // Giảm từ 13 xuống 12
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3), // Giảm từ 4 xuống 3
            decoration: BoxDecoration(
              color: ChuDe.mauChinh.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5), // Giảm từ 6 xuống 5
            ),
            child: Icon(
              Icons.tune_rounded,
              color: ChuDe.mauChinh,
              size: 12, // Giảm từ 14 xuống 12
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _xayDungBannerCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          FlutterCarousel(
            items: [
              _xayDungBanner(
                'Khám Phá Ẩm Thực Việt',
                'Hàng ngàn công thức nấu ăn đặc sắc từ khắp ba miền đất nước',
                'assets/images/hinhnen1.jpg',
                () {},
              ),
              _xayDungBanner(
                'Món Ngon Mùa Hè',
                'Những món ăn giải nhiệt cho ngày nắng nóng',
                'assets/images/hinhnen2.jpg',
                () {},
              ),
              _xayDungBanner(
                'Cùng Nấu Ăn Tại Nhà',
                'Tiết kiệm chi phí với các công thức đơn giản',
                'assets/images/hinhnen3.jpg',
                () {},
              ),
            ],
            options: FlutterCarouselOptions(
              height: 180, // Giảm từ 200 xuống 180
              aspectRatio: 16 / 9,
              viewportFraction: 1.0,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInOutCubic,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _chiSoHienTai = index;
                });
              },
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 10), // Giảm từ 15 xuống 10
          
          // Chỉ số trang với thiết kế mới
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0, 1, 2].map((index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _chiSoHienTai == index ? 20 : 6, // Giảm từ 24/8 xuống 20/6
                height: 6, // Giảm từ 8 xuống 6
                margin: const EdgeInsets.symmetric(horizontal: 3), // Giảm từ 4 xuống 3
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), // Giảm từ 4 xuống 3
                  color: _chiSoHienTai == index
                      ? ChuDe.mauChinh
                      : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _xayDungTabBarMoi() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Giảm từ 25 xuống 20
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10, // Giảm từ 15 xuống 10
            offset: const Offset(0, 3), // Giảm từ 5 xuống 3
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: ChuDe.mauChinh,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [ChuDe.mauChinh, Colors.orange.shade400],
          ),
          borderRadius: BorderRadius.circular(20), // Giảm từ 25 xuống 20
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13, // Giảm từ 14 xuống 13
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13, // Giảm từ 14 xuống 13
        ),
        tabs: const [
          Tab(text: 'Dành Cho Bạn'),
          Tab(text: 'Phổ Biến'),
          Tab(text: 'Mới Nhất'),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _xayDungBanner(String tieuDe, String moTa, String hinhAnh, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Giảm từ 20 xuống 16
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15, // Giữ nguyên
              offset: const Offset(0, 8), // Giảm từ 10 xuống 8
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // Giảm từ 20 xuống 16
          child: Stack(
            children: [
              Container(
                height: 180, // Giảm từ 200 xuống 180
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(hinhAnh),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 180, // Giảm từ 200 xuống 180
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20), // Giảm từ 25 xuống 20
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tieuDe,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Giảm từ 22 xuống 20
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6), // Giảm từ 8 xuống 6
                      Text(
                        moTa,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12, // Giảm từ 14 xuống 12
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _xayDungTabDanhChoBan(List<CongThuc> danhSachCongThuc) {
    final List<CongThuc> danhSachLoc = _danhMucDuocChon == 0
        ? danhSachCongThuc
        : danhSachCongThuc
            .where((ct) =>
                ct.loai.toLowerCase() ==
                danhMuc[_danhMucDuocChon].toLowerCase())
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh mục với thiết kế mới
          SizedBox(
            height: 40, // Giảm từ 50 xuống 40
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: danhMuc.length,
              itemBuilder: (context, index) {
                final duocChon = _danhMucDuocChon == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10), // Giảm từ 12 xuống 10
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _danhMucDuocChon = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, // Giảm từ 20 xuống 16
                        vertical: 10, // Giảm từ 12 xuống 10
                      ),
                      decoration: BoxDecoration(
                        gradient: duocChon
                            ? LinearGradient(
                                colors: [ChuDe.mauChinh, Colors.orange.shade400],
                              )
                            : null,
                        color: duocChon ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20), // Giảm từ 25 xuống 20
                        boxShadow: [
                          BoxShadow(
                            color: duocChon 
                                ? ChuDe.mauChinh.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: duocChon ? 8 : 4, // Giảm từ 10/5 xuống 8/4
                            offset: Offset(0, duocChon ? 4 : 2), // Giảm từ 5/2 xuống 4/2
                          ),
                        ],
                      ),
                      child: Text(
                        danhMuc[index],
                        style: TextStyle(
                          color: duocChon ? Colors.white : Colors.grey.shade700,
                          fontWeight: duocChon ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13, // Giảm từ 14 xuống 13
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 24), // Giảm từ 30 xuống 24

          Text(
            '🔥 Công Thức Nổi Bật',
            style: TextStyle(
              fontSize: 20, // Giảm từ 22 xuống 20
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 16), // Giảm từ 20 xuống 16

          // Grid công thức với animation
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12, // Giảm từ 16 xuống 12
              crossAxisSpacing: 12, // Giảm từ 16 xuống 12
              childAspectRatio: 0.75,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: danhSachLoc.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManHinhChiTietCongThuc(
                          congThuc: danhSachLoc[index],
                          taiLaiCongThuc: _taiCongThuc),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), // Giảm từ 20 xuống 16
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10, // Giảm từ 15 xuống 10
                        offset: const Offset(0, 3), // Giảm từ 5 xuống 3
                      ),
                    ],
                  ),
                  child: TheCongThuc(
                    congThuc: danhSachLoc[index],
                    chieuCao: index % 2 == 0 ? 260 : 220, // Giảm từ 280/240 xuống 260/220
                  ),
                ),
              ).animate().fadeIn(
                duration: 500.ms, 
                delay: (500 + index * 100).ms
              ).slideY(begin: 0.3, end: 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _xayDungTabPhoBien(List<CongThuc> danhSachCongThuc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
      itemCount: danhSachCongThuc.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // Giảm từ 16 xuống 12
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietCongThuc(
                    congThuc: danhSachCongThuc[index],
                    taiLaiCongThuc: _taiCongThuc,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // Giảm từ 20 xuống 16
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10, // Giảm từ 15 xuống 10
                    offset: const Offset(0, 3), // Giảm từ 5 xuống 3
                  ),
                ],
              ),
              child: TheCongThuc(
                congThuc: danhSachCongThuc[index],
                ngang: true,
              ),
            ),
          ),
        ).animate().fadeIn(
          duration: 500.ms, 
          delay: (300 + index * 100).ms
        ).slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _xayDungTabMoiNhat(List<CongThuc> danhSachCongThuc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
      itemCount: danhSachCongThuc.length,
      itemBuilder: (context, index) {
        final congThuc = danhSachCongThuc[index];
        Widget imageWidget =
            _xayDungHinhAnhCongThuc(congThuc.hinhAnh, 180, double.infinity); // Giảm từ 200 xuống 180

        ImageProvider anhTacGiaWidget;
        if (congThuc.anhTacGia.startsWith('http')) {
          anhTacGiaWidget = NetworkImage(congThuc.anhTacGia);
        } else {
          anhTacGiaWidget = AssetImage(congThuc.anhTacGia);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16), // Giảm từ 20 xuống 16
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietCongThuc(
                    congThuc: congThuc,
                    taiLaiCongThuc: _taiCongThuc,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Giảm từ 20 xuống 16
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10, // Giảm từ 15 xuống 10
                    offset: const Offset(0, 3), // Giảm từ 5 xuống 3
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)), // Giảm từ 20 xuống 16
                    child: imageWidget,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5, // Giảm từ 2 xuống 1.5
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 25, // Giảm từ 18 xuống 16
                                backgroundImage: anhTacGiaWidget,
                              ),
                            ),
                            const SizedBox(width: 13), // Giảm từ 12 xuống 10
                            Expanded(
                              child: Text(
                                congThuc.tacGia,
                                style: const TextStyle(
                                  fontSize: 16, // Giảm từ 16 xuống 14
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5), // Giảm từ 12/6 xuống 10/5
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [ChuDe.mauChinh, Colors.orange.shade400],
                                ),
                                borderRadius: BorderRadius.circular(12), // Giảm từ 15 xuống 12
                              ),
                              child: Text(
                                congThuc.loai,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10, // Giảm từ 12 xuống 10
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12), // Giảm từ 15 xuống 12
                        Text(
                          congThuc.tenMon,
                          style: const TextStyle(
                            fontSize: 18, // Giảm từ 20 xuống 18
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10), // Giảm từ 12 xuống 10
                        Row(
                          children: [
                            _xayDungThongTinNho(
                              Icons.access_time_rounded,
                              '${congThuc.thoiGianNau} phút',
                              Colors.blue.shade600,
                            ),
                            const SizedBox(width: 16), // Giảm từ 20 xuống 16
                            _xayDungThongTinNho(
                              Icons.star_rounded,
                              congThuc.diemDanhGia.toStringAsFixed(1),
                              Colors.amber.shade600,
                            ),
                            const SizedBox(width: 16), // Giảm từ 20 xuống 16
                            _xayDungThongTinNho(
                              Icons.favorite_rounded,
                              '${congThuc.luotThich}',
                              Colors.red.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
          duration: 500.ms, 
          delay: (300 + index * 100).ms
        ).slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _xayDungThongTinNho(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3), // Giảm từ 4 xuống 3
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6), // Giảm từ 8 xuống 6
          ),
          child: Icon(
            icon,
            size: 14, // Giảm từ 16 xuống 14
            color: color,
          ),
        ),
        const SizedBox(width: 4), // Giảm từ 6 xuống 4
        Text(
          text,
          style: TextStyle(
            fontSize: 11, // Giảm từ 12 xuống 11
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _hienThiDanhSachThongBao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🔔 Thông Báo',
                    style: TextStyle(
                      fontSize: 18, // Giảm từ 20 xuống 18
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_danhSachThongBao.isNotEmpty)
                        _xayDungNutHanhDong(
                          Icons.delete_sweep_rounded,
                          'Xóa tất cả',
                          Colors.red.shade600,
                          () => _xoaTatCaThongBao(),
                        ),
                      const SizedBox(width: 10), // Giảm từ 12 xuống 10
                      _xayDungNutHanhDong(
                        Icons.done_all_rounded,
                        'Đánh dấu',
                        ChuDe.mauChinh,
                        () => _danhDauTatCaDaDoc(),
                      ),
                      const SizedBox(width: 10), // Giảm từ 12 xuống 10
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6), // Giảm từ 8 xuống 6
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8), // Giảm từ 10 xuống 8
                          ),
                          child: const Icon(Icons.close_rounded, size: 18), // Giảm từ 20 xuống 18
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _danhSachThongBao.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 48, // Giảm từ 64 xuống 48
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16), // Giảm từ 20 xuống 16
                          Text(
                            'Chưa có thông báo nào',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16, // Giảm từ 18 xuống 16
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6), // Giảm từ 8 xuống 6
                          Text(
                            'Các thông báo mới sẽ xuất hiện ở đây',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12, // Giảm từ 14 xuống 12
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
                      itemCount: _danhSachThongBao.length,
                      itemBuilder: (context, index) {
                        final thongBao = _danhSachThongBao[index];
                        return _xayDungThongBao(thongBao, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungNutHanhDong(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Giảm từ 12/8 xuống 10/6
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10), // Giảm từ 12 xuống 10
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color), // Giảm từ 16 xuống 14
            const SizedBox(width: 4), // Giảm từ 6 xuống 4
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11, // Giảm từ 12 xuống 11
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongBao(ThongBao thongBao, int index) {
    IconData icon;
    Color mauIcon;

    switch (thongBao.loai) {
      case 'thich':
        icon = Icons.favorite_rounded;
        mauIcon = Colors.red.shade600;
        break;
      case 'binh_luan':
        icon = Icons.comment_rounded;
        mauIcon = Colors.blue.shade600;
        break;
      case 'theo_doi':
        icon = Icons.person_add_rounded;
        mauIcon = Colors.green.shade600;
        break;
      case 'danh_gia':
        icon = Icons.star_rounded;
        mauIcon = Colors.orange.shade600;
        break;
      default:
        icon = Icons.notifications_rounded;
        mauIcon = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Giảm từ 12 xuống 10
      decoration: BoxDecoration(
        color: thongBao.daDoc ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12), // Giảm từ 16 xuống 12
        border: Border.all(
          color: thongBao.daDoc ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12), // Giảm từ 16 xuống 12
        leading: Container(
          padding: const EdgeInsets.all(10), // Giảm từ 12 xuống 10
          decoration: BoxDecoration(
            color: mauIcon.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10), // Giảm từ 12 xuống 10
          ),
          child: Icon(icon, color: mauIcon, size: 20), // Giảm từ 24 xuống 20
        ),
        title: Text(
          thongBao.tieuDe,
          style: TextStyle(
            fontWeight: thongBao.daDoc ? FontWeight.w600 : FontWeight.bold,
            fontSize: 14, // Giảm từ 16 xuống 14
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3), // Giảm từ 4 xuống 3
            Text(
              thongBao.noiDung,
              style: const TextStyle(fontSize: 12), // Giảm từ 14 xuống 12
            ),
            const SizedBox(height: 6), // Giảm từ 8 xuống 6
            Text(
              thongBao.thoiGianHienThi,
              style: TextStyle(
                fontSize: 10, // Giảm từ 12 xuống 10
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () => _xuLyNhanThongBao(thongBao),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: (index * 50).ms,
    ).slideX(begin: 0.3, end: 0);
  }

  Future<void> _xuLyNhanThongBao(ThongBao thongBao) async {
    HapticFeedback.lightImpact();
    
    final dangNhapService =
        Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    if (nguoiDung != null && !thongBao.daDoc) {
      await _dichVuThongBao.danhDauDaDoc(nguoiDung.ma, thongBao.ma);
    }

    if (mounted) {
      Navigator.pop(context);

      if (thongBao.maCongThuc != null && danhSachCongThuc.isNotEmpty) {
        final congThuc = danhSachCongThuc.firstWhere(
          (ct) => ct.ma == thongBao.maCongThuc,
          orElse: () => danhSachCongThuc.first,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhChiTietCongThuc(
                congThuc: congThuc, taiLaiCongThuc: _taiCongThuc),
          ),
        );
      }
    }
  }

  Future<void> _xoaTatCaThongBao() async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan == true && mounted) {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        try {
          await _dichVuThongBao.xoaTatCaThongBao(nguoiDung.ma);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đã xóa tất cả thông báo'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Lỗi khi xóa thông báo'),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _danhDauTatCaDaDoc() async {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    if (nguoiDung != null) {
      try {
        await _dichVuThongBao.danhDauTatCaDaDoc(nguoiDung.ma);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã đánh dấu tất cả thông báo là đã đọc'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lỗi khi đánh dấu đã đọc'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Widget _xayDungHinhAnhCongThuc(String duongDanAnh, double height, double width) {
    if (duongDanAnh.startsWith('/')) {
      final file = File(duongDanAnh);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _xayDungHinhAnhMacDinh(height, width);
          },
        );
      } else {
        return _xayDungHinhAnhMacDinh(height, width);
      }
    } else if (duongDanAnh.startsWith('assets/')) {
      return Image.asset(
        duongDanAnh,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(height, width);
        },
      );
    } else if (duongDanAnh.startsWith('http')) {
      return Image.network(
        duongDanAnh,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(height, width);
        },
      );
    } else {
      return _xayDungHinhAnhMacDinh(height, width);
    }
  }

  Widget _xayDungHinhAnhMacDinh(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade200, Colors.grey.shade300],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16), // Giảm từ 20 xuống 16
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Giảm từ 15 xuống 12
            ),
            child: Icon(
              Icons.restaurant_rounded,
              size: 32, // Giảm từ 40 xuống 32
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10), // Giảm từ 12 xuống 10
          Text(
            'Hình ảnh\nkhông có sẵn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12, // Giảm từ 14 xuống 12
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
