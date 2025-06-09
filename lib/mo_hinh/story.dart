class Story {
  final String ma;
  final String maNguoiDung;
  final String tenNguoiDung;
  final String anhNguoiDung;
  final String urlHinhAnh;
  final DateTime thoiGian;
  final bool daXem;

  Story({
    required this.ma,
    required this.maNguoiDung,
    required this.tenNguoiDung,
    required this.anhNguoiDung,
    required this.urlHinhAnh,
    required this.thoiGian,
    this.daXem = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      ma: json['ma'] ?? '',
      maNguoiDung: json['maNguoiDung'] ?? '',
      tenNguoiDung: json['tenNguoiDung'] ?? '',
      anhNguoiDung: json['anhNguoiDung'] ?? '',
      urlHinhAnh: json['urlHinhAnh'] ?? '',
      thoiGian: DateTime.parse(json['thoiGian'] ?? DateTime.now().toIso8601String()),
      daXem: json['daXem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma': ma,
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
      'anhNguoiDung': anhNguoiDung,
      'urlHinhAnh': urlHinhAnh,
      'thoiGian': thoiGian.toIso8601String(),
      'daXem': daXem,
    };
  }
}
