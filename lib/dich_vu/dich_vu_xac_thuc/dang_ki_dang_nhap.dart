import 'package:do_an/mo_hinh/nguoi_dung.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DangKiDangNhapEmail with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _dangTaiNguoiDung = false;
  bool get dangTaiNguoiDung => _dangTaiNguoiDung;

  NguoiDung? _nguoiDungHienTai;
  NguoiDung? get nguoiDungHienTai => _nguoiDungHienTai;

  // Đăng nhập với email
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        if (!user.emailVerified) {
          await _firebaseAuth.signOut();
          print('Email chưa được xác minh: ${user.email}');
          return null;
        }

        final doc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          final userData = {
            'hoTen': user.displayName ?? '',
            'email': user.email ?? '',
            'anhDaiDien': user.photoURL ?? 'assets/images/avatar_default.jpg',
            'moTa': 'Người yêu ẩm thực & đầu bếp tại nhà',
            'soLuongCongThuc': 0,
            'soLuongNguoiTheoDoi': 0,
            'soLuongDangTheoDoi': 0,
            'diaChi': '',
            'gioiTinh': '',
            'ngaySinh': '',
            'soDienThoai': '',
          };

          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .set(userData);

          print('Đã lưu thông tin người dùng mới vào Firestore.');
        }

        // Lấy người dùng hiện tại (từ Firestore)
        await layNguoiDungHienTai();
        notifyListeners();

        print(
            'Người dùng hiện tại sau khi đăng nhập: ${nguoiDungHienTai?.hoTen}, ${nguoiDungHienTai?.soLuongCongThuc}');
        return user;
      }

      return null;
    } catch (e) {
      print('Đăng nhập lỗi: $e');
      return null;
    }
  }

  // Đăng ký với email

  Future<User?> signUpWithEmail(
      String email, String password, String username) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        final userData = {
          'hoTen': username,
          'email': user.email,
          'anhDaiDien': 'assets/images/avatar_default.jpg',
          'moTa': 'Người yêu ẩm thực & đầu bếp tại nhà',
          'soLuongCongThuc': 0,
          'soLuongNguoiTheoDoi': 0,
          'soLuongDangTheoDoi': 0,
          'diaChi': '',
          'gioiTinh': '',
          'ngaySinh': '',
          'soDienThoai': '',
        };

        try {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .set(userData);

          await layNguoiDungHienTai();

          if (!user.emailVerified) {
            await user.sendEmailVerification();
          }

          return user;
        } catch (e) {
          print('Lưu dữ liệu Firestore thất bại: $e');
          await user.delete();
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Đăng ký lỗi: $e');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Người dùng hủy đăng nhập Google.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        final userDoc = await _firestore.collection('user').doc(user.uid).get();

        if (!userDoc.exists) {
          final userData = {
            'hoTen': user.displayName ?? '',
            'email': user.email ?? '',
            'anhDaiDien': user.photoURL ?? 'assets/images/avatar_default.jpg',
            'moTa': 'Người yêu ẩm thực & đầu bếp tại nhà',
            'soLuongCongThuc': 0,
            'soLuongNguoiTheoDoi': 0,
            'soLuongDangTheoDoi': 0,
            'diaChi': '',
            'gioiTinh': '',
            'ngaySinh': '',
            'soDienThoai': '',
          };

          await _firestore.collection('user').doc(user.uid).set(userData);
        }

        await layNguoiDungHienTai();
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'Tài khoản này đã được đăng ký bằng phương thức khác. Hãy sử dụng email và mật khẩu để đăng nhập.');
      } else {
        throw Exception('Lỗi Firebase: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _nguoiDungHienTai = null;
    notifyListeners();
  }

  Future<void> layNguoiDungHienTai() async {
    _dangTaiNguoiDung = true;
    notifyListeners();

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('user').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          _nguoiDungHienTai = NguoiDung(
            ma: user.uid,
            hoTen: data['hoTen'] ?? '',
            email: data['email'] ?? '',
            anhDaiDien: data['anhDaiDien'] ?? '',
            moTa: data['moTa'] ?? '',
            soLuongCongThuc: data['soLuongCongThuc'] ?? 0,
            soLuongNguoiTheoDoi: data['soLuongNguoiTheoDoi'] ?? 0,
            soLuongDangTheoDoi: data['soLuongDangTheoDoi'] ?? 0,
          );
        }
      } catch (e) {
        print("Lỗi khi lấy người dùng từ Firestore: $e");
      }
    }

    _dangTaiNguoiDung = false;
    notifyListeners();
  }
}
