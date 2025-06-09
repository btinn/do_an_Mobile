import 'package:do_an/dich_vu/dich_vu_tym.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class TheCongThuc extends StatelessWidget {
  final CongThuc congThuc;
  final double? chieuRong;
  final double? chieuCao;
  final bool ngang;

  const TheCongThuc({
    super.key,
    required this.congThuc,
    this.chieuRong,
    this.chieuCao,
    this.ngang = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ngang) {
      return _xayDungTheNgang(context);
    } else {
      return _xayDungTheDoc(context);
    }
  }

  Widget _xayDungTheDoc(BuildContext context) {
    return Container(
      width: chieuRong,
      height: chieuCao,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh công thức
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'recipe_image_${congThuc.ma}',
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: _xayDungHinhAnh(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<DichVuTym>(
                    builder: (context, dichVuTym, child) {
                      final uid = Provider.of<DangKiDangNhapEmail>(context,
                              listen: false)
                          .nguoiDungHienTai
                          ?.ma;

                      // Tải trạng thái tym khi widget được build lần đầu
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (uid != null) {
                          dichVuTym.taiTrangThaiTym(congThuc.ma, uid);
                        }
                      });

                      final daTym = dichVuTym.daTym(congThuc.ma);

                      return GestureDetector(
                        onTap: () async {
                          if (uid != null) {
                            final daTymTruocDo = dichVuTym.daTym(congThuc.ma);

                            // Phản hồi ngay lập tức
                            await dichVuTym.toggleTym(congThuc.ma, uid);

                            // Tạo hiệu ứng rung nhẹ
                            HapticFeedback.lightImpact();

                            // Nếu là lần đầu tym (tức là trước đó chưa tym) VÀ người tym khác người tạo
                            if (!daTymTruocDo && uid != congThuc.uid) {
                              final thongBaoService = DichVuThongBao();
                              final tenNguoiGui =
                                  Provider.of<DangKiDangNhapEmail>(context,
                                              listen: false)
                                          .nguoiDungHienTai
                                          ?.hoTen ??
                                      'Người dùng';

                              await thongBaoService.taoThongBaoThich(
                                maNguoiNhan: congThuc.uid,
                                maNguoiGui: uid,
                                tenNguoiGui: tenNguoiGui,
                                maCongThuc: congThuc.ma,
                                tenCongThuc: congThuc.tenMon,
                              );
                            }
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              daTym ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(daTym),
                              color: daTym ? ChuDe.mauChinh : Colors.grey,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ChuDe.mauChinh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      congThuc.loai,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề công thức
                Text(
                  congThuc.tenMon,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Thông tin công thức
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: ChuDe.mauChuPhu,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${congThuc.thoiGianNau} phút',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChuDe.mauChuPhu,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      congThuc.diemDanhGia.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChuDe.mauChuPhu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tác giả
                Row(
                  children: [
                    _xayDungAvatar(10),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        congThuc.tacGia,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungTheNgang(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hình ảnh công thức
          Stack(
            children: [
              Hero(
                tag: 'recipe_image_${congThuc.ma}',
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: _xayDungHinhAnh(width: 120, height: 120),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ChuDe.mauChinh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    congThuc.loai,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề công thức
                  Text(
                    congThuc.tenMon,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Tác giả
                  Row(
                    children: [
                      _xayDungAvatar(8),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          congThuc.tacGia,
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
                  // Thông tin công thức
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: ChuDe.mauChuPhu,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${congThuc.thoiGianNau} phút',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ChuDe.mauChuPhu,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        congThuc.diemDanhGia.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ChuDe.mauChuPhu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Lượt thích và xem
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 16,
                        color: ChuDe.mauChinh,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${congThuc.luotThich}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ChuDe.mauChuPhu,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.visibility,
                        size: 16,
                        color: ChuDe.mauChuPhu,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${congThuc.luotXem}',
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
          // Nút yêu thích
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<DichVuTym>(
              builder: (context, dichVuTym, child) {
                final uid =
                    Provider.of<DangKiDangNhapEmail>(context, listen: false)
                        .nguoiDungHienTai
                        ?.ma;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (uid != null) {
                    dichVuTym.taiTrangThaiTym(congThuc.ma, uid);
                  }
                });

                final daTym = dichVuTym.daTym(congThuc.ma);

                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      daTym ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(daTym),
                      color: daTym ? ChuDe.mauChinh : Colors.grey,
                    ),
                  ),
                  onPressed: () async {
                    if (uid != null) {
                      await dichVuTym.toggleTym(congThuc.ma, uid);
                      HapticFeedback.lightImpact();
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _xayDungHinhAnh({double? width, double? height}) {
    // Kiểm tra xem hình ảnh có phải là file local không
    if (congThuc.hinhAnh.startsWith('/')) {
      // Đây là file local
      final file = File(congThuc.hinhAnh);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _xayDungHinhAnhMacDinh(width, height);
          },
        );
      } else {
        return _xayDungHinhAnhMacDinh(width, height);
      }
    } else if (congThuc.hinhAnh.startsWith('assets/')) {
      // Đây là asset
      return Image.asset(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(width, height);
        },
      );
    } else if (congThuc.hinhAnh.startsWith('http')) {
      // Đây là URL
      return Image.network(
        congThuc.hinhAnh,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _xayDungHinhAnhMacDinh(width, height);
        },
      );
    } else {
      return _xayDungHinhAnhMacDinh(width, height);
    }
  }

  Widget _xayDungHinhAnhMacDinh(double? width, double? height) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: (width != null && width < 150) ? 30 : 50,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Hình ảnh\nkhông có sẵn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: (width != null && width < 150) ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xayDungAvatar(double radius) {
    // Kiểm tra xem avatar có phải là file local không
    if (congThuc.anhTacGia.startsWith('/')) {
      // Đây là file local
      final file = File(congThuc.anhTacGia);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          onBackgroundImageError: (exception, stackTrace) {
            // Nếu có lỗi, sẽ fallback về avatar mặc định
          },
          child: file.existsSync() ? null : _xayDungAvatarMacDinh(radius),
        );
      } else {
        return _xayDungAvatarMacDinh(radius);
      }
    } else if (congThuc.anhTacGia.startsWith('assets/')) {
      // Đây là asset
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(congThuc.anhTacGia),
        onBackgroundImageError: (exception, stackTrace) {
          // Nếu có lỗi, sẽ fallback về avatar mặc định
        },
      );
    } else if (congThuc.anhTacGia.startsWith('http')) {
      // Đây là URL
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(congThuc.anhTacGia),
        onBackgroundImageError: (exception, stackTrace) {
          // Nếu có lỗi, sẽ fallback về avatar mặc định
        },
      );
    } else {
      return _xayDungAvatarMacDinh(radius);
    }
  }

  Widget _xayDungAvatarMacDinh(double radius) {
    // Lấy chữ cái đầu của tên tác giả
    String chuCaiDau = '';
    if (congThuc.tacGia.isNotEmpty) {
      chuCaiDau = congThuc.tacGia[0].toUpperCase();
    }

    // Tạo màu dựa trên tên tác giả
    final int mauIndex = congThuc.tacGia.hashCode % _mauAvatar.length;
    final Color mauNen = _mauAvatar[mauIndex];

    return CircleAvatar(
      radius: radius,
      backgroundColor: mauNen,
      child: Text(
        chuCaiDau,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Danh sách màu cho avatar mặc định
  static const List<Color> _mauAvatar = [
    Color(0xFFE57373), // Red
    Color(0xFFBA68C8), // Purple
    Color(0xFF64B5F6), // Blue
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF4DB6AC), // Teal
    Color(0xFF81C784), // Green
    Color(0xFFAED581), // Light Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFA1887F), // Brown
  ];
}

class NutTym extends StatefulWidget {
  final String maCongThuc;
  final String uid;

  const NutTym({
    super.key,
    required this.maCongThuc,
    required this.uid,
  });

  @override
  State<NutTym> createState() => _NutTymState();
}

class _NutTymState extends State<NutTym> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _daTym = false;
  bool _dangXuLy = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final dichVuTym = Provider.of<DichVuTym>(context, listen: false);
    await dichVuTym.taiTrangThaiTym(widget.maCongThuc, widget.uid);
    if (mounted) {
      setState(() {
        _daTym = dichVuTym.daTym(widget.maCongThuc);
      });
    }
  }

  Future<void> _toggle() async {
    if (_dangXuLy) return;

    setState(() {
      _dangXuLy = true;
      _daTym = !_daTym;
    });

    // Hiệu ứng animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Rung nhẹ
    HapticFeedback.lightImpact();

    // Cập nhật Firebase
    final dichVuTym = Provider.of<DichVuTym>(context, listen: false);
    try {
      await dichVuTym.toggleTym(widget.maCongThuc, widget.uid);
    } catch (e) {
      // Hoàn tác nếu có lỗi
      if (mounted) {
        setState(() {
          _daTym = !_daTym;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _daTym ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(_daTym),
                  color: _daTym ? Colors.red : Colors.grey,
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
