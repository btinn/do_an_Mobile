import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_tin_nhan.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/mo_hinh/cuoc_tro_chuyen_tom_tat.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';

class ManHinhHopThu extends StatefulWidget {
  const ManHinhHopThu({super.key});

  @override
  State<ManHinhHopThu> createState() => _ManHinhHopThuState();
}

class _ManHinhHopThuState extends State<ManHinhHopThu>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _fabController;

  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();
  final TextEditingController _searchController2 = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CuocTroChuyenTomTat> _danhSachCuocTroChuyenTomTat = [];
  List<CuocTroChuyenTomTat> _danhSachTimKiem = [];
  
  // Map để lưu trữ tin nhắn theo người dùng
  final Map<String, List<TinNhan>> _danhSachTinNhanTheoNguoiDung = {};

  bool _dangTai = false;
  bool _dangTimKiem = false;
  bool _hienThiTimKiem = false;
  
  // ID người dùng hiện tại (giả lập)
  final String _maNguoiDungHienTai = 'current_user';

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    setState(() => _dangTai = true);
    _taiDuLieuRealTime();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    _searchController2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  void _taiDuLieuRealTime() {
    _dichVuTinNhan.langNgheCuocTroChuyenTomTat(_maNguoiDungHienTai).listen((danhSach) {
      if (mounted) {
        setState(() {
          _danhSachCuocTroChuyenTomTat = danhSach;
          _dangTai = false;
        });
        
        // Tải tin nhắn cho mỗi cuộc trò chuyện
        for (var cuocTroChuyenTomTat in danhSach) {
          _taiTinNhanTheoNguoiDung(cuocTroChuyenTomTat.maNguoiKhac);
        }
      }
    });
  }
  
  void _taiTinNhanTheoNguoiDung(String maNguoiKhac) {
    final cuocTroChuyenId = _dichVuTinNhan.taoMaCuocTroChuyenId(_maNguoiDungHienTai, maNguoiKhac);
    
    _dichVuTinNhan.langNgheTinNhan(cuocTroChuyenId).listen((danhSachTinNhan) {
      if (mounted) {
        setState(() {
          _danhSachTinNhanTheoNguoiDung[maNguoiKhac] = danhSachTinNhan;
        });
      }
    });
  }

  void _timKiem(String query) {
    setState(() {
      _dangTimKiem = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() {
          _danhSachTimKiem = [];
          _dangTimKiem = false;
        });
        return;
      }

      final ketQua = _danhSachCuocTroChuyenTomTat.where((cuocTroChuyenTomTat) {
        return cuocTroChuyenTomTat.tenNguoiKhac
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            cuocTroChuyenTomTat.tinNhanCuoi
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();

      setState(() {
        _danhSachTimKiem = ketQua;
        _dangTimKiem = false;
      });
    });
  }

  void _toggleTimKiem() {
    setState(() {
      _hienThiTimKiem = !_hienThiTimKiem;
    });

    if (_hienThiTimKiem) {
      _searchController.forward();
    } else {
      _searchController.reverse();
      _searchController2.clear();
      _danhSachTimKiem.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChuDe.mauNenTinNhan,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _xayDungSliverAppBar(),
          SliverToBoxAdapter(
            child: _xayDungTabTinNhan(),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
        ),
        child: FloatingActionButton.extended(
          onPressed: _hienThiDialogTaoTinNhanMoi,
          backgroundColor: ChuDe.mauTinNhanGui,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.edit_rounded),
          label: const Text(
            'Tin nhắn mới',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _xayDungSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _hienThiTimKiem ? 120 : 80,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, ChuDe.mauNenTinNhan],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _xayDungHeader(),
                if (_hienThiTimKiem) _xayDungTimKiem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Tin Nhắn',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChu,
              ),
            ),
          ),
          _xayDungNutHanhDong(
            icon: Icons.search_rounded,
            onTap: _toggleTimKiem,
            isActive: _hienThiTimKiem,
          ),
          const SizedBox(width: 12),
          _xayDungNutHanhDong(
            icon: Icons.more_vert_rounded,
            onTap: _hienThiMenuTuyChon,
          ),
        ],
      ),
    );
  }

  Widget _xayDungNutHanhDong({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? ChuDe.mauTinNhanGui : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
          boxShadow: isActive ? ChuDe.shadowCard : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : ChuDe.mauChu,
          size: 22,
        ),
      ),
    );
  }

  Widget _xayDungTimKiem() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _searchController,
        curve: Curves.easeOutCubic,
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
            boxShadow: ChuDe.shadowCard,
          ),
          child: TextField(
            controller: _searchController2,
            onChanged: _timKiem,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tin nhắn...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: ChuDe.mauChuPhu),
              suffixIcon: _searchController2.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController2.clear();
                        _timKiem('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            autofocus: true,
          ),
        ),
      ),
    );
  }

  Widget _xayDungTabTinNhan() {
    if (_dangTai) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: const Center(
          child: CircularProgressIndicator(color: ChuDe.mauTinNhanGui),
        ),
      );
    }

    final danhSachHienThi =
        _hienThiTimKiem && _searchController2.text.isNotEmpty
            ? _danhSachTimKiem
            : _danhSachCuocTroChuyenTomTat;

    if (_dangTimKiem) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: const Center(
          child: CircularProgressIndicator(color: ChuDe.mauTinNhanGui),
        ),
      );
    }

    if (danhSachHienThi.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: _xayDungManHinhTrong(),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: danhSachHienThi.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 88,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final cuocTroChuyenTomTat = danhSachHienThi[index];
          return _xayDungItemCuocTroChuyenTomTat(cuocTroChuyenTomTat, index);
        },
      ),
    );
  }

  Widget _xayDungItemCuocTroChuyenTomTat(
      CuocTroChuyenTomTat cuocTroChuyenTomTat, int index) {
    // Lấy danh sách tin nhắn của cuộc trò chuyện này
    final danhSachTinNhan = _danhSachTinNhanTheoNguoiDung[cuocTroChuyenTomTat.maNguoiKhac] ?? [];
    
    // Lấy 3 tin nhắn gần nhất để hiển thị bong bóng chat
    final tinNhanGanNhat = danhSachTinNhan.isNotEmpty 
        ? danhSachTinNhan.sublist(
            danhSachTinNhan.length > 3 ? danhSachTinNhan.length - 3 : 0, 
            danhSachTinNhan.length
          )
        : <TinNhan>[];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: _xayDungAvatar(cuocTroChuyenTomTat),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    cuocTroChuyenTomTat.tenNguoiKhac,
                    style: TextStyle(
                      fontWeight: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 16,
                      color: ChuDe.mauChu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  cuocTroChuyenTomTat.thoiGianHienThi,
                  style: TextStyle(
                    fontSize: 12,
                    color: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                        ? ChuDe.mauTinNhanGui
                        : ChuDe.mauChuPhu,
                    fontWeight: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    _layNoiDungTinNhanHienThi(cuocTroChuyenTomTat),
                    style: TextStyle(
                      color: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                          ? ChuDe.mauChu
                          : ChuDe.mauChuPhu,
                      fontWeight: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (cuocTroChuyenTomTat.soTinNhanChuaDoc > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: ChuDe.gradientTinNhan,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cuocTroChuyenTomTat.soTinNhanChuaDoc > 99
                          ? '99+'
                          : cuocTroChuyenTomTat.soTinNhanChuaDoc.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => _moChiTietTinNhan(cuocTroChuyenTomTat),
          ),
          
          // Hiển thị bong bóng chat
          if (tinNhanGanNhat.isNotEmpty)
            _xayDungBongBongChat(tinNhanGanNhat, cuocTroChuyenTomTat),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }
  
  Widget _xayDungBongBongChat(List<TinNhan> tinNhanGanNhat, CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: tinNhanGanNhat.map((tinNhan) {
          final laTinNhanCuaToi = tinNhan.maNguoiGui == _maNguoiDungHienTai;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: laTinNhanCuaToi 
                  ? MainAxisAlignment.end 
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!laTinNhanCuaToi) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(cuocTroChuyenTomTat.anhNguoiKhac),
                  ),
                  const SizedBox(width: 8),
                ],
                
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: laTinNhanCuaToi 
                          ? ChuDe.mauTinNhanGui 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tinNhan.noiDung,
                      style: TextStyle(
                        color: laTinNhanCuaToi ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                if (laTinNhanCuaToi) ...[
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=Me&background=0D8ABC&color=fff'),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _xayDungTrangThaiOnline(String maNguoiKhac) {
    return StreamBuilder<bool>(
      stream: _dichVuTinNhan.langNgheTrangThaiOnline(maNguoiKhac),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isOnline ? ChuDe.mauOnline : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      },
    );
  }

  Widget _xayDungAvatar(CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0
                  ? ChuDe.mauTinNhanGui
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(cuocTroChuyenTomTat.anhNguoiKhac),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: _xayDungTrangThaiOnline(cuocTroChuyenTomTat.maNguoiKhac),
        ),
      ],
    );
  }

  Widget _xayDungManHinhTrong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: ChuDe.gradientTinNhan,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.message_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChu,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bắt đầu trò chuyện với những người\nyêu ẩm thực khác',
            style: TextStyle(
              fontSize: 16,
              color: ChuDe.mauChuPhu,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _hienThiDialogTaoTinNhanMoi,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChuDe.mauTinNhanGui,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
              ),
              elevation: 8,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Tạo Tin Nhắn Mới',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  String _layNoiDungTinNhanHienThi(CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    switch (cuocTroChuyenTomTat.loaiTinNhanCuoi) {
      case 'image':
        return '📷 Hình ảnh';
      case 'recipe':
        return '🍳 Chia sẻ công thức';
      case 'sticker':
        return '😊 Nhãn dán';
      case 'voice':
        return '🎤 Tin nhắn thoại';
      case 'location':
        return '📍 Vị trí';
      case 'file':
        return '📎 Tệp đính kèm';
      default:
        return cuocTroChuyenTomTat.tinNhanCuoi;
    }
  }

  void _moChiTietTinNhan(CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ManHinhChiTietTinNhan(
          maNguoiKhac: cuocTroChuyenTomTat.maNguoiKhac,
          tenNguoiKhac: cuocTroChuyenTomTat.tenNguoiKhac,
          anhNguoiKhac: cuocTroChuyenTomTat.anhNguoiKhac,
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

  void _hienThiMenuTuyChon() {
    HapticFeedback.mediumImpact();

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
              icon: Icons.mark_email_read_rounded,
              title: 'Đánh dấu tất cả đã đọc',
              onTap: () {
                Navigator.pop(context);
                _danhDauTatCaDaDoc();
              },
            ),
            _xayDungTuyChonMenu(
              icon: Icons.archive_rounded,
              title: 'Tin nhắn đã lưu trữ',
              onTap: () {
                Navigator.pop(context);
                _hienThiTinNhanDaLuuTru();
              },
            ),
            _xayDungTuyChonMenu(
              icon: Icons.settings_rounded,
              title: 'Cài đặt tin nhắn',
              onTap: () {
                Navigator.pop(context);
                _hienThiCaiDatTinNhan();
              },
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
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
        ),
        child: Icon(icon, color: ChuDe.mauChu),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _danhDauTatCaDaDoc() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả tin nhắn là đã đọc'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hienThiTinNhanDaLuuTru() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển: Tin nhắn đã lưu trữ'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hienThiCaiDatTinNhan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển: Cài đặt tin nhắn'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hienThiDialogTaoTinNhanMoi() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
        ),
        title: const Text(
          'Tạo Tin Nhắn Mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tính năng này đang được phát triển. Bạn có thể nhắn tin với người dùng khác từ trang hồ sơ của họ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
