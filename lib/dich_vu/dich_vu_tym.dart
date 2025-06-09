import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DichVuTym with ChangeNotifier {
  final _db = FirebaseDatabase.instance.ref();

  final Map<String, bool> _trangThaiTym = {};

  bool daTym(String maCongThuc) => _trangThaiTym[maCongThuc] ?? false;

  Future<void> taiTrangThaiTym(String maCongThuc, String uid) async {
    final snap = await _db.child('tym/$maCongThuc/$uid').get();
    _trangThaiTym[maCongThuc] = snap.exists;
    notifyListeners();
  }

  Future<void> toggleTym(String maCongThuc, String uid) async {
    // Cập nhật UI ngay lập tức
    final hienTai = _trangThaiTym[maCongThuc] ?? false;
    _trangThaiTym[maCongThuc] = !hienTai;
    notifyListeners();

    // Sau đó cập nhật Firebase
    try {
      final ref = _db.child('tym/$maCongThuc/$uid');
      if (hienTai) {
        await ref.remove();
      } else {
        await ref.set(true);
      }
    } catch (e) {
      // Nếu có lỗi, hoàn tác thay đổi
      _trangThaiTym[maCongThuc] = hienTai;
      notifyListeners();
      debugPrint('Lỗi cập nhật tym: $e');
    }
  }

  Future<bool> kiemTraDaTym(String maCongThuc, String uid) async {
    final data = await _db.child('tym/$maCongThuc/$uid').get();
    return data.exists;
  }

  Future<int> demSoLuongTym(String maCongThuc) async {
    final data = await _db.child('tym/$maCongThuc').get();
    return data.exists ? data.children.length : 0;
  }

  Future<void> capNhatTym(String maCongThuc, String uid, bool daThich) async {
    final ref = _db.child('tym/$maCongThuc/$uid');

    if (daThich) {
      await ref.set(true);
    } else {
      await ref.remove();
    }

    _trangThaiTym[maCongThuc] = daThich;
    notifyListeners();
  }

  Future<void> dongBoTrangThai(String maCongThuc, String uid) async {
    try {
      final snap = await _db.child('tym/$maCongThuc/$uid').get();
      final trangThaiThucTe = snap.exists;
      
      if (_trangThaiTym[maCongThuc] != trangThaiThucTe) {
        _trangThaiTym[maCongThuc] = trangThaiThucTe;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi đồng bộ trạng thái tym: $e');
    }
  }
}
