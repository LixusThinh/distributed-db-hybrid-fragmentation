-- File được sinh tự động bởi demo/data/gen_demo_sql.py. Sửa dữ liệu thì sửa file .py rồi chạy lại.
/* =====================================================================
   02_fragments.sql
   Tạo 4 site, mỗi site là một database, rồi phân mảnh dữ liệu từ QLDH_GOC
   theo đúng thiết kế ở docs/01_bai_toan_thiet_ke.md:
     S0 QLDH_TRUSO : KH_1_TC, KH_2_TC, KH_3_TC, NV_NS, ChiNhanh*, SanPham*
     S1 QLDH_HN    : KH_1_GD, NV_CV_1, DH_1, CTDH_1, ChiNhanh*, SanPham*
     S2 QLDH_DN    : KH_2_GD, NV_CV_2, DH_2, CTDH_2, ChiNhanh*, SanPham*
     S3 QLDH_HCM   : KH_3_GD, NV_CV_3, DH_3, CTDH_3, ChiNhanh*, SanPham*
   (* = bản nhân bản)
   Chạy SAU 01_global_schema.sql. Chạy lại script này thì phải chạy lại 03.
   ===================================================================== */
USE master;
GO
IF DB_ID(N'QLDH_TRUSO') IS NOT NULL
BEGIN
    ALTER DATABASE QLDH_TRUSO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLDH_TRUSO;
END
GO
CREATE DATABASE QLDH_TRUSO;
GO
IF DB_ID(N'QLDH_HN') IS NOT NULL
BEGIN
    ALTER DATABASE QLDH_HN SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLDH_HN;
END
GO
CREATE DATABASE QLDH_HN;
GO
IF DB_ID(N'QLDH_DN') IS NOT NULL
BEGIN
    ALTER DATABASE QLDH_DN SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLDH_DN;
END
GO
CREATE DATABASE QLDH_DN;
GO
IF DB_ID(N'QLDH_HCM') IS NOT NULL
BEGIN
    ALTER DATABASE QLDH_HCM SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLDH_HCM;
END
GO
CREATE DATABASE QLDH_HCM;
GO

/* ---------------------------------------------------------------------
   SITE S1: QLDH_HN  (chi nhánh CN01)
   --------------------------------------------------------------------- */
USE QLDH_HN;
GO
-- Nhân bản toàn phần: ChiNhanh, SanPham
SELECT * INTO dbo.ChiNhanh FROM QLDH_GOC.dbo.ChiNhanh;
ALTER TABLE dbo.ChiNhanh ADD CONSTRAINT PK_ChiNhanh PRIMARY KEY (MaCN);
SELECT * INTO dbo.SanPham FROM QLDH_GOC.dbo.SanPham;
ALTER TABLE dbo.SanPham ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSP);
GO

-- KhachHang (hỗn hợp HV): KH_1_GD = π[MaKH,HoTen,SDT,Email,DiaChi,MaCN]( σ[MaCN='CN01'](KhachHang) )
CREATE TABLE dbo.KH_1_GD (
    MaKH   CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50)  NOT NULL,
    SDT    VARCHAR(12)   NOT NULL,
    Email  VARCHAR(60)   NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    MaCN   CHAR(4)       NOT NULL,
    -- vị từ phân mảnh được ghi thành ràng buộc: mảnh không nhận khách của chi nhánh khác
    CONSTRAINT CK_KH_1_GD_MaCN CHECK (MaCN = 'CN01')
);
INSERT INTO dbo.KH_1_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN01';                                   -- mong đợi 10 dòng

-- NhanVien (hỗn hợp VH): NV_CV_1 = σ[MaCN='CN01']( π[MaNV,HoTen,ChucVu,SDT,MaCN](NhanVien) )
CREATE TABLE dbo.NV_CV_1 (
    MaNV   CHAR(4)      NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50) NOT NULL,
    ChucVu NVARCHAR(30) NOT NULL,
    SDT    VARCHAR(12)  NOT NULL,
    MaCN   CHAR(4)      NOT NULL,
    CONSTRAINT CK_NV_CV_1_MaCN CHECK (MaCN = 'CN01')
);
INSERT INTO dbo.NV_CV_1 (MaNV, HoTen, ChucVu, SDT, MaCN)
SELECT MaNV, HoTen, ChucVu, SDT, MaCN
FROM QLDH_GOC.dbo.NhanVien
WHERE MaCN = 'CN01';                                   -- mong đợi 4 dòng

