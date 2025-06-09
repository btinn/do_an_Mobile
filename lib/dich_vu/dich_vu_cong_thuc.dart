import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DichVuCongThuc {
  final _db = FirebaseDatabase.instance.ref();

  // Thêm công thức mới vào Firebase
  Future<bool> themCongThuc(CongThuc congThuc) async {
    try {
      // Tạo key mới cho công thức
      final congThucRef = _db.child('cong_thuc').push();
      final maCongThuc = congThucRef.key!;

      // Cập nhật mã công thức
      final congThucData = {
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
        'danhSachDanhGia': [],
      };

      await congThucRef.set(congThucData);

      // Cập nhật số lượng công thức của user
      await _capNhatSoLuongCongThucUser(congThuc.uid);

      debugPrint('Đã thêm công thức thành công: $maCongThuc');
      return true;
    } catch (e) {
      debugPrint('Lỗi khi thêm công thức: $e');
      return false;
    }
  }

  // Cập nhật số lượng công thức của user
  Future<void> _capNhatSoLuongCongThucUser(String uid) async {
    try {
      final userRef = _db.child('user').child(uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final soLuongHienTai = userData['soLuongCongThuc'] ?? 0;

        await userRef.update({
          'soLuongCongThuc': soLuongHienTai + 1,
        });
      } else {
        // Tạo mới nếu chưa có
        await userRef.set({
          'soLuongCongThuc': 1,
        });
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật số lượng công thức: $e');
    }
  }

  Future<List<CongThuc>> layDanhSachCongThuc(String uid) async {
    final congThucSnap = await _db.child('cong_thuc').get();
    final tymSnap = await _db.child('tym').get();

    if (!congThucSnap.exists) return [];

    final List<CongThuc> danhSach = [];

    for (final child in congThucSnap.children) {
      try {
        final data = child.value as Map?;
        if (data == null) continue;

        final maCongThuc = data['ma']?.toString() ?? '';
        if (maCongThuc.isEmpty) continue;

        final bool daTym = tymSnap.child(maCongThuc).hasChild(uid);

        final danhSachDanhGiaRaw = data['danhSachDanhGia'] ?? [];
        final danhSachDanhGia = danhSachDanhGiaRaw is List
            ? danhSachDanhGiaRaw
                .map((e) => (e as num?)?.toDouble() ?? 0.0)
                .toList()
            : <double>[];

        danhSach.add(
          CongThuc(
            ma: maCongThuc,
            tenMon: data['tenMon'] ?? '',
            hinhAnh: data['hinhAnh'] ?? '',
            loai: data['loai'] ?? '',
            thoiGianNau: data['thoiGianNau'] ?? 0,
            khauPhan: data['khauPhan'] ?? 0,
            diemDanhGia: (data['diemDanhGia'] ?? 0).toDouble(),
            luotThich: data['luotThich'] ?? 0,
            luotXem: data['luotXem'] ?? 0,
            nguyenLieu: List<String>.from(data['nguyenLieu'] ?? []),
            cachLam: List<String>.from(data['cachLam'] ?? []),
            tacGia: data['tacGia'] ?? '',
            anhTacGia: data['anhTacGia'] ?? '',
            uid: data['uid'] ?? '',
            daThich: daTym,
            danhSachDanhGia: danhSachDanhGia,
            danhSachBinhLuan: [],
          ),
        );
      } catch (e) {
        debugPrint('Lỗi khi chuyển đổi dữ liệu công thức: $e');
      }
    }

    return danhSach;
  }

  // Lấy danh sách công thức của một tác giả cụ thể
  Future<List<CongThuc>> layDanhSachCongThucCuaTacGia(
      String uidTacGia, String uidNguoiXem) async {
    try {
      final congThucSnap = await _db.child('cong_thuc').get();
      final tymSnap = await _db.child('tym').get();

      if (!congThucSnap.exists) return [];

      final List<CongThuc> danhSach = [];

      for (final child in congThucSnap.children) {
        try {
          final data = child.value as Map?;
          if (data == null) continue;

          // Chỉ lấy công thức của tác giả này
          if (data['uid'] != uidTacGia) continue;

          final maCongThuc = data['ma']?.toString() ?? '';
          if (maCongThuc.isEmpty) continue;

          final bool daTym = tymSnap.child(maCongThuc).hasChild(uidNguoiXem);

          danhSach.add(
            CongThuc(
              ma: maCongThuc,
              tenMon: data['tenMon'] ?? '',
              hinhAnh: data['hinhAnh'] ?? '',
              loai: data['loai'] ?? '',
              thoiGianNau: data['thoiGianNau'] ?? 0,
              khauPhan: data['khauPhan'] ?? 0,
              diemDanhGia: (data['diemDanhGia'] ?? 0).toDouble(),
              luotThich: data['luotThich'] ?? 0,
              luotXem: data['luotXem'] ?? 0,
              nguyenLieu: List<String>.from(data['nguyenLieu'] ?? []),
              cachLam: List<String>.from(data['cachLam'] ?? []),
              tacGia: data['tacGia'] ?? '',
              anhTacGia: data['anhTacGia'] ?? '',
              uid: data['uid'] ?? '',
              daThich: daTym,
              danhSachDanhGia: List<double>.from(
                (data['danhSachDanhGia'] ?? [])
                    .map((e) => (e as num).toDouble()),
              ),
              danhSachBinhLuan: [],
            ),
          );
        } catch (e) {
          debugPrint('Lỗi khi chuyển đổi dữ liệu công thức: $e');
        }
      }

      return danhSach;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách công thức của tác giả: $e');
      return [];
    }
  }

  Future<List<CongThuc>> layTatCaCongThucCoTrangThaiTym(String uid) async {
    final congThucSnap = await _db.child('cong_thuc').get();
    final tymSnap = await _db.child('tym').get();

    if (!congThucSnap.exists) return [];

    return congThucSnap.children
        .map((child) {
          final data = child.value as Map<dynamic, dynamic>?;
          if (data == null) return null;

          final ma = data['ma']?.toString() ?? '';
          final daTym = tymSnap.child(ma).hasChild(uid);

          return CongThuc(
            ma: ma,
            tenMon: data['tenMon'] ?? '',
            hinhAnh: data['hinhAnh'] ?? '',
            loai: data['loai'] ?? '',
            thoiGianNau: data['thoiGianNau'] ?? 0,
            khauPhan: data['khauPhan'] ?? 0,
            diemDanhGia: (data['diemDanhGia'] ?? 0).toDouble(),
            luotThich: data['luotThich'] ?? 0,
            luotXem: data['luotXem'] ?? 0,
            nguyenLieu: List<String>.from(data['nguyenLieu'] ?? []),
            cachLam: List<String>.from(data['cachLam'] ?? []),
            tacGia: data['tacGia'] ?? '',
            anhTacGia: data['anhDaiDien'] ?? '',
            uid: data['uid'] ?? '',
            daThich: daTym,
            danhSachDanhGia: List<double>.from(
              (data['danhSachDanhGia'] ?? []).map((e) => (e as num).toDouble()),
            ),
            danhSachBinhLuan: [],
          );
        })
        .whereType<CongThuc>()
        .toList();
  }

  // Xóa công thức
  Future<bool> xoaCongThuc(String maCongThuc, String uid) async {
    try {
      // Kiểm tra quyền sở hữu
      final congThucRef = _db.child('cong_thuc').child(maCongThuc);
      final snapshot = await congThucRef.get();

      if (!snapshot.exists) {
        debugPrint('Công thức không tồn tại');
        return false;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      if (data['uid'] != uid) {
        debugPrint('Không có quyền xóa công thức này');
        return false;
      }

      // Xóa ảnh nếu là ảnh đã upload (URL Firebase)
      final hinhAnh = data['hinhAnh'] as String? ?? '';
      if (hinhAnh.startsWith('https://firebasestorage.googleapis.com')) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(hinhAnh);
          await ref.delete();
          debugPrint('Đã xóa hình ảnh từ Firebase Storage');
        } catch (e) {
          debugPrint('Lỗi khi xóa hình ảnh: $e');
        }
      }

      // Xóa công thức
      await congThucRef.remove();

      // Xóa các đánh giá liên quan
      final danhGiaRef = _db.child('danh_gia').child(maCongThuc);
      await danhGiaRef.remove();

      // Xóa các tym liên quan
      final tymRef = _db.child('tym').child(maCongThuc);
      await tymRef.remove();

      // Cập nhật số lượng công thức của user
      await _giamSoLuongCongThucUser(uid);

      debugPrint('Đã xóa công thức thành công: $maCongThuc');
      return true;
    } catch (e) {
      debugPrint('Lỗi khi xóa công thức: $e');
      return false;
    }
  }

  // Giảm số lượng công thức của user
  Future<void> _giamSoLuongCongThucUser(String uid) async {
    try {
      final userRef = _db.child('user').child(uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final soLuongHienTai = userData['soLuongCongThuc'] ?? 0;
        final soLuongMoi = soLuongHienTai > 0 ? soLuongHienTai - 1 : 0;

        await userRef.update({
          'soLuongCongThuc': soLuongMoi,
        });
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật số lượng công thức: $e');
    }
  }

  // Lấy công thức theo mã
  Future<CongThuc?> layCongThucTheoMa(String maCongThuc) async {
    try {
      final snapshot = await _db.child('cong_thuc').child(maCongThuc).get();
      
      if (!snapshot.exists) {
        debugPrint('Công thức không tồn tại: $maCongThuc');
        return null;
      }

      final data = snapshot.value as Map?;
      if (data == null) return null;

      // Kiểm tra trạng thái tym (có thể không cần thiết cho method này)
      final tymSnap = await _db.child('tym').child(maCongThuc).get();
      
      final danhSachDanhGiaRaw = data['danhSachDanhGia'] ?? [];
      final danhSachDanhGia = danhSachDanhGiaRaw is List
          ? danhSachDanhGiaRaw
              .map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList()
          : <double>[];

      return CongThuc(
        ma: maCongThuc,
        tenMon: data['tenMon'] ?? '',
        hinhAnh: data['hinhAnh'] ?? '',
        loai: data['loai'] ?? '',
        thoiGianNau: data['thoiGianNau'] ?? 0,
        khauPhan: data['khauPhan'] ?? 0,
        diemDanhGia: (data['diemDanhGia'] ?? 0).toDouble(),
        luotThich: data['luotThich'] ?? 0,
        luotXem: data['luotXem'] ?? 0,
        nguyenLieu: List<String>.from(data['nguyenLieu'] ?? []),
        cachLam: List<String>.from(data['cachLam'] ?? []),
        tacGia: data['tacGia'] ?? '',
        anhTacGia: data['anhTacGia'] ?? '',
        uid: data['uid'] ?? '',
        daThich: false, // Sẽ được cập nhật khi cần
        danhSachDanhGia: danhSachDanhGia,
        danhSachBinhLuan: [],
      );
    } catch (e) {
      debugPrint('Lỗi khi lấy công thức theo mã: $e');
      return null;
    }
  }

  // Lấy công thức theo mã với trạng thái tym của user
  Future<CongThuc?> layCongThucTheoMaVoiTrangThaiTym(String maCongThuc, String uid) async {
    try {
      final congThuc = await layCongThucTheoMa(maCongThuc);
      if (congThuc == null) return null;

      // Kiểm tra trạng thái tym
      final tymSnap = await _db.child('tym').child(maCongThuc).get();
      final daTym = tymSnap.hasChild(uid);

      return CongThuc(
        ma: congThuc.ma,
        tenMon: congThuc.tenMon,
        hinhAnh: congThuc.hinhAnh,
        loai: congThuc.loai,
        thoiGianNau: congThuc.thoiGianNau,
        khauPhan: congThuc.khauPhan,
        diemDanhGia: congThuc.diemDanhGia,
        luotThich: congThuc.luotThich,
        luotXem: congThuc.luotXem,
        nguyenLieu: congThuc.nguyenLieu,
        cachLam: congThuc.cachLam,
        tacGia: congThuc.tacGia,
        anhTacGia: congThuc.anhTacGia,
        uid: congThuc.uid,
        daThich: daTym,
        danhSachDanhGia: congThuc.danhSachDanhGia,
        danhSachBinhLuan: congThuc.danhSachBinhLuan,
      );
    } catch (e) {
      debugPrint('Lỗi khi lấy công thức với trạng thái tym: $e');
      return null;
    }
  }
}
