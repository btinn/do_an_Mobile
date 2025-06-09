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
  double _danhGia = 5.0;
  bool _dangHienThiDanhGia = false;
  bool _daLuuCongThuc = false;
  bool _daThich = false;
  bool _dangGuiBinhLuan = false;
  final ScrollController _scrollController = ScrollController();
  bool _hienThiAppBarMau = false;
  double _diemTrungBinh = 0.0;
  int _soLuongDanhGia = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _daThich = widget.congThuc.daThich;
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _binhLuanController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final soLuongMoi = await dichVu.demSoLuongDanhGia(widget.congThuc.ma);

    // Cập nhật lại Firebase
    await FirebaseDatabase.instance
        .ref('cong_thuc/${widget.congThuc.ma}/diemDanhGia')
        .set(diemTrungBinh);

    if (uid != widget.congThuc.uid) {
      final thongBaoService = DichVuThongBao();
      final tenNguoiGui =
          Provider.of<DangKiDangNhapEmail>(context, listen: false)
                  .nguoiDungHienTai
                  ?.hoTen ??
              'Người dùng';

      await thongBaoService.taoThongBaoDanhGia(
        maNguoiNhan: widget.congThuc.uid,
        maNguoiGui: uid,
        tenNguoiGui: tenNguoiGui,
        maCongThuc: widget.congThuc.ma,
        tenCongThuc: widget.congThuc.tenMon,
      );
    }

    if (mounted) {
      setState(() {
        _dangHienThiDanhGia = false;
        _diemTrungBinh = diemTrungBinh;
        _soLuongDanhGia = soLuongMoi;
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

  void _luuCongThuc() {
    setState(() {
      _daLuuCongThuc = !_daLuuCongThuc;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_daLuuCongThuc ? 'Đã lưu công thức' : 'Đã bỏ lưu công thức'),
        backgroundColor: _daLuuCongThuc ? ChuDe.mauXanhLa : ChuDe.mauChuPhu,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
                Navigator.pop(scaffoldContext, true);
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
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: _xayDungHinhAnhCongThuc(),
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
                color: Colors.black.withAlpha(100),
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
                    color: Colors.black.withAlpha(100),
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
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
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
                  color: Colors.black.withAlpha(100),
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
                  GestureDetector(
                    onTap: _chuyenDenTrangCaNhan,
                    child: Row(
                      children: [
                        _xayDungAvatarTacGia(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.congThuc.tacGia,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Tác giả công thức',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: ChuDe.mauChinh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      tabs: const [
                        Tab(text: 'Nguyên liệu'),
                        Tab(text: 'Cách làm'),
                        Tab(text: 'Bình luận'),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
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
          setState(() {
            _dangHienThiDanhGia = true;
          });
          _hienThiDialogDanhGia();
          if (widget.taiLaiCongThuc != null) {
            await widget.taiLaiCongThuc!();
          }
        },
        backgroundColor: ChuDe.mauChinh,
        icon: const Icon(Icons.star, color: Colors.white),
        label: const Text(
          'Đánh giá',
          style: TextStyle(color: Colors.white),
        ),
      ).animate().scale(duration: 500.ms, delay: 800.ms),
    );
  }

  Widget _xayDungThongTinNhanh(IconData icon, String giaTri, String nhan) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ChuDe.mauPhu,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: ChuDe.mauChinh, size: 24),
          const SizedBox(height: 4),
          Text(
            giaTri,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            nhan,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
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
        // Form nhập bình luận
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              TextField(
                controller: _binhLuanController,
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ cảm nhận của bạn về công thức này...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
                enabled: !_dangGuiBinhLuan,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _dangGuiBinhLuan ? null : _guiBinhLuan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChuDe.mauChinh,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _dangGuiBinhLuan
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label:
                      Text(_dangGuiBinhLuan ? 'Đang gửi...' : 'Gửi bình luận'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Danh sách bình luận
        Expanded(
          child: StreamBuilder<List<BinhLuan>>(
            stream: _dichVuBinhLuan.layDanhSachBinhLuan(widget.congThuc.ma),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
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
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bình luận nào',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
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

              return ListView.builder(
                itemCount: danhSachBinhLuan.length,
                itemBuilder: (context, index) {
                  final binhLuan = danhSachBinhLuan[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _xayDungAvatarBinhLuan(binhLuan.anhTacGia),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    binhLuan.tacGia,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(binhLuan.thoiGian),
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
                        const SizedBox(height: 8),
                        Text(
                          binhLuan.noiDung,
                          style: const TextStyle(fontSize: 14),
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

  Widget _xayDungAvatarBinhLuan(String anhDaiDien) {
    if (anhDaiDien.isEmpty ||
        anhDaiDien == 'assets/images/avatar_default.jpg') {
      return CircleAvatar(
        radius: 16,
        backgroundColor: ChuDe.mauChinh,
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (anhDaiDien.startsWith('http')) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(anhDaiDien),
        onBackgroundImageError: (exception, stackTrace) {},
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundImage: AssetImage(anhDaiDien),
      onBackgroundImageError: (exception, stackTrace) {},
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
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
                _dangHienThiDanhGia = false;
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
}
