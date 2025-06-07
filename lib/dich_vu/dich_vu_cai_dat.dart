import 'package:flutter/material.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/mo_hinh/cai_dat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DichVuCaiDat extends ChangeNotifier {
  // Dịch vụ xác thực

  // Danh sách công thức
  List<CongThuc> _danhSachCongThuc = [];
  List<CongThuc> get danhSachCongThuc => _danhSachCongThuc;

  // Danh sách công thức nổi bật
  List<CongThuc> get danhSachCongThucNoiBat =>
      _danhSachCongThuc.where((congThuc) => congThuc.luotThich > 10).toList();

  // Danh sách công thức phổ biến
  List<CongThuc> get danhSachCongThucPhoBien =>
      _danhSachCongThuc.where((congThuc) => congThuc.luotXem > 100).toList();

  // Người dùng hiện tại
  // NguoiDung? _nguoiDungHienTai;
  // NguoiDung? get nguoiDungHienTai => _nguoiDungHienTai;

  // Cài đặt ứng dụng
  CaiDat _caiDat = CaiDat();
  CaiDat get caiDat => _caiDat;

  // Khởi tạo dữ liệu
  DichVuCaiDat() {
    _taiCaiDat();
  }

  // Kiểm tra trạng thái đăng nhập
  // void _kiemTraDangNhap() {
  //   if (_dichVuXacThuc.kiemTraDangNhap()) {
  //     _nguoiDungHienTai = _dichVuXacThuc.layNguoiDungHienTai();
  //     notifyListeners();
  //   }
  // }

  // Thêm công thức mới
  // void themCongThuc(CongThuc congThuc) {
  //   _danhSachCongThuc.add(congThuc);
  //   notifyListeners();
  // }

  // Thích công thức
  void thichCongThuc(String maCongThuc) {
    final congThuc = _danhSachCongThuc.firstWhere((ct) => ct.ma == maCongThuc);
    congThuc.daThich = !congThuc.daThich;
    if (congThuc.daThich) {
      congThuc.luotThich++;
    } else {
      congThuc.luotThich--;
    }
    notifyListeners();
  }

  // // Thêm bình luận
  // void themBinhLuan(String maCongThuc, BinhLuan binhLuan) {
  //   final congThuc = _danhSachCongThuc.firstWhere((ct) => ct.ma == maCongThuc);
  //   congThuc.danhSachBinhLuan.add(binhLuan);
  //   notifyListeners();
  // }

  // // Đánh giá công thức
  // void danhGiaCongThuc(String maCongThuc, double diem) {
  //   final congThuc = _danhSachCongThuc.firstWhere((ct) => ct.ma == maCongThuc);
  //   congThuc.danhSachDanhGia.add(diem);
  //   congThuc.diemDanhGia = congThuc.danhSachDanhGia.reduce((a, b) => a + b) /
  //       congThuc.danhSachDanhGia.length;
  //   notifyListeners();
  // }

  // // Đăng nhập với email và mật khẩu
  // Future<bool> dangNhap(String email, String matKhau) async {
  //   final nguoiDung = await _dichVuXacThuc.dangNhapEmailMatKhau(email, matKhau);

  //   if (nguoiDung != null) {
  //     _nguoiDungHienTai = nguoiDung;
  //     notifyListeners();
  //     return true;
  //   }

  //   return false;
  // }

  // Đăng nhập với Google
  // Future<bool> dangNhapGoogle() async {
  //   final nguoiDung = await _dichVuXacThuc.dangNhapGoogle();

  //   if (nguoiDung != null) {
  //     _nguoiDungHienTai = nguoiDung;
  //     notifyListeners();
  //     return true;
  //   }

  //   return false;
  // }

  // Đăng ký tài khoản mới
  // Future<bool> dangKyTaiKhoan(
  //     String hoTen, String email, String matKhau) async {
  //   final nguoiDung =
  //       await _dichVuXacThuc.dangKyTaiKhoan(hoTen, email, matKhau);

  //   if (nguoiDung != null) {
  //     _nguoiDungHienTai = nguoiDung;
  //     notifyListeners();
  //     return true;
  //   }

  //   return false;
  // }

  // Đăng xuất
  // Future<void> dangXuat() async {
  //   await _dichVuXacThuc.dangXuat();
  //   _nguoiDungHienTai = null;
  //   notifyListeners();
  // }

  // Cập nhật thông tin người dùng
  // void capNhatThongTinNguoiDung(NguoiDung nguoiDungCapNhat) {
  //   _nguoiDungHienTai = nguoiDungCapNhat;
  //   notifyListeners();
  // }

  // Cập nhật cài đặt
  void capNhatCaiDat(CaiDat caiDatMoi) {
    _caiDat = caiDatMoi;
    _luuCaiDat();
    notifyListeners();
  }

  // Tìm kiếm công thức
  // List<CongThuc> timKiemCongThuc(String tuKhoa) {
  //   if (tuKhoa.isEmpty) {
  //     return _danhSachCongThuc;
  //   }

  //   return _danhSachCongThuc.where((congThuc) {
  //     return congThuc.tenMon.toLowerCase().contains(tuKhoa.toLowerCase()) ||
  //         congThuc.loai.toLowerCase().contains(tuKhoa.toLowerCase()) ||
  //         congThuc.nguyenLieu
  //             .any((nl) => nl.toLowerCase().contains(tuKhoa.toLowerCase()));
  //   }).toList();
  // }

  // Tải cài đặt từ SharedPreferences
  Future<void> _taiCaiDat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ngonNguInt = prefs.getInt('ngonNgu') ?? 0;
      final chuDeMauInt = prefs.getInt('chuDeMau') ?? 0;
      final thongBao = prefs.getBool('thongBao') ?? true;
      final tuDongPhatVideo = prefs.getBool('tuDongPhatVideo') ?? true;
      final luuDuLieuOffline = prefs.getBool('luuDuLieuOffline') ?? false;

      _caiDat = CaiDat(
        ngonNgu: NgonNgu.values[ngonNguInt],
        chuDeMau: ChuDeMau.values[chuDeMauInt],
        thongBao: thongBao,
        tuDongPhatVideo: tuDongPhatVideo,
        luuDuLieuOffline: luuDuLieuOffline,
      );

      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải cài đặt: $e');
    }
  }

  // Lưu cài đặt vào SharedPreferences
  Future<void> _luuCaiDat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ngonNgu', _caiDat.ngonNgu.index);
      await prefs.setInt('chuDeMau', _caiDat.chuDeMau.index);
      await prefs.setBool('thongBao', _caiDat.thongBao);
      await prefs.setBool('tuDongPhatVideo', _caiDat.tuDongPhatVideo);
      await prefs.setBool('luuDuLieuOffline', _caiDat.luuDuLieuOffline);
    } catch (e) {
      print('Lỗi khi lưu cài đặt: $e');
    }
  }

  // void batDauLangNgheDuLieu() {
  //   final ref = FirebaseDatabase.instance.ref("cong_thuc");

  //   ref.onValue.listen((DatabaseEvent event) {
  //     final snapshot = event.snapshot;
  //     if (snapshot.exists) {
  //       final data = Map<String, dynamic>.from(snapshot.value as Map);

  //       _danhSachCongThuc = data.entries.map((entry) {
  //         final ma = entry.key;
  //         final item = Map<String, dynamic>.from(entry.value);

  //         return CongThuc(
  //           ma: ma,
  //           tenMon: item['tenMon'],
  //           hinhAnh: item['hinhAnh'],
  //           loai: item['loai'],
  //           thoiGianNau: item['thoiGianNau'],
  //           khauPhan: item['khauPhan'],
  //           diemDanhGia: (item['diemDanhGia'] as num).toDouble(),
  //           luotThich: item['luotThich'],
  //           luotXem: item['luotXem'],
  //           nguyenLieu: List<String>.from(item['nguyenLieu']),
  //           cachLam: List<String>.from(item['cachLam']),
  //           tacGia: item['tacGia'],
  //           anhTacGia: item['anhTacGia'],
  //           daThich: false,
  //           danhSachBinhLuan: [],
  //           danhSachDanhGia: [],
  //         );
  //       }).toList();

  //       notifyListeners();
  //     }
  //   });
  // }
}