-- DonHang (ngang dẫn xuất): DH_1 = DonHang ⋉[MaKH] KH_1
CREATE TABLE dbo.DH_1 (
    MaDH      CHAR(5)       NOT NULL PRIMARY KEY,
    NgayDat   DATE          NOT NULL,
    MaKH      CHAR(5)       NOT NULL REFERENCES dbo.KH_1_GD(MaKH),
    MaNV      CHAR(4)       NOT NULL REFERENCES dbo.NV_CV_1(MaNV),
    TrangThai NVARCHAR(20)  NOT NULL,
    TongTien  DECIMAL(18,0) NOT NULL
);
INSERT INTO dbo.DH_1 (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
SELECT d.MaDH, d.NgayDat, d.MaKH, d.MaNV, d.TrangThai, d.TongTien
FROM QLDH_GOC.dbo.DonHang AS d
WHERE EXISTS (SELECT 1 FROM QLDH_GOC.dbo.KhachHang AS k      -- phép nửa kết nối
              WHERE k.MaKH = d.MaKH AND k.MaCN = 'CN01');   -- mong đợi 15 dòng

-- ChiTietDonHang (ngang dẫn xuất): CTDH_1 = ChiTietDonHang ⋉[MaDH] DH_1
CREATE TABLE dbo.CTDH_1 (
    MaDH    CHAR(5)       NOT NULL REFERENCES dbo.DH_1(MaDH),
    MaSP    CHAR(4)       NOT NULL REFERENCES dbo.SanPham(MaSP),
    SoLuong INT           NOT NULL CHECK (SoLuong > 0),
    DonGia  DECIMAL(18,0) NOT NULL,
    PRIMARY KEY (MaDH, MaSP)
);
INSERT INTO dbo.CTDH_1 (MaDH, MaSP, SoLuong, DonGia)
SELECT c.MaDH, c.MaSP, c.SoLuong, c.DonGia
FROM QLDH_GOC.dbo.ChiTietDonHang AS c
WHERE EXISTS (SELECT 1 FROM dbo.DH_1 AS d WHERE d.MaDH = c.MaDH);   -- mong đợi 29 dòng
GO

/* ---------------------------------------------------------------------
   SITE S2: QLDH_DN  (chi nhánh CN02)
   --------------------------------------------------------------------- */
USE QLDH_DN;
GO
-- Nhân bản toàn phần: ChiNhanh, SanPham
SELECT * INTO dbo.ChiNhanh FROM QLDH_GOC.dbo.ChiNhanh;
ALTER TABLE dbo.ChiNhanh ADD CONSTRAINT PK_ChiNhanh PRIMARY KEY (MaCN);
SELECT * INTO dbo.SanPham FROM QLDH_GOC.dbo.SanPham;
ALTER TABLE dbo.SanPham ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSP);
GO

-- KhachHang (hỗn hợp HV): KH_2_GD = π[MaKH,HoTen,SDT,Email,DiaChi,MaCN]( σ[MaCN='CN02'](KhachHang) )
CREATE TABLE dbo.KH_2_GD (
    MaKH   CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50)  NOT NULL,
    SDT    VARCHAR(12)   NOT NULL,
    Email  VARCHAR(60)   NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    MaCN   CHAR(4)       NOT NULL,
    -- vị từ phân mảnh được ghi thành ràng buộc: mảnh không nhận khách của chi nhánh khác
    CONSTRAINT CK_KH_2_GD_MaCN CHECK (MaCN = 'CN02')
);
INSERT INTO dbo.KH_2_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN02';                                   -- mong đợi 10 dòng

-- NhanVien (hỗn hợp VH): NV_CV_2 = σ[MaCN='CN02']( π[MaNV,HoTen,ChucVu,SDT,MaCN](NhanVien) )
CREATE TABLE dbo.NV_CV_2 (
    MaNV   CHAR(4)      NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50) NOT NULL,
    ChucVu NVARCHAR(30) NOT NULL,
    SDT    VARCHAR(12)  NOT NULL,
    MaCN   CHAR(4)      NOT NULL,
    CONSTRAINT CK_NV_CV_2_MaCN CHECK (MaCN = 'CN02')
);
INSERT INTO dbo.NV_CV_2 (MaNV, HoTen, ChucVu, SDT, MaCN)
SELECT MaNV, HoTen, ChucVu, SDT, MaCN
FROM QLDH_GOC.dbo.NhanVien
WHERE MaCN = 'CN02';                                   -- mong đợi 4 dòng

