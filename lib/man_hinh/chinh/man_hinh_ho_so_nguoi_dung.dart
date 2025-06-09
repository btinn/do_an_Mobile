import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/dich_vu/dich_vu_nguoi_dung.dart';
import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_tin_nhan.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
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
    with TickerProviderStateMixin {
  final DichVuNguoiDung _dichVuNguoiDung = DichVuNguoiDung();
  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();

  late AnimationController _animationController;
  late AnimationController _buttonController;

  Map<String, dynamic> _thongTinNguoiDung = {};
  bool _dangTheoDoi = false;
  bool _dangTai = true;
  bool _dangXuLy = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _taiThongTinNguoiDung();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _taiThongTinNguoiDung() async {
    try {
      // Lấy người dùng hiện tại
      final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
      final uidNguoiHienTai = nguoiDungHienTai?.ma ?? '';
      
      final thongTin = await _dichVuNguoiDung.layThongTinNguoiDung(widget.maNguoiDung);
      
      // Chỉ kiểm tra theo dõi nếu không phải chính mình
      bool dangTheoDoi = false;
      if (uidNguoiHienTai.isNotEmpty && uidNguoiHienTai != widget.maNguoiDung) {
        dangTheoDoi = await _dichVuNguoiDung.kiemTraDangTheoDoi(
          widget.maNguoiDung,
          uidNguoiHienTai,
        );
      }

      setState(() {
        _thongTinNguoiDung = thongTin;
        _dangTheoDoi = dangTheoDoi;
        _dangTai = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải thông tin người dùng: $e');
      setState(() => _dangTai = false);
    }
  }

  Future<void> _xuLyTheoDoi() async {
    if (_dangXuLy) return;

    // Lấy người dùng hiện tại
    final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
    final uidNguoiHienTai = nguoiDungHienTai?.ma;

    if (uidNguoiHienTai == null || uidNguoiHienTai.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để theo dõi')),
      );
      return;
    }

    if (uidNguoiHienTai == widget.maNguoiDung) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể theo dõi chính mình')),
      );
      return;
    }

    setState(() => _dangXuLy = true);
    _buttonController.forward();
    HapticFeedback.lightImpact();

    try {
      bool thanhCong;
      if (_dangTheoDoi) {
        thanhCong = await _dichVuNguoiDung.huyTheoDoi(
          widget.maNguoiDung,
          uidNguoiHienTai,
        );
      } else {
        thanhCong = await _dichVuNguoiDung.theoDoi(
          widget.maNguoiDung,
          uidNguoiHienTai,
        );
      }

      if (thanhCong) {
        setState(() {
          _dangTheoDoi = !_dangTheoDoi;
          if (_dangTheoDoi) {
            _thongTinNguoiDung['followers'] = (_thongTinNguoiDung['followers'] ?? 0) + 1;
          } else {
            _thongTinNguoiDung['followers'] = (_thongTinNguoiDung['followers'] ?? 1) - 1;
          }
        });

        HapticFeedback.mediumImpact();
        
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
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi xử lý theo dõi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ${_dangTheoDoi ? 'hủy theo dõi' : 'theo dõi'}. Vui lòng thử lại.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _dangXuLy = false);
      _buttonController.reverse();
    }
  }

  Future<void> _moTinNhan() async {
    HapticFeedback.lightImpact();

    // Lấy người dùng hiện tại
    final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
    final uidNguoiHienTai = nguoiDungHienTai?.ma;

    if (uidNguoiHienTai == null || uidNguoiHienTai.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để nhắn tin')),
      );
      return;
    }

    // Cập nhật trạng thái online cho người dùng hiện tại
    await _dichVuTinNhan.capNhatTrangThaiOnline(uidNguoiHienTai, true);

    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ManHinhChiTietTinNhan(
            maNguoiKhac: widget.maNguoiDung,
            tenNguoiKhac: widget.tenNguoiDung,
            anhNguoiKhac: widget.anhDaiDien,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChuDe.mauNenTinNhan,
      body: _dangTai ? _xayDungManHinhTai() : _xayDungNoiDung(),
    );
  }

  Widget _xayDungManHinhTai() {
    return const Center(
      child: CircularProgressIndicator(color: ChuDe.mauChinh),
    );
  }

  Widget _xayDungNoiDung() {
    return CustomScrollView(
      slivers: [
        _xayDungSliverAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _xayDungThongTinCoBan(),
              _xayDungCacNutHanhDong(),
              _xayDungThongKe(),
              _xayDungTrangThaiOnline(),
              const SizedBox(height: 20),
              _xayDungDanhSachCongThuc(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _xayDungSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: ChuDe.shadowCard,
          ),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
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
            child: const Icon(Icons.more_vert_rounded, size: 18),
          ),
          onPressed: _hienThiMenuTuyChon,
        ),
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
              tag: 'avatar_${widget.maNguoiDung}',
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
                  backgroundImage: NetworkImage(widget.anhDaiDien),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungThongTinCoBan() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.tenNguoiDung,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChu,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 8),
          Text(
            _thongTinNguoiDung['username'] ?? '@${widget.tenNguoiDung.toLowerCase()}',
            style: const TextStyle(
              fontSize: 16,
              color: ChuDe.mauChuPhu,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _xayDungCacNutHanhDong() {
  // Lấy người dùng hiện tại
  final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
  final uidNguoiHienTai = nguoiDungHienTai?.ma ?? '';
  final laChinhMinh = uidNguoiHienTai == widget.maNguoiDung;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        if (!laChinhMinh) ...[
          Expanded(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
              ),
              child: ElevatedButton.icon(
                onPressed: _dangXuLy ? null : _xuLyTheoDoi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dangTheoDoi ? Colors.grey.shade200 : ChuDe.mauChinh,
                  foregroundColor: _dangTheoDoi ? ChuDe.mauChu : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
                  ),
                  elevation: _dangTheoDoi ? 0 : 4,
                ),
                icon: _dangXuLy
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _dangTheoDoi ? ChuDe.mauChu : Colors.white,
                        ),
                      )
                    : Icon(_dangTheoDoi ? Icons.check_rounded : Icons.add_rounded),
                label: Text(
                  _dangTheoDoi ? 'Đang Theo Dõi' : 'Theo Dõi',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: laChinhMinh ? null : _moTinNhan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: laChinhMinh ? Colors.grey : ChuDe.mauChinh,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
                side: BorderSide(color: laChinhMinh ? Colors.grey : ChuDe.mauChinh),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.message_rounded),
            label: Text(
              laChinhMinh ? 'Hồ Sơ Của Bạn' : 'Nhắn Tin',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
}

  Widget _xayDungThongKe() {
    return Container(
      margin: const EdgeInsets.all(20),
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
            (_thongTinNguoiDung['recipes'] ?? 0).toString(),
            Icons.restaurant_menu_rounded,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _xayDungItemThongKe(
            'Người Theo Dõi',
            (_thongTinNguoiDung['followers'] ?? 0).toString(),
            Icons.people_rounded,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _xayDungItemThongKe(
            'Đang Theo Dõi',
            (_thongTinNguoiDung['following'] ?? 0).toString(),
            Icons.person_add_rounded,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
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

  Widget _xayDungTrangThaiOnline() {
    return StreamBuilder<bool>(
      stream: _dichVuTinNhan.langNgheTrangThaiOnline(widget.maNguoiDung),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isOnline ? ChuDe.mauOnline.withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? ChuDe.mauOnline : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'Đang hoạt động' : 'Không hoạt động',
                style: TextStyle(
                  fontSize: 12,
                  color: isOnline ? ChuDe.mauOnline : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _xayDungDanhSachCongThuc() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
        boxShadow: ChuDe.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Công Thức',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChu,
              ),
            ),
          ),
          FutureBuilder<List<CongThuc>>(
            future: _dichVuCongThuc.layDanhSachCongThucCuaTacGia(
              widget.maNguoiDung,
              context.read<DangKiDangNhapEmail>().nguoiDungHienTai?.ma ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Lỗi khi tải công thức',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final danhSachCongThuc = snapshot.data ?? [];

              if (danhSachCongThuc.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Chưa có công thức nào',
                      style: TextStyle(
                        color: ChuDe.mauChuPhu,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: danhSachCongThuc.length,
                itemBuilder: (context, index) {
                  final congThuc = danhSachCongThuc[index];
                  return _xayDungTheCongThuc(congThuc);
                },
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3);
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
              child: Image.network(
                congThuc.hinhAnh,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant, size: 40),
                  );
                },
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
                      const Icon(Icons.favorite, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${congThuc.luotThich}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        congThuc.diemDanhGia.toStringAsFixed(1),
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
  );
}

  void _hienThiMenuTuyChon() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ChuDe.borderRadiusXLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _xayDungTuyChonMenu(
              icon: Icons.share_rounded,
              title: 'Chia sẻ hồ sơ',
              onTap: () => Navigator.pop(context),
            ),
            _xayDungTuyChonMenu(
              icon: Icons.copy_rounded,
              title: 'Sao chép liên kết',
              onTap: () => Navigator.pop(context),
            ),
            _xayDungTuyChonMenu(
              icon: Icons.report_rounded,
              title: 'Báo cáo',
              onTap: () => Navigator.pop(context),
              isDestructive: true,
            ),
            _xayDungTuyChonMenu(
              icon: Icons.block_rounded,
              title: 'Chặn người dùng',
              onTap: () => Navigator.pop(context),
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _xayDungTuyChonMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : ChuDe.mauChu,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : ChuDe.mauChu,
        ),
      ),
      onTap: onTap,
    );
  }
}
