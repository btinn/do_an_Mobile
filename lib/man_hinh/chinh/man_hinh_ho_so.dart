import 'dart:io';

import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_them_cong_thuc.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'man_hinh_cai_dat.dart';
import 'man_hinh_chinh_sua_ho_so.dart';
import 'package:do_an/dich_vu/dich_vu_luu_cong_thuc.dart';

class ManHinhHoSo extends StatefulWidget {
  const ManHinhHoSo({super.key});

  @override
  State<ManHinhHoSo> createState() => _ManHinhHoSoState();
}

class _ManHinhHoSoState extends State<ManHinhHoSo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CongThuc> _danhSachCongThucCuaToi = [];
  bool _dangTai = false;
  final DichVuLuuCongThuc _dichVuLuuCongThuc = DichVuLuuCongThuc();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => _taiTatCaDuLieu());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _taiTatCaDuLieu() async {
    final dangNhapService =
        Provider.of<DangKiDangNhapEmail>(context, listen: false);
    await dangNhapService.layNguoiDungHienTai(); // <== thêm dòng này

    await _taiCongThucCuaToi();
  }

  Future<void> _taiCongThucCuaToi() async {
    setState(() => _dangTai = true);

    try {
      final dangNhapService =
          Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      if (nguoiDung != null) {
        _danhSachCongThucCuaToi = await DichVuCongThuc()
            .layDanhSachCongThucCuaTacGia(nguoiDung.ma, nguoiDung.ma);
      }

      setState(() => _dangTai = false);
    } catch (e) {
      debugPrint('Lỗi tải công thức: $e');
      setState(() => _dangTai = false);
    }
  }

  void _moManHinhCaiDat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManHinhCaiDat(),
      ),
    );
  }

  void _moManHinhChinhSuaHoSo(BuildContext context, NguoiDung nguoiDung) async {
    final nguoiDungMoi = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhChinhSuaHoSo(nguoiDung: nguoiDung),
      ),
    );

    if (nguoiDungMoi != null && mounted) {
      setState(() {
        // Refresh data after profile update
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    debugPrint(
        'Người dùng hiện tại sau khi đăng nhập: ${dangNhapService.nguoiDungHienTai?.hoTen}');

    if (nguoiDung == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _taiCongThucCuaToi,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 100,
                pinned: true,
                backgroundColor: ChuDe.mauChinh,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ChuDe.mauChinh,
                              ChuDe.mauChinh.withAlpha(200),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _moManHinhCaiDat(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _xayDungThongTinNguoiDung(nguoiDung),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: ChuDe.mauChinh,
                    unselectedLabelColor: ChuDe.mauChuPhu,
                    indicatorColor: ChuDe.mauChinh,
                    tabs: [
                      Tab(
                          text:
                              'Công Thức (${_danhSachCongThucCuaToi.length})'),
                      const Tab(text: 'Yêu thích'),
                      const Tab(text: 'Đã Lưu'),
                    ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManHinhThemCongThuc(),
            ),
          );

          // Refresh data when returning from add recipe screen
          if (result == true || mounted) {
            _taiCongThucCuaToi();
          }
        },
        backgroundColor: ChuDe.mauChinh,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _xayDungThongTinNguoiDung(NguoiDung nguoiDung) {
    debugPrint("Follower: ${nguoiDung.nguoiTheoDoiIds}");
    debugPrint("Following: ${nguoiDung.dangTheoDoiIds}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Ảnh đại diện
          Transform.translate(
            offset: const Offset(0, -5),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 47,
                backgroundImage: nguoiDung.anhDaiDien.startsWith('http')
                    ? NetworkImage(nguoiDung.anhDaiDien)
                    : AssetImage(nguoiDung.anhDaiDien) as ImageProvider,
              ),
            ),
          ),

          // Thông tin người dùng
          Transform.translate(
            offset: const Offset(0, -1),
            child: Column(
              children: [
                Text(
                  nguoiDung.hoTen,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${nguoiDung.hoTen.toLowerCase().replaceAll(' ', '')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChuDe.mauChuPhu,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _xayDungThongKe(
                        nguoiDung.congThucIds.length.toString(), 'Công Thức'),
                    Container(
                        height: 30, width: 1, color: Colors.grey.shade300),
                    _xayDungThongKe(nguoiDung.nguoiTheoDoiIds.length.toString(),
                        'Người Theo Dõi'),
                    Container(
                        height: 30, width: 1, color: Colors.grey.shade300),
                    _xayDungThongKe(nguoiDung.dangTheoDoiIds.length.toString(),
                        'Đang Theo Dõi'),
                  ],
                ),

                const SizedBox(height: 16),
                // Có thể thêm nút chỉnh sửa nếu cần
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _xayDungThongKe(String soLuong, String nhan) {
    return Column(
      children: [
        Text(
          soLuong,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          nhan,
          style: const TextStyle(
            fontSize: 12,
            color: ChuDe.mauChuPhu,
          ),
        ),
      ],
    );
  }

  Widget _xayDungTabCongThucCuaToi() {
    if (_dangTai) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_danhSachCongThucCuaToi.isEmpty) {
      return _xayDungKhongCoDuLieu(
        'Bạn chưa có công thức nào',
        'Hãy bắt đầu chia sẻ công thức nấu ăn của bạn',
        Icons.restaurant_menu,
        'Tạo Công Thức',
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManHinhThemCongThuc(),
            ),
          );

          if (result == true || mounted) {
            _taiCongThucCuaToi();
          }
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _danhSachCongThucCuaToi.length,
        itemBuilder: (context, index) {
          final congThuc = _danhSachCongThucCuaToi[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManHinhChiTietCongThuc(
                    congThuc: congThuc,
                  ),
                ),
              );

              // Refresh nếu có thay đổi (xóa bài)
              if (result == true) {
                _taiCongThucCuaToi();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: _xayDungHinhAnhCongThuc(congThuc),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            congThuc.tenMon,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            congThuc.loai,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ChuDe.mauChuPhu,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 16,
                                color: ChuDe.mauChinh,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${congThuc.luotThich}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ChuDe.mauChuPhu,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.visibility,
                                size: 16,
                                color: ChuDe.mauChuPhu,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${congThuc.luotXem}',
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
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms + (index * 100).ms);
        },
      ),
    );
  }

  Widget _xayDungTabYeuThich() {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
        .nguoiDungHienTai
        ?.ma;

    if (uid == null) {
      return _xayDungKhongCoDuLieu(
        'Chưa đăng nhập',
        'Vui lòng đăng nhập để xem công thức yêu thích',
        Icons.login,
        'Đăng nhập',
        () {},
      );
    }

    return FutureBuilder<List<CongThuc>>(
      future: DichVuCongThuc().layDanhSachCongThuc(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi khi tải dữ liệu'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _xayDungKhongCoDuLieu(
            'Bạn chưa yêu thích công thức nào',
            'Hãy khám phá và yêu thích các công thức hay',
            Icons.favorite_border,
            'Khám Phá Ngay',
            () {},
          );
        }

        final danhSachYeuThich =
            snapshot.data!.where((ct) => ct.daThich).toList();

        if (danhSachYeuThich.isEmpty) {
          return _xayDungKhongCoDuLieu(
            'Bạn chưa yêu thích công thức nào',
            'Hãy khám phá và yêu thích các công thức hay',
            Icons.favorite_border,
            'Khám Phá Ngay',
            () {},
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: danhSachYeuThich.length,
          itemBuilder: (context, index) {
            final congThuc = danhSachYeuThich[index];
            return _xayDungTheCongThuc(congThuc);
          },
        );
      },
    );
  }

  Widget _xayDungTheCongThuc(CongThuc congThuc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhChiTietCongThuc(congThuc: congThuc),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: _xayDungHinhAnhCongThuc(congThuc, width: 120, height: 120),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      congThuc.tenMon,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          congThuc.diemDanhGia.toStringAsFixed(1),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
    );
  }

  Widget _xayDungTabDaLuu() {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
        .nguoiDungHienTai
        ?.ma;

    if (uid == null) {
      return _xayDungKhongCoDuLieu(
        'Chưa đăng nhập',
        'Vui lòng đăng nhập để xem công thức đã lưu',
        Icons.login,
        'Đăng nhập',
        () {},
      );
    }

    return FutureBuilder<List<CongThuc>>(
      future: _dichVuLuuCongThuc.layDanhSachCongThucDaLuuChiTiet(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _xayDungKhongCoDuLieu(
            'Đã xảy ra lỗi',
            'Không thể tải danh sách công thức đã lưu',
            Icons.error_outline,
            'Thử lại',
            () => setState(() {}),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _xayDungKhongCoDuLieu(
            'Bạn chưa lưu công thức nào',
            'Hãy khám phá và lưu các công thức yêu thích',
            Icons.bookmark_border,
            'Khám Phá Ngay',
            () {},
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final congThuc = snapshot.data![index];
            return _xayDungTheCongThuc(congThuc);
          },
        );
      },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _xayDungHinhAnhCongThuc(CongThuc congThuc,
      {double? width, double? height}) {
    if (congThuc.hinhAnh.startsWith('/')) {
      final file = File(congThuc.hinhAnh);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _xayDungHinhAnhMacDinh(width, height);
          },
        );
      }
    } else if (congThuc.hinhAnh.startsWith('assets/')) {
      return Image.asset(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(width, height);
        },
      );
    } else if (congThuc.hinhAnh.startsWith('http')) {
      return Image.network(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(width, height);
        },
      );
    }

    return _xayDungHinhAnhMacDinh(width, height);
  }

  Widget _xayDungHinhAnhMacDinh(double? width, double? height) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: (width != null && width < 150) ? 30 : 50,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            'Hình ảnh\nkhông có sẵn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: (width != null && width < 150) ? 8 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
