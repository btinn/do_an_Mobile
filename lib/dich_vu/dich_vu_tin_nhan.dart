import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';
import 'package:do_an/mo_hinh/story.dart';
import 'package:do_an/mo_hinh/cuoc_tro_chuyen_tom_tat.dart';
import 'package:flutter/foundation.dart';

class DichVuTinNhan {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Tạo ID cuộc trò chuyện từ 2 user ID
  String taoMaCuocTroChuyenId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Gửi tin nhắn real-time
  Future<bool> guiTinNhan({
    required String maNguoiGui,
    required String tenNguoiGui,
    required String anhNguoiGui,
    required String maNguoiNhan,
    required String tenNguoiNhan,
    required String anhNguoiNhan,
    required String noiDung,
    String loai = 'text',
    String? urlHinhAnh,
    String? maCongThuc,
  }) async {
    try {
      final cuocTroChuyenId = taoMaCuocTroChuyenId(maNguoiGui, maNguoiNhan);
      final tinNhanId = DateTime.now().millisecondsSinceEpoch.toString();

      final tinNhan = {
        'ma': tinNhanId,
        'maNguoiGui': maNguoiGui,
        'tenNguoiGui': tenNguoiGui,
        'anhNguoiGui': anhNguoiGui,
        'maNguoiNhan': maNguoiNhan,
        'tenNguoiNhan': tenNguoiNhan,
        'anhNguoiNhan': anhNguoiNhan,
        'noiDung': noiDung,
        'loai': loai,
        'thoiGian': DateTime.now().millisecondsSinceEpoch,
        'daDoc': false,
        'urlHinhAnh': urlHinhAnh,
        'maCongThuc': maCongThuc,
      };

      // Lưu tin nhắn vào Firebase
      await _database
          .child('tin_nhan')
          .child(cuocTroChuyenId)
          .child(tinNhanId)
          .set(tinNhan);

      // Cập nhật cuộc trò chuyện tóm tắt cho cả hai người
      await _capNhatCuocTroChuyenTomTat(cuocTroChuyenId, tinNhan);

      return true;
    } catch (e) {
      debugPrint('Lỗi gửi tin nhắn: $e');
      return false;
    }
  }

  // Cập nhật cuộc trò chuyện tóm tắt
  Future<void> _capNhatCuocTroChuyenTomTat(
      String cuocTroChuyenId, Map<String, dynamic> tinNhan) async {
    final cuocTroChuyenTomTat = {
      'tinNhanCuoi': tinNhan['noiDung'],
      'loaiTinNhanCuoi': tinNhan['loai'],
      'thoiGianCuoi': tinNhan['thoiGian'],
      'maNguoiGuiCuoi': tinNhan['maNguoiGui'],
    };

    // Cập nhật cho người gửi
    await _database
        .child('cuoc_tro_chuyen')
        .child(tinNhan['maNguoiGui'])
        .child(cuocTroChuyenId)
        .update({
      ...cuocTroChuyenTomTat,
      'maNguoiKhac': tinNhan['maNguoiNhan'],
      'tenNguoiKhac': tinNhan['tenNguoiNhan'],
      'anhNguoiKhac': tinNhan['anhNguoiNhan'],
      'soTinNhanChuaDoc': 0, // Người gửi không có tin nhắn chưa đọc
    });

    // Cập nhật cho người nhận
    await _database
        .child('cuoc_tro_chuyen')
        .child(tinNhan['maNguoiNhan'])
        .child(cuocTroChuyenId)
        .update({
      ...cuocTroChuyenTomTat,
      'maNguoiKhac': tinNhan['maNguoiGui'],
      'tenNguoiKhac': tinNhan['tenNguoiGui'],
      'anhNguoiKhac': tinNhan['anhNguoiGui'],
    });

    // Tăng số tin nhắn chưa đọc cho người nhận
    await _tangSoTinNhanChuaDoc(tinNhan['maNguoiNhan'], cuocTroChuyenId);
  }

  // Tăng số tin nhắn chưa đọc
  Future<void> _tangSoTinNhanChuaDoc(
      String maNguoiDung, String cuocTroChuyenId) async {
    final snapshot = await _database
        .child('cuoc_tro_chuyen')
        .child(maNguoiDung)
        .child(cuocTroChuyenId)
        .child('soTinNhanChuaDoc')
        .get();
    final soHienTai = snapshot.exists ? (snapshot.value as int? ?? 0) : 0;
    await _database
        .child('cuoc_tro_chuyen')
        .child(maNguoiDung)
        .child(cuocTroChuyenId)
        .update({
      'soTinNhanChuaDoc': soHienTai + 1,
    });
  }

