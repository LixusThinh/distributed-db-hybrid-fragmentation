/* =====================================================================
   03_reconstruct_check.sql
   Chạy tại S0 (QLDH_TRUSO), SAU 02_fragments.sql.
   1. Tạo SYNONYM trỏ tới các mảnh nằm ở site chi nhánh
      → muốn chạy phân tán thật thì chỉ cần đổi synonym sang Linked Server.
   2. Tạo VIEW tái thiết quan hệ toàn cục (trong suốt phân mảnh + vị trí).
   3. Kiểm tra 3 quy tắc đúng đắn: ĐẦY ĐỦ – TÁI THIẾT – RỜI NHAU.
      Mong đợi: mọi dòng kết quả có SoDongLech = 0, KetQua = ĐẠT.
   ===================================================================== */
USE QLDH_TRUSO;
GO

/* ---------------------------------------------------------------------
   1. SYNONYM: tên cục bộ ở S0 → mảnh ở site khác
   --------------------------------------------------------------------- */
-- DROP SYNONYM chỉ nhận một tên mỗi lệnh
DROP SYNONYM IF EXISTS dbo.syn_KH_1_GD;
DROP SYNONYM IF EXISTS dbo.syn_NV_CV_1;
DROP SYNONYM IF EXISTS dbo.syn_DH_1;
DROP SYNONYM IF EXISTS dbo.syn_CTDH_1;
DROP SYNONYM IF EXISTS dbo.syn_KH_2_GD;
DROP SYNONYM IF EXISTS dbo.syn_NV_CV_2;
DROP SYNONYM IF EXISTS dbo.syn_DH_2;
DROP SYNONYM IF EXISTS dbo.syn_CTDH_2;
DROP SYNONYM IF EXISTS dbo.syn_KH_3_GD;
DROP SYNONYM IF EXISTS dbo.syn_NV_CV_3;
DROP SYNONYM IF EXISTS dbo.syn_DH_3;
DROP SYNONYM IF EXISTS dbo.syn_CTDH_3;

-- S1 – Hà Nội
CREATE SYNONYM dbo.syn_KH_1_GD FOR QLDH_HN.dbo.KH_1_GD;
CREATE SYNONYM dbo.syn_NV_CV_1 FOR QLDH_HN.dbo.NV_CV_1;
CREATE SYNONYM dbo.syn_DH_1    FOR QLDH_HN.dbo.DH_1;
CREATE SYNONYM dbo.syn_CTDH_1  FOR QLDH_HN.dbo.CTDH_1;
-- S2 – Đà Nẵng
CREATE SYNONYM dbo.syn_KH_2_GD FOR QLDH_DN.dbo.KH_2_GD;
CREATE SYNONYM dbo.syn_NV_CV_2 FOR QLDH_DN.dbo.NV_CV_2;
CREATE SYNONYM dbo.syn_DH_2    FOR QLDH_DN.dbo.DH_2;
CREATE SYNONYM dbo.syn_CTDH_2  FOR QLDH_DN.dbo.CTDH_2;
-- S3 – TP.HCM
CREATE SYNONYM dbo.syn_KH_3_GD FOR QLDH_HCM.dbo.KH_3_GD;
CREATE SYNONYM dbo.syn_NV_CV_3 FOR QLDH_HCM.dbo.NV_CV_3;
CREATE SYNONYM dbo.syn_DH_3    FOR QLDH_HCM.dbo.DH_3;
CREATE SYNONYM dbo.syn_CTDH_3  FOR QLDH_HCM.dbo.CTDH_3;
GO

/* ---------------------------------------------------------------------
   2. VIEW TÁI THIẾT
   UNION ALL (không phải UNION) là đúng vì các mảnh ngang RỜI NHAU.
   --------------------------------------------------------------------- */

