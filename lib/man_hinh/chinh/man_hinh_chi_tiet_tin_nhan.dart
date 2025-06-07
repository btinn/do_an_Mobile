import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class _ManHinhChiTietTinNhanState extends State<ManHinhChiTietTinNhan> {
  final TextEditingController _tinNhanController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();
  
  List<TinNhan> _danhSachTinNhan = [];
  bool _dangGui = false;
  String? _maCuocTroChuyenId;

  final List<String> _quickReactions = ['❤️', '😂', '👍', '😮', '😢', '😡'];

  @override
  void initState() {
    super.initState();
    _khoiTaoCuocTroChuyenId();
    _taiTinNhan();
  }

  @override
  void dispose() {
    _tinNhanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _khoiTaoCuocTroChuyenId() {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    
    if (nguoiDung != null) {
      _maCuocTroChuyenId = _dichVuTinNhan.taoMaCuocTroChuyenId(nguoiDung.ma, widget.maNguoiKhac);
    }
  }

  Future<void> _taiTinNhan() async {
    if (_maCuocTroChuyenId != null) {
      try {
        final danhSach = await _dichVuTinNhan.layTinNhanTrongCuocTroChuyenId(_maCuocTroChuyenId!);
        setState(() {
          _danhSachTinNhan = danhSach;
        });

        // Đánh dấu đã đọc
        final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
        final nguoiDung = dangNhapService.nguoiDungHienTai;
        if (nguoiDung != null) {
          await _dichVuTinNhan.danhDauDaDoc(_maCuocTroChuyenId!, nguoiDung.ma);
        }

        // Lắng nghe tin nhắn mới
        _dichVuTinNhan.langNgheTinNhan(_maCuocTroChuyenId!).listen((danhSach) {
          if (mounted) {
            setState(() {
              _danhSachTinNhan = danhSach;
            });
            _cuonXuongCuoi();
          }
        });

        _cuonXuongCuoi();
      } catch (e) {
        debugPrint('Lỗi tải tin nhắn: $e');
      }
    }
  }

  void _cuonXuongCuoi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _guiTinNhan({String? noiDung, String loai = 'text'}) async {
    final content = noiDung ?? _tinNhanController.text.trim();
    if (content.isEmpty || _dangGui) return;

    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    
    if (nguoiDung == null) return;

    setState(() => _dangGui = true);

    try {
      await _dichVuTinNhan.guiTinNhan(
        maNguoiGui: nguoiDung.ma,
        tenNguoiGui: nguoiDung.hoTen,
        anhNguoiGui: nguoiDung.anhDaiDien,
        maNguoiNhan: widget.maNguoiKhac,
        tenNguoiNhan: widget.tenNguoiKhac,
        anhNguoiNhan: widget.anhNguoiKhac,
        noiDung: content,
        loai: loai,
      );

      if (loai == 'text') {
        _tinNhanController.clear();
      }
    } catch (e) {
      debugPrint('Lỗi gửi tin nhắn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi gửi tin nhắn. Vui lòng thử lại.')),
        );
      }
    } finally {
      setState(() => _dangGui = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ChuDe.mauChu),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.anhNguoiKhac.startsWith('http')
                  ? NetworkImage(widget.anhNguoiKhac)
                  : AssetImage(widget.anhNguoiKhac) as ImageProvider,
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
                  const Text(
                    '@ssvictor0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    '9 đang follow • 16 follower',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: ChuDe.mauChu),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: ChuDe.mauChu),
            onPressed: () {
              _hienThiMenuTuyChon();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: _danhSachTinNhan.isEmpty
                ? _xayDungManHinhTrong()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _danhSachTinNhan.length,
                    itemBuilder: (context, index) {
                      final tinNhan = _danhSachTinNhan[index];
                      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
                      final nguoiDung = dangNhapService.nguoiDungHienTai;
                      final laTinNhanCuaToi = nguoiDung != null && tinNhan.maNguoiGui == nguoiDung.ma;
                      
                      return _xayDungTinNhan(tinNhan, laTinNhanCuaToi);
                    },
                  ),
          ),

          // Quick reactions
          if (_danhSachTinNhan.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const Text(
                    'Nói lời chào bằng cách gửi nhãn dán',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('👋', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ..._quickReactions.map((emoji) => GestureDetector(
                        onTap: () => _guiTinNhan(noiDung: emoji, loai: 'sticker'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      )),
                      GestureDetector(
                        onTap: () => _guiTinNhan(noiDung: '👋', loai: 'sticker'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Thú cưng streak',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Thanh nhập tin nhắn
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
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChuDe.mauChinh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tinNhanController,
                    decoration: InputDecoration(
                      hintText: 'Nhắn tin...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _guiTinNhan(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _dangGui ? null : () => _guiTinNhan(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _tinNhanController.text.trim().isNotEmpty 
                          ? ChuDe.mauChinh 
                          : Colors.grey.shade300,
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
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungManHinhTrong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.anhNguoiKhac.startsWith('http')
                ? NetworkImage(widget.anhNguoiKhac)
                : AssetImage(widget.anhNguoiKhac) as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            widget.tenNguoiKhac,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '@ssvictor0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '9 đang follow • 16 follower',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hôm nay 3:38 CH',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _xayDungTinNhan(TinNhan tinNhan, bool laTinNhanCuaToi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: laTinNhanCuaToi ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!laTinNhanCuaToi) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: tinNhan.anhNguoiGui.startsWith('http')
                  ? NetworkImage(tinNhan.anhNguoiGui)
                  : AssetImage(tinNhan.anhNguoiGui) as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: laTinNhanCuaToi ? ChuDe.mauChinh : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: laTinNhanCuaToi ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: laTinNhanCuaToi ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: tinNhan.loai == 'sticker'
                  ? Text(
                      tinNhan.noiDung,
                      style: const TextStyle(fontSize: 24),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tinNhan.noiDung,
                          style: TextStyle(
                            color: laTinNhanCuaToi ? Colors.white : ChuDe.mauChu,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tinNhan.thoiGianHienThi,
                          style: TextStyle(
                            color: laTinNhanCuaToi ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (laTinNhanCuaToi) ...[
            const SizedBox(width: 8),
            Icon(
              tinNhan.daDoc ? Icons.done_all : Icons.done,
              size: 16,
              color: tinNhan.daDoc ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: laTinNhanCuaToi ? 0.3 : -0.3, end: 0);
  }

  void _hienThiMenuTuyChon() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Xem hồ sơ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Tìm kiếm tin nhắn'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Tắt thông báo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Chặn người dùng', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
