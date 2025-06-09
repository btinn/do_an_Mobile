import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManHinhYeuThich extends StatefulWidget {
  const ManHinhYeuThich({super.key});

  @override
  State<ManHinhYeuThich> createState() => _ManHinhYeuThichState();
}

class _ManHinhYeuThichState extends State<ManHinhYeuThich>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final dichVuDuLieu = Provider.of<DichVuDuLieu>(context);
    // final danhSachCongThucYeuThich =
    //     dichVuDuLieu.danhSachCongThuc.where((ct) => ct.daThich).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu Thích'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ChuDe.mauChinh,
          unselectedLabelColor: ChuDe.mauChuPhu,
          indicatorColor: ChuDe.mauChinh,
          tabs: const [
            Tab(text: 'Công Thức'),
            Tab(text: 'Bộ Sưu Tập'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Công Thức
          _xayDungTabCongThuc([]),

          // Tab Bộ Sưu Tập
          _xayDungTabBoSuuTap(),
        ],
      ),
    );
  }

  Widget _xayDungTabCongThuc(List<CongThuc> danhSachCongThuc) {
    if (danhSachCongThuc.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có công thức yêu thích',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy khám phá và lưu các công thức bạn yêu thích',
              style: TextStyle(
                fontSize: 14,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ChuDe.mauChinh,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Khám Phá Ngay'),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: danhSachCongThuc.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(danhSachCongThuc[index].ma),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            // Provider.of<DichVuDuLieu>(context, listen: false).thichCongThuc(danhSachCongThuc[index].ma);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Đã xóa ${danhSachCongThuc[index].tenMon} khỏi danh sách yêu thích'),
                action: SnackBarAction(
                  label: 'Hoàn tác',
                  onPressed: () {
                    // Provider.of<DichVuDuLieu>(context, listen: false).thichCongThuc(danhSachCongThuc[index].ma);
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
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
              child: Container(
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
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16)),
                      child: Image.asset(
                        // Thay Image.network bằng Image.asset
                        danhSachCongThuc[index].hinhAnh,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  // Thêm Flexible để giới hạn kích thước Container
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ChuDe.mauPhu,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      danhSachCongThuc[index].loai,
                                      style: const TextStyle(
                                        color: ChuDe.mauChinh,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: ChuDe.mauChinh,
                                  ),
                                  onPressed: () {
                                    // Provider.of<DichVuDuLieu>(context, listen: false).thichCongThuc(danhSachCongThuc[index].ma);
                                  },
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              danhSachCongThuc[index].tenMon,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage: AssetImage(danhSachCongThuc[
                                          index]
                                      .anhTacGia), // Thay NetworkImage bằng AssetImage
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    danhSachCongThuc[index].tacGia,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ChuDe.mauChuPhu,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: ChuDe.mauChuPhu,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${danhSachCongThuc[index].thoiGianNau} phút',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ChuDe.mauChuPhu,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  danhSachCongThuc[index]
                                      .diemDanhGia
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ChuDe.mauChuPhu,
                                  ),
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
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms + (index * 100).ms);
      },
    );
  }

  Widget _xayDungTabBoSuuTap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.collections_bookmark,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có bộ sưu tập nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChuPhu,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tạo bộ sưu tập để tổ chức các công thức yêu thích của bạn',
            style: TextStyle(
              fontSize: 14,
              color: ChuDe.mauChuPhu,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ChuDe.mauChinh,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tạo Bộ Sưu Tập'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
