import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an/mo_hinh/cong_thuc.dart';
import 'package:do_an/dich_vu/dich_vu_cong_thuc.dart';
import 'dart:developer' as developer;

class DichVuLuuCongThuc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DichVuCongThuc _dichVuCongThuc = DichVuCongThuc();

  // Lưu công thức
  Future<void> luuCongThuc(String uid, String maCongThuc) async {
    try {
      await _firestore
          .collection('cong_thuc_da_luu')
          .doc(uid)
          .collection('danh_sach')
          .doc(maCongThuc)
          .set({
        'maCongThuc': maCongThuc,
        'thoiGianLuu': FieldValue.serverTimestamp(),
      });
      
      developer.log('Đã lưu công thức: $maCongThuc cho user: $uid');
    } catch (e) {
      developer.log('Lỗi khi lưu công thức: $e');
      rethrow;
    }
  }

  // Hủy lưu công thức
  Future<void> huyLuuCongThuc(String uid, String maCongThuc) async {
    try {
      await _firestore
          .collection('cong_thuc_da_luu')
          .doc(uid)
          .collection('danh_sach')
          .doc(maCongThuc)
          .delete();
      
      developer.log('Đã hủy lưu công thức: $maCongThuc cho user: $uid');
    } catch (e) {
      developer.log('Lỗi khi hủy lưu công thức: $e');
      rethrow;
    }
  }

  // Kiểm tra xem công thức đã được lưu chưa
  Future<bool> kiemTraDaLuu(String uid, String maCongThuc) async {
    try {
      final doc = await _firestore
          .collection('cong_thuc_da_luu')
          .doc(uid)
          .collection('danh_sach')
          .doc(maCongThuc)
          .get();
      
      return doc.exists;
    } catch (e) {
      developer.log('Lỗi khi kiểm tra trạng thái lưu: $e');
      return false;
    }
  }

  // Lấy danh sách ID công thức đã lưu
  Future<List<String>> layDanhSachCongThucDaLuu(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('cong_thuc_da_luu')
          .doc(uid)
          .collection('danh_sach')
          .orderBy('thoiGianLuu', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách công thức đã lưu: $e');
      return [];
    }
  }

  // Lấy danh sách công thức đã lưu với thông tin chi tiết
  Future<List<CongThuc>> layDanhSachCongThucDaLuuChiTiet(String uid) async {
    try {
      final danhSachMa = await layDanhSachCongThucDaLuu(uid);
      final List<CongThuc> danhSachCongThuc = [];

      for (String maCongThuc in danhSachMa) {
        try {
          // Sử dụng method với trạng thái tym để có thông tin đầy đủ
          final congThuc = await _dichVuCongThuc.layCongThucTheoMaVoiTrangThaiTym(maCongThuc, uid);
          if (congThuc != null) {
            danhSachCongThuc.add(congThuc);
          }
        } catch (e) {
          developer.log('Lỗi khi lấy chi tiết công thức $maCongThuc: $e');
        }
      }

      return danhSachCongThuc;
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách công thức đã lưu chi tiết: $e');
      return [];
    }
  }

  // Đếm số lượng công thức đã lưu
  Future<int> demSoLuongCongThucDaLuu(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('cong_thuc_da_luu')
          .doc(uid)
          .collection('danh_sach')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      developer.log('Lỗi khi đếm số lượng công thức đã lưu: $e');
      return 0;
    }
  }

  // Stream để lắng nghe thay đổi danh sách công thức đã lưu
  Stream<List<String>> streamDanhSachCongThucDaLuu(String uid) {
    return _firestore
        .collection('cong_thuc_da_luu')
        .doc(uid)
        .collection('danh_sach')
        .orderBy('thoiGianLuu', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
