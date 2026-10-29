-- File được sinh tự động bởi demo/data/gen_demo_sql.py. Sửa dữ liệu thì sửa file .py rồi chạy lại.
/* =====================================================================
   01_global_schema.sql
   Tạo CSDL gốc QLDH_GOC: lược đồ TOÀN CỤC của hệ thống quản lý đơn hàng
   và dữ liệu mẫu. Các site (02_fragments.sql) được phân mảnh từ đây.
   ===================================================================== */
USE master;
GO
IF DB_ID(N'QLDH_GOC') IS NOT NULL
BEGIN
    ALTER DATABASE QLDH_GOC SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLDH_GOC;
END
GO
CREATE DATABASE QLDH_GOC;
GO
USE QLDH_GOC;
GO

CREATE TABLE dbo.ChiNhanh (
    MaCN    CHAR(4)       NOT NULL PRIMARY KEY,
    TenCN   NVARCHAR(50)  NOT NULL,
    KhuVuc  NVARCHAR(10)  NOT NULL,
    DiaChi  NVARCHAR(100) NOT NULL,
    SDT     VARCHAR(12)   NOT NULL,
    -- Miền giá trị của MaCN: cơ sở để chứng minh tính ĐẦY ĐỦ của phân mảnh ngang
    CONSTRAINT CK_ChiNhanh_MaCN CHECK (MaCN IN ('CN01', 'CN02', 'CN03'))
);

CREATE TABLE dbo.KhachHang (
    MaKH        CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen       NVARCHAR(50)  NOT NULL,
    SDT         VARCHAR(12)   NOT NULL,
    Email       VARCHAR(60)   NULL,
    DiaChi      NVARCHAR(100) NOT NULL,
    MaCN        CHAR(4)       NOT NULL REFERENCES dbo.ChiNhanh(MaCN),
    HanMucNo    DECIMAL(18,0) NOT NULL,
    CongNo      DECIMAL(18,0) NOT NULL DEFAULT 0,
    DiemTichLuy INT           NOT NULL DEFAULT 0,
    CONSTRAINT CK_KhachHang_MaCN CHECK (MaCN IN ('CN01', 'CN02', 'CN03'))
);

CREATE TABLE dbo.NhanVien (
    MaNV       CHAR(4)       NOT NULL PRIMARY KEY,
    HoTen      NVARCHAR(50)  NOT NULL,
    ChucVu     NVARCHAR(30)  NOT NULL,
    SDT        VARCHAR(12)   NOT NULL,
    MaCN       CHAR(4)       NOT NULL REFERENCES dbo.ChiNhanh(MaCN),
    NgaySinh   DATE          NOT NULL,
    CCCD       CHAR(12)      NOT NULL UNIQUE,
    Luong      DECIMAL(18,0) NOT NULL,
    SoTaiKhoan VARCHAR(20)   NOT NULL,
    CONSTRAINT CK_NhanVien_MaCN CHECK (MaCN IN ('CN01', 'CN02', 'CN03'))
);

CREATE TABLE dbo.SanPham (
    MaSP      CHAR(4)       NOT NULL PRIMARY KEY,
    TenSP     NVARCHAR(60)  NOT NULL,
    DonViTinh NVARCHAR(10)  NOT NULL,
    GiaBan    DECIMAL(18,0) NOT NULL,
    MoTa      NVARCHAR(100) NULL
);

CREATE TABLE dbo.DonHang (
    MaDH      CHAR(5)       NOT NULL PRIMARY KEY,
    NgayDat   DATE          NOT NULL,
    MaKH      CHAR(5)       NOT NULL REFERENCES dbo.KhachHang(MaKH),
    MaNV      CHAR(4)       NOT NULL REFERENCES dbo.NhanVien(MaNV),
    TrangThai NVARCHAR(20)  NOT NULL,
    TongTien  DECIMAL(18,0) NOT NULL
);

