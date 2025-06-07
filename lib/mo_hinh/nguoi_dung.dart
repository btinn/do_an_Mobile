class NguoiDung {
  final String ma;
  String hoTen;
  String email;
  String anhDaiDien;
  String moTa;
  int soLuongCongThuc;
  int soLuongNguoiTheoDoi;
  int soLuongDangTheoDoi;
  String soDienThoai;
  String diaChi;
  String ngaySinh;
  String gioiTinh;

  NguoiDung({
    required this.ma,
    required this.hoTen,
    required this.email,
    required this.anhDaiDien,
    required this.moTa,
    required this.soLuongCongThuc,
    required this.soLuongNguoiTheoDoi,
    required this.soLuongDangTheoDoi,
    this.soDienThoai = '',
    this.diaChi = '',
    this.ngaySinh = '',
    this.gioiTinh = 'Nam',
  });

  NguoiDung copyWith({
    String? hoTen,
    String? email,
    String? anhDaiDien,
    String? moTa,
    String? soDienThoai,
    String? diaChi,
    String? ngaySinh,
    String? gioiTinh,
  }) {
    return NguoiDung(
      ma: ma,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      anhDaiDien: anhDaiDien ?? this.anhDaiDien,
      moTa: moTa ?? this.moTa,
      soLuongCongThuc: soLuongCongThuc,
      soLuongNguoiTheoDoi: soLuongNguoiTheoDoi,
      soLuongDangTheoDoi: soLuongDangTheoDoi,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      diaChi: diaChi ?? this.diaChi,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
    );
  }
}

// tin khung
