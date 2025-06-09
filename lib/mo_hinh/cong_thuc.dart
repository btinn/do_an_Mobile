import 'package:do_an/mo_hinh/binh_luan.dart';

class CongThuc {
  final String ma;
  final String tenMon;
  final String hinhAnh;
  final String loai;
  final int thoiGianNau;
  final int khauPhan;
  double diemDanhGia;
  int luotThich;
  final int luotXem;
  final List<String> nguyenLieu;
  final List<String> cachLam;
  final String tacGia;
  final String anhTacGia;
  final String uid; // ✅ thêm uid tác giả nếu cần
  bool daThich;
  final List<BinhLuan> danhSachBinhLuan;
  final List<double> danhSachDanhGia;

  CongThuc({
    required this.ma,
    required this.tenMon,
    required this.hinhAnh,
    required this.loai,
    required this.thoiGianNau,
    required this.khauPhan,
    required this.diemDanhGia,
    required this.luotThich,
    required this.luotXem,
    required this.nguyenLieu,
    required this.cachLam,
    required this.tacGia,
    required this.anhTacGia,
    required this.uid,
    required this.daThich,
    required this.danhSachBinhLuan,
    required this.danhSachDanhGia,
  });

  /// ✅ Tạo từ Firebase snapshot
  factory CongThuc.fromMap(Map<dynamic, dynamic> data,
      {required bool daThich}) {
    return CongThuc(
      ma: data['ma']?.toString() ?? '',
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
      uid: data['uid'] ?? '',
      daThich: daThich, // ✅ dùng giá trị tính toán từ Firebase `tym`
      danhSachBinhLuan: [],
      danhSachDanhGia: List<double>.from(
        (data['danhSachDanhGia'] ?? []).map((e) => (e as num).toDouble()),
      ),
    );
  }
}
