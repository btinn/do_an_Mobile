import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ManHinhChiTietTinNhan extends StatefulWidget {
  final String maNguoiKhac;
  final String tenNguoiKhac;
  final String anhNguoiKhac;

  const ManHinhChiTietTinNhan({
    super.key,
    required this.maNguoiKhac,
    required this.tenNguoiKhac,
    required this.anhNguoiKhac,
  });

  @override
  State<ManHinhChiTietTinNhan> createState() => _ManHinhChiTietTinNhanState();
}

class _ManHinhChiTietTinNhanState extends State<ManHinhChiTietTinNhan>
    with TickerProviderStateMixin {
  final TextEditingController _tinNhanController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();

  late AnimationController _inputController;
  late AnimationController _messageController;

  List<TinNhan> _danhSachTinNhan = [];
  StreamSubscription<List<TinNhan>>? _tinNhanSubscription;

  bool _dangGui = false;
  bool _dangNhap = false;
  String? _maCuocTroChuyenId;
  String? _maNguoiDungHienTai;

  final List<String> _quickReactions = ['👋', '❤️', '😂', '👍', '😮', '😢'];

  @override
  void initState() {
    super.initState();
    _inputController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Gọi _khoiTao() sau khi build context hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _khoiTao();
    });

    _focusNode.addListener(_onFocusChange);
    _tinNhanController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _tinNhanSubscription?.cancel();
    _inputController.dispose();
    _messageController.dispose();
    _tinNhanController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _inputController.forward();
    } else {
      _inputController.reverse();
    }
  }

  void _onTextChange() {
    setState(() {
      _dangNhap = _tinNhanController.text.isNotEmpty;
    });
  }

  void _khoiTao() {
    final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai;
    if (nguoiDungHienTai != null) {
      setState(() {
        _maNguoiDungHienTai = nguoiDungHienTai.ma;
        _maCuocTroChuyenId = _dichVuTinNhan.taoMaCuocTroChuyenId(
          nguoiDungHienTai.ma, 
          widget.maNguoiKhac
        );
      });
      
      // Gọi các hàm mà không gán kết quả
      _langNgheTinNhan();
      _danhDauDaDoc();
    }
  }

  void _langNgheTinNhan() {
    if (_maCuocTroChuyenId != null && _maNguoiDungHienTai != null) {
      _tinNhanSubscription?.cancel(); // Hủy subscription cũ nếu có
      _tinNhanSubscription = _dichVuTinNhan
          .langNgheTinNhan(_maCuocTroChuyenId!, maNguoiDung: _maNguoiDungHienTai!)
          .listen((danhSachTinNhan) {
        if (mounted) {
          setState(() {
            _danhSachTinNhan = danhSachTinNhan;
          });
          _cuonXuongCuoi();
          _messageController.forward();
        }
      });
    }
  }

  void _danhDauDaDoc() {
    if (_maCuocTroChuyenId != null && _maNguoiDungHienTai != null) {
      _dichVuTinNhan.danhDauDaDoc(_maCuocTroChuyenId!, _maNguoiDungHienTai!);
    }
  }

  void _cuonXuongCuoi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _guiTinNhan({String? noiDung, String loai = 'text'}) async {
    final content = noiDung ?? _tinNhanController.text.trim();
    if (content.isEmpty || _dangGui || _maNguoiDungHienTai == null) return;

    setState(() => _dangGui = true);
    HapticFeedback.lightImpact();

    try {
      final nguoiDungHienTai = context.read<DangKiDangNhapEmail>().nguoiDungHienTai!;
      
      // Gọi hàm gửi tin nhắn mà không gán kết quả
      await _dichVuTinNhan.guiTinNhan(
        maNguoiGui: nguoiDungHienTai.ma,
        tenNguoiGui: nguoiDungHienTai.hoTen,
        anhNguoiGui: nguoiDungHienTai.anhDaiDien,
        maNguoiNhan: widget.maNguoiKhac,
        tenNguoiNhan: widget.tenNguoiKhac,
        anhNguoiNhan: widget.anhNguoiKhac,
        noiDung: content,
        loai: loai,
      );

      // Nếu không có exception thì coi như thành công
      if (loai == 'text') {
        _tinNhanController.clear();
      }
      _cuonXuongCuoi();
      
    } catch (e) {
      debugPrint('Lỗi gửi tin nhắn: $e');
      _hienThiLoi('Lỗi gửi tin nhắn. Vui lòng thử lại.');
    } finally {
      setState(() => _dangGui = false);
    }
  }

  // Xóa tin nhắn cho bản thân
  Future<void> _xoaTinNhanChoBanThan(TinNhan tinNhan) async {
    if (_maCuocTroChuyenId == null || _maNguoiDungHienTai == null) return;

    try {
      final thanhCong = await _dichVuTinNhan.xoaTinNhanChoBanThan(
        cuocTroChuyenId: _maCuocTroChuyenId!,
        tinNhanId: tinNhan.ma,
        maNguoiDung: _maNguoiDungHienTai!,
      );

      if (thanhCong) {
        _hienThiThongBao('Đã xóa tin nhắn cho bạn');
      } else {
        _hienThiLoi('Không thể xóa tin nhắn');
      }
    } catch (e) {
      _hienThiLoi('Lỗi xóa tin nhắn');
    }
  }

  // Xóa tin nhắn cho mọi người
  Future<void> _xoaTinNhanChoMoiNguoi(TinNhan tinNhan) async {
    if (_maCuocTroChuyenId == null || _maNguoiDungHienTai == null) return;

    try {
      final thanhCong = await _dichVuTinNhan.xoaTinNhanChoMoiNguoi(
        cuocTroChuyenId: _maCuocTroChuyenId!,
        tinNhanId: tinNhan.ma,
        maNguoiGui: _maNguoiDungHienTai!,
      );

      if (thanhCong) {
        _hienThiThongBao('Đã xóa tin nhắn cho mọi người');
      } else {
        _hienThiLoi('Không thể xóa tin nhắn. Chỉ có thể xóa trong 24 giờ.');
      }
    } catch (e) {
      _hienThiLoi('Lỗi xóa tin nhắn');
    }
  }

  // Hiển thị menu xóa tin nhắn
  void _hienThiMenuXoaTinNhan(TinNhan tinNhan) {
    final laTinNhanCuaToi = tinNhan.maNguoiGui == _maNguoiDungHienTai;
    
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
            const SizedBox(height: 8),
            
            // Xóa cho bản thân (luôn có)
            _xayDungTuyChonXoa(
              icon: Icons.delete_outline_rounded,
              title: 'Xóa cho bạn',
              subtitle: 'Tin nhắn sẽ bị xóa khỏi thiết bị này',
              onTap: () {
                Navigator.pop(context);
                _xacNhanXoaTinNhan(
                  'Xóa tin nhắn cho bạn?',
                  'Tin nhắn này sẽ bị xóa khỏi thiết bị của bạn.',
                  () => _xoaTinNhanChoBanThan(tinNhan),
                );
              },
            ),
            
            // Xóa cho mọi người (chỉ tin nhắn của mình và trong 24h)
            if (laTinNhanCuaToi && tinNhan.coTheXoaChoMoiNguoi && !tinNhan.daBiXoa)
              _xayDungTuyChonXoa(
                icon: Icons.delete_forever_rounded,
                title: 'Xóa cho mọi người',
                subtitle: 'Tin nhắn sẽ bị xóa cho tất cả mọi người',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _xacNhanXoaTinNhan(
                    'Xóa tin nhắn cho mọi người?',
                    'Tin nhắn này sẽ bị xóa cho tất cả mọi người trong cuộc trò chuyện.',
                    () => _xoaTinNhanChoMoiNguoi(tinNhan),
                  );
                },
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _xayDungTuyChonXoa({
    required IconData icon,
    required String title,
    required String subtitle,
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
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : ChuDe.mauChu,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDestructive ? Colors.red.shade300 : ChuDe.mauChuPhu,
        ),
      ),
      onTap: onTap,
    );
  }

  // Xác nhận xóa tin nhắn
  void _xacNhanXoaTinNhan(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChuDe.borderRadiusLarge),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: ChuDe.mauChuPhu,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiLoi(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  void _hienThiThongBao(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChuDe.mauNenTinNhan,
      appBar: _xayDungAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _danhSachTinNhan.isEmpty
                ? _xayDungManHinhTrong()
                : _xayDungDanhSachTinNhan(),
          ),
          if (_danhSachTinNhan.isEmpty) _xayDungQuickReactions(),
          _xayDungThanhNhapTinNhan(),
        ],
      ),
    );
  }

  PreferredSizeWidget _xayDungAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: _hienThiThongTinNguoiDung,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.anhNguoiKhac),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: ChuDe.mauOnline,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tenNguoiKhac,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ChuDe.mauChu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      fontSize: 12,
                      color: ChuDe.mauOnline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        _xayDungNutHanhDong(Icons.videocam_rounded, () {}),
        _xayDungNutHanhDong(Icons.call_rounded, () {}),
        _xayDungNutHanhDong(Icons.more_vert_rounded, _hienThiMenuTuyChon),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _xayDungNutHanhDong(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
          ),
          child: Icon(icon, color: ChuDe.mauChu, size: 20),
        ),
      ),
    );
  }

  Widget _xayDungManHinhTrong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: ChuDe.gradientTinNhan,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(widget.anhNguoiKhac),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.tenNguoiKhac,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChu,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ChuDe.mauOnline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ChuDe.borderRadiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ChuDe.mauOnline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    fontSize: 12,
                    color: ChuDe.mauOnline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _xayDungDanhSachTinNhan() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _danhSachTinNhan.length,
      itemBuilder: (context, index) {
        final tinNhan = _danhSachTinNhan[index];
        final laTinNhanCuaToi = tinNhan.maNguoiGui == _maNguoiDungHienTai;
        return _xayDungTinNhan(tinNhan, laTinNhanCuaToi, index);
      },
    );
  }

  Widget _xayDungTinNhan(TinNhan tinNhan, bool laTinNhanCuaToi, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            laTinNhanCuaToi ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!laTinNhanCuaToi) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(tinNhan.anhNguoiGui),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _hienThiMenuXoaTinNhan(tinNhan),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: laTinNhanCuaToi ? ChuDe.gradientTinNhan : null,
                  color: laTinNhanCuaToi ? null : Colors.white,
                  borderRadius:
                      BorderRadius.circular(ChuDe.borderRadiusLarge).copyWith(
                    bottomLeft: laTinNhanCuaToi
                        ? const Radius.circular(ChuDe.borderRadiusLarge)
                        : const Radius.circular(4),
                    bottomRight: laTinNhanCuaToi
                        ? const Radius.circular(4)
                        : const Radius.circular(ChuDe.borderRadiusLarge),
                  ),
                  boxShadow: ChuDe.shadowCard,
                ),
                child: tinNhan.loai == 'sticker'
                    ? Text(
                        tinNhan.noiDung,
                        style: const TextStyle(fontSize: 32),
                      )
                    : tinNhan.daBiXoa
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.block_rounded,
                                size: 16,
                                color: laTinNhanCuaToi 
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : ChuDe.mauChuPhu,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tinNhan.noiDung,
                                style: TextStyle(
                                  color: laTinNhanCuaToi 
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : ChuDe.mauChuPhu,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tinNhan.noiDung,
                                style: TextStyle(
                                  color:
                                      laTinNhanCuaToi ? Colors.white : ChuDe.mauChu,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tinNhan.thoiGianHienThi,
                                    style: TextStyle(
                                      color: laTinNhanCuaToi
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : ChuDe.mauChuPhu,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (laTinNhanCuaToi) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      tinNhan.daDoc
                                          ? Icons.done_all_rounded
                                          : Icons.done_rounded,
                                      size: 14,
                                      color: tinNhan.daDoc
                                          ? Colors.blue.shade300
                                          : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
              ),
            ),
          ),
          if (laTinNhanCuaToi) const SizedBox(width: 8),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms)
        .slideX(begin: laTinNhanCuaToi ? 0.3 : -0.3, end: 0);
  }

  Widget _xayDungQuickReactions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Nói lời chào bằng cách gửi nhãn dán',
            style: TextStyle(
              color: ChuDe.mauChuPhu,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ..._quickReactions.map((emoji) => GestureDetector(
                    onTap: () => _guiTinNhan(noiDung: emoji, loai: 'sticker'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: ChuDe.shadowCard,
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xayDungThanhNhapTinNhan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: _hienThiMenuDinhKem,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: ChuDe.gradientTinNhan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ChuDe.mauNenTinNhan,
                  borderRadius: BorderRadius.circular(ChuDe.borderRadiusXLarge),
                ),
                child: TextField(
                  controller: _tinNhanController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Nhắn tin...',
                    hintStyle: const TextStyle(
                      color: ChuDe.mauChuPhu,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: _dangNhap
                        ? IconButton(
                            icon: const Icon(Icons.emoji_emotions_rounded),
                            onPressed: () {},
                          )
                        : null,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _guiTinNhan(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _dangGui ? null : () => _guiTinNhan(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient:
                      _dangNhap || _dangGui ? ChuDe.gradientTinNhan : null,
                  color: _dangNhap || _dangGui ? null : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: _dangGui
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _dangNhap ? Icons.send_rounded : Icons.mic_rounded,
                        color: _dangNhap ? Colors.white : ChuDe.mauChuPhu,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hienThiThongTinNguoiDung() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ChuDe.borderRadiusXLarge),
          ),
        ),
        child: Column(
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
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.anhNguoiKhac),
            ),
            const SizedBox(height: 16),
            Text(
              widget.tenNguoiKhac,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
              icon: Icons.person_rounded,
              title: 'Xem hồ sơ',
              onTap: () => Navigator.pop(context),
            ),
            _xayDungTuyChonMenu(
              icon: Icons.search_rounded,
              title: 'Tìm kiếm tin nhắn',
              onTap: () => Navigator.pop(context),
            ),
            _xayDungTuyChonMenu(
              icon: Icons.notifications_off_rounded,
              title: 'Tắt thông báo',
              onTap: () => Navigator.pop(context),
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

  void _hienThiMenuDinhKem() {
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _xayDungTuyChonDinhKem(
                  icon: Icons.photo_camera_rounded,
                  label: 'Camera',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _xayDungTuyChonDinhKem(
                  icon: Icons.photo_library_rounded,
                  label: 'Thư viện',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _xayDungTuyChonDinhKem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Công thức',
                  color: ChuDe.mauChinh,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _xayDungTuyChonDinhKem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ChuDe.mauChu,
            ),
          ),
        ],
      ),
    );
  }
}
