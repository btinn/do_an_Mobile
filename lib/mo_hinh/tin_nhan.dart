// class TinNhan {
//   final String ma;
//   final String maNguoiGui;
//   final String tenNguoiGui;
//   final String anhNguoiGui;
//   final String maNguoiNhan;
//   final String tenNguoiNhan;
//   final String anhNguoiNhan;
//   final String noiDung;
//   final String loai;
//   final DateTime thoiGian;
//   final bool daDoc;
//   final String? urlHinhAnh;
//   final String? maCongThuc;

//   // Thêm các thuộc tính cũ để tương thích
//   final String? nguoiGui;
//   final String? nguoiNhan;

//   TinNhan({
//     required this.ma,
//     required this.maNguoiGui,
//     required this.tenNguoiGui,
//     required this.anhNguoiGui,
//     required this.maNguoiNhan,
//     required this.tenNguoiNhan,
//     required this.anhNguoiNhan,
//     required this.noiDung,
//     required this.loai,
//     required this.thoiGian,
//     this.daDoc = false,
//     this.urlHinhAnh,
//     this.maCongThuc,
//     this.nguoiGui,
//     this.nguoiNhan,
//   });

//   // Constructor cũ để tương thích
//   TinNhan.simple({
//     required this.ma,
//     required this.nguoiGui,
//     required this.nguoiNhan,
//     required this.noiDung,
//     required this.thoiGian,
//     this.daDoc = false,
//   }) : maNguoiGui = nguoiGui ?? '',
//        tenNguoiGui = '',
//        anhNguoiGui = '',
//        maNguoiNhan = nguoiNhan ?? '',
//        tenNguoiNhan = '',
//        anhNguoiNhan = '',
//        loai = 'text',
//        urlHinhAnh = null,
//        maCongThuc = null;

//   String get thoiGianHienThi {
//     final now = DateTime.now();
//     final difference = now.difference(thoiGian);

//     if (difference.inMinutes < 1) {
//       return 'Vừa xong';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}p';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours}h';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d';
//     } else {
//       return '${thoiGian.day}/${thoiGian.month}';
//     }
//   }

//   factory TinNhan.fromJson(Map<String, dynamic> json) {
//     return TinNhan(
//       ma: json['ma'] ?? '',
//       maNguoiGui: json['maNguoiGui'] ?? json['nguoiGui'] ?? '',
//       tenNguoiGui: json['tenNguoiGui'] ?? '',
//       anhNguoiGui: json['anhNguoiGui'] ?? '',
//       maNguoiNhan: json['maNguoiNhan'] ?? json['nguoiNhan'] ?? '',
//       tenNguoiNhan: json['tenNguoiNhan'] ?? '',
//       anhNguoiNhan: json['anhNguoiNhan'] ?? '',
//       noiDung: json['noiDung'] ?? '',
//       loai: json['loai'] ?? 'text',
//       thoiGian: json['thoiGian'] is int 
//           ? DateTime.fromMillisecondsSinceEpoch(json['thoiGian'])
//           : DateTime.parse(json['thoiGian'] ?? DateTime.now().toIso8601String()),
//       daDoc: json['daDoc'] ?? false,
//       urlHinhAnh: json['urlHinhAnh'],
//       maCongThuc: json['maCongThuc'],
//       nguoiGui: json['nguoiGui'],
//       nguoiNhan: json['nguoiNhan'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'ma': ma,
//       'maNguoiGui': maNguoiGui,
//       'tenNguoiGui': tenNguoiGui,
//       'anhNguoiGui': anhNguoiGui,
//       'maNguoiNhan': maNguoiNhan,
//       'tenNguoiNhan': tenNguoiNhan,
//       'anhNguoiNhan': anhNguoiNhan,
//       'noiDung': noiDung,
//       'loai': loai,
//       'thoiGian': thoiGian.millisecondsSinceEpoch,
//       'daDoc': daDoc,
//       'urlHinhAnh': urlHinhAnh,
//       'maCongThuc': maCongThuc,
//       'nguoiGui': nguoiGui,
//       'nguoiNhan': nguoiNhan,
//     };
//   }
// }
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
  final bool hienThiBongBong; // Thêm thuộc tính này

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
    this.nguoiGui,
    this.nguoiNhan,
    this.hienThiBongBong = true, // Mặc định là hiển thị bong bóng
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
       hienThiBongBong = true;

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
      nguoiGui: json['nguoiGui'],
      nguoiNhan: json['nguoiNhan'],
      hienThiBongBong: json['hienThiBongBong'] ?? true,
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
      'nguoiGui': nguoiGui,
      'nguoiNhan': nguoiNhan,
      'hienThiBongBong': hienThiBongBong,
    };
  }
}
