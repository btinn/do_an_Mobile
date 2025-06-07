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

class ManHinhChiTietCongThuc extends StatefulWidget {
  final CongThuc congThuc;

  const ManHinhChiTietCongThuc({
    super.key,
    required this.congThuc,
  });

  @override
  State<ManHinhChiTietCongThuc> createState() => _ManHinhChiTietCongThucState();
}

class _ManHinhChiTietCongThucState extends State<ManHinhChiTietCongThuc>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _binhLuanController = TextEditingController();
  double _danhGia = 5.0;
  bool _dangHienThiDanhGia = false;
  bool _daLuuCongThuc = false;
  final ScrollController _scrollController = ScrollController();
  bool _hienThiAppBarMau = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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

  void _guiBinhLuan() {
    if (_binhLuanController.text.isNotEmpty) {
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
      final nguoiDung = dangNhapService.nguoiDungHienTai;

      final binhLuanMoi = BinhLuan(
        ma: DateTime.now().millisecondsSinceEpoch.toString(),
        noiDung: _binhLuanController.text,
        thoiGian: DateTime.now(),
        tacGia: nguoiDung?.hoTen ?? 'Người dùng ẩn danh',
        anhTacGia: nguoiDung?.anhDaiDien ?? 'assets/images/avatar.jpg',
      );

      // dichVuDuLieu.themBinhLuan(widget.congThuc.ma, binhLuanMoi);
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
    }
  }

  void _guiDanhGia() {
    // final dichVuDuLieu = Provider.of<DichVuDuLieu>(context, listen: false);
    // dichVuDuLieu.danhGiaCongThuc(widget.congThuc.ma, _danhGia);

    setState(() {
      _dangHienThiDanhGia = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor:
                  _hienThiAppBarMau ? ChuDe.mauChinh : Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'recipe_image_${widget.congThuc.ma}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.congThuc.hinhAnh,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(180),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ChuDe.mauChinh,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.congThuc.loai,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.congThuc.tenMon,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      AssetImage(widget.congThuc.anhTacGia),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.congThuc.tacGia,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.congThuc.diemDanhGia
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${widget.congThuc.danhSachDanhGia.length})',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                title: _hienThiAppBarMau
                    ? Text(
                        widget.congThuc.tenMon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _hienThiAppBarMau ? Colors.white24 : Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: _hienThiAppBarMau ? Colors.white : Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _hienThiAppBarMau ? Colors.white24 : Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _daLuuCongThuc ? Icons.bookmark : Icons.bookmark_border,
                      color: _hienThiAppBarMau ? Colors.white : Colors.white,
                    ),
                  ),
                  onPressed: _luuCongThuc,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _hienThiAppBarMau ? Colors.white24 : Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share,
                      color: _hienThiAppBarMau ? Colors.white : Colors.white,
                    ),
                  ),
                  onPressed: _chiaSeCongThuc,
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: ChuDe.mauChinh,
                  unselectedLabelColor: ChuDe.mauChuPhu,
                  indicatorColor: ChuDe.mauChinh,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Công Thức'),
                    Tab(text: 'Nguyên Liệu'),
                    Tab(text: 'Bình Luận'),
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
            // Tab Công Thức
            _xayDungTabCongThuc(),

            // Tab Nguyên Liệu
            _xayDungTabNguyenLieu(),

            // Tab Bình Luận
            _xayDungTabBinhLuan(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _dangHienThiDanhGia = true;
          });
        },
        backgroundColor: ChuDe.mauChinh,
        child: const Icon(Icons.star),
      ),
      bottomNavigationBar: Container(
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
        child: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: ChuDe.mauChinh,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.restaurant_menu),
          label: const Text(
            'Bắt Đầu Nấu Ăn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Hiển thị đánh giá
      bottomSheet: _dangHienThiDanhGia
          ? Container(
              color: Colors.black.withAlpha(150),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Đánh Giá Công Thức',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.congThuc.tenMon,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ChuDe.mauChuPhu,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    RatingBar.builder(
                      initialRating: _danhGia,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _danhGia = rating;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _dangHienThiDanhGia = false;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: _guiDanhGia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ChuDe.mauChinh,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Gửi Đánh Giá'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _xayDungTabCongThuc() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin công thức
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _xayDungThongTinCongThuc(
                  icon: Icons.access_time,
                  label: 'Thời gian',
                  value: '${widget.congThuc.thoiGianNau} phút',
                ),
                _xayDungThongTinCongThuc(
                  icon: Icons.restaurant,
                  label: 'Khẩu phần',
                  value: '${widget.congThuc.khauPhan} người',
                ),
                _xayDungThongTinCongThuc(
                  icon: Icons.local_fire_department,
                  label: 'Độ khó',
                  value: 'Trung bình',
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 24),

          // Hướng dẫn
          const Text(
            'Hướng Dẫn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          ...widget.congThuc.cachLam.asMap().entries.map((entry) {
            final index = entry.key;
            final buoc = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      buoc,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms + (index * 100).ms);
          }),

          const SizedBox(height: 24),

          // Mẹo nấu ăn
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChuDe.mauPhu,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: ChuDe.mauChinh,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mẹo Nấu Ăn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ChuDe.mauChinh,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Nên ninh xương trong nước lạnh để nước dùng trong hơn.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Nướng hành và gừng trước khi cho vào nồi sẽ giúp nước dùng thơm hơn.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Thịt bò nên thái mỏng và để đông lạnh trước khi thái để dễ thái hơn.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

          const SizedBox(height: 80), // Để tránh bị che bởi nút bắt đầu nấu ăn
        ],
      ),
    );
  }

  Widget _xayDungThongTinCongThuc({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: ChuDe.mauChinh,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ChuDe.mauChuPhu,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _xayDungTabNguyenLieu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Số lượng khẩu phần
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                const Text(
                  'Khẩu Phần:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: ChuDe.mauChuPhu),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {},
                        iconSize: 16,
                      ),
                      Text(
                        '${widget.congThuc.khauPhan}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                        iconSize: 16,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Đặt lại'),
                  style: TextButton.styleFrom(
                    foregroundColor: ChuDe.mauChinh,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 24),

          // Danh sách nguyên liệu
          const Text(
            'Nguyên Liệu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
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
              children: widget.congThuc.nguyenLieu.asMap().entries.map((entry) {
                final nguyenLieu = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                          nguyenLieu,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                        activeColor: ChuDe.mauChinh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 24),

          // Nút thêm vào danh sách mua sắm
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ChuDe.mauXanhLa,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shopping_cart),
            label: const Text(
              'Thêm Vào Danh Sách Mua Sắm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

          const SizedBox(height: 80), // Để tránh bị che bởi nút bắt đầu nấu ăn
        ],
      ),
    );
  }

  Widget _xayDungTabBinhLuan() {
    return Column(
      children: [
        Expanded(
          child: widget.congThuc.danhSachBinhLuan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: ChuDe.mauChuPhu,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có bình luận nào',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ChuDe.mauChuPhu,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy là người đầu tiên bình luận về công thức này',
                        style: TextStyle(
                          fontSize: 14,
                          color: ChuDe.mauChuPhu,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Focus vào ô nhập bình luận
                          FocusScope.of(context).requestFocus(FocusNode());
                          // Delay để đảm bảo keyboard hiển thị
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ChuDe.mauChinh,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('Viết bình luận'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.congThuc.danhSachBinhLuan.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final binhLuan = widget.congThuc.danhSachBinhLuan[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(binhLuan.anhTacGia),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      binhLuan.tacGia,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(binhLuan.thoiGian),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ChuDe.mauChuPhu,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(binhLuan.noiDung),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.thumb_up_outlined,
                                          size: 16),
                                      label: const Text('Thích'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: ChuDe.mauChuPhu,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        textStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.reply, size: 16),
                                      label: const Text('Trả lời'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: ChuDe.mauChuPhu,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        textStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        duration: 500.ms, delay: 300.ms + (index * 100).ms);
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  Provider.of<DangKiDangNhapEmail>(context)
                          .nguoiDungHienTai
                          ?.anhDaiDien ??
                      'assets/images/avatar.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _binhLuanController,
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: ChuDe.mauChinh,
                child: IconButton(
                  onPressed: _guiBinhLuan,
                  icon: const Icon(Icons.send, size: 18),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
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
