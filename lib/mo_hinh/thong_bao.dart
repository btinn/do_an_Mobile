class ThongBao {
  final String ma;
  final String maNguoiNhan;
  final String maNguoiGui;
  final String tenNguoiGui;
  final String loai; // 'thich', 'binh_luan', 'theo_doi', 'danh_gia'
  final String tieuDe;
  final String noiDung;
  final String? maCongThuc;
  final String? tenCongThuc;
  final int thoiGian;
  bool daDoc;
  final double? diemDanhGia; // Cho thông báo đánh giá
  final String? noiDungBinhLuan; // Cho thông báo bình luận
  final String? anhDaiDienNguoiGui; // Cho thông báo theo dõi

  ThongBao({
    required this.ma,
    required this.maNguoiNhan,
    required this.maNguoiGui,
    required this.tenNguoiGui,
    required this.loai,
    required this.tieuDe,
    required this.noiDung,
    this.maCongThuc,
    this.tenCongThuc,
    required this.thoiGian,
    required this.daDoc,
    this.diemDanhGia,
    this.noiDungBinhLuan,
    this.anhDaiDienNguoiGui,
  });

  factory ThongBao.fromMap(Map<dynamic, dynamic> map) {
    return ThongBao(
      ma: map['ma'] ?? '',
      maNguoiNhan: map['maNguoiNhan'] ?? '',
      maNguoiGui: map['maNguoiGui'] ?? '',
      tenNguoiGui: map['tenNguoiGui'] ?? '',
      loai: map['loai'] ?? '',
      tieuDe: map['tieuDe'] ?? '',
      noiDung: map['noiDung'] ?? '',
      maCongThuc: map['maCongThuc'],
      tenCongThuc: map['tenCongThuc'],
      thoiGian: map['thoiGian'] ?? 0,
      daDoc: map['daDoc'] ?? false,
      diemDanhGia: map['diemDanhGia']?.toDouble(),
      noiDungBinhLuan: map['noiDungBinhLuan'],
      anhDaiDienNguoiGui: map['anhDaiDienNguoiGui'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ma': ma,
      'maNguoiNhan': maNguoiNhan,
      'maNguoiGui': maNguoiGui,
      'tenNguoiGui': tenNguoiGui,
      'loai': loai,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'maCongThuc': maCongThuc,
      'tenCongThuc': tenCongThuc,
      'thoiGian': thoiGian,
      'daDoc': daDoc,
      'diemDanhGia': diemDanhGia,
      'noiDungBinhLuan': noiDungBinhLuan,
      'anhDaiDienNguoiGui': anhDaiDienNguoiGui,
    };
  }

  String get thoiGianHienThi {
    final now = DateTime.now();
    final notificationTime = DateTime.fromMillisecondsSinceEpoch(thoiGian);
    final difference = now.difference(notificationTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${difference.inDays ~/ 7} tuần trước';
    }
  }

  String get iconThongBao {
    switch (loai) {
      case 'thich':
        return '❤️';
      case 'binh_luan':
        return '💬';
      case 'theo_doi':
        return '👥';
      case 'danh_gia':
        return '⭐';
      default:
        return '🔔';
    }
  }

  String get mauThongBao {
    switch (loai) {
      case 'thich':
        return 'red';
      case 'binh_luan':
        return 'blue';
      case 'theo_doi':
        return 'green';
      case 'danh_gia':
        return 'orange';
      default:
        return 'grey';
    }
  }
}
