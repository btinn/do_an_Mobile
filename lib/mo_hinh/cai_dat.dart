enum NgonNgu { tiengViet, tiengAnh }
enum ChuDeMau { sang, toi }

class CaiDat {
  NgonNgu ngonNgu;
  ChuDeMau chuDeMau;
  bool thongBao;
  bool tuDongPhatVideo;
  bool luuDuLieuOffline;

  CaiDat({
    this.ngonNgu = NgonNgu.tiengViet,
    this.chuDeMau = ChuDeMau.sang,
    this.thongBao = true,
    this.tuDongPhatVideo = true,
    this.luuDuLieuOffline = false,
  });

  CaiDat copyWith({
    NgonNgu? ngonNgu,
    ChuDeMau? chuDeMau,
    bool? thongBao,
    bool? tuDongPhatVideo,
    bool? luuDuLieuOffline,
  }) {
    return CaiDat(
      ngonNgu: ngonNgu ?? this.ngonNgu,
      chuDeMau: chuDeMau ?? this.chuDeMau,
      thongBao: thongBao ?? this.thongBao,
      tuDongPhatVideo: tuDongPhatVideo ?? this.tuDongPhatVideo,
      luuDuLieuOffline: luuDuLieuOffline ?? this.luuDuLieuOffline,
    );
  }
}