-- DonHang (ngang dẫn xuất): DH_2 = DonHang ⋉[MaKH] KH_2
CREATE TABLE dbo.DH_2 (
    MaDH      CHAR(5)       NOT NULL PRIMARY KEY,
    NgayDat   DATE          NOT NULL,
    MaKH      CHAR(5)       NOT NULL REFERENCES dbo.KH_2_GD(MaKH),
    MaNV      CHAR(4)       NOT NULL REFERENCES dbo.NV_CV_2(MaNV),
    TrangThai NVARCHAR(20)  NOT NULL,
    TongTien  DECIMAL(18,0) NOT NULL
);
INSERT INTO dbo.DH_2 (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
SELECT d.MaDH, d.NgayDat, d.MaKH, d.MaNV, d.TrangThai, d.TongTien
FROM QLDH_GOC.dbo.DonHang AS d
WHERE EXISTS (SELECT 1 FROM QLDH_GOC.dbo.KhachHang AS k      -- phép nửa kết nối
              WHERE k.MaKH = d.MaKH AND k.MaCN = 'CN02');   -- mong đợi 15 dòng

-- ChiTietDonHang (ngang dẫn xuất): CTDH_2 = ChiTietDonHang ⋉[MaDH] DH_2
CREATE TABLE dbo.CTDH_2 (
    MaDH    CHAR(5)       NOT NULL REFERENCES dbo.DH_2(MaDH),
    MaSP    CHAR(4)       NOT NULL REFERENCES dbo.SanPham(MaSP),
    SoLuong INT           NOT NULL CHECK (SoLuong > 0),
    DonGia  DECIMAL(18,0) NOT NULL,
    PRIMARY KEY (MaDH, MaSP)
);
INSERT INTO dbo.CTDH_2 (MaDH, MaSP, SoLuong, DonGia)
SELECT c.MaDH, c.MaSP, c.SoLuong, c.DonGia
FROM QLDH_GOC.dbo.ChiTietDonHang AS c
WHERE EXISTS (SELECT 1 FROM dbo.DH_2 AS d WHERE d.MaDH = c.MaDH);   -- mong đợi 37 dòng
GO

/* ---------------------------------------------------------------------
   SITE S3: QLDH_HCM  (chi nhánh CN03)
   --------------------------------------------------------------------- */
USE QLDH_HCM;
GO
-- Nhân bản toàn phần: ChiNhanh, SanPham
SELECT * INTO dbo.ChiNhanh FROM QLDH_GOC.dbo.ChiNhanh;
ALTER TABLE dbo.ChiNhanh ADD CONSTRAINT PK_ChiNhanh PRIMARY KEY (MaCN);
SELECT * INTO dbo.SanPham FROM QLDH_GOC.dbo.SanPham;
ALTER TABLE dbo.SanPham ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSP);
GO

-- KhachHang (hỗn hợp HV): KH_3_GD = π[MaKH,HoTen,SDT,Email,DiaChi,MaCN]( σ[MaCN='CN03'](KhachHang) )
CREATE TABLE dbo.KH_3_GD (
    MaKH   CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50)  NOT NULL,
    SDT    VARCHAR(12)   NOT NULL,
    Email  VARCHAR(60)   NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    MaCN   CHAR(4)       NOT NULL,
    -- vị từ phân mảnh được ghi thành ràng buộc: mảnh không nhận khách của chi nhánh khác
    CONSTRAINT CK_KH_3_GD_MaCN CHECK (MaCN = 'CN03')
);
INSERT INTO dbo.KH_3_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN03';                                   -- mong đợi 10 dòng

-- NhanVien (hỗn hợp VH): NV_CV_3 = σ[MaCN='CN03']( π[MaNV,HoTen,ChucVu,SDT,MaCN](NhanVien) )
CREATE TABLE dbo.NV_CV_3 (
    MaNV   CHAR(4)      NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50) NOT NULL,
    ChucVu NVARCHAR(30) NOT NULL,
    SDT    VARCHAR(12)  NOT NULL,
    MaCN   CHAR(4)      NOT NULL,
    CONSTRAINT CK_NV_CV_3_MaCN CHECK (MaCN = 'CN03')
);
INSERT INTO dbo.NV_CV_3 (MaNV, HoTen, ChucVu, SDT, MaCN)
SELECT MaNV, HoTen, ChucVu, SDT, MaCN
FROM QLDH_GOC.dbo.NhanVien
WHERE MaCN = 'CN03';                                   -- mong đợi 4 dòng