  // Lấy danh sách cuộc trò chuyện tóm tắt
  // Future<List<CuocTroChuyenTomTat>> layDanhSachCuocTroChuyenTomTat(
  //     String maNguoiDung) async {
  //   // Trả về dữ liệu từ Firebase
  //   final snapshot = await _database.child('cuoc_tro_chuyen').child(maNguoiDung).get();
  //   final List<CuocTroChuyenTomTat> danhSachCuocTroChuyen = [];
  //
  //   if (snapshot.exists) {
  //     final data = Map<String, dynamic>.from(snapshot.value as Map);
  //     data.forEach((key, value) {
  //       final cuocTroChuyenData = Map<String, dynamic>.from(value);
  //       danhSachCuocTroChuyen.add(CuocTroChuyenTomTat(
  //         maNguoiKhac: cuocTroChuyenData['maNguoiKhac'],
  //         tenNguoiKhac: cuocTroChuyenData['tenNguoiKhac'],
  //         anhNguoiKhac: cuocTroChuyenData['anhNguoiKhac'],
  //         tinNhanCuoi: cuocTroChuyenData['tinNhanCuoi'],
  //         loaiTinNhanCuoi: cuocTroChuyenData['loaiTinNhanCuoi'],
  //         thoiGianCuoi: DateTime.fromMillisecondsSinceEpoch(cuocTroChuyenData['thoiGianCuoi']),
  //         soTinNhanChuaDoc: cuocTroChuyenData['soTinNhanChuaDoc'] ?? 0,
  //         dangOnline: cuocTroChuyenData['dangOnline'] ?? false,
  //       ));
  //     });
  //   }
  //
  //   return danhSachCuocTroChuyen;
  // }

  // Lắng nghe cuộc trò chuyện tóm tắt real-time
  Stream<List<CuocTroChuyenTomTat>> langNgheCuocTroChuyenTomTat(
      String maNguoiDung) {
    return _database.child('cuoc_tro_chuyen').child(maNguoiDung).onValue.map((event) {
      final List<CuocTroChuyenTomTat> danhSachCuocTroChuyen = [];

      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final cuocTroChuyenData = Map<String, dynamic>.from(value);
          danhSachCuocTroChuyen.add(CuocTroChuyenTomTat(
            maNguoiKhac: cuocTroChuyenData['maNguoiKhac'] ?? '',
            tenNguoiKhac: cuocTroChuyenData['tenNguoiKhac'] ?? '',
            anhNguoiKhac: cuocTroChuyenData['anhNguoiKhac'] ?? '',
            tinNhanCuoi: cuocTroChuyenData['tinNhanCuoi'] ?? '',
            loaiTinNhanCuoi: cuocTroChuyenData['loaiTinNhanCuoi'] ?? 'text',
            thoiGianCuoi: DateTime.fromMillisecondsSinceEpoch(cuocTroChuyenData['thoiGianCuoi'] ?? 0),
            soTinNhanChuaDoc: cuocTroChuyenData['soTinNhanChuaDoc'] ?? 0,
            dangOnline: cuocTroChuyenData['dangOnline'] ?? false,
          ));
        });
      }