-- KhachHang = ⋃ i=1..3 ( KH_i_GD ⋈[MaKH] KH_i_TC )            (hỗn hợp HV)
CREATE OR ALTER VIEW dbo.v_KhachHang AS
    SELECT gd.MaKH, gd.HoTen, gd.SDT, gd.Email, gd.DiaChi, gd.MaCN,
           tc.HanMucNo, tc.CongNo, tc.DiemTichLuy
    FROM dbo.syn_KH_1_GD AS gd JOIN dbo.KH_1_TC AS tc ON tc.MaKH = gd.MaKH
    UNION ALL
    SELECT gd.MaKH, gd.HoTen, gd.SDT, gd.Email, gd.DiaChi, gd.MaCN,
           tc.HanMucNo, tc.CongNo, tc.DiemTichLuy
    FROM dbo.syn_KH_2_GD AS gd JOIN dbo.KH_2_TC AS tc ON tc.MaKH = gd.MaKH
    UNION ALL
    SELECT gd.MaKH, gd.HoTen, gd.SDT, gd.Email, gd.DiaChi, gd.MaCN,
           tc.HanMucNo, tc.CongNo, tc.DiemTichLuy
    FROM dbo.syn_KH_3_GD AS gd JOIN dbo.KH_3_TC AS tc ON tc.MaKH = gd.MaKH;
GO

-- NhanVien = ( NV_CV_1 ∪ NV_CV_2 ∪ NV_CV_3 ) ⋈[MaNV] NV_NS      (hỗn hợp VH)
CREATE OR ALTER VIEW dbo.v_NhanVien AS
    SELECT cv.MaNV, cv.HoTen, cv.ChucVu, cv.SDT, cv.MaCN,
           ns.NgaySinh, ns.CCCD, ns.Luong, ns.SoTaiKhoan
    FROM (
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN FROM dbo.syn_NV_CV_1
        UNION ALL
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN FROM dbo.syn_NV_CV_2
        UNION ALL
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN FROM dbo.syn_NV_CV_3
    ) AS cv
    JOIN dbo.NV_NS AS ns ON ns.MaNV = cv.MaNV;
GO

-- DonHang = DH_1 ∪ DH_2 ∪ DH_3                                  (ngang dẫn xuất)
CREATE OR ALTER VIEW dbo.v_DonHang AS
    SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM dbo.syn_DH_1
    UNION ALL
    SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM dbo.syn_DH_2
    UNION ALL
    SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM dbo.syn_DH_3;
GO

-- ChiTietDonHang = CTDH_1 ∪ CTDH_2 ∪ CTDH_3                     (ngang dẫn xuất)
CREATE OR ALTER VIEW dbo.v_ChiTietDonHang AS
    SELECT MaDH, MaSP, SoLuong, DonGia FROM dbo.syn_CTDH_1
    UNION ALL
    SELECT MaDH, MaSP, SoLuong, DonGia FROM dbo.syn_CTDH_2
    UNION ALL
    SELECT MaDH, MaSP, SoLuong, DonGia FROM dbo.syn_CTDH_3;
GO

-- Xem thử: người dùng truy vấn như một bảng duy nhất, không cần biết dữ liệu ở site nào
SELECT TOP (6) * FROM dbo.v_KhachHang ORDER BY MaKH;
SELECT TOP (6) * FROM dbo.v_NhanVien  ORDER BY MaNV;
GO

/* ---------------------------------------------------------------------
   3. KIỂM TRA TÍNH ĐÚNG ĐẮN
   So sánh với lược đồ gốc QLDH_GOC. SoDongLech = số bộ/thuộc tính vi phạm.
   --------------------------------------------------------------------- */
DECLARE @KQ TABLE (
    STT        INT IDENTITY(1,1),
    QuanHe     NVARCHAR(20),
    QuyTac     NVARCHAR(12),
    MoTa       NVARCHAR(150),
    SoDongLech INT
);

/* ===== KhachHang (hỗn hợp HV) ===== */
-- Đầy đủ (ngang): bộ của KhachHang gốc không thuộc mảnh ngang nào
INSERT INTO @KQ
SELECT N'KhachHang', N'Đầy đủ', N'Bộ không thuộc mảnh ngang nào', COUNT(*)
FROM QLDH_GOC.dbo.KhachHang AS k
WHERE NOT EXISTS (SELECT 1 FROM (SELECT MaKH FROM dbo.syn_KH_1_GD
                                 UNION ALL SELECT MaKH FROM dbo.syn_KH_2_GD
                                 UNION ALL SELECT MaKH FROM dbo.syn_KH_3_GD) AS m
                  WHERE m.MaKH = k.MaKH);

