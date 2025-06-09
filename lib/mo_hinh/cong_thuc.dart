class CongThuc {
  final String ma;
  final String tenMon;
  final String hinhAnh;
  final String loai;
  final int thoiGianNau;
  final int khauPhan;
  final double diemDanhGia;
  int luotThich;
  final int luotXem;
  final List<String> nguyenLieu;
  final List<String> cachLam;
  final String tacGia;
  final String anhTacGia;
  final String uid;
  bool daThich;
  final List<double> danhSachDanhGia;
  final List<dynamic> danhSachBinhLuan;

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
    required this.danhSachDanhGia,
    required this.danhSachBinhLuan,
  });

  // Factory constructor để tạo từ Map
  factory CongThuc.fromMap(Map<String, dynamic> map, {required String ma, required bool daThich}) {
    return CongThuc(
      ma: ma,
      tenMon: map['tenMon'] ?? '',
      hinhAnh: map['hinhAnh'] ?? '',
      loai: map['loai'] ?? '',
      thoiGianNau: map['thoiGianNau'] ?? 0,
      khauPhan: map['khauPhan'] ?? 0,
      diemDanhGia: (map['diemDanhGia'] ?? 0).toDouble(),
      luotThich: map['luotThich'] ?? 0,
      luotXem: map['luotXem'] ?? 0,
      nguyenLieu: List<String>.from(map['nguyenLieu'] ?? []),
      cachLam: List<String>.from(map['cachLam'] ?? []),
      tacGia: map['tacGia'] ?? '',
      anhTacGia: map['anhTacGia'] ?? '',
      uid: map['uid'] ?? '',
      daThich: daThich,
      danhSachDanhGia: List<double>.from(
        (map['danhSachDanhGia'] ?? []).map((e) => (e as num).toDouble()),
      ),
      danhSachBinhLuan: map['danhSachBinhLuan'] ?? [],
    );
  }

  // Factory constructor để tạo empty object
  factory CongThuc.empty() {
    return CongThuc(
      ma: '',
      tenMon: '',
      hinhAnh: '',
      loai: '',
      thoiGianNau: 0,
      khauPhan: 0,
      diemDanhGia: 0.0,
      luotThich: 0,
      luotXem: 0,
      nguyenLieu: [],
      cachLam: [],
      tacGia: '',
      anhTacGia: '',
      uid: '',
      daThich: false,
      danhSachDanhGia: [],
      danhSachBinhLuan: [],
    );
  }

  // Chuyển đổi thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'ma': ma,
      'tenMon': tenMon,
      'hinhAnh': hinhAnh,
      'loai': loai,
      'thoiGianNau': thoiGianNau,
      'khauPhan': khauPhan,
      'diemDanhGia': diemDanhGia,
      'luotThich': luotThich,
      'luotXem': luotXem,
      'nguyenLieu': nguyenLieu,
      'cachLam': cachLam,
      'tacGia': tacGia,
      'anhTacGia': anhTacGia,
      'uid': uid,
      'danhSachDanhGia': danhSachDanhGia,
      'danhSachBinhLuan': danhSachBinhLuan,
    };
  }

  // Copy with method
  CongThuc copyWith({
    String? ma,
    String? tenMon,
    String? hinhAnh,
    String? loai,
    int? thoiGianNau,
    int? khauPhan,
    double? diemDanhGia,
    int? luotThich,
    int? luotXem,
    List<String>? nguyenLieu,
    List<String>? cachLam,
    String? tacGia,
    String? anhTacGia,
    String? uid,
    bool? daThich,
    List<double>? danhSachDanhGia,
    List<dynamic>? danhSachBinhLuan,
  }) {
    return CongThuc(
      ma: ma ?? this.ma,
      tenMon: tenMon ?? this.tenMon,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      loai: loai ?? this.loai,
      thoiGianNau: thoiGianNau ?? this.thoiGianNau,
      khauPhan: khauPhan ?? this.khauPhan,
      diemDanhGia: diemDanhGia ?? this.diemDanhGia,
      luotThich: luotThich ?? this.luotThich,
      luotXem: luotXem ?? this.luotXem,
      nguyenLieu: nguyenLieu ?? this.nguyenLieu,
      cachLam: cachLam ?? this.cachLam,
      tacGia: tacGia ?? this.tacGia,
      anhTacGia: anhTacGia ?? this.anhTacGia,
      uid: uid ?? this.uid,
      daThich: daThich ?? this.daThich,
      danhSachDanhGia: danhSachDanhGia ?? this.danhSachDanhGia,
      danhSachBinhLuan: danhSachBinhLuan ?? this.danhSachBinhLuan,
    );
  }
}
