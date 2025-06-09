import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/binh_luan.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class DichVuBinhLuan {
  final _db = FirebaseDatabase.instance.ref();
  final DichVuThongBao _dichVuThongBao = DichVuThongBao();

  // Thêm bình luận mới
  Future<bool> themBinhLuan({
    required String maCongThuc,
    required String noiDung,
    required String uid,
    required String hoTen,
    required String anhDaiDien,
  }) async {
    try {
      // Tạo key mới cho bình luận
      final binhLuanRef = _db.child('binh_luan').child(maCongThuc).push();
      final maBinhLuan = binhLuanRef.key!;

      final binhLuanData = {
        'ma': maBinhLuan,
        'maCongThuc': maCongThuc,
        'noiDung': noiDung,
        'uid': uid,
        'hoTen': hoTen,
        'anhDaiDien': anhDaiDien,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
      };

      await binhLuanRef.set(binhLuanData);

      // Cập nhật số lượng bình luận trong công thức
      await _capNhatSoLuongBinhLuan(maCongThuc);

      // Lấy thông tin công thức để gửi thông báo
      final congThucSnapshot = await _db.child('cong_thuc/$maCongThuc').get();
      if (congThucSnapshot.exists) {
        final congThucData = Map<String, dynamic>.from(congThucSnapshot.value as Map);
        final tacGiaUid = congThucData['uid'] as String;
        final tenCongThuc = congThucData['tenMon'] as String;
        
        // Gửi thông báo cho tác giả công thức
        await _dichVuThongBao.taoThongBaoBinhLuan(
          maNguoiNhan: tacGiaUid,
          maNguoiGui: uid,
          tenNguoiGui: hoTen,
          maCongThuc: maCongThuc,
          tenCongThuc: tenCongThuc,
          noiDungBinhLuan: noiDung,
        );
      }

      developer.log('Đã thêm bình luận thành công: $maBinhLuan');
      return true;
    } catch (e) {
      developer.log('Lỗi khi thêm bình luận: $e');
      return false;
    }
  }

  // Lấy danh sách bình luận theo mã công thức
  Stream<List<BinhLuan>> layDanhSachBinhLuan(String maCongThuc) {
    return _db
        .child('binh_luan')
        .child(maCongThuc)
        .orderByChild('thoiGian')
        .onValue
        .map((event) {
      final List<BinhLuan> danhSach = [];
      
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          try {
            final binhLuanData = Map<String, dynamic>.from(value);
            
            danhSach.add(BinhLuan(
              ma: binhLuanData['ma'] ?? key,
              noiDung: binhLuanData['noiDung'] ?? '',
              thoiGian: DateTime.fromMillisecondsSinceEpoch(
                binhLuanData['thoiGian'] ?? DateTime.now().millisecondsSinceEpoch,
              ),
              tacGia: binhLuanData['hoTen'] ?? 'Người dùng ẩn danh',
              anhTacGia: binhLuanData['anhDaiDien'] ?? 'assets/images/avatar_default.jpg',
            ));
          } catch (e) {
            developer.log('Lỗi khi parse bình luận: $e');
          }
        });
      }
      
      // Sắp xếp theo thời gian mới nhất
      danhSach.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      return danhSach;
    });
  }

  // Cập nhật số lượng bình luận
  Future<void> _capNhatSoLuongBinhLuan(String maCongThuc) async {
    try {
      final snapshot = await _db.child('binh_luan').child(maCongThuc).get();
      
      int soLuong = 0;
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        soLuong = data.length;
      }

      await _db.child('cong_thuc').child(maCongThuc).update({
        'soLuongBinhLuan': soLuong,
      });
    } catch (e) {
      developer.log('Lỗi cập nhật số lượng bình luận: $e');
    }
  }

  // Xóa bình luận (chỉ chủ sở hữu hoặc admin)
  Future<bool> xoaBinhLuan({
    required String maCongThuc,
    required String maBinhLuan,
    required String uid,
  }) async {
    try {
      // Kiểm tra quyền sở hữu
      final snapshot = await _db
          .child('binh_luan')
          .child(maCongThuc)
          .child(maBinhLuan)
          .get();

      if (!snapshot.exists) {
        developer.log('Bình luận không tồn tại');
        return false;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      if (data['uid'] != uid) {
        developer.log('Không có quyền xóa bình luận này');
        return false;
      }

      // Xóa bình luận
      await _db
          .child('binh_luan')
          .child(maCongThuc)
          .child(maBinhLuan)
          .remove();

      // Cập nhật số lượng bình luận
      await _capNhatSoLuongBinhLuan(maCongThuc);

      developer.log('Đã xóa bình luận thành công: $maBinhLuan');
      return true;
    } catch (e) {
      developer.log('Lỗi khi xóa bình luận: $e');
      return false;
    }
  }

  // Đếm số lượng bình luận
  Future<int> demSoLuongBinhLuan(String maCongThuc) async {
    try {
      final snapshot = await _db.child('binh_luan').child(maCongThuc).get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.length;
      }
      
      return 0;
    } catch (e) {
      developer.log('Lỗi khi đếm bình luận: $e');
      return 0;
    }
  }
}
