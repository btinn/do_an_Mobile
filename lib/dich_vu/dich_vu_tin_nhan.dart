import 'package:firebase_database/firebase_database.dart';
import 'package:do_an/mo_hinh/tin_nhan.dart';

class DichVuTinNhan {
  final _db = FirebaseDatabase.instance.ref();

  // Tạo ID cuộc trò chuyện từ 2 user ID
  String taoMaCuocTroChuyenId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Gửi tin nhắn
  Future<void> guiTinNhan({
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

    // Lưu tin nhắn
    await _db.child('tin_nhan').child(cuocTroChuyenId).child(tinNhanId).set(tinNhan);

    // Cập nhật cuộc trò chuyện tóm tắt
    await _capNhatCuocTroChuyenTomTat(cuocTroChuyenId, tinNhan);
  }

  // Cập nhật cuộc trò chuyện tóm tắt
  Future<void> _capNhatCuocTroChuyenTomTat(String cuocTroChuyenId, Map<String, dynamic> tinNhan) async {
    final cuocTroChuyenTomTat = {
      'tinNhanCuoi': tinNhan['noiDung'],
      'loaiTinNhanCuoi': tinNhan['loai'],
      'thoiGianCuoi': tinNhan['thoiGian'],
      'maNguoiGuiCuoi': tinNhan['maNguoiGui'],
    };

    // Cập nhật cho người gửi
    await _db.child('cuoc_tro_chuyen').child(tinNhan['maNguoiGui']).child(cuocTroChuyenId).update({
      ...cuocTroChuyenTomTat,
      'maNguoiKhac': tinNhan['maNguoiNhan'],
      'tenNguoiKhac': tinNhan['tenNguoiNhan'],
      'anhNguoiKhac': tinNhan['anhNguoiNhan'],
    });

    // Cập nhật cho người nhận
    await _db.child('cuoc_tro_chuyen').child(tinNhan['maNguoiNhan']).child(cuocTroChuyenId).update({
      ...cuocTroChuyenTomTat,
      'maNguoiKhac': tinNhan['maNguoiGui'],
      'tenNguoiKhac': tinNhan['tenNguoiGui'],
      'anhNguoiKhac': tinNhan['anhNguoiGui'],
    });

    // Tăng số tin nhắn chưa đọc cho người nhận
    await _tangSoTinNhanChuaDoc(tinNhan['maNguoiNhan'], cuocTroChuyenId);
  }

  // Tăng số tin nhắn chưa đọc
  Future<void> _tangSoTinNhanChuaDoc(String maNguoiDung, String cuocTroChuyenId) async {
    final snapshot = await _db.child('cuoc_tro_chuyen').child(maNguoiDung).child(cuocTroChuyenId).child('soTinNhanChuaDoc').get();
    final soHienTai = snapshot.exists ? (snapshot.value as int? ?? 0) : 0;
    await _db.child('cuoc_tro_chuyen').child(maNguoiDung).child(cuocTroChuyenId).update({
      'soTinNhanChuaDoc': soHienTai + 1,
    });
  }

  // Lấy danh sách cuộc trò chuyện tóm tắt với dữ liệu mẫu
  Future<List<CuocTroChuyenTomTat>> layDanhSachCuocTroChuyenTomTat(
      String maNguoiDung) async {
    // Trả về dữ liệu mẫu thay vì từ Firebase
    return _layDuLieuMau();
  }

  // Tạo dữ liệu mẫu
  List<CuocTroChuyenTomTat> _layDuLieuMau() {
    final now = DateTime.now();

    return [
      CuocTroChuyenTomTat(
        maNguoiKhac: 'user_system',
        tenNguoiKhac: 'Thông báo hệ thống',
        anhNguoiKhac: 'https://i.pravatar.cc/150?img=2',
        tinNhanCuoi: 'LIVE: LIVE Studio hiệu...',
        loaiTinNhanCuoi: 'text',
        thoiGianCuoi: now.subtract(const Duration(days: 1)),
        soTinNhanChuaDoc: 1,
        dangOnline: false,
      ),
      CuocTroChuyenTomTat(
        maNguoiKhac: 'user_tiktokshop',
        tenNguoiKhac: 'TikTok Shop',
        anhNguoiKhac: 'https://i.pravatar.cc/150?img=3',
        tinNhanCuoi: '29 tin cập nhật của c...',
        loaiTinNhanCuoi: 'text',
        thoiGianCuoi: now.subtract(const Duration(days: 2)),
        soTinNhanChuaDoc: 57,
        dangOnline: false,
      ),
    ];
  }

  // Lấy tin nhắn trong cuộc trò chuyện với dữ liệu mẫu
  Future<List<TinNhan>> layTinNhanTrongCuocTroChuyenId(
      String cuocTroChuyenId) async {
    // Trả về dữ liệu mẫu dựa trên cuocTroChuyenId
    return _layTinNhanMau(cuocTroChuyenId);
  }

  // Tạo tin nhắn mẫu cho từng cuộc trò chuyện
  List<TinNhan> _layTinNhanMau(String cuocTroChuyenId) {
    final now = DateTime.now();

    // Dựa vào cuocTroChuyenId để tạo tin nhắn phù hợp
    if (cuocTroChuyenId.contains('user_thihin')) {
      return [
        TinNhan(
          ma: '1',
          maNguoiGui: 'user_thihin',
          tenNguoiGui: 'thi hin',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=1',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào thi hin',
          loai: 'text',
          thoiGian: now.subtract(const Duration(minutes: 5)),
          daDoc: false,
        ),
      ];
    } else if (cuocTroChuyenId.contains('user_seto666')) {
      return [
        TinNhan(
          ma: '2',
          maNguoiGui: 'user_seto666',
          tenNguoiGui: 'Seto.666✝',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=4',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào Seto.666✝',
          loai: 'text',
          thoiGian: now.subtract(const Duration(hours: 3)),
          daDoc: false,
        ),
      ];
    } else if (cuocTroChuyenId.contains('user_juno')) {
      return [
        TinNhan(
          ma: '3',
          maNguoiGui: 'user_juno',
          tenNguoiGui: 'JUNO.OKYO 🇻🇳',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=5',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào JUNO.OKYO',
          loai: 'text',
          thoiGian: now.subtract(const Duration(hours: 6)),
          daDoc: false,
        ),
      ];
    } else if (cuocTroChuyenId.contains('user_chef_minh')) {
      return [
        TinNhan(
          ma: '4',
          maNguoiGui: 'user_chef_minh',
          tenNguoiGui: 'Chef Minh',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=6',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào Chef Minh',
          loai: 'text',
          thoiGian: now.subtract(const Duration(hours: 12)),
          daDoc: false,
        ),
      ];
    } else if (cuocTroChuyenId.contains('user_foodie_lan')) {
      return [
        TinNhan(
          ma: '5',
          maNguoiGui: 'user_foodie_lan',
          tenNguoiGui: 'Foodie Lan',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=7',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào Foodie Lan',
          loai: 'text',
          thoiGian: now.subtract(const Duration(days: 1, hours: 2)),
          daDoc: false,
        ),
      ];
    } else if (cuocTroChuyenId.contains('user_baker_anna')) {
      return [
        TinNhan(
          ma: '6',
          maNguoiGui: 'user_baker_anna',
          tenNguoiGui: 'Baker Anna',
          anhNguoiGui: 'https://i.pravatar.cc/150?img=8',
          maNguoiNhan: 'current_user',
          tenNguoiNhan: 'Bạn',
          anhNguoiNhan: 'https://i.pravatar.cc/150?img=50',
          noiDung: 'Hãy chào Baker Anna',
          loai: 'text',
          thoiGian: now.subtract(const Duration(days: 2, hours: 5)),
          daDoc: false,
        ),
      ];
    }

    // Mặc định trả về danh sách rỗng
    return [];
  }

  // Đánh dấu đã đọc
  Future<void> danhDauDaDoc(String cuocTroChuyenId, String maNguoiDung) async {
    // Giả lập đánh dấu đã đọc
    print('Đã đánh dấu đọc cuộc trò chuyện: $cuocTroChuyenId');
  }

  // Lắng nghe cuộc trò chuyện tóm tắt
  Stream<List<CuocTroChuyenTomTat>> langNgheCuocTroChuyenTomTat(
      String maNguoiDung) {
    // Trả về stream với dữ liệu mẫu
    return Stream.value(_layDuLieuMau());
  }

  // Lắng nghe tin nhắn
  Stream<List<TinNhan>> langNgheTinNhan(String cuocTroChuyenId) {
    // Trả về stream với tin nhắn mẫu
    return Stream.value(_layTinNhanMau(cuocTroChuyenId));
  }

  // Lấy danh sách stories (giả lập)
  Future<List<Story>> layDanhSachStories() async {
    return [
      Story(
        ma: '1',
        maNguoiDung: 'current_user',
        tenNguoiDung: 'Bạn',
        anhNguoiDung: 'https://i.pravatar.cc/150?img=50',
        urlHinhAnh: 'https://picsum.photos/400/600?random=1',
        thoiGian: DateTime.now().subtract(const Duration(hours: 2)),
        daXem: false,
      ),
    ];
  }

  // Lấy thông tin chi tiết người dùng
  Map<String, dynamic> layThongTinNguoiDung(String maNguoiDung) {
    final thongTinNguoiDung = {
      'user_thihin': {
        'username': '@thihin2004',
        'following': 15,
        'followers': 32,
      },
      'user_seto666': {
        'username': '@ssvictor0',
        'following': 9,
        'followers': 16,
      },
      'user_juno': {
        'username': '@juno_okyo',
        'following': 1200,
        'followers': 856,
      },
      'user_chef_minh': {
        'username': '@chef_minh_official',
        'following': 500,
        'followers': 2500,
      },
      'user_foodie_lan': {
        'username': '@foodie_lan_vn',
        'following': 300,
        'followers': 1200,
      },
      'user_baker_anna': {
        'username': '@baker_anna_sweet',
        'following': 150,
        'followers': 800,
      },
    };

    return thongTinNguoiDung[maNguoiDung] ??
        {
          'username': '@unknown',
          'following': 0,
          'followers': 0,
        };
  }
}