CREATE TABLE dbo.ChiTietDonHang (
    MaDH    CHAR(5)       NOT NULL REFERENCES dbo.DonHang(MaDH),
    MaSP    CHAR(4)       NOT NULL REFERENCES dbo.SanPham(MaSP),
    SoLuong INT           NOT NULL CHECK (SoLuong > 0),
    DonGia  DECIMAL(18,0) NOT NULL,
    PRIMARY KEY (MaDH, MaSP)
);
GO

-- ------------------------------------------------------------ dữ liệu mẫu

-- ChiNhanh: 3 dòng
INSERT INTO dbo.ChiNhanh (MaCN, TenCN, KhuVuc, DiaChi, SDT) VALUES
    (N'CN01', N'Chi nhánh Hà Nội', N'Bắc', N'25 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', N'0243825001'),
    (N'CN02', N'Chi nhánh Đà Nẵng', N'Trung', N'88 Bạch Đằng, Hải Châu, Đà Nẵng', N'0236382502'),
    (N'CN03', N'Chi nhánh TP.HCM', N'Nam', N'120 Nguyễn Huệ, Quận 1, TP.HCM', N'0283825003');

-- KhachHang: 30 dòng
INSERT INTO dbo.KhachHang (MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy) VALUES
    (N'KH001', N'Bùi Hoàng Nam', N'0987973091', N'bui.hoang.nam1@example.com', N'166 Trần Hưng Đạo, Cầu Giấy, Hà Nội', N'CN01', 300000000, 223300000, 907),
    (N'KH002', N'Phạm Thanh An', N'0945568151', N'pham.thanh.an2@example.com', N'209 Nguyễn Văn Linh, Cẩm Lệ, Đà Nẵng', N'CN02', 200000000, 39900000, 4566),
    (N'KH003', N'Đặng Thanh Hà', N'0961698716', N'dang.thanh.ha3@example.com', N'225 Quang Trung, Quận 1, TP.HCM', N'CN03', 200000000, 69100000, 4148),
    (N'KH004', N'Hồ Minh Lan', N'0909320819', N'ho.minh.lan4@example.com', N'217 Lê Duẩn, Thanh Xuân, Hà Nội', N'CN01', 300000000, 146200000, 3517),
    (N'KH005', N'Hoàng Thanh Hạnh', N'0984864887', N'hoang.thanh.hanh5@example.com', N'218 Trần Hưng Đạo, Cẩm Lệ, Đà Nẵng', N'CN02', 300000000, 192200000, 3292),
    (N'KH006', N'Phan Thu Lan', N'0975347787', N'phan.thu.lan6@example.com', N'3 Lê Lợi, Quận 3, TP.HCM', N'CN03', 300000000, 229000000, 3557),
    (N'KH007', N'Đặng Quốc Long', N'0926714751', N'dang.quoc.long7@example.com', N'235 Trần Hưng Đạo, Hai Bà Trưng, Hà Nội', N'CN01', 200000000, 86100000, 1594),
    (N'KH008', N'Hoàng Thanh An', N'0933190845', N'hoang.thanh.an8@example.com', N'24 Lê Lợi, Ngũ Hành Sơn, Đà Nẵng', N'CN02', 50000000, 29000000, 1267),
    (N'KH009', N'Bùi Bảo Phúc', N'0979298416', N'bui.bao.phuc9@example.com', N'148 Nguyễn Văn Linh, Gò Vấp, TP.HCM', N'CN03', 100000000, 51900000, 1311),
    (N'KH010', N'Đặng Hoàng Khoa', N'0916105500', N'dang.hoang.khoa10@example.com', N'100 Nguyễn Trãi, Thanh Xuân, Hà Nội', N'CN01', 100000000, 35700000, 4181),
    (N'KH011', N'Bùi Bảo Lan', N'0999229836', N'bui.bao.lan11@example.com', N'116 Phan Chu Trinh, Hải Châu, Đà Nẵng', N'CN02', 300000000, 270400000, 2755),
    (N'KH012', N'Vũ Bảo Yến', N'0920807370', N'vu.bao.yen12@example.com', N'18 Lê Duẩn, Quận 1, TP.HCM', N'CN03', 100000000, 61500000, 1057),
    (N'KH013', N'Hoàng Minh Quân', N'0961642524', N'hoang.minh.quan13@example.com', N'217 Nguyễn Trãi, Hai Bà Trưng, Hà Nội', N'CN01', 200000000, 80800000, 3800),
    (N'KH014', N'Ngô Thu Nga', N'0988413301', N'ngo.thu.nga14@example.com', N'46 Phan Chu Trinh, Liên Chiểu, Đà Nẵng', N'CN02', 300000000, 126700000, 3720),
    (N'KH015', N'Ngô Minh Ngân', N'0958983194', N'ngo.minh.ngan15@example.com', N'214 Nguyễn Trãi, Quận 1, TP.HCM', N'CN03', 200000000, 160800000, 4553),
    (N'KH016', N'Đặng Hoàng Hiếu', N'0962105218', N'dang.hoang.hieu16@example.com', N'172 Nguyễn Trãi, Ba Đình, Hà Nội', N'CN01', 200000000, 18300000, 2568),
    (N'KH017', N'Lê Thu Linh', N'0946001304', N'le.thu.linh17@example.com', N'42 Quang Trung, Sơn Trà, Đà Nẵng', N'CN02', 50000000, 700000, 1007),
    (N'KH018', N'Đỗ Quốc Tuấn', N'0997615846', N'do.quoc.tuan18@example.com', N'117 Lê Lợi, Phú Nhuận, TP.HCM', N'CN03', 200000000, 115500000, 2391),
    (N'KH019', N'Trần Bảo Yến', N'0914659085', N'tran.bao.yen19@example.com', N'112 Lê Lợi, Đống Đa, Hà Nội', N'CN01', 200000000, 55000000, 1617),
    (N'KH020', N'Phạm Minh Phúc', N'0994069256', N'pham.minh.phuc20@example.com', N'32 Trần Hưng Đạo, Hải Châu, Đà Nẵng', N'CN02', 100000000, 49600000, 3146),
    (N'KH021', N'Vũ Thanh Vy', N'0988642300', N'vu.thanh.vy21@example.com', N'57 Nguyễn Trãi, Quận 3, TP.HCM', N'CN03', 50000000, 31400000, 2267),
    (N'KH022', N'Ngô Thu Linh', N'0984585003', N'ngo.thu.linh22@example.com', N'36 Trần Hưng Đạo, Cầu Giấy, Hà Nội', N'CN01', 50000000, 30900000, 3854),
    (N'KH023', N'Vũ Bảo Nam', N'0953845355', N'vu.bao.nam23@example.com', N'221 Nguyễn Trãi, Cẩm Lệ, Đà Nẵng', N'CN02', 300000000, 201600000, 3762),
    (N'KH024', N'Lý Bảo Trang', N'0905860214', N'ly.bao.trang24@example.com', N'80 Hai Bà Trưng, Quận 3, TP.HCM', N'CN03', 300000000, 43800000, 3053),
    (N'KH025', N'Hoàng Bảo Yến', N'0994906688', N'hoang.bao.yen25@example.com', N'26 Lê Lợi, Thanh Xuân, Hà Nội', N'CN01', 100000000, 80700000, 1294),
    (N'KH026', N'Lê Minh Sơn', N'0993244845', N'le.minh.son26@example.com', N'100 Phan Chu Trinh, Liên Chiểu, Đà Nẵng', N'CN02', 200000000, 59000000, 1097),
    (N'KH027', N'Phan Bảo Vy', N'0982802582', N'phan.bao.vy27@example.com', N'3 Nguyễn Văn Linh, Phú Nhuận, TP.HCM', N'CN03', 200000000, 154300000, 1342),
    (N'KH028', N'Phạm Hoàng Quân', N'0938299321', N'pham.hoang.quan28@example.com', N'226 Lê Lợi, Đống Đa, Hà Nội', N'CN01', 50000000, 17500000, 2672),
    (N'KH029', N'Phạm Bảo Châu', N'0957718835', N'pham.bao.chau29@example.com', N'98 Quang Trung, Liên Chiểu, Đà Nẵng', N'CN02', 200000000, 123000000, 3735),
    (N'KH030', N'Lê Thị Ngân', N'0932568855', N'le.thi.ngan30@example.com', N'250 Trần Hưng Đạo, Phú Nhuận, TP.HCM', N'CN03', 200000000, 50400000, 4040);

