import 'package:do_an/dich_vu/dich_vu_luu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/binh_luan.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_ho_so_nguoi_dung.dart';
import 'package:do_an/dich_vu/dich_vu_danh_gia.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_binh_luan.dart';
import 'dart:io';

class ManHinhChiTietCongThuc extends StatefulWidget {
  final CongThuc congThuc;
  final Future<void> Function()? taiLaiCongThuc;

  const ManHinhChiTietCongThuc({
    super.key,
    required this.congThuc,
    this.taiLaiCongThuc,
  });

  @override
  State<ManHinhChiTietCongThuc> createState() => _ManHinhChiTietCongThucState();
}

class _ManHinhChiTietCongThucState extends State<ManHinhChiTietCongThuc>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _binhLuanController = TextEditingController();
  final DichVuBinhLuan _dichVuBinhLuan = DichVuBinhLuan();
  final DichVuLuuCongThuc _dichVuLuuCongThuc = DichVuLuuCongThuc();
  double _danhGia = 5.0;
  bool _dangGuiBinhLuan = false;
  final ScrollController _scrollController = ScrollController();
  bool _hienThiAppBarMau = false;
  bool _dangKiemTraLuu = true;
  bool _daLuuCongThuc = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _danhGia = widget.congThuc.diemDanhGia;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 200 && !_hienThiAppBarMau) {
        setState(() {
          _hienThiAppBarMau = true;
        });
      } else if (_scrollController.position.pixels <= 200 &&
          _hienThiAppBarMau) {
        setState(() {
          _hienThiAppBarMau = false;
        });
      }
    });
    
    // Tăng lượt xem khi vào xem chi tiết công thức
    _tangLuotXem();
    
    // Kiểm tra trạng thái lưu công thức
    _kiemTraTrangThaiLuu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _binhLuanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _kiemTraTrangThaiLuu() async {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
            .nguoiDungHienTai
            ?.ma ??
        '';
    if (uid.isEmpty) {
      setState(() {
        _dangKiemTraLuu = false;
      });
      return;
    }

    try {
      final daLuu = await _dichVuLuuCongThuc.kiemTraDaLuu(uid, widget.congThuc.ma);
      if (mounted) {
        setState(() {
          _daLuuCongThuc = daLuu;
          _dangKiemTraLuu = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra trạng thái lưu: $e');
      if (mounted) {
        setState(() {
          _dangKiemTraLuu = false;
        });
      }
    }
  }

  void _guiBinhLuan() async {
    if (_binhLuanController.text.trim().isEmpty || _dangGuiBinhLuan) return;

    final dangNhapService =
        Provider.of<DangKiDangNhapEmail>(context, listen: false);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    if (nguoiDung == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để bình luận'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _dangGuiBinhLuan = true;
    });

    try {
      final thanhCong = await _dichVuBinhLuan.themBinhLuan(
        maCongThuc: widget.congThuc.ma,
        noiDung: _binhLuanController.text.trim(),
        uid: nguoiDung.ma,
        hoTen: nguoiDung.hoTen,
        anhDaiDien: nguoiDung.anhDaiDien,
      );

      if (mounted) {
        if (thanhCong) {
          _binhLuanController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bình luận của bạn đã được gửi!'),
              backgroundColor: ChuDe.mauXanhLa,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi gửi bình luận'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi gửi bình luận'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _dangGuiBinhLuan = false;
        });
      }
    }
  }

  void _guiDanhGia() async {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
            .nguoiDungHienTai
            ?.ma ??
        '';
    if (uid.isEmpty) return;

    final dichVu = DichVuDanhGia();

    // Gửi đánh giá lên Firebase
    await dichVu.danhGiaCongThuc(widget.congThuc.ma, uid, _danhGia);

    // Tính điểm trung bình mới
    final diemTrungBinh = await dichVu.layDiemTrungBinh(widget.congThuc.ma);

    // Cập nhật lại Firebase
    await FirebaseDatabase.instance
        .ref('cong_thuc/${widget.congThuc.ma}/diemDanhGia')
        .set(diemTrungBinh);

    if (uid != widget.congThuc.uid) {
      if (!mounted) return;

      final thongBaoService = DichVuThongBao();
      final tenNguoiGui = Provider.of<DangKiDangNhapEmail>(context, listen: false)
          .nguoiDungHienTai?.hoTen ??
          'Người dùng';

      await thongBaoService.taoThongBaoDanhGia(
        maNguoiNhan: widget.congThuc.uid,
        maNguoiGui: uid,
        tenNguoiGui: tenNguoiGui,
        maCongThuc: widget.congThuc.ma,
        tenCongThuc: widget.congThuc.tenMon,
        diemDanhGia: _danhGia,
      );
    }

    if (mounted) {
      setState(() {
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cảm ơn bạn đã đánh giá công thức!'),
          backgroundColor: ChuDe.mauXanhLa,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _luuCongThuc() async {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
            .nguoiDungHienTai
            ?.ma ??
        '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu công thức'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _dangKiemTraLuu = true;
    });

    try {
      if (_daLuuCongThuc) {
        // Hủy lưu
        await _dichVuLuuCongThuc.huyLuuCongThuc(uid, widget.congThuc.ma);
        if (mounted) {
          setState(() {
            _daLuuCongThuc = false;
            _dangKiemTraLuu = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã bỏ lưu công thức'),
              backgroundColor: ChuDe.mauChuPhu,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        // Lưu mới
        await _dichVuLuuCongThuc.luuCongThuc(uid, widget.congThuc.ma);
        if (mounted) {
          setState(() {
            _daLuuCongThuc = true;
            _dangKiemTraLuu = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã lưu công thức'),
              backgroundColor: ChuDe.mauXanhLa,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu/hủy lưu công thức: $e');
      if (mounted) {
        setState(() {
          _dangKiemTraLuu = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi thực hiện thao tác'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _chiaSeCongThuc() {
    Share.share(
      'Hãy thử làm món ${widget.congThuc.tenMon} ngon tuyệt này! Xem công thức tại: https://amthucviet.app/cong-thuc/${widget.congThuc.ma}',
      subject: 'Chia sẻ công thức ${widget.congThuc.tenMon}',
    );
  }

  void _chuyenDenTrangCaNhan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhHoSoNguoiDung(
          maNguoiDung: widget.congThuc.uid,
          tenNguoiDung: widget.congThuc.tacGia,
          anhDaiDien: widget.congThuc.anhTacGia,
        ),
      ),
    );
  }

  void _xoaCongThuc() {
    final scaffoldContext = context;

    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công thức này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final uid = Provider.of<DangKiDangNhapEmail>(
                    scaffoldContext,
                    listen: false,
                  ).nguoiDungHienTai?.ma ??
                  '';

              Navigator.pop(dialogContext);

              final dichVuCongThuc = DichVuCongThuc();
              final thanhCong =
                  await dichVuCongThuc.xoaCongThuc(widget.congThuc.ma, uid);

              if (!mounted) return;

              if (thanhCong) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa công thức thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                if (mounted) {
                  Navigator.pop(scaffoldContext, true);
                }
              } else {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Có lỗi xảy ra khi xóa công thức'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _xayDungHinhAnh() {
  return Container(
    height: 320,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: _xayDungHinhAnhCongThuc(),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _xayDungHinhAnhCongThuc() {
    if (widget.congThuc.hinhAnh.startsWith('/')) {
      final file = File(widget.congThuc.hinhAnh);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        return Image.asset(
          'assets/images/default_food.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        );
      }
    } else if (widget.congThuc.hinhAnh.startsWith('assets/')) {
      return Image.asset(
        widget.congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return Image.network(
        widget.congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  Widget _xayDungAvatarTacGia() {
    if (widget.congThuc.anhTacGia.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: ChuDe.mauChinh,
        child: Text(
          widget.congThuc.tacGia.isNotEmpty
              ? widget.congThuc.tacGia[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (widget.congThuc.anhTacGia.startsWith('/')) {
      final file = File(widget.congThuc.anhTacGia);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: FileImage(file),
        );
      }
    } else if (widget.congThuc.anhTacGia.startsWith('assets/')) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(widget.congThuc.anhTacGia),
      );
    } else if (widget.congThuc.anhTacGia.startsWith('http')) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(widget.congThuc.anhTacGia),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: ChuDe.mauChinh,
      child: Text(
        widget.congThuc.tacGia.isNotEmpty
            ? widget.congThuc.tacGia[0].toUpperCase()
            : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDungHienTai = dangNhapService.nguoiDungHienTai;
    final laChuSoHuu = nguoiDungHienTai?.ma == widget.congThuc.uid;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor:
                _hienThiAppBarMau ? ChuDe.mauChinh : Colors.transparent,
            elevation: _hienThiAppBarMau ? 4 : 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 100),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              if (laChuSoHuu)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 100),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _xoaCongThuc,
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 100),
                  shape: BoxShape.circle,
                ),
                child: _dangKiemTraLuu
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _daLuuCongThuc ? Icons.bookmark : Icons.bookmark_border,
                          color: _daLuuCongThuc ? ChuDe.mauVang : Colors.white,
                        ),
                        onPressed: _luuCongThuc,
                      ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 100),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _chiaSeCongThuc,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _xayDungHinhAnh(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.congThuc.tenMon,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ChuDe.mauChinh,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 12),
                  Container(
  margin: const EdgeInsets.symmetric(vertical: 8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.grey.shade50,
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: GestureDetector(
    onTap: _chuyenDenTrangCaNhan,
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ChuDe.mauChinh.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _xayDungAvatarTacGia(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.congThuc.tacGia,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ChuDe.mauChinh,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tác giả công thức',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChuDe.mauChinh.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: ChuDe.mauChinh,
          ),
        ),
      ],
    ),
  ),
)
                  .animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _xayDungThongTinNhanh(
                          Icons.access_time,
                          '${widget.congThuc.thoiGianNau} phút',
                          'Thời gian',
                        ),
                      ),
                      Expanded(
                        child: _xayDungThongTinNhanh(
                          Icons.people,
                          '${widget.congThuc.khauPhan} người',
                          'Khẩu phần',
                        ),
                      ),
                      Expanded(
                        child: _xayDungThongTinNhanh(
                          Icons.star,
                          widget.congThuc.diemDanhGia.toStringAsFixed(1),
                          'Đánh giá',
                        ),
                      ),
                      Expanded(
                        child: _xayDungThongTinNhanh(
                          Icons.category,
                          widget.congThuc.loai,
                          'Loại',
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                  const SizedBox(height: 24),
                  Container(
  margin: const EdgeInsets.symmetric(horizontal: 4),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TabBar(
    controller: _tabController,
    indicator: BoxDecoration(
      gradient: LinearGradient(
        colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: ChuDe.mauChinh.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey.shade600,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    tabs: const [
      Tab(text: 'Nguyên liệu'),
      Tab(text: 'Cách làm'),
      Tab(text: 'Bình luận'),
    ],
  ),
)
                  .animate().fadeIn(duration: 500.ms, delay: 600.ms),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5, // Responsive height
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _xayDungDanhSachNguyenLieu(),
                        _xayDungCachLam(),
                        _xayDungBinhLuan(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    setState(() {});
    _hienThiDialogDanhGia();
    if (widget.taiLaiCongThuc != null) {
      await widget.taiLaiCongThuc!();
    }
  },
  backgroundColor: Colors.transparent,
  elevation: 8,
  label: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [ChuDe.mauChinh, ChuDe.mauChinh.withValues(alpha: 0.8)],
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: ChuDe.mauChinh.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: Colors.white, size: 20),
        SizedBox(width: 8),
        Text(
          'Đánh giá',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
)
          .animate().scale(duration: 500.ms, delay: 800.ms),
    );
  }

  Widget _xayDungThongTinNhanh(IconData icon, String giaTri, String nhan) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.grey.shade50,
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: ChuDe.mauChinh.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: ChuDe.mauChinh.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChuDe.mauChinh.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: ChuDe.mauChinh, 
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          giaTri,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ChuDe.mauChinh,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          nhan,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

  Widget _xayDungDanhSachNguyenLieu() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.congThuc.nguyenLieu.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ChuDe.mauChinh,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.congThuc.nguyenLieu[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _xayDungCachLam() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.congThuc.cachLam.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: ChuDe.mauChinh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.congThuc.cachLam[index],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _xayDungBinhLuan() {
  return Column(
    children: [
      // Form nhập bình luận - cải thiện giao diện
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chia sẻ cảm nhận của bạn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ChuDe.mauChinh,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: TextField(
                controller: _binhLuanController,
                decoration: const InputDecoration(
                  hintText: 'Viết bình luận của bạn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                maxLines: 3,
                enabled: !_dangGuiBinhLuan,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _dangGuiBinhLuan ? null : _guiBinhLuan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChuDe.mauChinh,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                icon: _dangGuiBinhLuan
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _dangGuiBinhLuan ? 'Đang gửi...' : 'Gửi',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),

      // Danh sách bình luận
      Expanded(
        child: StreamBuilder<List<BinhLuan>>(
          stream: _dichVuBinhLuan.layDanhSachBinhLuan(widget.congThuc.ma).asBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: ChuDe.mauChinh),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra khi tải bình luận',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            final danhSachBinhLuan = snapshot.data ?? [];

            if (danhSachBinhLuan.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bình luận nào',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy là người đầu tiên chia sẻ cảm nhận!',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 80), // Tránh đè nút floating
              itemCount: danhSachBinhLuan.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final binhLuan = danhSachBinhLuan[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.08),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _xayDungAvatarBinhLuan(binhLuan.anhTacGia, binhLuan.tacGia),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  binhLuan.tacGia,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: ChuDe.mauChinh,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd/MM/yyyy • HH:mm').format(binhLuan.thoiGian),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          binhLuan.noiDung,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
              },
            );
          },
        ),
      ),
    ],
  );
}

  Widget _xayDungAvatarBinhLuan(String anhDaiDien, String tenNguoiDung) {
  // Nếu không có ảnh hoặc ảnh mặc định
  if (anhDaiDien.isEmpty || anhDaiDien == 'assets/images/avatar_default.jpg') {
    return CircleAvatar(
      radius: 20,
      backgroundColor: ChuDe.mauChinh,
      child: Text(
        tenNguoiDung.isNotEmpty ? tenNguoiDung[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Nếu là đường dẫn file local
  if (anhDaiDien.startsWith('/')) {
    final file = File(anhDaiDien);
    if (file.existsSync()) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: FileImage(file),
        backgroundColor: Colors.grey.shade200,
      );
    }
  }

  // Nếu là asset
  if (anhDaiDien.startsWith('assets/')) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage(anhDaiDien),
      backgroundColor: Colors.grey.shade200,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Lỗi load avatar asset: $exception');
      },
    );
  }

  // Nếu là URL
  if (anhDaiDien.startsWith('http')) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          anhDaiDien,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(ChuDe.mauChinh),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 20,
              backgroundColor: ChuDe.mauChinh,
              child: Text(
                tenNguoiDung.isNotEmpty ? tenNguoiDung[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Fallback
  return CircleAvatar(
    radius: 20,
    backgroundColor: ChuDe.mauChinh,
    child: Text(
      tenNguoiDung.isNotEmpty ? tenNguoiDung[0].toUpperCase() : 'U',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}

  void _hienThiDialogDanhGia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá công thức'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn cảm thấy công thức này như thế nào?'),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _danhGia,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: ChuDe.mauVang,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _danhGia = rating;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${_danhGia.toStringAsFixed(1)} sao',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChinh,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
              });
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _guiDanhGia();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ChuDe.mauChinh,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi đánh giá'),
          ),
        ],
      ),
    );
  }

  Future<void> _tangLuotXem() async {
    try {
      final dichVuCongThuc = DichVuCongThuc();
      await dichVuCongThuc.tangLuotXem(widget.congThuc.ma);
    } catch (e) {
      debugPrint('Lỗi khi tăng lượt xem: $e');
    }
  }
}
