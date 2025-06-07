import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
// import 'package:do_an/mo_hinh/binh_luan.dart';

class DichVuCongThuc {
  final _db = FirebaseDatabase.instance.ref();

  Future<List<CongThuc>> layDanhSachCongThuc() async {
    final snapshot = await _db.child('cong_thuc').get();

    if (!snapshot.exists) return [];

    final List<CongThuc> danhSach = [];

    for (final child in snapshot.children) {
      print("Dữ liệu child: ${child.value}");
      try {
        final data = child.value as Map<dynamic, dynamic>?;
        if (data == null) continue;
        print('Tải công thức: ${data['tenMon']}');

        danhSach.add(
          CongThuc(
            ma: data['ma'].toString(),
            tenMon: data['tenMon'] ?? '',
            hinhAnh: data['hinhAnh'] ?? '',
            loai: data['loai'] ?? '',
            thoiGianNau: data['thoiGianNau'] ?? 0,
            khauPhan: data['khauPhan'] ?? 0,
            diemDanhGia: (data['diemDanhGia'] ?? 0).toDouble(),
            luotThich: data['luotThich'] ?? 0,
            luotXem: data['luotXem'] ?? 0,
            nguyenLieu: List<String>.from(data['nguyenLieu'] ?? []),
            cachLam: List<String>.from(data['cachLam'] ?? []),
            tacGia: data['tacGia'] ?? '',
            anhTacGia: data['anhTacGia'] ?? '',
            daThich: data['daThich'] ?? false,
            danhSachDanhGia: List<double>.from(
                (data['danhSachDanhGia'] ?? []).map((e) => e.toDouble())),
            danhSachBinhLuan: [], // Bạn sẽ xử lý phần này sau nếu lưu riêng
          ),
        );
      } catch (e) {
        // Bỏ qua các lỗi không mong muốn trong quá trình chuyển đổi
        print('Lỗi khi chuyển đổi dữ liệu: $e');
      }
    }

    return danhSach;
  }
}
