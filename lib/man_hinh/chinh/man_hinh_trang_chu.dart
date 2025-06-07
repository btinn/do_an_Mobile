import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/thong_bao.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/tien_ich/the_danh_muc.dart';
import 'package:do_an/tien_ich/the_cong_thuc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

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
    with SingleTickerProviderStateMixin {
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
  
  // Thêm biến cho thông báo
  final DichVuThongBao _dichVuThongBao = DichVuThongBao();
  List<ThongBao> _danhSachThongBao = [];
  int _soThongBaoChuaDoc = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Gọi _taiCongThuc sau khi khởi tạo xong UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taiCongThuc();
      _taiThongBao();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100 && _hienThiAppBarMoRong) {
        setState(() {
          _hienThiAppBarMoRong = false;
        });
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
    super.dispose();
  }

  bool _dangTai = false;

  Future<void> _taiCongThuc() async {
    if (_dangTai) return; // Ngăn gọi liên tục
    setState(() => _dangTai = true);

    try {
      final dichVu = DichVuCongThuc();
      final danhSach = await dichVu.layDanhSachCongThuc();

      setState(() {
        danhSachCongThuc = danhSach;
      });
    } catch (e) {
      debugPrint('Lỗi tải công thức: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải dữ liệu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _taiThongBao() async {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    
    if (nguoiDung != null) {
      try {
        final danhSach = await _dichVuThongBao.layDanhSachThongBao(nguoiDung.ma);
        final soThongBaoChuaDoc = await _dichVuThongBao.demThongBaoChuaDoc(nguoiDung.ma);
        
        setState(() {
          _danhSachThongBao = danhSach;
          _soThongBaoChuaDoc = soThongBaoChuaDoc;
        });

        // Lắng nghe thông báo mới
        _dichVuThongBao.langNgheThongBao(nguoiDung.ma).listen((danhSach) {
          if (mounted) {
            setState(() {
              _danhSachThongBao = danhSach;
            });
            _capNhatSoThongBaoChuaDoc();
          }
        });
      } catch (e) {
        debugPrint('Lỗi tải thông báo: $e');
      }
    }
  }

  Future<void> _capNhatSoThongBaoChuaDoc() async {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    
    if (nguoiDung != null) {
      final soThongBaoChuaDoc = await _dichVuThongBao.demThongBaoChuaDoc(nguoiDung.ma);
      setState(() {
        _soThongBaoChuaDoc = soThongBaoChuaDoc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    print(
        'Manhinhtrangchu Người dùng hiện tại sau khi đăng nhập: ${dangNhapService.nguoiDungHienTai?.hoTen}');

    final tenNguoiDung =
        nguoiDung?.hoTen != null ? nguoiDung!.hoTen.split(' ').last : 'Bạn';
    final anhDaiDien =
        nguoiDung?.anhDaiDien ?? 'assets/images/avatar_default.jpg';

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _hienThiAppBarMoRong ? 120 : 0,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false, // Tắt nút back mặc định
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: anhDaiDien.startsWith('http')
                        ? NetworkImage(anhDaiDien)
                        : AssetImage(anhDaiDien) as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, $tenNguoiDung!',
                        style: const TextStyle(
                          color: ChuDe.mauChu,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hôm nay bạn muốn nấu món gì?',
                        style: TextStyle(
                          color: ChuDe.mauChuPhu,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, color: ChuDe.mauChu),
                      if (_soThongBaoChuaDoc > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: ChuDe.mauChinh,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              _soThongBaoChuaDoc > 99 ? '99+' : _soThongBaoChuaDoc.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    _hienThiDanhSachThongBao();
                  },
                ),
              ],
              bottom: _hienThiAppBarMoRong
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Chuyển sang tab tìm kiếm thay vì navigate
                            if (widget.onChuyenSangTimKiem != null) {
                              widget.onChuyenSangTimKiem!();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: ChuDe.mauChuPhu),
                                const SizedBox(width: 8),
                                Text(
                                  'Tìm kiếm công thức, nguyên liệu...',
                                  style: TextStyle(
                                    color: ChuDe.mauChuPhu,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await _taiCongThuc();
            await _taiThongBao();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner quảng cáo - Sử dụng FlutterCarousel
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
                    height: 180,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _chiSoHienTai = index;
                      });
                    },
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                // Chỉ số trang
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [0, 1, 2].map((index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _chiSoHienTai == index ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _chiSoHienTai == index
                            ? ChuDe.mauChinh
                            : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ChuDe.mauChinh,
                    unselectedLabelColor: ChuDe.mauChuPhu,
                    indicatorColor: ChuDe.mauChinh,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Dành Cho Bạn'),
                      Tab(text: 'Phổ Biến'),
                      Tab(text: 'Mới Nhất'),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                // Tab Bar View
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab Dành Cho Bạn
                      _xayDungTabDanhChoBan(
                        danhSachCongThuc,
                      ),

                      // Tab Phổ Biến
                      _xayDungTabPhoBien(
                        List.from(danhSachCongThuc)
                          ..sort((a, b) => b.luotThich.compareTo(a.luotThich)),
                      ),

                      // Tab Mới Nhất
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _taiCongThuc,
        backgroundColor: ChuDe.mauChinh,
        child: const Icon(Icons.refresh),
        tooltip: 'Làm mới danh sách công thức',
      ),
    );
  }

  void _hienThiDanhSachThongBao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông Báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
                      final nguoiDung = dangNhapService.nguoiDungHienTai;
                      
                      if (nguoiDung != null) {
                        await _dichVuThongBao.danhDauTatCaDaDoc(nguoiDung.ma);
                        await _capNhatSoThongBaoChuaDoc();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã đánh dấu tất cả thông báo là đã đọc')),
                        );
                      }
                    },
                    child: const Text('Đánh dấu đã đọc'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _danhSachThongBao.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có thông báo nào',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _danhSachThongBao.length,
                      itemBuilder: (context, index) {
                        final thongBao = _danhSachThongBao[index];
                        return _xayDungThongBao(thongBao);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongBao(ThongBao thongBao) {
    IconData icon;
    Color mauIcon;
    
    switch (thongBao.loai) {
      case 'thich':
        icon = Icons.favorite;
        mauIcon = Colors.red;
        break;
      case 'binh_luan':
        icon = Icons.comment;
        mauIcon = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        mauIcon = Colors.grey;
    }

    return Container(
      color: thongBao.daDoc ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mauIcon.withOpacity(0.1),
          child: Icon(icon, color: mauIcon, size: 20),
        ),
        title: Text(
          thongBao.tieuDe,
          style: TextStyle(
            fontWeight: thongBao.daDoc ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thongBao.noiDung,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              thongBao.thoiGianHienThi,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: () async {
          // Đánh dấu đã đọc
          final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
          final nguoiDung = dangNhapService.nguoiDungHienTai;
          
          if (nguoiDung != null && !thongBao.daDoc) {
            await _dichVuThongBao.danhDauDaDoc(nguoiDung.ma, thongBao.ma);
            await _capNhatSoThongBaoChuaDoc();
          }

          Navigator.pop(context);

          // Chuyển đến chi tiết công thức nếu có
          if (thongBao.maCongThuc != null) {
            final congThuc = danhSachCongThuc.firstWhere(
              (ct) => ct.ma == thongBao.maCongThuc,
              orElse: () => danhSachCongThuc.first,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManHinhChiTietCongThuc(congThuc: congThuc),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _xayDungBanner(
      String tieuDe, String moTa, String hinhAnh, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(hinhAnh),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withAlpha(180),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieuDe,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  moTa,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungTabDanhChoBan(List<CongThuc> danhSachCongThuc) {
    // Thêm đoạn lọc theo danh mục ở đây
    final List<CongThuc> danhSachLoc = _danhMucDuocChon == 0
        ? danhSachCongThuc
        : danhSachCongThuc
            .where((ct) =>
                ct.loai.toLowerCase() ==
                danhMuc[_danhMucDuocChon].toLowerCase())
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh mục
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: danhMuc.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TheDanhMuc(
                    nhan: danhMuc[index],
                    daDuocChon: _danhMucDuocChon == index,
                    onTap: () {
                      setState(() {
                        _danhMucDuocChon = index;
                      });
                    },
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 24),

          const Text(
            'Công Thức Nổi Bật',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChu,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 16),
          
          // Danh sách công thức sau khi lọc
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: danhSachLoc.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManHinhChiTietCongThuc(
                        congThuc: danhSachLoc[index],
                      ),
                    ),
                  );
                },
                child: TheCongThuc(
                  congThuc: danhSachLoc[index],
                  chieuCao: index % 2 == 0 ? 280 : 240,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms + (index * 100).ms);
            },
          ),
        ],
      ),
    );
  }

  Widget _xayDungTabPhoBien(List<CongThuc> danhSachCongThuc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: danhSachCongThuc.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietCongThuc(
                    congThuc: danhSachCongThuc[index],
                  ),
                ),
              );
            },
            child: TheCongThuc(
              congThuc: danhSachCongThuc[index],
              ngang: true,
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms + (index * 100).ms);
      },
    );
  }

  Widget _xayDungTabMoiNhat(List<CongThuc> danhSachCongThuc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: danhSachCongThuc.length,
      itemBuilder: (context, index) {
        final congThuc = danhSachCongThuc[index];

        // Xử lý ảnh món ăn
        Image imageWidget;
        if (congThuc.hinhAnh.startsWith('http')) {
          imageWidget = Image.network(
            congThuc.hinhAnh,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        } else {
          imageWidget = Image.asset(
            congThuc.hinhAnh,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }

        // Xử lý ảnh tác giả
        ImageProvider anhTacGiaWidget;
        if (congThuc.anhTacGia.startsWith('http')) {
          anhTacGiaWidget = NetworkImage(congThuc.anhTacGia);
        } else {
          anhTacGiaWidget = AssetImage(congThuc.anhTacGia);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietCongThuc(
                    congThuc: congThuc,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: imageWidget,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: anhTacGiaWidget,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              congThuc.tacGia,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ChuDe.mauPhu,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                congThuc.loai,
                                style: const TextStyle(
                                  color: ChuDe.mauChinh,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          congThuc.tenMon,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: ChuDe.mauChuPhu),
                            const SizedBox(width: 4),
                            Text(
                              '${congThuc.thoiGianNau} phút',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ChuDe.mauChuPhu,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              congThuc.diemDanhGia.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                color: ChuDe.mauChuPhu,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.favorite,
                                size: 16, color: ChuDe.mauChinh),
                            const SizedBox(width: 4),
                            Text(
                              '${congThuc.luotThich}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ChuDe.mauChuPhu,
                              ),
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
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms + (index * 100).ms);
      },
    );
  }
}