-- NhanVien: 12 dòng
INSERT INTO dbo.NhanVien (MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan) VALUES
    (N'NV01', N'Dương Quốc Dũng', N'Quản lý chi nhánh', N'0984352814', N'CN01', N'1997-06-06', N'001097735569', 25500000, N'632792645154'),
    (N'NV02', N'Võ Ngọc Linh', N'Nhân viên bán hàng', N'0999677500', N'CN01', N'1999-11-13', N'001199085651', 13000000, N'788365506204'),
    (N'NV03', N'Phan Minh Vy', N'Nhân viên bán hàng', N'0924196898', N'CN01', N'1988-11-28', N'001188503784', 12000000, N'951838012537'),
    (N'NV04', N'Hoàng Thị Nga', N'Thủ kho', N'0954735486', N'CN01', N'1988-01-09', N'001188028837', 10500000, N'555597475407'),
    (N'NV05', N'Huỳnh Thu Thảo', N'Quản lý chi nhánh', N'0986193073', N'CN02', N'1991-10-02', N'048191188479', 25000000, N'188957555218'),
    (N'NV06', N'Hoàng Thanh Tâm', N'Nhân viên bán hàng', N'0990044224', N'CN02', N'1998-09-28', N'048098834728', 14000000, N'556898329822'),
    (N'NV07', N'Bùi Minh Sơn', N'Nhân viên bán hàng', N'0980700159', N'CN02', N'1996-03-15', N'048096202269', 13000000, N'780438581762'),
    (N'NV08', N'Đỗ Bảo Hải', N'Thủ kho', N'0947897133', N'CN02', N'1993-06-25', N'048093283166', 10000000, N'323373528667'),
    (N'NV09', N'Đỗ Đức Dũng', N'Quản lý chi nhánh', N'0912835769', N'CN03', N'1987-06-23', N'079087123636', 26000000, N'082445607874'),
    (N'NV10', N'Phạm Thanh Ngân', N'Nhân viên bán hàng', N'0997978025', N'CN03', N'1986-12-22', N'079186417758', 13000000, N'881440190187'),
    (N'NV11', N'Vũ Hoàng Tâm', N'Nhân viên bán hàng', N'0956073927', N'CN03', N'1985-02-13', N'079085284001', 12000000, N'981524735736'),
    (N'NV12', N'Đỗ Minh Thảo', N'Thủ kho', N'0928195391', N'CN03', N'1988-10-16', N'079188780736', 11000000, N'087243854690');

