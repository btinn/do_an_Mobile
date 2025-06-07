import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/man_hinh/xac_thuc/man_hinh_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/mo_hinh/cai_dat.dart';
import 'package:provider/provider.dart';
import 'package:do_an/dich_vu/dich_vu_cai_dat.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManHinhCaiDat extends StatefulWidget {
  const ManHinhCaiDat({super.key});

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  @override
  Widget build(BuildContext context) {
    final dichVuDuLieu = Provider.of<DichVuCaiDat>(context);
    final caiDat = dichVuDuLieu.caiDat;

    final dangNhapService = Provider.of<DangKiDangNhapEmail>(context);
    final nguoiDung = dangNhapService.nguoiDungHienTai;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt'),
      ),
      body: ListView(
        children: [
          // Phần tài khoản
          _xayDungTieuDePhan('Tài Khoản'),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông Tin Tài Khoản'),
            subtitle: Text(nguoiDung?.email ?? 'Chưa đăng nhập'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Mở màn hình thông tin tài khoản
            },
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Bảo Mật & Quyền Riêng Tư'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Mở màn hình bảo mật
            },
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Chuyển Tài Khoản'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _hienThiDialogChuyenTaiKhoan(context);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const Divider(),

          // Phần giao diện
          _xayDungTieuDePhan('Giao Diện'),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn Ngữ'),
            subtitle: Text(
                caiDat.ngonNgu == NgonNgu.tiengViet ? 'Tiếng Việt' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _hienThiDialogChonNgonNgu(context, caiDat);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          SwitchListTile(
            secondary: Icon(
              caiDat.chuDeMau == ChuDeMau.toi
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: const Text('Chế Độ Tối'),
            subtitle:
                Text(caiDat.chuDeMau == ChuDeMau.toi ? 'Đang bật' : 'Đang tắt'),
            value: caiDat.chuDeMau == ChuDeMau.toi,
            onChanged: (value) {
              final caiDatMoi = caiDat.copyWith(
                chuDeMau: value ? ChuDeMau.toi : ChuDeMau.sang,
              );
              dichVuDuLieu.capNhatCaiDat(caiDatMoi);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

          const Divider(),

          // Phần thông báo
          _xayDungTieuDePhan('Thông Báo & Nội Dung'),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Thông Báo'),
            subtitle: Text(caiDat.thongBao ? 'Đang bật' : 'Đang tắt'),
            value: caiDat.thongBao,
            onChanged: (value) {
              final caiDatMoi = caiDat.copyWith(
                thongBao: value,
              );
              dichVuDuLieu.capNhatCaiDat(caiDatMoi);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

          SwitchListTile(
            secondary: const Icon(Icons.play_circle),
            title: const Text('Tự Động Phát Video'),
            subtitle: Text(caiDat.tuDongPhatVideo ? 'Đang bật' : 'Đang tắt'),
            value: caiDat.tuDongPhatVideo,
            onChanged: (value) {
              final caiDatMoi = caiDat.copyWith(
                tuDongPhatVideo: value,
              );
              dichVuDuLieu.capNhatCaiDat(caiDatMoi);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

          const Divider(),

          // Phần dữ liệu
          _xayDungTieuDePhan('Dữ Liệu & Lưu Trữ'),

          SwitchListTile(
            secondary: const Icon(Icons.offline_bolt),
            title: const Text('Lưu Dữ Liệu Offline'),
            subtitle: Text(caiDat.luuDuLieuOffline ? 'Đang bật' : 'Đang tắt'),
            value: caiDat.luuDuLieuOffline,
            onChanged: (value) {
              final caiDatMoi = caiDat.copyWith(
                luuDuLieuOffline: value,
              );
              dichVuDuLieu.capNhatCaiDat(caiDatMoi);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Xóa Bộ Nhớ Cache'),
            subtitle: const Text('0.0 MB'),
            onTap: () {
              _hienThiDialogXacNhanXoaCache(context);
            },
          ).animate().fadeIn(duration: 500.ms, delay: 900.ms),

          const Divider(),

          // Phần thông tin ứng dụng
          _xayDungTieuDePhan('Thông Tin Ứng Dụng'),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Phiên Bản'),
            subtitle: const Text('1.0.0'),
          ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Điều Khoản Sử Dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Mở màn hình điều khoản sử dụng
            },
          ).animate().fadeIn(duration: 500.ms, delay: 1100.ms),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Chính Sách Bảo Mật'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Mở màn hình chính sách bảo mật
            },
          ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

          const SizedBox(height: 24),

          // Nút đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final confirmed = await _hienThiDialogXacNhanDangXuat(context);
                if (confirmed == true && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManHinhDangNhap()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đăng Xuất'),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 1300.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _xayDungTieuDePhan(String tieuDe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        tieuDe,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ChuDe.mauChinh,
        ),
      ),
    );
  }

  void _hienThiDialogChonNgonNgu(BuildContext context, CaiDat caiDat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn Ngôn Ngữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<NgonNgu>(
                title: const Text('Tiếng Việt'),
                value: NgonNgu.tiengViet,
                groupValue: caiDat.ngonNgu,
                onChanged: (value) {
                  final dichVuDuLieu =
                      Provider.of<DichVuCaiDat>(context, listen: false);
                  final caiDatMoi = caiDat.copyWith(
                    ngonNgu: value,
                  );
                  dichVuDuLieu.capNhatCaiDat(caiDatMoi);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<NgonNgu>(
                title: const Text('English'),
                value: NgonNgu.tiengAnh,
                groupValue: caiDat.ngonNgu,
                onChanged: (value) {
                  final dichVuDuLieu =
                      Provider.of<DichVuCaiDat>(context, listen: false);
                  final caiDatMoi = caiDat.copyWith(
                    ngonNgu: value,
                  );
                  dichVuDuLieu.capNhatCaiDat(caiDatMoi);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _hienThiDialogChuyenTaiKhoan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chuyển Tài Khoản'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                ),
                title: const Text('Nguyễn Văn Minh'),
                subtitle: const Text('nguyenvanminh@gmail.com'),
                selected: true,
                selectedTileColor: Colors.grey.shade200,
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user1.jpg'),
                ),
                title: const Text('Nguyễn Thị Lan'),
                subtitle: const Text('nguyenthilan@gmail.com'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Mở màn hình đăng nhập
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm Tài Khoản'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChuDe.mauChinh,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _hienThiDialogXacNhanXoaCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa Bộ Nhớ Cache'),
          content: const Text(
              'Bạn có chắc chắn muốn xóa bộ nhớ cache của ứng dụng không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa bộ nhớ cache'),
                    backgroundColor: ChuDe.mauXanhLa,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _hienThiDialogXacNhanDangXuat(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng Xuất'),
          content: const Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Không xác nhận
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<DangKiDangNhapEmail>().signOut();

                if (context.mounted) {
                  Navigator.pop(context, true); // Xác nhận
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng Xuất'),
            ),
          ],
        );
      },
    );
  }
}