-- Đầy đủ (dọc): thuộc tính của KhachHang không nằm trong mảnh dọc nào
-- (kiểm tra trên KH_1_GD / KH_1_TC; các mảnh 2, 3 có cùng cấu trúc)
INSERT INTO @KQ
SELECT N'KhachHang', N'Đầy đủ', N'Thuộc tính không thuộc mảnh dọc nào (GD ∪ TC)', COUNT(*)
FROM (
    SELECT name FROM QLDH_GOC.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_GOC.dbo.KhachHang')
    EXCEPT
    SELECT name FROM (
        SELECT name FROM QLDH_HN.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_HN.dbo.KH_1_GD')
        UNION
        SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.KH_1_TC')
    ) AS u
) AS x;

-- Tái thiết: số bộ lệch giữa KhachHang gốc và v_KhachHang (hai chiều + so số lượng)
INSERT INTO @KQ
SELECT N'KhachHang', N'Tái thiết', N'Bộ lệch giữa KhachHang gốc và v_KhachHang',
    (SELECT COUNT(*) FROM (
        SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy FROM QLDH_GOC.dbo.KhachHang
        EXCEPT
        SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy FROM dbo.v_KhachHang) AS a)
  + (SELECT COUNT(*) FROM (
        SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy FROM dbo.v_KhachHang
        EXCEPT
        SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy FROM QLDH_GOC.dbo.KhachHang) AS b)
  + ABS((SELECT COUNT(*) FROM dbo.v_KhachHang) - (SELECT COUNT(*) FROM QLDH_GOC.dbo.KhachHang));

-- Rời nhau (ngang): MaKH xuất hiện ở hơn một mảnh ngang
INSERT INTO @KQ
SELECT N'KhachHang', N'Rời nhau', N'MaKH thuộc nhiều hơn 1 mảnh ngang', COUNT(*)
FROM (SELECT MaKH FROM (SELECT MaKH FROM dbo.syn_KH_1_GD
                        UNION ALL SELECT MaKH FROM dbo.syn_KH_2_GD
                        UNION ALL SELECT MaKH FROM dbo.syn_KH_3_GD) AS m
      GROUP BY MaKH HAVING COUNT(*) > 1) AS x;

-- Rời nhau (dọc): thuộc tính KHÔNG phải khóa có mặt ở cả GD và TC
INSERT INTO @KQ
SELECT N'KhachHang', N'Rời nhau', N'Thuộc tính không khóa lặp ở cả GD và TC', COUNT(*)
FROM (
    SELECT name FROM QLDH_HN.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_HN.dbo.KH_1_GD')
    INTERSECT
    SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.KH_1_TC')
) AS x
WHERE name <> N'MaKH';

/* ===== NhanVien (hỗn hợp VH) ===== */
INSERT INTO @KQ
SELECT N'NhanVien', N'Đầy đủ', N'Thuộc tính không thuộc mảnh dọc nào (CV ∪ NS)', COUNT(*)
FROM (
    SELECT name FROM QLDH_GOC.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_GOC.dbo.NhanVien')
    EXCEPT
    SELECT name FROM (
        SELECT name FROM QLDH_HN.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_HN.dbo.NV_CV_1')
        UNION
        SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NV_NS')
    ) AS u
) AS x;

INSERT INTO @KQ
SELECT N'NhanVien', N'Đầy đủ', N'Bộ của NV_CV không thuộc mảnh ngang nào', COUNT(*)
FROM QLDH_GOC.dbo.NhanVien AS v
WHERE NOT EXISTS (SELECT 1 FROM (SELECT MaNV FROM dbo.syn_NV_CV_1
                                 UNION ALL SELECT MaNV FROM dbo.syn_NV_CV_2
                                 UNION ALL SELECT MaNV FROM dbo.syn_NV_CV_3) AS m
                  WHERE m.MaNV = v.MaNV);

INSERT INTO @KQ
SELECT N'NhanVien', N'Tái thiết', N'Bộ lệch giữa NhanVien gốc và v_NhanVien',
    (SELECT COUNT(*) FROM (
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan FROM QLDH_GOC.dbo.NhanVien
        EXCEPT
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan FROM dbo.v_NhanVien) AS a)
  + (SELECT COUNT(*) FROM (
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan FROM dbo.v_NhanVien
        EXCEPT
        SELECT MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan FROM QLDH_GOC.dbo.NhanVien) AS b)
  + ABS((SELECT COUNT(*) FROM dbo.v_NhanVien) - (SELECT COUNT(*) FROM QLDH_GOC.dbo.NhanVien));

