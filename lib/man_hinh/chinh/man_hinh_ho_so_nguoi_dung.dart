import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_tin_nhan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_nguoi_dung.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class ManHinhHoSoNguoiDung extends StatefulWidget {
  final String maNguoiDung;
  final String tenNguoiDung;
  final String anhDaiDien;

  const ManHinhHoSoNguoiDung({
    super.key,
    required this.maNguoiDung,
    required this.tenNguoiDung,
    required this.anhDaiDien,
  });

  @override
  State<ManHinhHoSoNguoiDung> createState() => _ManHinhHoSoNguoiDungState();
}

class _ManHinhHoSoNguoiDungState extends State<ManHinhHoSoNguoiDung>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();
  final DichVuNguoiDung _dichVuNguoiDung = DichVuNguoiDung();

  bool _dangTheoDoi = false;
  Map<String, dynamic> _thongTinNguoiDung = {};
  List<CongThuc> _danhSachCongThucCuaTacGia = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _taiThongTinNguoiDung();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _taiThongTinNguoiDung() async {
    setState(() => _dangTai = true);

    try {
      // Sử dụng dịch vụ người dùng để lấy thông tin
      final thongTinNguoiDung = await _dichVuNguoiDung.layThongTinNguoiDung(widget.maNguoiDung);
      
      // Kiểm tra trạng thái theo dõi
      final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
      if (nguoiDungHienTai != null) {
        final dangTheoDoi = await _dichVuNguoiDung.kiemTraDangTheoDoi(
          widget.maNguoiDung, 
          nguoiDungHienTai.ma
        );
        
        setState(() {
          _dangTheoDoi = dangTheoDoi;
        });
      }

      setState(() {
        _thongTinNguoiDung = thongTinNguoiDung;
      });

      // Lấy danh sách công thức
      await _taiDanhSachCongThucCuaTacGia();
    } catch (e) {
      debugPrint('Lỗi tải thông tin người dùng: $e');
    }

    setState(() => _dangTai = false);
  }

  Future<void> _taiDanhSachCongThucCuaTacGia() async {
    try {
      final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
      final uidNguoiXem = nguoiDungHienTai?.ma ?? '';
      
      // Sử dụng service để lấy danh sách công thức
      _danhSachCongThucCuaTacGia = await _dichVuCongThuc.layDanhSachCongThucCuaTacGia(
        widget.maNguoiDung,
        uidNguoiXem
      );

      setState(() {});
    } catch (e) {
      debugPrint('Lỗi tải danh sách công thức: $e');
    }
  }

  void _toggleTheoDoi() async {
    final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
    final uidNguoiDangXem = widget.maNguoiDung;
    final uidNguoiHienTai = nguoiDungHienTai?.ma;

    if (uidNguoiHienTai == null || uidNguoiDangXem == uidNguoiHienTai) return;

    try {
      bool thanhCong;
      
      if (_dangTheoDoi) {
        // Hủy theo dõi
        thanhCong = await _dichVuNguoiDung.huyTheoDoi(uidNguoiDangXem, uidNguoiHienTai);
        
        if (thanhCong) {
          setState(() {
            _dangTheoDoi = false;
            _thongTinNguoiDung['followers'] = (_thongTinNguoiDung['followers'] ?? 1) - 1;
          });
        }
      } else {
        // Bắt đầu theo dõi
        thanhCong = await _dichVuNguoiDung.theoDoi(uidNguoiDangXem, uidNguoiHienTai);
        
        if (thanhCong) {
          setState(() {
            _dangTheoDoi = true;
            _thongTinNguoiDung['followers'] = (_thongTinNguoiDung['followers'] ?? 0) + 1;
          });
        }
      }

      if (thanhCong) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_dangTheoDoi
                ? 'Đã theo dõi ${widget.tenNguoiDung}'
                : 'Đã hủy theo dõi ${widget.tenNguoiDung}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật theo dõi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau')),
      );
    }
  }

  void _moManHinhNhanTin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhChiTietTinNhan(
          maNguoiKhac: widget.maNguoiDung,
          tenNguoiKhac: widget.tenNguoiDung,
          anhNguoiKhac: widget.anhDaiDien,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _taiThongTinNguoiDung();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data khi quay lại từ màn hình khác
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    if (_dangTai) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100,
              pinned: true,
              backgroundColor: ChuDe.mauChinh,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
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
            ),
            SliverToBoxAdapter(
              child: _xayDungThongTinNguoiDung(),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: ChuDe.mauChinh,
                  unselectedLabelColor: ChuDe.mauChuPhu,
                  indicatorColor: ChuDe.mauChinh,
                  tabs: const [
                    Tab(text: 'Công Thức'),
                    Tab(text: 'Đã Lưu'),
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
            // Tab Công Thức - hiển thị danh sách công thức thực tế
            _xayDungTabCongThuc(),
            _xayDungKhongCoDuLieu(
              'Không thể xem công thức đã lưu',
              'Chỉ chủ tài khoản mới có thể xem mục này',
              Icons.bookmark_border,
              'Quay Lại',
              () => _tabController.animateTo(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongTinNguoiDung() {
    final username = _thongTinNguoiDung['username'] ?? '@unknown';
    final followers = _thongTinNguoiDung['followers'] ?? 0;
    final following = _thongTinNguoiDung['following'] ?? 0;
    final recipes = _thongTinNguoiDung['recipes'] ?? 0;

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
                backgroundImage: widget.anhDaiDien.startsWith('http')
                    ? NetworkImage(widget.anhDaiDien)
                    : AssetImage(widget.anhDaiDien) as ImageProvider,
              ),
            ),
          ),

          // Thông tin người dùng
          Transform.translate(
            offset: const Offset(0, -1),
            child: Column(
              children: [
                Text(
                  widget.tenNguoiDung,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChuDe.mauChuPhu,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Số liệu thống kê
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _xayDungThongKe(
                      recipes.toString(),
                      'Công Thức',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _xayDungThongKe(
                      followers.toString(),
                      'Người Theo Dõi',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _xayDungThongKe(
                      following.toString(),
                      'Đang Theo Dõi',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nút theo dõi và nhắn tin
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _toggleTheoDoi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _dangTheoDoi ? Colors.white : ChuDe.mauChinh,
                        foregroundColor:
                            _dangTheoDoi ? ChuDe.mauChinh : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _dangTheoDoi
                                ? ChuDe.mauChinh
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_dangTheoDoi ? Icons.check : Icons.add),
                          const SizedBox(width: 4),
                          Text(_dangTheoDoi ? 'Đang Theo Dõi' : 'Theo Dõi'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _moManHinhNhanTin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ChuDe.mauChinh,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: ChuDe.mauChinh),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.message_outlined),
                          SizedBox(width: 4),
                          Text('Nhắn Tin'),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _xayDungTabCongThuc() {
    if (_danhSachCongThucCuaTacGia.isEmpty) {
      return _xayDungKhongCoDuLieu(
        '${widget.tenNguoiDung} chưa có công thức nào',
        'Hãy theo dõi để nhận thông báo khi có công thức mới',
        Icons.restaurant_menu,
        'Theo Dõi',
        _toggleTheoDoi,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _danhSachCongThucCuaTacGia.length,
      itemBuilder: (context, index) {
        final congThuc = _danhSachCongThucCuaTacGia[index];
        return _xayDungTheCongThuc(congThuc, index);
      },
    );
  }

  Widget _xayDungTheCongThuc(CongThuc congThuc, int index) {
    return GestureDetector(
      onTap: () async {
        // Tăng lượt xem khi người dùng xem chi tiết công thức
        await _dichVuCongThuc.tangLuotXem(congThuc.ma);
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhChiTietCongThuc(congThuc: congThuc),
          ),
        );

        // Refresh nếu có thay đổi (xóa bài)
        if (result == true) {
          _taiDanhSachCongThucCuaTacGia();
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
            // Hình ảnh công thức
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    // Hình ảnh chính
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: _xayDungHinhAnhCongThuc(congThuc.hinhAnh),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
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
                    // Rating
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
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
                    // Time
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${congThuc.thoiGianNau}p',
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
            // Thông tin công thức
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
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
                        GestureDetector(
                          onTap: () async {
                            final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
                            if (nguoiDungHienTai == null) return;
                            
                            if (congThuc.daThich) {
                              // Bỏ thích
                              final thanhCong = await _dichVuCongThuc.boThichCongThuc(
                                congThuc.ma, 
                                nguoiDungHienTai.ma
                              );
                              
                              if (thanhCong) {
                                setState(() {
                                  congThuc.daThich = false;
                                  congThuc.luotThich = congThuc.luotThich > 0 ? congThuc.luotThich - 1 : 0;
                                });
                              }
                            } else {
                              // Thích
                              final thanhCong = await _dichVuCongThuc.thichCongThuc(
                                congThuc.ma, 
                                nguoiDungHienTai.ma
                              );
                              
                              if (thanhCong) {
                                setState(() {
                                  congThuc.daThich = true;
                                  congThuc.luotThich = congThuc.luotThich + 1;
                                });
                              }
                            }
                          },
                          child: Icon(
                            Icons.favorite,
                            color: congThuc.daThich ? Colors.red : Colors.grey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${congThuc.luotThich}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ChuDe.mauChuPhu,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${congThuc.luotXem} lượt xem',
                          style: const TextStyle(
                            fontSize: 10,
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
    ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
  }

  Widget _xayDungHinhAnhCongThuc(String duongDanHinhAnh) {
    // Kiểm tra xem hình ảnh có phải là file local không
    if (duongDanHinhAnh.startsWith('/')) {
      // Đây là file local
      final file = File(duongDanHinhAnh);
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
      } else {
        return _xayDungHinhAnhMacDinh();
      }
    } else if (duongDanHinhAnh.startsWith('assets/')) {
      // Đây là asset
      return Image.asset(
        duongDanHinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh();
        },
      );
    } else if (duongDanHinhAnh.startsWith('http')) {
      // Đây là URL
      return Image.network(
        duongDanHinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh();
        },
      );
    } else {
      return _xayDungHinhAnhMacDinh();
    }
  }

  Widget _xayDungHinhAnhMacDinh() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 40,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Hình ảnh\nkhông có sẵn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
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
