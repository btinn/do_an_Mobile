import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_tin_nhan.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_tin_nhan.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManHinhHopThu extends StatefulWidget {
  const ManHinhHopThu({super.key});

  @override
  State<ManHinhHopThu> createState() => _ManHinhHopThuState();
}

class _ManHinhHopThuState extends State<ManHinhHopThu> {
  final DichVuTinNhan _dichVuTinNhan = DichVuTinNhan();
  List<CuocTroChuyenTomTat> _danhSachCuocTroChuyenTomTat = [];
  List<Story> _danhSachStories = [];
  bool _dangTai = false;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    
    try {
      // Tải stories
      final stories = await _dichVuTinNhan.layDanhSachStories();
      setState(() {
        _danhSachStories = stories;
      });

      // Tải cuộc trò chuyện
      final dangNhapService = Provider.of<DangKiDangNhapEmail>(context, listen: false);
      final nguoiDung = dangNhapService.nguoiDungHienTai;
      
      if (nguoiDung != null) {
        final danhSach = await _dichVuTinNhan.layDanhSachCuocTroChuyenTomTat(nguoiDung.ma);
        setState(() {
          _danhSachCuocTroChuyenTomTat = danhSach;
        });

        // Lắng nghe cập nhật real-time
        _dichVuTinNhan.langNgheCuocTroChuyenTomTat(nguoiDung.ma).listen((danhSach) {
          if (mounted) {
            setState(() {
              _danhSachCuocTroChuyenTomTat = danhSach;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu: $e');
    } finally {
      setState(() => _dangTai = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.people_outline, color: ChuDe.mauChu),
            const SizedBox(width: 8),
            const Text(
              'Hộp thư',
              style: TextStyle(
                color: ChuDe.mauChu,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: ChuDe.mauChu),
            onPressed: () {
              // Tìm kiếm
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _taiDuLieu,
        child: CustomScrollView(
          slivers: [
            // Stories Section
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _danhSachStories.length,
                  itemBuilder: (context, index) {
                    final story = _danhSachStories[index];
                    return _xayDungStoryItem(story, index == 0);
                  },
                ),
              ),
            ),

            // Divider
            const SliverToBoxAdapter(
              child: Divider(height: 1, thickness: 0.5),
            ),

            // Chat List
            if (_dangTai)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: ChuDe.mauChinh),
                  ),
                ),
              )
            else if (_danhSachCuocTroChuyenTomTat.isEmpty)
              SliverFillRemaining(
                child: _xayDungManHinhTrong(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return _xayDungItemHeThong();
                    }
                    final cuocTroChuyenIndex = index - 1;
                    if (cuocTroChuyenIndex < _danhSachCuocTroChuyenTomTat.length) {
                      final cuocTroChuyenTomTat = _danhSachCuocTroChuyenTomTat[cuocTroChuyenIndex];
                      return _xayDungItemCuocTroChuyenTomTat(cuocTroChuyenTomTat);
                    }
                    return const SizedBox.shrink();
                  },
                  childCount: _danhSachCuocTroChuyenTomTat.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungStoryItem(Story story, bool isMyStory) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Xem story
        },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.daXem
                        ? null
                        : const LinearGradient(
                            colors: [Colors.purple, Colors.pink, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: story.daXem
                        ? Border.all(color: Colors.grey.shade300, width: 2)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: story.anhNguoiDung.startsWith('http')
                          ? NetworkImage(story.anhNguoiDung)
                          : AssetImage(story.anhNguoiDung) as ImageProvider,
                    ),
                  ),
                ),
                if (isMyStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ChuDe.mauChinh,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                story.tenNguoiDung,
                style: const TextStyle(
                  fontSize: 12,
                  color: ChuDe.mauChu,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (100 * _danhSachStories.indexOf(story)).ms);
  }

  Widget _xayDungItemHeThong() {
    return Column(
      children: [
        _xayDungItemChat(
          icon: Icons.people,
          iconColor: Colors.blue,
          title: 'Những Follower mới',
          subtitle: 'Ngọc Sang đã bắt đầu follow b...',
          time: '',
          hasUnread: false,
          onTap: () {},
        ),
        _xayDungItemChat(
          icon: Icons.notifications,
          iconColor: Colors.pink,
          title: 'Hoạt động',
          subtitle: 'thyynhi2004 đã xem hồ sơ của...',
          time: '',
          hasUnread: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _xayDungItemChat({
    IconData? icon,
    Color? iconColor,
    String? avatarUrl,
    required String title,
    required String subtitle,
    required String time,
    required bool hasUnread,
    int unreadCount = 0,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null
          ? CircleAvatar(
              backgroundColor: iconColor?.withOpacity(0.1),
              child: Icon(icon, color: iconColor, size: 24),
            )
          : CircleAvatar(
              backgroundImage: avatarUrl != null
                  ? (avatarUrl.startsWith('http')
                      ? NetworkImage(avatarUrl)
                      : AssetImage(avatarUrl) as ImageProvider)
                  : const AssetImage('assets/images/avatar_default.jpg'),
            ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: hasUnread ? ChuDe.mauChu : Colors.grey.shade600,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time.isNotEmpty)
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          if (hasUnread && unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: ChuDe.mauChinh,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else if (hasUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: ChuDe.mauChinh,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _xayDungItemCuocTroChuyenTomTat(CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    return _xayDungItemChat(
      avatarUrl: cuocTroChuyenTomTat.anhNguoiKhac,
      title: cuocTroChuyenTomTat.tenNguoiKhac,
      subtitle: _layNoiDungTinNhanHienThi(cuocTroChuyenTomTat),
      time: cuocTroChuyenTomTat.thoiGianHienThi,
      hasUnread: cuocTroChuyenTomTat.soTinNhanChuaDoc > 0,
      unreadCount: cuocTroChuyenTomTat.soTinNhanChuaDoc,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManHinhChiTietTinNhan(
              maNguoiKhac: cuocTroChuyenTomTat.maNguoiKhac,
              tenNguoiKhac: cuocTroChuyenTomTat.tenNguoiKhac,
              anhNguoiKhac: cuocTroChuyenTomTat.anhNguoiKhac,
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  String _layNoiDungTinNhanHienThi(CuocTroChuyenTomTat cuocTroChuyenTomTat) {
    switch (cuocTroChuyenTomTat.loaiTinNhanCuoi) {
      case 'image':
        return '📷 Hình ảnh';
      case 'recipe':
        return '🍳 Chia sẻ công thức';
      case 'sticker':
        return '😊 Nhãn dán';
      default:
        return cuocTroChuyenTomTat.tinNhanCuoi;
    }
  }

  Widget _xayDungManHinhTrong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ChuDe.mauChuPhu,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Bắt đầu trò chuyện với những người yêu ẩm thực khác',
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