INSERT INTO @KQ
SELECT N'NhanVien', N'Rời nhau', N'MaNV thuộc nhiều hơn 1 mảnh ngang', COUNT(*)
FROM (SELECT MaNV FROM (SELECT MaNV FROM dbo.syn_NV_CV_1
                        UNION ALL SELECT MaNV FROM dbo.syn_NV_CV_2
                        UNION ALL SELECT MaNV FROM dbo.syn_NV_CV_3) AS m
      GROUP BY MaNV HAVING COUNT(*) > 1) AS x;

INSERT INTO @KQ
SELECT N'NhanVien', N'Rời nhau', N'Thuộc tính không khóa lặp ở cả CV và NS', COUNT(*)
FROM (
    SELECT name FROM QLDH_HN.sys.columns WHERE object_id = OBJECT_ID(N'QLDH_HN.dbo.NV_CV_1')
    INTERSECT
    SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NV_NS')
) AS x
WHERE name <> N'MaNV';

/* ===== DonHang, ChiTietDonHang (ngang dẫn xuất) ===== */
INSERT INTO @KQ
SELECT N'DonHang', N'Đầy đủ', N'Đơn hàng không thuộc mảnh nào', COUNT(*)
FROM QLDH_GOC.dbo.DonHang AS d
WHERE NOT EXISTS (SELECT 1 FROM dbo.v_DonHang AS m WHERE m.MaDH = d.MaDH);

INSERT INTO @KQ
SELECT N'DonHang', N'Tái thiết', N'Bộ lệch giữa DonHang gốc và v_DonHang',
    (SELECT COUNT(*) FROM (
        SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM QLDH_GOC.dbo.DonHang
        EXCEPT
        SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM dbo.v_DonHang) AS a)
  + (SELECT COUNT(*) FROM (
        SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM dbo.v_DonHang
        EXCEPT
        SELECT MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien FROM QLDH_GOC.dbo.DonHang) AS b)
  + ABS((SELECT COUNT(*) FROM dbo.v_DonHang) - (SELECT COUNT(*) FROM QLDH_GOC.dbo.DonHang));

INSERT INTO @KQ
SELECT N'DonHang', N'Rời nhau', N'MaDH thuộc nhiều hơn 1 mảnh', COUNT(*)
FROM (SELECT MaDH FROM dbo.v_DonHang GROUP BY MaDH HAVING COUNT(*) > 1) AS x;

INSERT INTO @KQ
SELECT N'ChiTietDonHang', N'Tái thiết', N'Bộ lệch giữa ChiTietDonHang gốc và v_ChiTietDonHang',
    (SELECT COUNT(*) FROM (
        SELECT MaDH, MaSP, SoLuong, DonGia FROM QLDH_GOC.dbo.ChiTietDonHang
        EXCEPT
        SELECT MaDH, MaSP, SoLuong, DonGia FROM dbo.v_ChiTietDonHang) AS a)
  + (SELECT COUNT(*) FROM (
        SELECT MaDH, MaSP, SoLuong, DonGia FROM dbo.v_ChiTietDonHang
        EXCEPT
        SELECT MaDH, MaSP, SoLuong, DonGia FROM QLDH_GOC.dbo.ChiTietDonHang) AS b)
  + ABS((SELECT COUNT(*) FROM dbo.v_ChiTietDonHang) - (SELECT COUNT(*) FROM QLDH_GOC.dbo.ChiTietDonHang));

-- Kết quả (chụp màn hình bảng này cho slide 15 và mục 4.7)
SELECT STT, QuanHe, QuyTac, MoTa, SoDongLech,
       CASE WHEN SoDongLech = 0 THEN N'ĐẠT' ELSE N'KHÔNG ĐẠT' END AS KetQua
FROM @KQ
ORDER BY STT;
-- Mong đợi: 13 dòng, tất cả SoDongLech = 0, KetQua = ĐẠT
GO
