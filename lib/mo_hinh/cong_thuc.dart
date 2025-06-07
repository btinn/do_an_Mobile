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
    required this.daThich,
    required this.danhSachBinhLuan,
    required this.danhSachDanhGia,
  });
}
