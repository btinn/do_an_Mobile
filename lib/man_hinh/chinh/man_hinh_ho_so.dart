import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
// import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/nguoi_dung.dart';
// import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:provider/provider.dart';
// import 'package:do_an/dich_vu/dich_vu_du_lieu.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'man_hinh_cai_dat.dart';
import 'man_hinh_chinh_sua_ho_so.dart';

class ManHinhHoSo extends StatefulWidget {
  const ManHinhHoSo({super.key});

  @override
  State<ManHinhHoSo> createState() => _ManHinhHoSoState();
}

class _ManHinhHoSoState extends State<ManHinhHoSo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moManHinhCaiDat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManHinhCaiDat(),
      ),
    );
  }

  void _moManHinhChinhSuaHoSo(BuildContext context, NguoiDung nguoiDung) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManHinhChinhSuaHoSo(nguoiDung: nguoiDung),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;
    print(
        'Người dùng hiện tại sau khi đăng nhập: ${dangNhapService.nguoiDungHienTai?.hoTen}');
    if (nguoiDung == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight:
                  100, // Tăng expandedHeight để có đủ không gian cho avatar
              pinned: true,
              backgroundColor: ChuDe.mauChinh,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ChuDe.mauChinh,
                            ChuDe.mauChinh.withAlpha(200),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50, // Tăng chiều cao của phần nền trắng cong
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => _moManHinhCaiDat(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _xayDungThongTinNguoiDung(nguoiDung),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: ChuDe.mauChinh,
                  unselectedLabelColor: ChuDe.mauChuPhu,
                  indicatorColor: ChuDe.mauChinh,
                  tabs: const [
                    Tab(text: 'Công Thức'),
                    Tab(text: 'Đã Lưu'),
                    Tab(text: 'Hoạt Động'),
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
            _xayDungKhongCoDuLieu(
              'Bạn chưa có công thức nào',
              'Hãy bắt đầu chia sẻ công thức nấu ăn của bạn',
              Icons.restaurant_menu,
              'Tạo Công Thức',
              () {},
            ),
            _xayDungKhongCoDuLieu(
              'Bạn chưa lưu công thức nào',
              'Hãy khám phá và lưu các công thức yêu thích',
              Icons.bookmark_border,
              'Khám Phá Ngay',
              () {},
            ),
            _xayDungTabHoatDong(),
          ],
        ),
      ),
    );
  }

  Widget _xayDungThongTinNguoiDung(NguoiDung nguoiDung) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Ảnh đại diện
          Transform.translate(
            offset: const Offset(
                0, -5), // Giảm offset để avatar không bị đẩy quá cao
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 47,
                backgroundImage: nguoiDung.anhDaiDien.startsWith('http')
                    ? NetworkImage(nguoiDung.anhDaiDien)
                    : AssetImage(nguoiDung.anhDaiDien) as ImageProvider,
              ),
            ),
          ),

          // Thông tin người dùng
          Transform.translate(
            offset: const Offset(0,
                -1), // Điều chỉnh offset để phù hợp với vị trí mới của avatar
            child: Column(
              children: [
                Text(
                  nguoiDung.hoTen,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nguoiDung.moTa,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChuDe.mauChuPhu,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Số liệu thống kê
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _xayDungThongKe(
                      nguoiDung.congThucIds.length.toString(),
                      'Công Thức',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _xayDungThongKe(
                      nguoiDung.nguoiTheoDoiIds.length.toString(),
                      'Người Theo Dõi',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _xayDungThongKe(
                      nguoiDung.dangTheoDoiIds.length.toString(),
                      'Đang Theo Dõi',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nút chỉnh sửa hồ sơ
                ElevatedButton(
                  onPressed: () => _moManHinhChinhSuaHoSo(context, nguoiDung),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ChuDe.mauChinh,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: ChuDe.mauChinh),
                    ),
                  ),
                  child: const Text('Chỉnh Sửa Hồ Sơ'),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _xayDungThongKe(String soLuong, String nhan) {
    return Column(
      children: [
        Text(
          soLuong,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          nhan,
          style: const TextStyle(
            fontSize: 12,
            color: ChuDe.mauChuPhu,
          ),
        ),
      ],
    );
  }

  // Widget _xayDungTabCongThuc(List<CongThuc> danhSachCongThuc) {
  //   return danhSachCongThuc.isEmpty
  //       ? _xayDungKhongCoDuLieu(
  //           'Bạn chưa có công thức nào',
  //           'Hãy bắt đầu chia sẻ công thức nấu ăn của bạn',
  //           Icons.restaurant_menu,
  //           'Tạo Công Thức',
  //           () {},
  //         )
  //       : Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: GridView.builder(
  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: 2,
  //               mainAxisSpacing: 16,
  //               crossAxisSpacing: 16,
  //               childAspectRatio: 0.75,
  //             ),
  //             itemCount: danhSachCongThuc.length,
  //             itemBuilder: (context, index) {
  //               return GestureDetector(
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => ManHinhChiTietCongThuc(
  //                         congThuc: danhSachCongThuc[index],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(16),
  //                       child: Image.asset(
  //                         danhSachCongThuc[index].hinhAnh,
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Text(
  //                       danhSachCongThuc[index].tenMon,
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Row(
  //                       children: [
  //                         const Icon(
  //                           Icons.favorite,
  //                           size: 16,
  //                           color: ChuDe.mauChinh,
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           '${danhSachCongThuc[index].luotThich}',
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             color: ChuDe.mauChuPhu,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         const Icon(
  //                           Icons.visibility,
  //                           size: 16,
  //                           color: ChuDe.mauChuPhu,
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           '${danhSachCongThuc[index].luotXem}',
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             color: ChuDe.mauChuPhu,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               )
  //                   .animate()
  //                   .fadeIn(duration: 500.ms, delay: 200.ms + (index * 100).ms);
  //             },
  //           ),
  //         );
  // }

  // Widget _xayDungTabDaLuu(List<CongThuc> danhSachCongThuc) {
  //   return danhSachCongThuc.isEmpty
  //       ? _xayDungKhongCoDuLieu(
  //           'Bạn chưa lưu công thức nào',
  //           'Hãy khám phá và lưu các công thức yêu thích',
  //           Icons.search,
  //           'Khám Phá Ngay',
  //           () {},
  //         )
  //       : Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: ListView.builder(
  //             itemCount: danhSachCongThuc.length,
  //             itemBuilder: (context, index) {
  //               return Padding(
  //                 padding: const EdgeInsets.only(bottom: 16),
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => ManHinhChiTietCongThuc(
  //                           congThuc: danhSachCongThuc[index],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(16),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withAlpha(10),
  //                           blurRadius: 10,
  //                           offset: const Offset(0, 5),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         ClipRRect(
  //                           borderRadius: const BorderRadius.horizontal(
  //                               left: Radius.circular(16)),
  //                           child: Image.asset(
  //                             danhSachCongThuc[index].hinhAnh,
  //                             width: 120,
  //                             height: 120,
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(12),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Container(
  //                                       padding: const EdgeInsets.symmetric(
  //                                           horizontal: 8, vertical: 4),
  //                                       decoration: BoxDecoration(
  //                                         color: ChuDe.mauPhu,
  //                                         borderRadius:
  //                                             BorderRadius.circular(12),
  //                                       ),
  //                                       child: Text(
  //                                         danhSachCongThuc[index].loai,
  //                                         style: const TextStyle(
  //                                           color: ChuDe.mauChinh,
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     const Spacer(),
  //                                     Consumer<DichVuDuLieu>(
  //                                       builder:
  //                                           (context, dichVuDuLieu, child) {
  //                                         return IconButton(
  //                                           icon: const Icon(
  //                                             Icons.favorite,
  //                                             color: ChuDe.mauChinh,
  //                                           ),
  //                                           onPressed: () {
  //                                             dichVuDuLieu.thichCongThuc(
  //                                                 danhSachCongThuc[index].ma);
  //                                           },
  //                                           iconSize: 20,
  //                                           padding: EdgeInsets.zero,
  //                                           constraints: const BoxConstraints(),
  //                                         );
  //                                       },
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 8),
  //                                 Text(
  //                                   danhSachCongThuc[index].tenMon,
  //                                   style: const TextStyle(
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                   maxLines: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                                 const SizedBox(height: 4),
  //                                 Row(
  //                                   children: [
  //                                     CircleAvatar(
  //                                       radius: 10,
  //                                       backgroundImage: AssetImage(
  //                                           danhSachCongThuc[index].anhTacGia),
  //                                     ),
  //                                     const SizedBox(width: 4),
  //                                     Expanded(
  //                                       child: Text(
  //                                         danhSachCongThuc[index].tacGia,
  //                                         style: const TextStyle(
  //                                           fontSize: 12,
  //                                           color: ChuDe.mauChuPhu,
  //                                         ),
  //                                         maxLines: 1,
  //                                         overflow: TextOverflow.ellipsis,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 8),
  //                                 Row(
  //                                   children: [
  //                                     const Icon(
  //                                       Icons.access_time,
  //                                       size: 14,
  //                                       color: ChuDe.mauChuPhu,
  //                                     ),
  //                                     const SizedBox(width: 4),
  //                                     Text(
  //                                       '${danhSachCongThuc[index].thoiGianNau} phút',
  //                                       style: const TextStyle(
  //                                         fontSize: 12,
  //                                         color: ChuDe.mauChuPhu,
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 12),
  //                                     const Icon(
  //                                       Icons.star,
  //                                       size: 14,
  //                                       color: Colors.amber,
  //                                     ),
  //                                     const SizedBox(width: 4),
  //                                     Text(
  //                                       danhSachCongThuc[index]
  //                                           .diemDanhGia
  //                                           .toStringAsFixed(1),
  //                                       style: const TextStyle(
  //                                         fontSize: 12,
  //                                         color: ChuDe.mauChuPhu,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               )
  //                   .animate()
  //                   .fadeIn(duration: 500.ms, delay: 200.ms + (index * 100).ms);
  //             },
  //           ),
  //         );
  // }

  Widget _xayDungTabHoatDong() {
    return _xayDungKhongCoDuLieu(
      'Chưa có hoạt động nào',
      'Các hoạt động của bạn sẽ hiển thị ở đây',
      Icons.history,
      'Khám Phá Ngay',
      () {},
    );
  }

  Widget _xayDungKhongCoDuLieu(
    String tieuDe,
    String moTa,
    IconData icon,
    String nhanNut,
    VoidCallback onPressed,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              tieuDe,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              moTa,
              style: const TextStyle(
                fontSize: 14,
                color: ChuDe.mauChuPhu,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ChuDe.mauChinh,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(nhanNut),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
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
