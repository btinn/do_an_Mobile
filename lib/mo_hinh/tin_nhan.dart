class TinNhan {
  final String ma;
  final String maNguoiGui;
  final String tenNguoiGui;
  final String anhNguoiGui;
  final String maNguoiNhan;
  final String tenNguoiNhan;
  final String anhNguoiNhan;
  final String noiDung;
  final String loai;
  final DateTime thoiGian;
  final bool daDoc;
  final String? urlHinhAnh;
  final String? maCongThuc;
  final int? thoiGianXoa; // Thêm thuộc tính này

  // Thêm các thuộc tính cũ để tương thích
  final String? nguoiGui;
  final String? nguoiNhan;

  TinNhan({
    required this.ma,
    required this.maNguoiGui,
    required this.tenNguoiGui,
    required this.anhNguoiGui,
    required this.maNguoiNhan,
    required this.tenNguoiNhan,
    required this.anhNguoiNhan,
    required this.noiDung,
    required this.loai,
    required this.thoiGian,
    this.daDoc = false,
    this.urlHinhAnh,
    this.maCongThuc,
    this.thoiGianXoa, // Thêm vào constructor
    this.nguoiGui,
    this.nguoiNhan,
  });

  // Constructor cũ để tương thích
  TinNhan.simple({
    required this.ma,
    required this.nguoiGui,
    required this.nguoiNhan,
    required this.noiDung,
    required this.thoiGian,
    this.daDoc = false,
  }) : maNguoiGui = nguoiGui ?? '',
       tenNguoiGui = '',
       anhNguoiGui = '',
       maNguoiNhan = nguoiNhan ?? '',
       tenNguoiNhan = '',
       anhNguoiNhan = '',
       loai = 'text',
       urlHinhAnh = null,
       maCongThuc = null,
       thoiGianXoa = null; // Thêm vào constructor cũ

  // Thêm getter để kiểm tra tin nhắn có bị xóa không
  bool get daBiXoa => loai == 'deleted';
  
  // Thêm getter để kiểm tra có thể xóa cho mọi người không (trong 24h)
  bool get coTheXoaChoMoiNguoi {
    if (daBiXoa) return false;
    final thoiGianHienTai = DateTime.now();
    final chenhLech = thoiGianHienTai.difference(thoiGian);
    return chenhLech.inHours <= 24;
  }

  String get thoiGianHienThi {
    final now = DateTime.now();
    final difference = now.difference(thoiGian);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}p';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${thoiGian.day}/${thoiGian.month}';
    }
  }

  factory TinNhan.fromJson(Map<String, dynamic> json) {
    return TinNhan(
      ma: json['ma'] ?? '',
      maNguoiGui: json['maNguoiGui'] ?? json['nguoiGui'] ?? '',
      tenNguoiGui: json['tenNguoiGui'] ?? '',
      anhNguoiGui: json['anhNguoiGui'] ?? '',
      maNguoiNhan: json['maNguoiNhan'] ?? json['nguoiNhan'] ?? '',
      tenNguoiNhan: json['tenNguoiNhan'] ?? '',
      anhNguoiNhan: json['anhNguoiNhan'] ?? '',
      noiDung: json['noiDung'] ?? '',
      loai: json['loai'] ?? 'text',
      thoiGian: json['thoiGian'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['thoiGian'])
          : DateTime.parse(json['thoiGian'] ?? DateTime.now().toIso8601String()),
      daDoc: json['daDoc'] ?? false,
      urlHinhAnh: json['urlHinhAnh'],
      maCongThuc: json['maCongThuc'],
      thoiGianXoa: json['thoiGianXoa'], // Thêm vào fromJson
      nguoiGui: json['nguoiGui'],
      nguoiNhan: json['nguoiNhan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma': ma,
      'maNguoiGui': maNguoiGui,
      'tenNguoiGui': tenNguoiGui,
      'anhNguoiGui': anhNguoiGui,
      'maNguoiNhan': maNguoiNhan,
      'tenNguoiNhan': tenNguoiNhan,
      'anhNguoiNhan': anhNguoiNhan,
      'noiDung': noiDung,
      'loai': loai,
      'thoiGian': thoiGian.millisecondsSinceEpoch,
      'daDoc': daDoc,
      'urlHinhAnh': urlHinhAnh,
      'maCongThuc': maCongThuc,
      'thoiGianXoa': thoiGianXoa, // Thêm vào toJson
      'nguoiGui': nguoiGui,
      'nguoiNhan': nguoiNhan,
    };
  }
}