-- SanPham: 10 dòng
INSERT INTO dbo.SanPham (MaSP, TenSP, DonViTinh, GiaBan, MoTa) VALUES
    (N'SP01', N'Laptop văn phòng 15 inch', N'Cái', 16990000, N'Core i5, RAM 16GB, SSD 512GB'),
    (N'SP02', N'Màn hình 24 inch Full HD', N'Cái', 3290000, N'Tấm nền IPS, 75Hz'),
    (N'SP03', N'Bàn phím cơ', N'Cái', 890000, N'Switch đỏ, có đèn nền'),
    (N'SP04', N'Chuột không dây', N'Cái', 350000, N'Kết nối 2.4GHz'),
    (N'SP05', N'Máy in laser đơn sắc', N'Cái', 4590000, N'In 2 mặt tự động'),
    (N'SP06', N'Giấy A4 (thùng 5 ram)', N'Thùng', 420000, N'Định lượng 70gsm'),
    (N'SP07', N'Ổ cứng SSD 512GB', N'Cái', 1290000, N'Chuẩn M.2 NVMe'),
    (N'SP08', N'USB 64GB', N'Cái', 190000, N'Chuẩn USB 3.2'),
    (N'SP09', N'Tai nghe chụp tai', N'Cái', 650000, N'Có micro'),
    (N'SP10', N'Webcam Full HD', N'Cái', 790000, N'1080p, có micro');