      // Sắp xếp theo thời gian mới nhất
      danhSachCuocTroChuyen.sort((a, b) => b.thoiGianCuoi.compareTo(a.thoiGianCuoi));
      return danhSachCuocTroChuyen;
    });
  }

  // Lấy tin nhắn trong cuộc trò chuyện
  // Future<List<TinNhan>> layTinNhanTrongCuocTroChuyenId(
  //     String cuocTroChuyenId) async {
  //   final snapshot = await _database.child('tin_nhan').child(cuocTroChuyenId).get();
  //   final List<TinNhan> danhSachTinNhan = [];
  //
  //   if (snapshot.exists) {
  //     final data = Map<String, dynamic>.from(snapshot.value as Map);
  //     data.forEach((key, value) {
  //       final tinNhanData = Map<String, dynamic>.from(value);
  //       danhSachTinNhan.add(TinNhan.fromJson({
  //         'ma': key,
  //         'maNguoiGui': tinNhanData['maNguoiGui'],
  //         'tenNguoiGui': tinNhanData['tenNguoiGui'],
  //         'anhNguoiGui': tinNhanData['anhNguoiGui'],
  //         'maNguoiNhan': tinNhanData['maNguoiNhan'],
  //         'tenNguoiNhan': tinNhanData['tenNguoiNhan'],
  //         'anhNguoiNhan': tinNhanData['anhNguoiNhan'],
  //         'noiDung': tinNhanData['noiDung'],
  //         'loai': tinNhanData['loai'],
  //         'thoiGian': tinNhanData['thoiGian'],
  //         'daDoc': tinNhanData['daDoc'] ?? false,
  //         'urlHinhAnh': tinNhanData['urlHinhAnh'],
  //         'maCongThuc': tinNhanData['maCongThuc'],
  //       }));
  //     });
  //   }
  //
  //   return danhSachTinNhan;
  // }

  // Lắng nghe tin nhắn real-time
  Stream<List<TinNhan>> langNgheTinNhan(String cuocTroChuyenId, {String? maNguoiDung}) {
    return _database.child('tin_nhan').child(cuocTroChuyenId).onValue.asyncMap((event) async {
      final List<TinNhan> danhSachTinNhan = [];

      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        
        for (final entry in data.entries) {
          final key = entry.key;
          final value = entry.value;
          final tinNhanData = Map<String, dynamic>.from(value);
          
          // Kiểm tra tin nhắn có bị xóa cho người dùng này không
          bool daXoaChoBanThan = false;
          if (maNguoiDung != null) {
            daXoaChoBanThan = await kiemTraTinNhanDaXoa(maNguoiDung, cuocTroChuyenId, key);
          }
          
          // Chỉ thêm tin nhắn nếu chưa bị xóa cho người dùng này
          if (!daXoaChoBanThan) {
            danhSachTinNhan.add(TinNhan.fromJson({
              'ma': key,
              'maNguoiGui': tinNhanData['maNguoiGui'],
              'tenNguoiGui': tinNhanData['tenNguoiGui'],
              'anhNguoiGui': tinNhanData['anhNguoiGui'],
              'maNguoiNhan': tinNhanData['maNguoiNhan'],
              'tenNguoiNhan': tinNhanData['tenNguoiNhan'],
              'anhNguoiNhan': tinNhanData['anhNguoiNhan'],
              'noiDung': tinNhanData['noiDung'],
              'loai': tinNhanData['loai'],
              'thoiGian': tinNhanData['thoiGian'],
              'daDoc': tinNhanData['daDoc'] ?? false,
              'urlHinhAnh': tinNhanData['urlHinhAnh'],
              'maCongThuc': tinNhanData['maCongThuc'],
              'thoiGianXoa': tinNhanData['thoiGianXoa'],
            }));
          }
        }
      }

      // Sắp xếp theo thời gian
      danhSachTinNhan.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
      return danhSachTinNhan;
    });
  }

  // Đánh dấu đã đọc
  Future<void> danhDauDaDoc(String cuocTroChuyenId, String maNguoiDung) async {
    // Cập nhật số tin nhắn chưa đọc
    await _database
        .child('cuoc_tro_chuyen')
        .child(maNguoiDung)
        .child(cuocTroChuyenId)
        .update({'soTinNhanChuaDoc': 0});
  }

  // Lấy danh sách stories
  Future<List<Story>> layDanhSachStories() async {
    final snapshot = await _database.child('stories').get();
    final List<Story> danhSachStories = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        final storyData = Map<String, dynamic>.from(value);
        danhSachStories.add(Story(
          ma: key,
          maNguoiDung: storyData['maNguoiDung'],
          tenNguoiDung: storyData['tenNguoiDung'],
          anhNguoiDung: storyData['anhNguoiDung'],
          urlHinhAnh: storyData['urlHinhAnh'],
          thoiGian: DateTime.parse(storyData['thoiGian']),
          daXem: storyData['daXem'] ?? false,
        ));
      });
    }

    return danhSachStories;
  }

  // Lấy thông tin người dùng từ auth_users
  Map<String, dynamic> layThongTinNguoiDung(String uid) {
    // Trả về thông tin mặc định, trong thực tế sẽ lấy từ Firebase
    return {
      'username': '@user${uid.substring(0, 6)}',
      'followers': 0,
      'following': 0,
      'displayName': 'Người dùng',
      'photoURL': 'assets/images/avatar_default.jpg',
    };
  }

  // Lấy danh sách tin nhắn
  // Stream<List<TinNhan>> layDanhSachTinNhan(String nguoiDung1, String nguoiDung2) {
  //   return _database
  //       .child('tin_nhan')
  //       .orderByChild('thoiGian')
  //       .onValue
  //       .map((event) {
  //     final List<TinNhan> danhSachTinNhan = [];
  //
  //     if (event.snapshot.exists) {
  //       final data = Map<String, dynamic>.from(event.snapshot.value as Map);
  //
  //       data.forEach((key, value) {
  //         final tinNhanData = Map<String, dynamic>.from(value);
  //         final nguoiGui = tinNhanData['nguoiGui'];
  //         final nguoiNhan = tinNhanData['nguoiNhan'];
  //
  //         // Chỉ lấy tin nhắn giữa 2 người dùng
  //         if ((nguoiGui == nguoiDung1 && nguoiNhan == nguoiDung2) ||
  //             (nguoiGui == nguoiDung2 && nguoiNhan == nguoiDung1)) {
  //           danhSachTinNhan.add(TinNhan.fromJson({
  //             'ma': key,
  //             'nguoiGui': nguoiGui,
  //             'nguoiNhan': nguoiNhan,
  //             'noiDung': tinNhanData['noiDung'],
  //             'thoiGian': tinNhanData['thoiGian'],
  //             'daDoc': tinNhanData['daDoc'] ?? false,
  //           }));
  //         }
  //       });
  //     }
  //
  //     // Sắp xếp theo thời gian
  //     danhSachTinNhan.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
  //     return danhSachTinNhan;
  //   });
  // }

  // Kiểm tra cuộc trò chuyện có tồn tại không
  Future<bool> kiemTraCuocTroChuyenTonTai(String cuocTroChuyenId) async {
    final snapshot = await _database.child('tin_nhan').child(cuocTroChuyenId).get();
    return snapshot.exists;
  }

  // Xóa tin nhắn cho bản thân
  Future<bool> xoaTinNhanChoBanThan({
    required String cuocTroChuyenId,
    required String tinNhanId,
    required String maNguoiDung,
  }) async {
    try {
      // Đánh dấu tin nhắn đã bị xóa cho người dùng này
      await _database
          .child('tin_nhan_da_xoa')
          .child(maNguoiDung)
          .child(cuocTroChuyenId)
          .child(tinNhanId)
          .set(true);
    
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa tin nhắn cho bản thân: $e');
      return false;
    }
  }

  // Xóa tin nhắn cho mọi người (chỉ người gửi mới được xóa)
  Future<bool> xoaTinNhanChoMoiNguoi({
    required String cuocTroChuyenId,
    required String tinNhanId,
    required String maNguoiGui,
  }) async {
    try {
      // Kiểm tra thời gian gửi tin nhắn (chỉ cho phép xóa trong 24h)
      final tinNhanSnapshot = await _database
          .child('tin_nhan')
          .child(cuocTroChuyenId)
          .child(tinNhanId)
          .get();
    
      if (!tinNhanSnapshot.exists) {
        return false;
      }
    
      final tinNhanData = Map<String, dynamic>.from(tinNhanSnapshot.value as Map);
      final thoiGianGui = DateTime.fromMillisecondsSinceEpoch(tinNhanData['thoiGian']);
      final thoiGianHienTai = DateTime.now();
      final chenhLech = thoiGianHienTai.difference(thoiGianGui);
    
      // Chỉ cho phép xóa trong 24 giờ
      if (chenhLech.inHours > 24) {
        return false;
      }
    
      // Kiểm tra quyền xóa (chỉ người gửi mới được xóa)
      if (tinNhanData['maNguoiGui'] != maNguoiGui) {
        return false;
      }
    
      // Cập nhật tin nhắn thành "đã bị xóa"
      await _database
          .child('tin_nhan')
          .child(cuocTroChuyenId)
          .child(tinNhanId)
          .update({
        'noiDung': 'Tin nhắn đã bị xóa',
        'loai': 'deleted',
        'thoiGianXoa': DateTime.now().millisecondsSinceEpoch,
      });
    
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa tin nhắn cho mọi người: $e');
      return false;
    }
  }

  // Kiểm tra tin nhắn có bị xóa cho người dùng không
  Future<bool> kiemTraTinNhanDaXoa(String maNguoiDung, String cuocTroChuyenId, String tinNhanId) async {
    final snapshot = await _database
        .child('tin_nhan_da_xoa')
        .child(maNguoiDung)
        .child(cuocTroChuyenId)
        .child(tinNhanId)
        .get();
  
    return snapshot.exists && (snapshot.value as bool? ?? false);
  }
}
