import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/thong_bao.dart';
import 'package:flutter/foundation.dart';

class DichVuThongBao {
  final _db = FirebaseDatabase.instance.ref();

  // Tạo thông báo khi ai đó thích công thức
  Future<void> taoThongBaoThich({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
    required String maCongThuc,
    required String tenCongThuc,
  }) async {
    // Không gửi thông báo cho chính mình
    if (maNguoiNhan == maNguoiGui) return;

    try {
      final thongBaoRef = _db.child('thong_bao/$maNguoiNhan').push();
      
      await thongBaoRef.set({
        'ma': thongBaoRef.key,
        'maNguoiNhan': maNguoiNhan,
        'maNguoiGui': maNguoiGui,
        'loai': 'thich',
        'tieuDe': 'Có người thích công thức của bạn',
        'noiDung': '$tenNguoiGui đã thích công thức "$tenCongThuc" của bạn',
        'maCongThuc': maCongThuc,
        'daDoc': false,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo thích: $e');
    }
  }

  // Tạo thông báo khi ai đó bình luận
  Future<void> taoThongBaoBinhLuan({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
    required String maCongThuc,
    required String tenCongThuc,
    required String noiDungBinhLuan,
  }) async {
    // Không gửi thông báo cho chính mình
    if (maNguoiNhan == maNguoiGui) return;

    try {
      final thongBaoRef = _db.child('thong_bao/$maNguoiNhan').push();
      
      await thongBaoRef.set({
        'ma': thongBaoRef.key,
        'maNguoiNhan': maNguoiNhan,
        'maNguoiGui': maNguoiGui,
        'loai': 'binh_luan',
        'tieuDe': 'Có bình luận mới',
        'noiDung': '$tenNguoiGui đã bình luận: "${noiDungBinhLuan.length > 50 ? '${noiDungBinhLuan.substring(0, 50)}...' : noiDungBinhLuan}"',
        'maCongThuc': maCongThuc,
        'daDoc': false,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo bình luận: $e');
    }
  }

  // Tạo thông báo khi ai đó theo dõi
  Future<void> taoThongBaoTheoDoi({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
  }) async {
    // Không gửi thông báo cho chính mình
    if (maNguoiNhan == maNguoiGui) return;

    try {
      final thongBaoRef = _db.child('thong_bao/$maNguoiNhan').push();
      
      await thongBaoRef.set({
        'ma': thongBaoRef.key,
        'maNguoiNhan': maNguoiNhan,
        'maNguoiGui': maNguoiGui,
        'loai': 'theo_doi',
        'tieuDe': 'Có người theo dõi bạn',
        'noiDung': '$tenNguoiGui đã bắt đầu theo dõi bạn',
        'daDoc': false,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo theo dõi: $e');
    }
  }

  // Tạo thông báo khi ai đó đánh giá
  Future<void> taoThongBaoDanhGia({
    required String maNguoiNhan,
    required String maNguoiGui,
    required String tenNguoiGui,
    required String maCongThuc,
    required String tenCongThuc,
    required double diemDanhGia,
  }) async {
    // Không gửi thông báo cho chính mình
    if (maNguoiNhan == maNguoiGui) return;

    try {
      final thongBaoRef = _db.child('thong_bao/$maNguoiNhan').push();
      
      await thongBaoRef.set({
        'ma': thongBaoRef.key,
        'maNguoiNhan': maNguoiNhan,
        'maNguoiGui': maNguoiGui,
        'loai': 'danh_gia',
        'tieuDe': 'Có đánh giá mới',
        'noiDung': '$tenNguoiGui đã đánh giá ${diemDanhGia.toStringAsFixed(1)} sao cho công thức "$tenCongThuc"',
        'maCongThuc': maCongThuc,
        'daDoc': false,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo đánh giá: $e');
    }
  }

  // Lấy danh sách thông báo
  Future<List<ThongBao>> layDanhSachThongBao(String uid) async {
    try {
      final snapshot = await _db.child('thong_bao/$uid').get();
      
      if (!snapshot.exists) return [];

      final List<ThongBao> danhSach = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        try {
          final thongBaoData = Map<String, dynamic>.from(entry.value);
          final thongBao = ThongBao.fromMap(thongBaoData);
          danhSach.add(thongBao);
        } catch (e) {
          debugPrint('Lỗi parse thông báo ${entry.key}: $e');
        }
      }

      // Sắp xếp theo thời gian mới nhất
      danhSach.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      
      return danhSach;
    } catch (e) {
      debugPrint('Lỗi lấy danh sách thông báo: $e');
      return [];
    }
  }

  // Lắng nghe thông báo real-time
  Stream<List<ThongBao>> langNgheThongBao(String uid) {
    return _db.child('thong_bao/$uid').onValue.map((event) {
      if (!event.snapshot.exists) return <ThongBao>[];

      final List<ThongBao> danhSach = [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        try {
          final thongBaoData = Map<String, dynamic>.from(entry.value);
          final thongBao = ThongBao.fromMap(thongBaoData);
          danhSach.add(thongBao);
        } catch (e) {
          debugPrint('Lỗi parse thông báo ${entry.key}: $e');
        }
      }

      // Sắp xếp theo thời gian mới nhất
      danhSach.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      
      return danhSach;
    });
  }

  // Đếm số thông báo chưa đọc
  Future<int> demThongBaoChuaDoc(String uid) async {
    try {
      final snapshot = await _db.child('thong_bao/$uid').get();
      
      if (!snapshot.exists) return 0;

      int count = 0;
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final thongBaoData = Map<String, dynamic>.from(entry.value);
        if (!(thongBaoData['daDoc'] ?? false)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint('Lỗi đếm thông báo chưa đọc: $e');
      return 0;
    }
  }

  // Stream đếm số thông báo chưa đọc
  Stream<int> demThongBaoChuaDocStream(String uid) {
    return _db.child('thong_bao/$uid').onValue.map((event) {
      if (!event.snapshot.exists) return 0;

      int count = 0;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final entry in data.entries) {
        final thongBaoData = Map<String, dynamic>.from(entry.value);
        if (!(thongBaoData['daDoc'] ?? false)) {
          count++;
        }
      }

      return count;
    });
  }

  // Đánh dấu đã đọc
  Future<void> danhDauDaDoc(String uid, String maThongBao) async {
    try {
      await _db.child('thong_bao/$uid/$maThongBao/daDoc').set(true);
    } catch (e) {
      debugPrint('Lỗi đánh dấu đã đọc: $e');
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> danhDauTatCaDaDoc(String uid) async {
    try {
      final snapshot = await _db.child('thong_bao/$uid').get();
      
      if (!snapshot.exists) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final Map<String, dynamic> updates = {};

      for (final key in data.keys) {
        updates['$key/daDoc'] = true;
      }

      await _db.child('thong_bao/$uid').update(updates);
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả đã đọc: $e');
    }
  }

  // Tạo thông báo test
  Future<void> taoThongBaoTest(String uid) async {
    try {
      final thongBaoRef = _db.child('thong_bao/$uid').push();
      
      await thongBaoRef.set({
        'ma': thongBaoRef.key,
        'maNguoiNhan': uid,
        'maNguoiGui': 'system',
        'loai': 'test',
        'tieuDe': 'Thông báo test',
        'noiDung': 'Đây là thông báo test để kiểm tra hệ thống',
        'daDoc': false,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo test: $e');
    }
  }

  // Xóa tất cả thông báo
  Future<void> xoaTatCaThongBao(String uid) async {
    try {
      await _db.child('thong_bao/$uid').remove();
      debugPrint('Đã xóa tất cả thông báo cho user: $uid');
    } catch (e) {
      debugPrint('Lỗi xóa tất cả thông báo: $e');
      rethrow;
    }
  }
}
