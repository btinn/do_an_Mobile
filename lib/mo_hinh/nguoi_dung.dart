class NguoiDung {
  final String ma;
  String hoTen;
  String email;
  String anhDaiDien;
  String moTa;
  List<String> congThucIds;
  List<String> nguoiTheoDoiIds;
  List<String> dangTheoDoiIds;
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
    this.congThucIds = const [],
    this.nguoiTheoDoiIds = const [],
    this.dangTheoDoiIds = const [],
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
    List<String>? congThucIds,
    List<String>? nguoiTheoDoiIds,
    List<String>? dangTheoDoiIds,
  }) {
    return NguoiDung(
      ma: ma,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      anhDaiDien: anhDaiDien ?? this.anhDaiDien,
      moTa: moTa ?? this.moTa,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      diaChi: diaChi ?? this.diaChi,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      congThucIds: congThucIds ?? this.congThucIds,
      nguoiTheoDoiIds: nguoiTheoDoiIds ?? this.nguoiTheoDoiIds,
      dangTheoDoiIds: dangTheoDoiIds ?? this.dangTheoDoiIds,
    );
  }

  factory NguoiDung.fromMap(Map<String, dynamic> data, String uid) {
    return NguoiDung(
      ma: uid,
      hoTen: data['hoTen'] ?? '',
      email: data['email'] ?? '',
      anhDaiDien: data['anhDaiDien'] ?? '',
      moTa: data['moTa'] ?? '',
      congThucIds: (data['soLuongCongThuc'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nguoiTheoDoiIds: (data['soLuongNguoiTheoDoi'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dangTheoDoiIds: (data['soLuongDangTheoDoi'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      soDienThoai: data['soDienThoai'] ?? '',
      diaChi: data['diaChi'] ?? '',
      ngaySinh: data['ngaySinh'] ?? '',
      gioiTinh: data['gioiTinh'] ?? 'Nam',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'hoTen': hoTen,
      'email': email,
      'anhDaiDien': anhDaiDien,
      'moTa': moTa,
      'soLuongCongThuc': congThucIds,
      'soLuongNguoiTheoDoi': nguoiTheoDoiIds,
      'soLuongDangTheoDoi': dangTheoDoiIds,
      'soDienThoai': soDienThoai,
      'diaChi': diaChi,
      'ngaySinh': ngaySinh,
      'gioiTinh': gioiTinh,
    };
  }
}
