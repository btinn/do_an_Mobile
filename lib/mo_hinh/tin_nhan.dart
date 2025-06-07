class TinNhan {
  final String ma;
  final String maNguoiGui;
  final String tenNguoiGui;
  final String anhNguoiGui;
  final String maNguoiNhan;
  final String tenNguoiNhan;
  final String anhNguoiNhan;
  final String noiDung;
  final String loai; // 'text', 'image', 'recipe', 'sticker'
  final DateTime thoiGian;
  final bool daDoc;
  final String? urlHinhAnh;
  final String? maCongThuc;

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
    required this.daDoc,
    this.urlHinhAnh,
    this.maCongThuc,
  });

  factory TinNhan.fromMap(Map<String, dynamic> map) {
    return TinNhan(
      ma: map['ma'] ?? '',
      maNguoiGui: map['maNguoiGui'] ?? '',
      tenNguoiGui: map['tenNguoiGui'] ?? '',
      anhNguoiGui: map['anhNguoiGui'] ?? '',
      maNguoiNhan: map['maNguoiNhan'] ?? '',
      tenNguoiNhan: map['tenNguoiNhan'] ?? '',
      anhNguoiNhan: map['anhNguoiNhan'] ?? '',
      noiDung: map['noiDung'] ?? '',
      loai: map['loai'] ?? 'text',
      thoiGian: DateTime.fromMillisecondsSinceEpoch(map['thoiGian'] ?? 0),
      daDoc: map['daDoc'] ?? false,
      urlHinhAnh: map['urlHinhAnh'],
      maCongThuc: map['maCongThuc'],
    );
  }

  Map<String, dynamic> toMap() {
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
    };
  }

  String get thoiGianHienThi {
    final now = DateTime.now();
    final difference = now.difference(thoiGian);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }
}

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
    required this.soTinNhanChuaDoc,
    required this.dangOnline,
  });

  String get thoiGianHienThi {
    final now = DateTime.now();
    final difference = now.difference(thoiGianCuoi);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }
}

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
    required this.daXem,
  });
}