-- DonHang (ngang dẫn xuất): DH_3 = DonHang ⋉[MaKH] KH_3
CREATE TABLE dbo.DH_3 (
    MaDH      CHAR(5)       NOT NULL PRIMARY KEY,
    NgayDat   DATE          NOT NULL,
    MaKH      CHAR(5)       NOT NULL REFERENCES dbo.KH_3_GD(MaKH),
    MaNV      CHAR(4)       NOT NULL REFERENCES dbo.NV_CV_3(MaNV),
    TrangThai NVARCHAR(20)  NOT NULL,
    TongTien  DECIMAL(18,0) NOT NULL
);
INSERT INTO dbo.DH_3 (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
SELECT d.MaDH, d.NgayDat, d.MaKH, d.MaNV, d.TrangThai, d.TongTien
FROM QLDH_GOC.dbo.DonHang AS d
WHERE EXISTS (SELECT 1 FROM QLDH_GOC.dbo.KhachHang AS k      -- phép nửa kết nối
              WHERE k.MaKH = d.MaKH AND k.MaCN = 'CN03');   -- mong đợi 15 dòng

-- ChiTietDonHang (ngang dẫn xuất): CTDH_3 = ChiTietDonHang ⋉[MaDH] DH_3
CREATE TABLE dbo.CTDH_3 (
    MaDH    CHAR(5)       NOT NULL REFERENCES dbo.DH_3(MaDH),
    MaSP    CHAR(4)       NOT NULL REFERENCES dbo.SanPham(MaSP),
    SoLuong INT           NOT NULL CHECK (SoLuong > 0),
    DonGia  DECIMAL(18,0) NOT NULL,
    PRIMARY KEY (MaDH, MaSP)
);
INSERT INTO dbo.CTDH_3 (MaDH, MaSP, SoLuong, DonGia)
SELECT c.MaDH, c.MaSP, c.SoLuong, c.DonGia
FROM QLDH_GOC.dbo.ChiTietDonHang AS c
WHERE EXISTS (SELECT 1 FROM dbo.DH_3 AS d WHERE d.MaDH = c.MaDH);   -- mong đợi 31 dòng
GO

/* ---------------------------------------------------------------------
   SITE S0: QLDH_TRUSO  (trụ sở chính – phòng Kế toán, Nhân sự)
   --------------------------------------------------------------------- */
USE QLDH_TRUSO;
GO
-- Nhân bản toàn phần: ChiNhanh, SanPham
SELECT * INTO dbo.ChiNhanh FROM QLDH_GOC.dbo.ChiNhanh;
ALTER TABLE dbo.ChiNhanh ADD CONSTRAINT PK_ChiNhanh PRIMARY KEY (MaCN);
SELECT * INTO dbo.SanPham FROM QLDH_GOC.dbo.SanPham;
ALTER TABLE dbo.SanPham ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSP);
GO

-- NhanVien (hỗn hợp VH): NV_NS = π[MaNV,NgaySinh,CCCD,Luong,SoTaiKhoan](NhanVien) – dữ liệu nhạy cảm
CREATE TABLE dbo.NV_NS (
    MaNV       CHAR(4)       NOT NULL PRIMARY KEY,
    NgaySinh   DATE          NOT NULL,
    CCCD       CHAR(12)      NOT NULL UNIQUE,
    Luong      DECIMAL(18,0) NOT NULL,
    SoTaiKhoan VARCHAR(20)   NOT NULL
);
INSERT INTO dbo.NV_NS (MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan)
SELECT MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan
FROM QLDH_GOC.dbo.NhanVien;                              -- mong đợi 12 dòng

-- KhachHang (hỗn hợp HV): KH_1_TC = π[MaKH,HanMucNo,CongNo,DiemTichLuy]( σ[MaCN='CN01'](KhachHang) )
CREATE TABLE dbo.KH_1_TC (
    MaKH        CHAR(5)       NOT NULL PRIMARY KEY,
    HanMucNo    DECIMAL(18,0) NOT NULL,
    CongNo      DECIMAL(18,0) NOT NULL,
    DiemTichLuy INT           NOT NULL
);
INSERT INTO dbo.KH_1_TC (MaKH, HanMucNo, CongNo, DiemTichLuy)
SELECT MaKH, HanMucNo, CongNo, DiemTichLuy
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN01';                                   -- mong đợi 10 dòng

