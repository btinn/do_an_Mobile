class ThongBao {
  final String ma;
  final String maNguoiNhan;
  final String maNguoiGui;
  final String tenNguoiGui;
  final String loai; // 'thich', 'binh_luan', 'theo_doi'
  final String tieuDe;
  final String noiDung;
  final String? maCongThuc;
  final String? tenCongThuc;
  final int thoiGian;
  bool daDoc;

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
    );
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
}
