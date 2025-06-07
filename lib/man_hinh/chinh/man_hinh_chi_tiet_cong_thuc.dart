import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/binh_luan.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_ho_so_nguoi_dung.dart';

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
  bool _daThich = false;
  bool _daLuu = false;
  final ScrollController _scrollController = ScrollController();
  bool _hienThiAppBar = false;

  final List<BinhLuan> _danhSachBinhLuan = [
    BinhLuan(
      ma: '1',
      noiDung: 'Món này rất ngon, tôi đã làm thử và cả nhà đều thích!',
      thoiGian: DateTime.now().subtract(const Duration(days: 2)),
      tenNguoiDung: 'Nguyễn Văn A',
      anhDaiDien: 'assets/images/avatar1.jpg',
    ),
    BinhLuan(
      ma: '2',
      noiDung: 'Cảm ơn bạn đã chia sẻ công thức tuyệt vời này.',
      thoiGian: DateTime.now().subtract(const Duration(hours: 5)),
      tenNguoiDung: 'Trần Thị B',
      anhDaiDien: 'assets/images/avatar2.jpg',
    ),
    BinhLuan(
      ma: '3',
      noiDung: 'Tôi thấy nên thêm một chút tiêu để món ăn đậm đà hơn.',
      thoiGian: DateTime.now().subtract(const Duration(minutes: 30)),
      tenNguoiDung: 'Lê Văn C',
      anhDaiDien: 'assets/images/avatar3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_hienThiAppBar) {
      setState(() {
        _hienThiAppBar = true;
      });
    } else if (_scrollController.offset <= 200 && _hienThiAppBar) {
      setState(() {
        _hienThiAppBar = false;
      });
    }
  }

  void _toggleThich() {
    setState(() {
      _daThich = !_daThich;
    });
  }

  void _toggleLuu() {
    setState(() {
      _daLuu = !_daLuu;
    });
  }

  void _moHoSoNguoiDung() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhHoSoNguoiDung(
          maNguoiDung: 'user_${widget.congThuc.tacGia.toLowerCase().replaceAll(' ', '_')}',
          tenNguoiDung: widget.congThuc.tacGia,
          anhDaiDien: widget.congThuc.anhTacGia,
        ),
      ),
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
              floating: false,
              pinned: true,
              backgroundColor: _hienThiAppBar ? ChuDe.mauChinh : Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _daLuu ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _toggleLuu,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hình ảnh món ăn
                    widget.congThuc.hinhAnh.startsWith('http')
                        ? Image.network(
                            widget.congThuc.hinhAnh,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.congThuc.hinhAnh,
                            fit: BoxFit.cover,
                          ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Thông tin món ăn
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Loại món
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ChuDe.mauChinh,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.congThuc.loai,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tên món
                          Text(
                            widget.congThuc.tenMon,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Thông tin tác giả
                          GestureDetector(
                            onTap: _moHoSoNguoiDung,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: widget.congThuc.anhTacGia.startsWith('http')
                                      ? NetworkImage(widget.congThuc.anhTacGia)
                                      : AssetImage(widget.congThuc.anhTacGia) as ImageProvider,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.congThuc.tacGia,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                // Đánh giá
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.congThuc.diemDanhGia.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${widget.congThuc.luotDanhGia})',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: _hienThiAppBar ? Colors.white : ChuDe.mauChinh,
                unselectedLabelColor:
                    _hienThiAppBar ? Colors.white70 : ChuDe.mauChuPhu,
                indicatorColor: _hienThiAppBar ? Colors.white : ChuDe.mauChinh,
                tabs: const [
                  Tab(text: 'Công Thức'),
                  Tab(text: 'Nguyên Liệu'),
                  Tab(text: 'Bình Luận'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _xayDungTabCongThuc(),
            _xayDungTabNguyenLieu(),
            _xayDungTabBinhLuan(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleThich,
        backgroundColor: _daThich ? ChuDe.mauChinh : Colors.white,
        child: Icon(
          _daThich ? Icons.favorite : Icons.favorite_border,
          color: _daThich ? Colors.white : ChuDe.mauChinh,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ChuDe.mauChinh,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu),
                const SizedBox(width: 8),
                const Text(
                  'Bắt Đầu Nấu Ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungTabCongThuc() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin cơ bản
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _xayDungThongTinCoBan(
                  Icons.access_time,
                  'Thời gian',
                  '${widget.congThuc.thoiGianNau} phút',
                ),
                _xayDungThongTinCoBan(
                  Icons.people,
                  'Khẩu phần',
                  '${widget.congThuc.khauPhan} người',
                ),
                _xayDungThongTinCoBan(
                  Icons.local_fire_department,
                  'Độ khó',
                  widget.congThuc.doKho,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Hướng dẫn nấu ăn
          const Text(
            'Hướng Dẫn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.congThuc.cacBuoc.length,
            itemBuilder: (context, index) {
              return _xayDungBuocNau(
                index + 1,
                widget.congThuc.cacBuoc[index],
              ).animate().fadeIn(
                    duration: 500.ms,
                    delay: Duration(milliseconds: 300 + (index * 100)),
                  );
            },
          ),

          const SizedBox(height: 24),

          // Mẹo nấu ăn
          const Text(
            'Mẹo Nấu Ăn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChuDe.mauPhu.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ChuDe.mauPhu),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: ChuDe.mauChinh,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lời khuyên từ đầu bếp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ChuDe.mauChinh,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.congThuc.meoNauAn,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 900.ms),

          const SizedBox(height: 80), // Để không bị che bởi FAB
        ],
      ),
    );
  }

  Widget _xayDungThongTinCoBan(IconData icon, String label, String value) {
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

  Widget _xayDungBuocNau(int buoc, String moTa) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                buoc.toString(),
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
              moTa,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungTabNguyenLieu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh sách nguyên liệu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguyên Liệu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.congThuc.nguyenLieu.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return _xayDungNguyenLieu(
                      widget.congThuc.nguyenLieu[index],
                    ).animate().fadeIn(
                          duration: 500.ms,
                          delay: Duration(milliseconds: 200 + (index * 100)),
                        );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Ghi chú
          const Text(
            'Ghi Chú',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn có thể thay thế một số nguyên liệu nếu không có sẵn:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.congThuc.ghiChu,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

          const SizedBox(height: 80), // Để không bị che bởi FAB
        ],
      ),
    );
  }

  Widget _xayDungNguyenLieu(String nguyenLieu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ChuDe.mauPhu,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nguyenLieu,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungTabBinhLuan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Đánh giá tổng quan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      widget.congThuc.diemDanhGia.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: ChuDe.mauChinh,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.congThuc.diemDanhGia.floor()
                              ? Icons.star
                              : index < widget.congThuc.diemDanhGia
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.congThuc.luotDanhGia} đánh giá',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChuDe.mauChuPhu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _xayDungThanhDanhGia(5, 0.7),
                      _xayDungThanhDanhGia(4, 0.2),
                      _xayDungThanhDanhGia(3, 0.05),
                      _xayDungThanhDanhGia(2, 0.03),
                      _xayDungThanhDanhGia(1, 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Form bình luận
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Viết Đánh Giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: const Icon(Icons.star_border),
                      color: Colors.amber,
                      onPressed: () {},
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Chia sẻ trải nghiệm của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChuDe.mauChinh,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Gửi Đánh Giá'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 24),

          // Danh sách bình luận
          const Text(
            'Bình Luận',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _danhSachBinhLuan.length,
            itemBuilder: (context, index) {
              return _xayDungBinhLuan(_danhSachBinhLuan[index])
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: Duration(milliseconds: 500 + (index * 100)),
                  );
            },
          ),

          const SizedBox(height: 80), // Để không bị che bởi FAB
        ],
      ),
    );
  }

  Widget _xayDungThanhDanhGia(int sao, double tiLe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$sao',
            style: const TextStyle(
              fontSize: 12,
              color: ChuDe.mauChuPhu,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: tiLe,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: ChuDe.mauChinh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(tiLe * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: ChuDe.mauChuPhu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungBinhLuan(BinhLuan binhLuan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(binhLuan.anhDaiDien),
              ),
              const SizedBox(width: 8),
              Text(
                binhLuan.tenNguoiDung,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatThoiGian(binhLuan.thoiGian),
                style: const TextStyle(
                  fontSize: 12,
                  color: ChuDe.mauChuPhu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            binhLuan.noiDung,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_outlined),
                iconSize: 16,
                color: ChuDe.mauChuPhu,
                onPressed: () {},
              ),
              const Text(
                '12',
                style: TextStyle(
                  fontSize: 12,
                  color: ChuDe.mauChuPhu,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.thumb_down_outlined),
                iconSize: 16,
                color: ChuDe.mauChuPhu,
                onPressed: () {},
              ),
              const Text(
                '2',
                style: TextStyle(
                  fontSize: 12,
                  color: ChuDe.mauChuPhu,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Trả lời'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatThoiGian(DateTime thoiGian) {
    final now = DateTime.now();
    final difference = now.difference(thoiGian);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
