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

  // Lấy danh sách cuộc trò chuyện tóm tắt
  Future<List<CuocTroChuyenTomTat>> layDanhSachCuocTroChuyenTomTat(String maNguoiDung) async {
    final snapshot = await _db.child('cuoc_tro_chuyen').child(maNguoiDung).get();
    
    if (!snapshot.exists) return [];

    final List<CuocTroChuyenTomTat> danhSach = [];
    
    for (final child in snapshot.children) {
      try {
        final data = child.value as Map<dynamic, dynamic>?;
        if (data == null) continue;

        danhSach.add(CuocTroChuyenTomTat(
          maNguoiKhac: data['maNguoiKhac'] ?? '',
          tenNguoiKhac: data['tenNguoiKhac'] ?? '',
          anhNguoiKhac: data['anhNguoiKhac'] ?? '',
          tinNhanCuoi: data['tinNhanCuoi'] ?? '',
          loaiTinNhanCuoi: data['loaiTinNhanCuoi'] ?? 'text',
          thoiGianCuoi: DateTime.fromMillisecondsSinceEpoch(data['thoiGianCuoi'] ?? 0),
          soTinNhanChuaDoc: data['soTinNhanChuaDoc'] ?? 0,
          dangOnline: data['dangOnline'] ?? false,
        ));
      } catch (e) {
        print('Lỗi khi chuyển đổi cuộc trò chuyện: $e');
      }
    }

    // Sắp xếp theo thời gian mới nhất
    danhSach.sort((a, b) => b.thoiGianCuoi.compareTo(a.thoiGianCuoi));
    
    return danhSach;
  }

  // Lấy tin nhắn trong cuộc trò chuyện
  Future<List<TinNhan>> layTinNhanTrongCuocTroChuyenId(String cuocTroChuyenId) async {
    final snapshot = await _db.child('tin_nhan').child(cuocTroChuyenId).get();
    
    if (!snapshot.exists) return [];

    final List<TinNhan> danhSach = [];
    
    for (final child in snapshot.children) {
      try {
        final data = child.value as Map<dynamic, dynamic>?;
        if (data == null) continue;

        danhSach.add(TinNhan.fromMap(Map<String, dynamic>.from(data)));
      } catch (e) {
        print('Lỗi khi chuyển đổi tin nhắn: $e');
      }
    }

    // Sắp xếp theo thời gian
    danhSach.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
    
    return danhSach;
  }

  // Đánh dấu đã đọc
  Future<void> danhDauDaDoc(String cuocTroChuyenId, String maNguoiDung) async {
    await _db.child('cuoc_tro_chuyen').child(maNguoiDung).child(cuocTroChuyenId).update({
      'soTinNhanChuaDoc': 0,
    });
  }

  // Lắng nghe cuộc trò chuyện tóm tắt
  Stream<List<CuocTroChuyenTomTat>> langNgheCuocTroChuyenTomTat(String maNguoiDung) {
    return _db.child('cuoc_tro_chuyen').child(maNguoiDung).onValue.map((event) {
      if (!event.snapshot.exists) return <CuocTroChuyenTomTat>[];

      final List<CuocTroChuyenTomTat> danhSach = [];
      
      for (final child in event.snapshot.children) {
        try {
          final data = child.value as Map<dynamic, dynamic>?;
          if (data == null) continue;

          danhSach.add(CuocTroChuyenTomTat(
            maNguoiKhac: data['maNguoiKhac'] ?? '',
            tenNguoiKhac: data['tenNguoiKhac'] ?? '',
            anhNguoiKhac: data['anhNguoiKhac'] ?? '',
            tinNhanCuoi: data['tinNhanCuoi'] ?? '',
            loaiTinNhanCuoi: data['loaiTinNhanCuoi'] ?? 'text',
            thoiGianCuoi: DateTime.fromMillisecondsSinceEpoch(data['thoiGianCuoi'] ?? 0),
            soTinNhanChuaDoc: data['soTinNhanChuaDoc'] ?? 0,
            dangOnline: data['dangOnline'] ?? false,
          ));
        } catch (e) {
          print('Lỗi khi chuyển đổi cuộc trò chuyện: $e');
        }
      }

      // Sắp xếp theo thời gian mới nhất
      danhSach.sort((a, b) => b.thoiGianCuoi.compareTo(a.thoiGianCuoi));
      
      return danhSach;
    });
  }

  // Lắng nghe tin nhắn
  Stream<List<TinNhan>> langNgheTinNhan(String cuocTroChuyenId) {
    return _db.child('tin_nhan').child(cuocTroChuyenId).onValue.map((event) {
      if (!event.snapshot.exists) return <TinNhan>[];

      final List<TinNhan> danhSach = [];
      
      for (final child in event.snapshot.children) {
        try {
          final data = child.value as Map<dynamic, dynamic>?;
          if (data == null) continue;

          danhSach.add(TinNhan.fromMap(Map<String, dynamic>.from(data)));
        } catch (e) {
          print('Lỗi khi chuyển đổi tin nhắn: $e');
        }
      }

      // Sắp xếp theo thời gian
      danhSach.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
      
      return danhSach;
    });
  }

  // Lấy danh sách stories (giả lập)
  Future<List<Story>> layDanhSachStories() async {
    // Giả lập dữ liệu stories
    return [
      Story(
        ma: '1',
        maNguoiDung: 'user1',
        tenNguoiDung: 'Bạn',
        anhNguoiDung: 'assets/images/avatar_default.jpg',
        urlHinhAnh: 'assets/images/story1.jpg',
        thoiGian: DateTime.now().subtract(const Duration(hours: 2)),
        daXem: false,
      ),
      Story(
        ma: '2',
        maNguoiDung: 'user2',
        tenNguoiDung: 'Quay',
        anhNguoiDung: 'assets/images/user1.jpg',
        urlHinhAnh: 'assets/images/story2.jpg',
        thoiGian: DateTime.now().subtract(const Duration(hours: 1)),
        daXem: false,
      ),
      Story(
        ma: '3',
        maNguoiDung: 'user3',
        tenNguoiDung: 'Ký niệm xưa',
        anhNguoiDung: 'assets/images/user2.jpg',
        urlHinhAnh: 'assets/images/story3.jpg',
        thoiGian: DateTime.now().subtract(const Duration(minutes: 30)),
        daXem: true,
      ),
      Story(
        ma: '4',
        maNguoiDung: 'user4',
        tenNguoiDung: 'Anh Phi Có...',
        anhNguoiDung: 'assets/images/user3.jpg',
        urlHinhAnh: 'assets/images/story4.jpg',
        thoiGian: DateTime.now().subtract(const Duration(minutes: 15)),
        daXem: false,
      ),
      Story(
        ma: '5',
        maNguoiDung: 'user5',
        tenNguoiDung: 'Dr Hưng Da...',
        anhNguoiDung: 'assets/images/user4.jpg',
        urlHinhAnh: 'assets/images/story5.jpg',
        thoiGian: DateTime.now().subtract(const Duration(minutes: 5)),
        daXem: false,
      ),
    ];
  }
}