-- DonHang: 45 dòng
INSERT INTO dbo.DonHang (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien) VALUES
    (N'DH001', N'2026-09-01', N'KH018', N'NV11', N'Hoàn tất', 1080000),
    (N'DH002', N'2026-09-03', N'KH006', N'NV10', N'Hoàn tất', 2730000),
    (N'DH003', N'2026-09-03', N'KH025', N'NV02', N'Hoàn tất', 67960000),
    (N'DH004', N'2026-09-04', N'KH023', N'NV07', N'Đang giao', 5640000),
    (N'DH005', N'2026-09-05', N'KH014', N'NV06', N'Hoàn tất', 2580000),
    (N'DH006', N'2026-09-06', N'KH029', N'NV06', N'Đã hủy', 51620000),
    (N'DH007', N'2026-09-06', N'KH009', N'NV11', N'Hoàn tất', 8170000),
    (N'DH008', N'2026-09-11', N'KH007', N'NV02', N'Hoàn tất', 17260000),
    (N'DH009', N'2026-09-11', N'KH030', N'NV11', N'Hoàn tất', 1290000),
    (N'DH010', N'2026-09-11', N'KH030', N'NV10', N'Hoàn tất', 1050000),
    (N'DH011', N'2026-09-12', N'KH005', N'NV07', N'Hoàn tất', 2940000),
    (N'DH012', N'2026-09-13', N'KH030', N'NV11', N'Đang giao', 10020000),
    (N'DH013', N'2026-09-15', N'KH027', N'NV10', N'Đang giao', 1050000),
    (N'DH014', N'2026-09-16', N'KH020', N'NV06', N'Đang giao', 11820000),
    (N'DH015', N'2026-09-16', N'KH016', N'NV03', N'Đã hủy', 2370000),
    (N'DH016', N'2026-09-16', N'KH026', N'NV07', N'Hoàn tất', 11010000),
    (N'DH017', N'2026-09-17', N'KH030', N'NV10', N'Hoàn tất', 6940000),
    (N'DH018', N'2026-09-19', N'KH024', N'NV10', N'Đang giao', 83410000),
    (N'DH019', N'2026-09-23', N'KH026', N'NV07', N'Hoàn tất', 8750000),
    (N'DH020', N'2026-09-25', N'KH001', N'NV03', N'Mới', 8260000),
    (N'DH021', N'2026-09-26', N'KH003', N'NV10', N'Hoàn tất', 700000),
    (N'DH022', N'2026-09-27', N'KH030', N'NV11', N'Hoàn tất', 5650000),
    (N'DH023', N'2026-09-29', N'KH026', N'NV06', N'Hoàn tất', 6580000),
    (N'DH024', N'2026-09-30', N'KH005', N'NV07', N'Hoàn tất', 14110000),
    (N'DH025', N'2026-10-01', N'KH003', N'NV10', N'Hoàn tất', 1260000),
    (N'DH026', N'2026-10-02', N'KH019', N'NV02', N'Hoàn tất', 10760000),
    (N'DH027', N'2026-10-03', N'KH016', N'NV02', N'Mới', 760000),
    (N'DH028', N'2026-10-04', N'KH004', N'NV03', N'Đang giao', 3290000),
    (N'DH029', N'2026-10-05', N'KH022', N'NV03', N'Hoàn tất', 760000),
    (N'DH030', N'2026-10-05', N'KH022', N'NV03', N'Hoàn tất', 47140000),
    (N'DH031', N'2026-10-05', N'KH006', N'NV11', N'Hoàn tất', 4440000),
    (N'DH032', N'2026-10-05', N'KH002', N'NV06', N'Hoàn tất', 9050000),
    (N'DH033', N'2026-10-06', N'KH006', N'NV11', N'Đang giao', 28610000),
    (N'DH034', N'2026-10-06', N'KH029', N'NV06', N'Hoàn tất', 73200000),
    (N'DH035', N'2026-10-06', N'KH013', N'NV02', N'Hoàn tất', 5610000),
    (N'DH036', N'2026-10-08', N'KH004', N'NV02', N'Đang giao', 1050000),
    (N'DH037', N'2026-10-10', N'KH017', N'NV06', N'Đang giao', 11960000),
    (N'DH038', N'2026-10-10', N'KH004', N'NV03', N'Hoàn tất', 3280000),
    (N'DH039', N'2026-10-11', N'KH018', N'NV11', N'Hoàn tất', 14950000),
    (N'DH040', N'2026-10-12', N'KH002', N'NV06', N'Hoàn tất', 74500000),
    (N'DH041', N'2026-10-14', N'KH019', N'NV03', N'Hoàn tất', 26520000),
    (N'DH042', N'2026-10-15', N'KH007', N'NV02', N'Hoàn tất', 2060000),
    (N'DH043', N'2026-10-17', N'KH005', N'NV07', N'Đã hủy', 3290000),
    (N'DH044', N'2026-10-19', N'KH005', N'NV06', N'Hoàn tất', 24820000),
    (N'DH045', N'2026-10-23', N'KH016', N'NV03', N'Hoàn tất', 67960000);