-- KhachHang (hỗn hợp HV): KH_2_TC = π[MaKH,HanMucNo,CongNo,DiemTichLuy]( σ[MaCN='CN02'](KhachHang) )
CREATE TABLE dbo.KH_2_TC (
    MaKH        CHAR(5)       NOT NULL PRIMARY KEY,
    HanMucNo    DECIMAL(18,0) NOT NULL,
    CongNo      DECIMAL(18,0) NOT NULL,
    DiemTichLuy INT           NOT NULL
);
INSERT INTO dbo.KH_2_TC (MaKH, HanMucNo, CongNo, DiemTichLuy)
SELECT MaKH, HanMucNo, CongNo, DiemTichLuy
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN02';                                   -- mong đợi 10 dòng

-- KhachHang (hỗn hợp HV): KH_3_TC = π[MaKH,HanMucNo,CongNo,DiemTichLuy]( σ[MaCN='CN03'](KhachHang) )
CREATE TABLE dbo.KH_3_TC (
    MaKH        CHAR(5)       NOT NULL PRIMARY KEY,
    HanMucNo    DECIMAL(18,0) NOT NULL,
    CongNo      DECIMAL(18,0) NOT NULL,
    DiemTichLuy INT           NOT NULL
);
INSERT INTO dbo.KH_3_TC (MaKH, HanMucNo, CongNo, DiemTichLuy)
SELECT MaKH, HanMucNo, CongNo, DiemTichLuy
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN03';                                   -- mong đợi 10 dòng
GO

-- Tổng kết số dòng từng mảnh (chạy để chụp màn hình)
SELECT N'S0 QLDH_TRUSO' AS Site, N'NV_NS' AS Manh, COUNT(*) AS SoDong FROM QLDH_TRUSO.dbo.NV_NS
UNION ALL SELECT N'S0 QLDH_TRUSO', N'KH_1_TC', COUNT(*) FROM QLDH_TRUSO.dbo.KH_1_TC
UNION ALL SELECT N'S0 QLDH_TRUSO', N'KH_2_TC', COUNT(*) FROM QLDH_TRUSO.dbo.KH_2_TC
UNION ALL SELECT N'S0 QLDH_TRUSO', N'KH_3_TC', COUNT(*) FROM QLDH_TRUSO.dbo.KH_3_TC
UNION ALL SELECT N'S1 QLDH_HN', N'KH_1_GD', COUNT(*) FROM QLDH_HN.dbo.KH_1_GD
UNION ALL SELECT N'S1 QLDH_HN', N'NV_CV_1', COUNT(*) FROM QLDH_HN.dbo.NV_CV_1
UNION ALL SELECT N'S1 QLDH_HN', N'DH_1', COUNT(*) FROM QLDH_HN.dbo.DH_1
UNION ALL SELECT N'S1 QLDH_HN', N'CTDH_1', COUNT(*) FROM QLDH_HN.dbo.CTDH_1
UNION ALL SELECT N'S2 QLDH_DN', N'KH_2_GD', COUNT(*) FROM QLDH_DN.dbo.KH_2_GD
UNION ALL SELECT N'S2 QLDH_DN', N'NV_CV_2', COUNT(*) FROM QLDH_DN.dbo.NV_CV_2
UNION ALL SELECT N'S2 QLDH_DN', N'DH_2', COUNT(*) FROM QLDH_DN.dbo.DH_2
UNION ALL SELECT N'S2 QLDH_DN', N'CTDH_2', COUNT(*) FROM QLDH_DN.dbo.CTDH_2
UNION ALL SELECT N'S3 QLDH_HCM', N'KH_3_GD', COUNT(*) FROM QLDH_HCM.dbo.KH_3_GD
UNION ALL SELECT N'S3 QLDH_HCM', N'NV_CV_3', COUNT(*) FROM QLDH_HCM.dbo.NV_CV_3
UNION ALL SELECT N'S3 QLDH_HCM', N'DH_3', COUNT(*) FROM QLDH_HCM.dbo.DH_3
UNION ALL SELECT N'S3 QLDH_HCM', N'CTDH_3', COUNT(*) FROM QLDH_HCM.dbo.CTDH_3;
-- Mong đợi: NV_NS = 12; S1: KH_1_GD = KH_1_TC = 10, NV_CV_1 = 4, DH_1 = 15, CTDH_1 = 29; S2: KH_2_GD = KH_2_TC = 10, NV_CV_2 = 4, DH_2 = 15, CTDH_2 = 37; S3: KH_3_GD = KH_3_TC = 10, NV_CV_3 = 4, DH_3 = 15, CTDH_3 = 31
