import 'package:do_an/dich_vu/dich_vu_xac_thuc/dang_ki_dang_nhap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:do_an/man_hinh/man_hinh_chao.dart';
import 'package:do_an/giao_dien/chu_de.dart';
import 'package:do_an/dich_vu/dich_vu_cai_dat.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (Android dùng google-services.json nên không cần options)
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Khởi tạo dịch vụ xác thực

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DichVuCaiDat()),
        ChangeNotifierProvider(create: (_) => DangKiDangNhapEmail()),
      ],
      child: const AmThucVietApp(),
    ),
  );
}

//Huy gfdgfdf
//hhdsadasdsadasdasdasd
class AmThucVietApp extends StatelessWidget {
  const AmThucVietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ẩm Thực Việt',
      debugShowCheckedModeBanner: false,
      theme: ChuDe.chuDeSang,
      home: const ManHinhChao(),
    );
  }
}