-- ChiTietDonHang: 97 dòng
INSERT INTO dbo.ChiTietDonHang (MaDH, MaSP, SoLuong, DonGia) VALUES
    (N'DH001', N'SP03', 1, 890000),
    (N'DH001', N'SP08', 1, 190000),
    (N'DH002', N'SP09', 2, 650000),
    (N'DH002', N'SP04', 3, 350000),
    (N'DH002', N'SP08', 2, 190000),
    (N'DH003', N'SP01', 4, 16990000),
    (N'DH004', N'SP10', 1, 790000),
    (N'DH004', N'SP06', 10, 420000),
    (N'DH004', N'SP09', 1, 650000),
    (N'DH005', N'SP07', 2, 1290000),
    (N'DH006', N'SP09', 1, 650000),
    (N'DH006', N'SP01', 3, 16990000),
    (N'DH007', N'SP02', 2, 3290000),
    (N'DH007', N'SP04', 4, 350000),
    (N'DH007', N'SP08', 1, 190000),
    (N'DH008', N'SP09', 4, 650000),
    (N'DH008', N'SP05', 3, 4590000),
    (N'DH008', N'SP03', 1, 890000),
    (N'DH009', N'SP07', 1, 1290000),
    (N'DH010', N'SP04', 3, 350000),
    (N'DH011', N'SP08', 3, 190000),
    (N'DH011', N'SP10', 3, 790000),
    (N'DH012', N'SP05', 2, 4590000),
    (N'DH012', N'SP06', 2, 420000),
    (N'DH013', N'SP04', 3, 350000),
    (N'DH014', N'SP06', 4, 420000),
    (N'DH014', N'SP03', 4, 890000),
    (N'DH014', N'SP02', 2, 3290000),
    (N'DH015', N'SP10', 3, 790000),
    (N'DH016', N'SP05', 2, 4590000),
    (N'DH016', N'SP06', 3, 420000),
    (N'DH016', N'SP08', 3, 190000),
    (N'DH017', N'SP03', 2, 890000),
    (N'DH017', N'SP07', 4, 1290000),
    (N'DH018', N'SP05', 3, 4590000),
    (N'DH018', N'SP01', 4, 16990000),
    (N'DH018', N'SP06', 4, 420000),
    (N'DH019', N'SP10', 3, 790000),
    (N'DH019', N'SP09', 4, 650000),
    (N'DH019', N'SP06', 9, 420000),
    (N'DH020', N'SP07', 2, 1290000),
    (N'DH020', N'SP10', 4, 790000),
    (N'DH020', N'SP06', 6, 420000),
    (N'DH021', N'SP04', 2, 350000),
    (N'DH022', N'SP03', 2, 890000),
    (N'DH022', N'SP07', 3, 1290000),
    (N'DH023', N'SP02', 2, 3290000),
    (N'DH024', N'SP06', 7, 420000),
    (N'DH024', N'SP09', 2, 650000),
    (N'DH024', N'SP02', 3, 3290000),
    (N'DH025', N'SP06', 3, 420000),
    (N'DH026', N'SP02', 3, 3290000),
    (N'DH026', N'SP04', 2, 350000),
    (N'DH026', N'SP08', 1, 190000),
    (N'DH027', N'SP08', 4, 190000),
    (N'DH028', N'SP02', 1, 3290000),
    (N'DH029', N'SP08', 4, 190000),
    (N'DH030', N'SP02', 4, 3290000),
    (N'DH030', N'SP01', 2, 16990000),
    (N'DH031', N'SP09', 4, 650000),
    (N'DH031', N'SP10', 1, 790000),
    (N'DH031', N'SP04', 3, 350000),
    (N'DH032', N'SP10', 4, 790000),
    (N'DH032', N'SP05', 1, 4590000),
    (N'DH032', N'SP09', 2, 650000),
    (N'DH033', N'SP02', 4, 3290000),
    (N'DH033', N'SP05', 3, 4590000),
    (N'DH033', N'SP06', 4, 420000),
    (N'DH034', N'SP07', 3, 1290000),
    (N'DH034', N'SP05', 4, 4590000),
    (N'DH034', N'SP01', 3, 16990000),
    (N'DH035', N'SP10', 3, 790000),
    (N'DH035', N'SP08', 3, 190000),
    (N'DH035', N'SP03', 3, 890000),
    (N'DH036', N'SP04', 3, 350000),
    (N'DH037', N'SP06', 10, 420000),
    (N'DH037', N'SP07', 4, 1290000),
    (N'DH037', N'SP09', 4, 650000),
    (N'DH038', N'SP08', 4, 190000),
    (N'DH038', N'SP06', 6, 420000),
    (N'DH039', N'SP06', 1, 420000),
    (N'DH039', N'SP05', 3, 4590000),
    (N'DH039', N'SP08', 4, 190000),
    (N'DH040', N'SP05', 1, 4590000),
    (N'DH040', N'SP09', 3, 650000),
    (N'DH040', N'SP01', 4, 16990000),
    (N'DH041', N'SP05', 2, 4590000),
    (N'DH041', N'SP01', 1, 16990000),
    (N'DH041', N'SP04', 1, 350000),
    (N'DH042', N'SP06', 2, 420000),
    (N'DH042', N'SP09', 1, 650000),
    (N'DH042', N'SP08', 3, 190000),
    (N'DH043', N'SP02', 1, 3290000),
    (N'DH044', N'SP07', 4, 1290000),
    (N'DH044', N'SP01', 1, 16990000),
    (N'DH044', N'SP03', 3, 890000),
    (N'DH045', N'SP01', 4, 16990000);
GO

-- Kiểm tra nhanh: số dòng mỗi bảng
SELECT N'ChiNhanh' AS Bang, COUNT(*) AS SoDong FROM dbo.ChiNhanh
UNION ALL SELECT N'KhachHang', COUNT(*) FROM dbo.KhachHang
UNION ALL SELECT N'NhanVien', COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT N'SanPham', COUNT(*) FROM dbo.SanPham
UNION ALL SELECT N'DonHang', COUNT(*) FROM dbo.DonHang
UNION ALL SELECT N'ChiTietDonHang', COUNT(*) FROM dbo.ChiTietDonHang
-- Mong đợi: ChiNhanh = 3, KhachHang = 30, NhanVien = 12, SanPham = 10, DonHang = 45, ChiTietDonHang = 97
