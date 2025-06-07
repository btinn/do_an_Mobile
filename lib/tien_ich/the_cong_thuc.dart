import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:provider/provider.dart';
import 'package:do_an/dich_vu/dich_vu_cai_dat.dart';

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
                    child: Image.asset(
                      congThuc.hinhAnh,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<DichVuCaiDat>(
                    //Dich vụ cài đặt ở đây là sai vì nó không liên quan đến việc thích công thức
                    // Nên cần phải tạo một dịch vụ mới cho việc thích công thức
                    // Hoặc có thể sử dụng DichVuDuLieu nếu đã được định nghĩa
                    // để quản lý việc thích công thức
                    builder: (context, dichVuDuLieu, child) {
                      return GestureDetector(
                        onTap: () {
                          dichVuDuLieu.thichCongThuc(congThuc.ma);
                        },
                        child: Container(
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
                          child: Icon(
                            congThuc.daThich
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                congThuc.daThich ? ChuDe.mauChinh : Colors.grey,
                            size: 18,
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
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: AssetImage(congThuc.anhTacGia),
                    ),
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
                  child: Image.asset(
                    congThuc.hinhAnh,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
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
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: AssetImage(congThuc.anhTacGia),
                      ),
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
            child: Consumer<DichVuCaiDat>(
              // Sử dụng DichVuCaiDat để quản lý việc thích công thức
              // Nếu bạn đã tạo DichVuDuLieu thì có thể thay thế bằng DichVuDuLieu
              // và sử dụng phương thức thích công thức trong DichVuDuLieu
              builder: (context, dichVuDuLieu, child) {
                return IconButton(
                  icon: Icon(
                    congThuc.daThich ? Icons.favorite : Icons.favorite_border,
                    color: congThuc.daThich ? ChuDe.mauChinh : Colors.grey,
                  ),
                  onPressed: () {
                    dichVuDuLieu.thichCongThuc(congThuc.ma);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
