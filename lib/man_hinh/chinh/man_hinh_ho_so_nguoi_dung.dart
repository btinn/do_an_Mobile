import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_tin_nhan.dart';

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
  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();
  
  bool _dangTheoDoi = false;
  Map<String, dynamic> _thongTinNguoiDung = {};
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      // Lấy thông tin người dùng từ dịch vụ
      final thongTin = _dichVuTinNhan.layThongTinNguoiDung(widget.maNguoiDung);
      
      setState(() {
        _thongTinNguoiDung = thongTin;
        _dangTai = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải thông tin người dùng: $e');
      setState(() => _dangTai = false);
    }
  }

  void _toggleTheoDoi() {
    setState(() {
      _dangTheoDoi = !_dangTheoDoi;
    });
    
    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_dangTheoDoi 
            ? 'Đã theo dõi ${widget.tenNguoiDung}' 
            : 'Đã hủy theo dõi ${widget.tenNguoiDung}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                    Tab(text: 'Hoạt Động'),
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
            _xayDungKhongCoDuLieu(
              '${widget.tenNguoiDung} chưa có công thức nào',
              'Hãy theo dõi để nhận thông báo khi có công thức mới',
              Icons.restaurant_menu,
              'Theo Dõi',
              _toggleTheoDoi,
            ),
            _xayDungKhongCoDuLieu(
              'Không thể xem công thức đã lưu',
              'Chỉ chủ tài khoản mới có thể xem mục này',
              Icons.bookmark_border,
              'Quay Lại',
              () => _tabController.animateTo(0),
            ),
            _xayDungKhongCoDuLieu(
              'Không thể xem hoạt động',
              'Chỉ chủ tài khoản mới có thể xem mục này',
              Icons.history,
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
                      '0',
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
                        backgroundColor: _dangTheoDoi ? Colors.white : ChuDe.mauChinh,
                        foregroundColor: _dangTheoDoi ? ChuDe.mauChinh : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _dangTheoDoi ? ChuDe.mauChinh : Colors.transparent,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
