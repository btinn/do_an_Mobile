import 'package:firebase_database/firebase_database.dart';

class DichVuDanhGia {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> danhGiaCongThuc(
      String maCongThuc, String uid, double diem) async {
    await _db.child('danh_gia/$maCongThuc/$uid').set(diem);
  }

  Future<double> layDiemTrungBinh(String maCongThuc) async {
    final data = await _db.child('danh_gia/$maCongThuc').get();
    if (!data.exists) return 0.0;

    double tong = 0;
    int dem = 0;
    for (final child in data.children) {
      final diem = double.tryParse(child.value.toString());
      if (diem != null) {
        tong += diem;
        dem++;
      }
    }

    return dem > 0 ? tong / dem : 0.0;
  }

  Future<int> demSoLuongDanhGia(String maCongThuc) async {
    final snap = await _db.child('danh_gia/$maCongThuc').get();
    return snap.exists ? snap.children.length : 0;
  }

  Future<double?> layDiemDanhGiaCuaNguoiDung(
      String maCongThuc, String uid) async {
    final data = await _db.child('danh_gia/$maCongThuc/$uid').get();
    if (!data.exists) return null;
    return double.tryParse(data.value.toString());
  }
}
