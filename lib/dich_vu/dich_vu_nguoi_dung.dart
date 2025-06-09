import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/dich_vu/dich_vu_thong_bao.dart';
import 'package:flutter/foundation.dart';

class DichVuNguoiDung {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DichVuThongBao _dichVuThongBao = DichVuThongBao();

  /// Lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>> layThongTinNguoiDung(String uid) async {
    try {
      // Lấy thông tin từ auth_users trong Realtime Database
      final authUserRef = _database.ref('auth_users/$uid');
      final authUserSnapshot = await authUserRef.get();

      String displayName = 'Người dùng';
      String photoURL = 'assets/images/avatar_default.jpg';

      if (authUserSnapshot.exists) {
        final authUserData = Map<String, dynamic>.from(authUserSnapshot.value as Map);
        displayName = authUserData['displayName'] ?? displayName;
        photoURL = authUserData['photoURL'] ?? photoURL;
      }

      // Lấy thông tin từ Firestore
      final userDoc = await _firestore.collection('user').doc(uid).get();
      
      // Đếm số lượng công thức
      final congThucRef = _database.ref('cong_thuc');
      final congThucSnapshot = await congThucRef.get();
      
      int soLuongCongThuc = 0;
      if (congThucSnapshot.exists) {
        final congThucData = Map<String, dynamic>.from(congThucSnapshot.value as Map);
        soLuongCongThuc = congThucData.values
            .where((congThuc) => congThuc['uid'] == uid)
            .length;
      }

      // Lấy danh sách người theo dõi và đang theo dõi
      List<dynamic> soLuongNguoiTheoDoi = [];
      List<dynamic> soLuongDangTheoDoi = [];
      
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        soLuongNguoiTheoDoi = userData['soLuongNguoiTheoDoi'] ?? [];
        soLuongDangTheoDoi = userData['soLuongDangTheoDoi'] ?? [];
      }

      return {
        'displayName': displayName,
        'photoURL': photoURL,
        'username': '@${displayName.toLowerCase().replaceAll(' ', '')}',
        'recipes': soLuongCongThuc,
        'followers': soLuongNguoiTheoDoi.length,
        'following': soLuongDangTheoDoi.length,
        'followersList': soLuongNguoiTheoDoi,
        'followingList': soLuongDangTheoDoi,
      };
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin người dùng: $e');
      return {
        'displayName': 'Người dùng',
        'photoURL': 'assets/images/avatar_default.jpg',
        'username': '@unknown',
        'recipes': 0,
        'followers': 0,
        'following': 0,
        'followersList': [],
        'followingList': [],
      };
    }
  }

  /// Kiểm tra xem người dùng A có đang theo dõi người dùng B không
  Future<bool> kiemTraDangTheoDoi(String uidNguoiDung, String uidNguoiTheoDoi) async {
    try {
      final userDoc = await _firestore.collection('user').doc(uidNguoiTheoDoi).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final soLuongDangTheoDoi = userData['soLuongDangTheoDoi'] ?? [];
        return soLuongDangTheoDoi.contains(uidNguoiDung);
      }
      
      return false;
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra theo dõi: $e');
      return false;
    }
  }

  /// Theo dõi người dùng
  Future<bool> theoDoi(String uidNguoiDuocTheoDoi, String uidNguoiTheoDoi) async {
    try {
      // Thêm người theo dõi vào danh sách người theo dõi của người được theo dõi
      await _firestore.collection('user').doc(uidNguoiDuocTheoDoi).update({
        'soLuongNguoiTheoDoi': FieldValue.arrayUnion([uidNguoiTheoDoi])
      });
      
      // Thêm người được theo dõi vào danh sách đang theo dõi của người theo dõi
      await _firestore.collection('user').doc(uidNguoiTheoDoi).update({
        'soLuongDangTheoDoi': FieldValue.arrayUnion([uidNguoiDuocTheoDoi])
      });
      
      // Lấy thông tin người theo dõi để gửi thông báo
      final nguoiTheoDoiSnapshot = await _database.ref('auth_users/$uidNguoiTheoDoi').get();
      if (nguoiTheoDoiSnapshot.exists) {
        final nguoiTheoDoiData = Map<String, dynamic>.from(nguoiTheoDoiSnapshot.value as Map);
        final tenNguoiTheoDoi = nguoiTheoDoiData['displayName'] as String? ?? 'Người dùng';
        final anhDaiDienNguoiTheoDoi = nguoiTheoDoiData['photoURL'] as String?;
        
        // Gửi thông báo cho người được theo dõi
        await _dichVuThongBao.taoThongBaoTheoDoi(
          maNguoiNhan: uidNguoiDuocTheoDoi,
          maNguoiGui: uidNguoiTheoDoi,
          tenNguoiGui: tenNguoiTheoDoi,
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Lỗi khi theo dõi người dùng: $e');
      return false;
    }
  }

  /// Hủy theo dõi người dùng
  Future<bool> huyTheoDoi(String uidNguoiDuocTheoDoi, String uidNguoiTheoDoi) async {
    try {
      // Xóa người theo dõi khỏi danh sách người theo dõi của người được theo dõi
      await _firestore.collection('user').doc(uidNguoiDuocTheoDoi).update({
        'soLuongNguoiTheoDoi': FieldValue.arrayRemove([uidNguoiTheoDoi])
      });
      
      // Xóa người được theo dõi khỏi danh sách đang theo dõi của người theo dõi
      await _firestore.collection('user').doc(uidNguoiTheoDoi).update({
        'soLuongDangTheoDoi': FieldValue.arrayRemove([uidNguoiDuocTheoDoi])
      });
      
      return true;
    } catch (e) {
      debugPrint('Lỗi khi hủy theo dõi người dùng: $e');
      return false;
    }
  }

  /// Khởi tạo người dùng mới trong Firestore
  Future<void> khoiTaoNguoiDung(String uid, String hoTen, String email, String anhDaiDien) async {
    try {
      // Kiểm tra xem người dùng đã tồn tại chưa
      final userDoc = await _firestore.collection('user').doc(uid).get();
      
      if (!userDoc.exists) {
        // Tạo document mới cho người dùng
        await _firestore.collection('user').doc(uid).set({
          'hoTen': hoTen,
          'email': email,
          'anhDaiDien': anhDaiDien,
          'soLuongNguoiTheoDoi': [],
          'soLuongDangTheoDoi': [],
          'soLuongCongThuc': 0,
          'ngaySinh': '',
          'gioiTinh': '',
          'diaChi': '',
          'soDienThoai': '',
          'moTa': '',
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo người dùng: $e');
    }
  }
}
