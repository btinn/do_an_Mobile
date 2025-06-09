import 'package:do_an/dich_vu/dich_vu_luu_cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/man_hinh/chinh/man_hinh_chi_tiet_cong_thuc.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/tien_ich/the_cong_thuc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class ManHinhDaLuu extends StatefulWidget {
  const ManHinhDaLuu({super.key});

  @override
  State<ManHinhDaLuu> createState() => _ManHinhDaLuuState();
}

class _ManHinhDaLuuState extends State<ManHinhDaLuu> {
  final DichVuLuuCongThuc _dichVuLuuCongThuc = DichVuLuuCongThuc();
  List<CongThuc> _danhSachCongThucDaLuu = [];
  bool _dangTai = true;
  bool _daCoLoi = false;

  @override
  void initState() {
    super.initState();
    _taiDanhSachCongThucDaLuu();
  }

  Future<void> _taiDanhSachCongThucDaLuu() async {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
            .nguoiDungHienTai
            ?.ma ??
        '';
    if (uid.isEmpty) {
      setState(() {
        _dangTai = false;
        _daCoLoi = true;
      });
      return;
    }

    try {
      final danhSach = await _dichVuLuuCongThuc.layDanhSachCongThucDaLuuChiTiet(uid);
      if (mounted) {
        setState(() {
          _danhSachCongThucDaLuu = danhSach;
          _dangTai = false;
          _daCoLoi = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách công thức đã lưu: $e');
      if (mounted) {
        setState(() {
          _dangTai = false;
          _daCoLoi = true;
        });
      }
    }
  }

  Future<void> _huyLuuCongThuc(String maCongThuc) async {
    final uid = Provider.of<DangKiDangNhapEmail>(context, listen: false)
            .nguoiDungHienTai
            ?.ma ??
        '';
    if (uid.isEmpty) return;

    try {
      await _dichVuLuuCongThuc.huyLuuCongThuc(uid, maCongThuc);
      if (mounted) {
        setState(() {
          _danhSachCongThucDaLuu.removeWhere((ct) => ct.ma == maCongThuc);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã bỏ lưu công thức'),
            backgroundColor: ChuDe.mauChuPhu,
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi hủy lưu công thức: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi bỏ lưu công thức'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công Thức Đã Lưu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _dangTai = true;
              });
              _taiDanhSachCongThucDaLuu();
            },
          ),
        ],
      ),
      body: _dangTai
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _daCoLoi
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Có lỗi xảy ra khi tải danh sách công thức đã lưu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _dangTai = true;
                          });
                          _taiDanhSachCongThucDaLuu();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _danhSachCongThucDaLuu.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bạn chưa lưu công thức nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hãy lưu các công thức yêu thích để xem sau',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _taiDanhSachCongThucDaLuu,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _danhSachCongThucDaLuu.length,
                        itemBuilder: (context, index) {
                          final congThuc = _danhSachCongThucDaLuu[index];
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManHinhChiTietCongThuc(
                                    congThuc: congThuc,
                                  ),
                                ),
                              );
                              
                              // Nếu có thay đổi, tải lại danh sách
                              if (result == true) {
                                _taiDanhSachCongThucDaLuu();
                              }
                            },
                            onLongPress: () {
                              _hienThiMenuXoa(congThuc.ma, congThuc.tenMon);
                            },
                            child: TheCongThuc(
                              congThuc: congThuc,
                              chieuCao: 240,
                            ),
                          ).animate().fadeIn(
                                duration: 500.ms,
                                delay: (index * 100).ms,
                              );
                        },
                      ),
                    ),
    );
  }

  void _hienThiMenuXoa(String maCongThuc, String tenMon) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tùy chọn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.bookmark_remove, color: Colors.red),
              title: const Text('Bỏ lưu công thức'),
              subtitle: Text('Bỏ lưu "$tenMon"'),
              onTap: () {
                Navigator.pop(context);
                _huyLuuCongThuc(maCongThuc);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Hủy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
