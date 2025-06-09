import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:flutter/foundation.dart';

class DichVuCongThuc {
  final _db = FirebaseDatabase.instance.ref();
  final DichVuThongBao _dichVuThongBao = DichVuThongBao();

  // Thích công thức
  Future<bool> thichCongThuc(String maCongThuc, String uid) async {
    try {
      // Thêm vào danh sách yêu thích
      await _db.child('tym/$maCongThuc/$uid').set(true);
      
      // Lấy thông tin công thức để gửi thông báo
      final congThucSnapshot = await _db.child('cong_thuc/$maCongThuc').get();
      if (congThucSnapshot.exists) {
        final congThucData = Map<String, dynamic>.from(congThucSnapshot.value as Map);
        final tacGiaUid = congThucData['uid'] as String;
        final tenCongThuc = congThucData['tenMon'] as String;
        
        // Lấy thông tin người thích
        final nguoiThichSnapshot = await _db.child('auth_users/$uid').get();
        if (nguoiThichSnapshot.exists) {
          final nguoiThichData = Map<String, dynamic>.from(nguoiThichSnapshot.value as Map);
          final tenNguoiThich = nguoiThichData['displayName'] as String? ?? 'Người dùng';
          
          // Gửi thông báo cho tác giả
          await _dichVuThongBao.taoThongBaoThich(
            maNguoiNhan: tacGiaUid,
            maNguoiGui: uid,
            tenNguoiGui: tenNguoiThich,
            maCongThuc: maCongThuc,
            tenCongThuc: tenCongThuc,
          );
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Lỗi khi thích công thức: $e');
      return false;
    }
  }

  // Bỏ thích công thức
  Future<bool> boThichCongThuc(String maCongThuc, String uid) async {
    try {
      await _db.child('tym/$maCongThuc/$uid').remove();
      return true;
    } catch (e) {
      debugPrint('Lỗi khi bỏ thích công thức: $e');
      return false;
    }
  }

  // Đánh giá công thức
  Future<bool> danhGiaCongThuc(String maCongThuc, String uid, double diem, String tenNguoiDanhGia) async {
    try {
      // Lưu đánh giá
      await _db.child('danh_gia/$maCongThuc/$uid').set(diem);
      
      // Lấy thông tin công thức để gửi thông báo
      final congThucSnapshot = await _db.child('cong_thuc/$maCongThuc').get();
      if (congThucSnapshot.exists) {
        final congThucData = Map<String, dynamic>.from(congThucSnapshot.value as Map);
        final tacGiaUid = congThucData['uid'] as String;
        final tenCongThuc = congThucData['tenMon'] as String;
        
        // Gửi thông báo cho tác giả
        await _dichVuThongBao.taoThongBaoDanhGia(
          maNguoiNhan: tacGiaUid,
          maNguoiGui: uid,
          tenNguoiGui: tenNguoiDanhGia,
          maCongThuc: maCongThuc,
          tenCongThuc: tenCongThuc,
          diemDanhGia: diem,
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Lỗi khi đánh giá công thức: $e');
      return false;
    }
  }

  // Lấy danh sách công thức
  Future<List<CongThuc>> layDanhSachCongThuc(String uid) async {
    try {
      final snapshot = await _db.child('cong_thuc').get();
      
      if (!snapshot.exists) return [];

      final List<CongThuc> danhSach = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        try {
          final congThucData = Map<String, dynamic>.from(entry.value);
          
          // Kiểm tra trạng thái yêu thích
          bool daThich = false;
          if (uid.isNotEmpty) {
            final tymSnapshot = await _db.child('tym/${entry.key}/$uid').get();
            daThich = tymSnapshot.exists;
          }

          // Đếm số lượt thích
          final tymSnapshot = await _db.child('tym/${entry.key}').get();
          int luotThich = 0;
          if (tymSnapshot.exists) {
            luotThich = tymSnapshot.children.length;
          }

          final congThuc = CongThuc.fromMap(congThucData, ma: entry.key, daThich: daThich);
          congThuc.daThich = daThich;
          congThuc.luotThich = luotThich;
          
          danhSach.add(congThuc);
        } catch (e) {
          debugPrint('Lỗi khi parse công thức ${entry.key}: $e');
        }
      }

      return danhSach;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách công thức: $e');
      return [];
    }
  }

  // Lấy công thức theo mã với trạng thái tym
  Future<CongThuc?> layCongThucTheoMaVoiTrangThaiTym(String maCongThuc, String uid) async {
    try {
      final snapshot = await _db.child('cong_thuc/$maCongThuc').get();
      
      if (!snapshot.exists) return null;

      final congThucData = Map<String, dynamic>.from(snapshot.value as Map);
      
      // Kiểm tra trạng thái yêu thích
      bool daThich = false;
      if (uid.isNotEmpty) {
        final tymSnapshot = await _db.child('tym/$maCongThuc/$uid').get();
        daThich = tymSnapshot.exists;
      }

      // Đếm số lượt thích
      final tymSnapshot = await _db.child('tym/$maCongThuc').get();
      int luotThich = 0;
      if (tymSnapshot.exists) {
        luotThich = tymSnapshot.children.length;
      }

      final congThuc = CongThuc.fromMap(congThucData, ma: maCongThuc, daThich: daThich);
      congThuc.daThich = daThich;
      congThuc.luotThich = luotThich;
      
      return congThuc;
    } catch (e) {
      debugPrint('Lỗi khi lấy công thức theo mã: $e');
      return null;
    }
  }

  // Lấy danh sách công thức của tác giả
  Future<List<CongThuc>> layDanhSachCongThucCuaTacGia(String uidTacGia, String uidNguoiXem) async {
    try {
      final snapshot = await _db.child('cong_thuc').get();
      
      if (!snapshot.exists) return [];

      final List<CongThuc> danhSach = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        try {
          final congThucData = Map<String, dynamic>.from(entry.value);
          
          // Chỉ lấy công thức của tác giả này
          if (congThucData['uid'] != uidTacGia) continue;
          
          // Kiểm tra trạng thái yêu thích
          bool daThich = false;
          if (uidNguoiXem.isNotEmpty) {
            final tymSnapshot = await _db.child('tym/${entry.key}/$uidNguoiXem').get();
            daThich = tymSnapshot.exists;
          }

          // Đếm số lượt thích
          final tymSnapshot = await _db.child('tym/${entry.key}').get();
          int luotThich = 0;
          if (tymSnapshot.exists) {
            luotThich = tymSnapshot.children.length;
          }

          final congThuc = CongThuc.fromMap(congThucData, ma: entry.key, daThich: daThich);
          congThuc.daThich = daThich;
          congThuc.luotThich = luotThich;
          
          danhSach.add(congThuc);
        } catch (e) {
          debugPrint('Lỗi khi parse công thức ${entry.key}: $e');
        }
      }

      return danhSach;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách công thức của tác giả: $e');
      return [];
    }
  }

  // Xóa công thức
  Future<bool> xoaCongThuc(String maCongThuc, String uid) async {
    try {
      // Kiểm tra quyền sở hữu
      final snapshot = await _db.child('cong_thuc/$maCongThuc').get();
      if (!snapshot.exists) return false;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      if (data['uid'] != uid) return false;

      // Xóa công thức
      await _db.child('cong_thuc/$maCongThuc').remove();
      
      // Xóa các dữ liệu liên quan
      await _db.child('tym/$maCongThuc').remove();
      await _db.child('danh_gia/$maCongThuc').remove();
      await _db.child('binh_luan/$maCongThuc').remove();
      
      return true;
    } catch (e) {
      debugPrint('Lỗi khi xóa công thức: $e');
      return false;
    }
  }

  // Tăng lượt xem
  Future<void> tangLuotXem(String maCongThuc) async {
    try {
      final snapshot = await _db.child('cong_thuc/$maCongThuc/luotXem').get();
      int luotXemHienTai = 0;
      
      if (snapshot.exists) {
        luotXemHienTai = snapshot.value as int? ?? 0;
      }
      
      await _db.child('cong_thuc/$maCongThuc/luotXem').set(luotXemHienTai + 1);
    } catch (e) {
      debugPrint('Lỗi khi tăng lượt xem: $e');
    }
  }

  // Thêm method này vào class DichVuCongThuc
  Future<bool> themCongThuc(CongThuc congThuc) async {
    try {
      final ref = _db.child('cong_thuc').push();
      final maCongThuc = ref.key!;
      
      final data = {
        'ma': maCongThuc,
        'tenMon': congThuc.tenMon,
        'hinhAnh': congThuc.hinhAnh,
        'loai': congThuc.loai,
        'thoiGianNau': congThuc.thoiGianNau,
        'khauPhan': congThuc.khauPhan,
        'diemDanhGia': congThuc.diemDanhGia,
        'luotThich': 0,
        'luotXem': 0,
        'nguyenLieu': congThuc.nguyenLieu,
        'cachLam': congThuc.cachLam,
        'tacGia': congThuc.tacGia,
        'anhTacGia': congThuc.anhTacGia,
        'uid': congThuc.uid,
      };
      
      await ref.set(data);
      return true;
    } catch (e) {
      debugPrint('Lỗi khi thêm công thức: $e');
      return false;
    }
  }
}
