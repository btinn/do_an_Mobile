import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/thong_bao.dart';

class DichVuThongBao {
  final _db = FirebaseDatabase.instance.ref();

  // Tạo thông báo khi có người thích công thức
  Future<void> taoThongBaoThich({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
    required String maCongThuc,
    required String tenCongThuc,
  }) async {
    final thongBao = {
      'ma': DateTime.now().millisecondsSinceEpoch.toString(),
      'maNguoiNhan': maNguoiNhan,
      'maNguoiGui': maNguoiGui,
      'tenNguoiGui': tenNguoiGui,
      'loai': 'thich',
      'tieuDe': 'Ai đó đã thích công thức của bạn',
      'noiDung': '$tenNguoiGui đã thích công thức "$tenCongThuc" của bạn',
      'maCongThuc': maCongThuc,
      'tenCongThuc': tenCongThuc,
      'thoiGian': DateTime.now().millisecondsSinceEpoch,
      'daDoc': false,
    };

    await _db.child('thong_bao').child(maNguoiNhan).push().set(thongBao);
  }

  // Tạo thông báo khi có người bình luận
  Future<void> taoThongBaoBinhLuan({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
    required String maCongThuc,
    required String tenCongThuc,
    required String noiDungBinhLuan,
  }) async {
    final thongBao = {
      'ma': DateTime.now().millisecondsSinceEpoch.toString(),
      'maNguoiNhan': maNguoiNhan,
      'maNguoiGui': maNguoiGui,
      'tenNguoiGui': tenNguoiGui,
      'loai': 'binh_luan',
      'tieuDe': 'Bình luận mới',
      'noiDung': '$tenNguoiGui đã bình luận: "${noiDungBinhLuan.length > 50 ? noiDungBinhLuan.substring(0, 50) + '...' : noiDungBinhLuan}"',
      'maCongThuc': maCongThuc,
      'tenCongThuc': tenCongThuc,
      'thoiGian': DateTime.now().millisecondsSinceEpoch,
      'daDoc': false,
    };

    await _db.child('thong_bao').child(maNguoiNhan).push().set(thongBao);
  }

  // Lấy danh sách thông báo của người dùng
  Future<List<ThongBao>> layDanhSachThongBao(String maNguoiDung) async {
    final snapshot = await _db.child('thong_bao').child(maNguoiDung).get();
    
    if (!snapshot.exists) return [];

    final List<ThongBao> danhSach = [];
    
    for (final child in snapshot.children) {
      try {
        final data = child.value as Map<dynamic, dynamic>?;
        if (data == null) continue;

        danhSach.add(ThongBao.fromMap(data));
      } catch (e) {
        print('Lỗi khi chuyển đổi thông báo: $e');
      }
    }

    // Sắp xếp theo thời gian mới nhất
    danhSach.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    
    return danhSach;
  }

  // Đánh dấu thông báo đã đọc
  Future<void> danhDauDaDoc(String maNguoiDung, String maThongBao) async {
    final snapshot = await _db.child('thong_bao').child(maNguoiDung).get();
    
    if (snapshot.exists) {
      for (final child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>?;
        if (data != null && data['ma'] == maThongBao) {
          await child.ref.update({'daDoc': true});
          break;
        }
      }
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> danhDauTatCaDaDoc(String maNguoiDung) async {
    final snapshot = await _db.child('thong_bao').child(maNguoiDung).get();
    
    if (snapshot.exists) {
      for (final child in snapshot.children) {
        await child.ref.update({'daDoc': true});
      }
    }
  }

  // Đếm số thông báo chưa đọc
  Future<int> demThongBaoChuaDoc(String maNguoiDung) async {
    final snapshot = await _db.child('thong_bao').child(maNguoiDung).get();
    
    if (!snapshot.exists) return 0;

    int count = 0;
    for (final child in snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>?;
      if (data != null && data['daDoc'] == false) {
        count++;
      }
    }
    
    return count;
  }

  // Lắng nghe thông báo mới
  Stream<List<ThongBao>> langNgheThongBao(String maNguoiDung) {
    return _db.child('thong_bao').child(maNguoiDung).onValue.map((event) {
      if (!event.snapshot.exists) return <ThongBao>[];

      final List<ThongBao> danhSach = [];
      
      for (final child in event.snapshot.children) {
        try {
          final data = child.value as Map<dynamic, dynamic>?;
          if (data == null) continue;

          danhSach.add(ThongBao.fromMap(data));
        } catch (e) {
          print('Lỗi khi chuyển đổi thông báo: $e');
        }
      }

      // Sắp xếp theo thời gian mới nhất
      danhSach.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      
      return danhSach;
    });
  }
}
