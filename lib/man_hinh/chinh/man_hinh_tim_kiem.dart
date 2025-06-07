import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/tien_ich/the_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManHinhTimKiem extends StatefulWidget {
  const ManHinhTimKiem({super.key});

  @override
  State<ManHinhTimKiem> createState() => _ManHinhTimKiemState();
}

class _ManHinhTimKiemState extends State<ManHinhTimKiem>
    with SingleTickerProviderStateMixin {
  final TextEditingController _timKiemController = TextEditingController();
  final List<String> _lichSuTimKiem = [
    'Phở bò',
    'Bánh xèo',
    'Món chay',
    'Cơm chiên',
  ];
  final List<String> _goiYTimKiem = [
    'Món ăn nhanh',
    'Món tráng miệng',
    'Món ăn ít calo',
    'Món ăn cho trẻ em',
    'Món ăn ngày Tết',
    'Món ăn chay',
  ];

  List<CongThuc> _ketQuaTimKiem = [];
  bool _dangTimKiem = false;
  bool _daTimKiem = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _timKiemController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _xuLyTimKiem(String tuKhoa) async {
    if (tuKhoa.isEmpty) return;

    setState(() {
      _dangTimKiem = true;
    });

    final dichVu = DichVuCongThuc();
    final tatCaCongThuc = await dichVu.layDanhSachCongThuc();

    final ketQua = tatCaCongThuc.where((congThuc) {
      final lowerKhoa = tuKhoa.toLowerCase();
      return congThuc.tenMon.toLowerCase().contains(lowerKhoa) ||
          congThuc.nguyenLieu
              .any((nl) => nl.toLowerCase().contains(lowerKhoa)) ||
          congThuc.tacGia.toLowerCase().contains(lowerKhoa) ||
          congThuc.loai.toLowerCase().contains(lowerKhoa);
    }).toList();

    if (mounted) {
      setState(() {
        _ketQuaTimKiem = ketQua;
        _dangTimKiem = false;
        _daTimKiem = true;

        if (!_lichSuTimKiem.contains(tuKhoa)) {
          _lichSuTimKiem.insert(0, tuKhoa);
          if (_lichSuTimKiem.length > 5) {
            _lichSuTimKiem.removeLast();
          }
        }
      });
    }
  }

  void _xoaLichSuTimKiem(int index) {
    setState(() {
      _lichSuTimKiem.removeAt(index);
    });
  }

  void _xoaTatCaLichSuTimKiem() {
    setState(() {
      _lichSuTimKiem.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _timKiemController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm công thức, nguyên liệu...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: ChuDe.mauChuPhu),
            prefixIcon: const Icon(Icons.search, color: ChuDe.mauChuPhu),
            suffixIcon: _timKiemController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: ChuDe.mauChuPhu),
                    onPressed: () {
                      setState(() {
                        _timKiemController.clear();
                        _daTimKiem = false;
                      });
                    },
                  )
                : null,
          ),
          onSubmitted: _xuLyTimKiem,
          onChanged: (value) {
            setState(() {});
          },
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 16),
        ),
        bottom: _daTimKiem
            ? TabBar(
                controller: _tabController,
                labelColor: ChuDe.mauChinh,
                unselectedLabelColor: ChuDe.mauChuPhu,
                indicatorColor: ChuDe.mauChinh,
                tabs: const [
                  Tab(text: 'Tất Cả'),
                  Tab(text: 'Công Thức'),
                  Tab(text: 'Tác Giả'),
                ],
              )
            : null,
      ),
      body: _dangTimKiem
          ? const Center(
              child: CircularProgressIndicator(
                color: ChuDe.mauChinh,
              ),
            )
          : _daTimKiem
              ? _xayDungKetQuaTimKiem()
              : _xayDungManHinhTimKiem(),
    );
  }

  Widget _xayDungManHinhTimKiem() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lịch sử tìm kiếm
          if (_lichSuTimKiem.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch Sử Tìm Kiếm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _xoaTatCaLichSuTimKiem,
                  child: const Text('Xóa Tất Cả'),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _lichSuTimKiem.asMap().entries.map((entry) {
                final index = entry.key;
                final tuKhoa = entry.value;
                return InputChip(
                  label: Text(tuKhoa),
                  onPressed: () {
                    _timKiemController.text = tuKhoa;
                    _xuLyTimKiem(tuKhoa);
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _xoaLichSuTimKiem(index),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: const TextStyle(color: ChuDe.mauChu),
                );
              }).toList(),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 24),
          ],

          // Gợi ý tìm kiếm
          const Text(
            'Gợi Ý Cho Bạn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goiYTimKiem.map((goiY) {
              return ActionChip(
                label: Text(goiY),
                onPressed: () {
                  _timKiemController.text = goiY;
                  _xuLyTimKiem(goiY);
                },
                backgroundColor: ChuDe.mauPhu,
                labelStyle: const TextStyle(color: ChuDe.mauChinh),
              );
            }).toList(),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
          const SizedBox(height: 24),

          // Khám phá theo danh mục
          const Text(
            'Khám Phá Theo Danh Mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _xayDungDanhMuc('Món Bắc', 'assets/images/mienbac.jpg'),
              _xayDungDanhMuc('Món Trung', 'assets/images/miennam.jpg'),
              _xayDungDanhMuc('Món Nam', 'assets/images/mientrung.jpg'),
              _xayDungDanhMuc('Món Chay', 'assets/images/monchay.jpg'),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _xayDungDanhMuc(String tenDanhMuc, String hinhAnh) {
    return GestureDetector(
      onTap: () {
        _timKiemController.text = tenDanhMuc;
        _xuLyTimKiem(tenDanhMuc);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(hinhAnh), // Thay NetworkImage bằng AssetImage
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(100),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            tenDanhMuc,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _xayDungKetQuaTimKiem() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab Tất Cả
        _ketQuaTimKiem.isEmpty
            ? _xayDungKhongCoKetQua()
            : _xayDungDanhSachKetQua(_ketQuaTimKiem),

        // Tab Công Thức
        _ketQuaTimKiem.isEmpty
            ? _xayDungKhongCoKetQua()
            : _xayDungDanhSachKetQua(_ketQuaTimKiem),

        // Tab Tác Giả
        _xayDungKhongCoKetQua(),
      ],
    );
  }

  Widget _xayDungDanhSachKetQua(List<CongThuc> danhSachCongThuc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm thấy ${danhSachCongThuc.length} kết quả cho "${_timKiemController.text}"',
            style: const TextStyle(
              fontSize: 14,
              color: ChuDe.mauChuPhu,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: danhSachCongThuc.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManHinhChiTietCongThuc(
                          congThuc: danhSachCongThuc[index],
                        ),
                      ),
                    );
                  },
                  child: TheCongThuc(
                    congThuc: danhSachCongThuc[index],
                    chieuCao: index % 2 == 0 ? 280 : 240,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms + (index * 100).ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungKhongCoKetQua() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: ChuDe.mauChuPhu,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả cho "${_timKiemController.text}"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChuPhu,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thử tìm kiếm với từ khóa khác',
            style: TextStyle(
              fontSize: 14,
              color: ChuDe.mauChuPhu,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
