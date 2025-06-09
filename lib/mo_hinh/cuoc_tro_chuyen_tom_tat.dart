class CuocTroChuyenTomTat {
  final String maNguoiKhac;
  final String tenNguoiKhac;
  final String anhNguoiKhac;
  final String tinNhanCuoi;
  final String loaiTinNhanCuoi;
  final DateTime thoiGianCuoi;
  final int soTinNhanChuaDoc;
  final bool dangOnline;

  CuocTroChuyenTomTat({
    required this.maNguoiKhac,
    required this.tenNguoiKhac,
    required this.anhNguoiKhac,
    required this.tinNhanCuoi,
    required this.loaiTinNhanCuoi,
    required this.thoiGianCuoi,
    this.soTinNhanChuaDoc = 0,
    this.dangOnline = false,
  });

  factory CuocTroChuyenTomTat.fromJson(Map<String, dynamic> json) {
    return CuocTroChuyenTomTat(
      maNguoiKhac: json['maNguoiKhac'] ?? '',
      tenNguoiKhac: json['tenNguoiKhac'] ?? '',
      anhNguoiKhac: json['anhNguoiKhac'] ?? '',
      tinNhanCuoi: json['tinNhanCuoi'] ?? '',
      loaiTinNhanCuoi: json['loaiTinNhanCuoi'] ?? '',
      thoiGianCuoi: DateTime.fromMillisecondsSinceEpoch(json['thoiGianCuoi'] ?? 0),
      soTinNhanChuaDoc: json['soTinNhanChuaDoc'] ?? 0,
      dangOnline: json['dangOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNguoiKhac': maNguoiKhac,
      'tenNguoiKhac': tenNguoiKhac,
      'anhNguoiKhac': anhNguoiKhac,
      'tinNhanCuoi': tinNhanCuoi,
      'loaiTinNhanCuoi': loaiTinNhanCuoi,
      'thoiGianCuoi': thoiGianCuoi.millisecondsSinceEpoch,
      'soTinNhanChuaDoc': soTinNhanChuaDoc,
      'dangOnline': dangOnline,
    };
  }

  String get thoiGianHienThi {
    final now = DateTime.now();
    final difference = now.difference(thoiGianCuoi);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}p';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${thoiGianCuoi.day}/${thoiGianCuoi.month}';
    }
  }
}
