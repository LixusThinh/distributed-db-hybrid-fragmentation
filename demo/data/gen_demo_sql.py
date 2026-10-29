"""Sinh dữ liệu mẫu + script 01_global_schema.sql và 02_fragments.sql cho demo.

Chạy:  python demo/data/gen_demo_sql.py
Kết quả: demo/sql/01_global_schema.sql, demo/sql/02_fragments.sql, demo/data/*.csv
và in ra số dòng mong đợi của từng mảnh (kiểm tra bằng SQLite).
Dữ liệu cố định nhờ seed, chạy lại luôn cho cùng kết quả.
"""
import csv
import random
import sqlite3
import sys
import unicodedata
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = ROOT / "sql"
DATA_DIR = ROOT / "data"
rng = random.Random(2026)
sys.stdout.reconfigure(encoding="utf-8")  # console Windows mặc định cp1252

# ---------------------------------------------------------------- dữ liệu
CHI_NHANH = [
    ("CN01", "Chi nhánh Hà Nội", "Bắc", "25 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội", "0243825001"),
    ("CN02", "Chi nhánh Đà Nẵng", "Trung", "88 Bạch Đằng, Hải Châu, Đà Nẵng", "0236382502"),
    ("CN03", "Chi nhánh TP.HCM", "Nam", "120 Nguyễn Huệ, Quận 1, TP.HCM", "0283825003"),
]
SITE = {"CN01": ("QLDH_HN", 1), "CN02": ("QLDH_DN", 2), "CN03": ("QLDH_HCM", 3)}
QUAN = {
    "CN01": (["Ba Đình", "Cầu Giấy", "Đống Đa", "Hai Bà Trưng", "Thanh Xuân", "Long Biên"], "Hà Nội", "001"),
    "CN02": (["Hải Châu", "Thanh Khê", "Sơn Trà", "Ngũ Hành Sơn", "Liên Chiểu", "Cẩm Lệ"], "Đà Nẵng", "048"),
    "CN03": (["Quận 1", "Quận 3", "Bình Thạnh", "Phú Nhuận", "Tân Bình", "Gò Vấp"], "TP.HCM", "079"),
}
DUONG = ["Lê Lợi", "Trần Hưng Đạo", "Nguyễn Trãi", "Hai Bà Trưng", "Quang Trung", "Phan Chu Trinh", "Lê Duẩn", "Nguyễn Văn Linh"]
HO = ["Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Võ", "Đặng", "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý"]
DEM = {"nam": ["Văn", "Minh", "Quốc", "Đức", "Hoàng", "Bảo", "Thanh"],
       "nu": ["Thị", "Ngọc", "Thu", "Thanh", "Minh", "Bảo"]}
TEN = {"nam": ["An", "Bình", "Dũng", "Hải", "Hiếu", "Hùng", "Khoa", "Long", "Nam", "Phúc", "Quân", "Sơn", "Tuấn", "Tâm"],
       "nu": ["An", "Châu", "Hà", "Hạnh", "Lan", "Linh", "Mai", "Nga", "Thảo", "Trang", "Vy", "Yến", "Ngân"]}
SAN_PHAM = [
    ("SP01", "Laptop văn phòng 15 inch", "Cái", 16990000, "Core i5, RAM 16GB, SSD 512GB"),
    ("SP02", "Màn hình 24 inch Full HD", "Cái", 3290000, "Tấm nền IPS, 75Hz"),
    ("SP03", "Bàn phím cơ", "Cái", 890000, "Switch đỏ, có đèn nền"),
    ("SP04", "Chuột không dây", "Cái", 350000, "Kết nối 2.4GHz"),
    ("SP05", "Máy in laser đơn sắc", "Cái", 4590000, "In 2 mặt tự động"),
    ("SP06", "Giấy A4 (thùng 5 ram)", "Thùng", 420000, "Định lượng 70gsm"),
    ("SP07", "Ổ cứng SSD 512GB", "Cái", 1290000, "Chuẩn M.2 NVMe"),
    ("SP08", "USB 64GB", "Cái", 190000, "Chuẩn USB 3.2"),
    ("SP09", "Tai nghe chụp tai", "Cái", 650000, "Có micro"),
    ("SP10", "Webcam Full HD", "Cái", 790000, "1080p, có micro"),
]
TRANG_THAI = ["Hoàn tất"] * 9 + ["Đang giao"] * 3 + ["Mới"] * 2 + ["Đã hủy"]


def bo_dau(s):
    s = s.replace("Đ", "D").replace("đ", "d")
    return "".join(c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn")


def ho_ten(used, gioi):
    while True:
        t = f"{rng.choice(HO)} {rng.choice(DEM[gioi])} {rng.choice(TEN[gioi])}"
        if t not in used:
            used.add(t)
            return t


def sdt():
    return "09" + "".join(rng.choice("0123456789") for _ in range(8))


used_names = set()
khach_hang = []  # (MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy)
for i in range(30):
    macn = CHI_NHANH[i % 3][0]
    quans, tp, _ = QUAN[macn]
    ten = ho_ten(used_names, rng.choice(["nam", "nu"]))
    ma = f"KH{i + 1:03d}"
    email = bo_dau(ten).lower().replace(" ", ".") + f"{i + 1}@example.com"
    dia_chi = f"{rng.randint(1, 250)} {rng.choice(DUONG)}, {rng.choice(quans)}, {tp}"
    han_muc = rng.choice([50, 100, 200, 300]) * 1_000_000
    cong_no = round(han_muc * rng.uniform(0, 0.95) / 100_000) * 100_000
    khach_hang.append((ma, ten, sdt(), email, dia_chi, macn, han_muc, cong_no, rng.randint(0, 5000)))

nhan_vien = []  # (MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan)
CHUC_VU = [("Quản lý chi nhánh", 25_000_000), ("Nhân viên bán hàng", 13_000_000),
           ("Nhân viên bán hàng", 12_000_000), ("Thủ kho", 10_000_000)]
for b, (macn, *_rest) in enumerate(CHI_NHANH):
    for k, (cv, luong) in enumerate(CHUC_VU):
        n = b * 4 + k + 1
        ns = date(rng.randint(1985, 2002), rng.randint(1, 12), rng.randint(1, 28))
        gioi = rng.choice(["nam", "nu"])
        # chữ số thứ 4 của CCCD: thế kỷ sinh + giới tính (0/1 trước 2000, 2/3 từ 2000)
        ma_gioi = ("0" if gioi == "nam" else "1") if ns.year < 2000 else ("2" if gioi == "nam" else "3")
        cccd = QUAN[macn][2] + ma_gioi + f"{ns.year % 100:02d}" + "".join(rng.choice("0123456789") for _ in range(6))
        stk = "".join(rng.choice("0123456789") for _ in range(12))
        nhan_vien.append((f"NV{n:02d}", ho_ten(used_names, gioi), cv, sdt(), macn, ns.isoformat(), cccd,
                          luong + rng.choice([0, 500_000, 1_000_000]), stk))

# 15 đơn mỗi chi nhánh, ngày đặt 01/09 – 25/10/2026, mã đơn tăng theo ngày
branches = [c[0] for c in CHI_NHANH for _ in range(15)]
rng.shuffle(branches)
start = date(2026, 9, 1)
dates = sorted(start + timedelta(days=rng.randint(0, 54)) for _ in branches)
gia = {sp[0]: sp[3] for sp in SAN_PHAM}
don_hang, chi_tiet = [], []
for i, (macn, ngay) in enumerate(zip(branches, dates)):
    madh = f"DH{i + 1:03d}"
    kh = rng.choice([k for k in khach_hang if k[5] == macn])[0]
    nv = rng.choice([v for v in nhan_vien if v[4] == macn and v[2] == "Nhân viên bán hàng"])[0]
    tong = 0
    for sp in rng.sample(list(gia), rng.randint(1, 3)):
        sl = rng.randint(1, 10 if sp == "SP06" else 4)
        chi_tiet.append((madh, sp, sl, gia[sp]))
        tong += sl * gia[sp]
    don_hang.append((madh, ngay.isoformat(), kh, nv, rng.choice(TRANG_THAI), tong))

TABLES = {
    "ChiNhanh": (["MaCN", "TenCN", "KhuVuc", "DiaChi", "SDT"], CHI_NHANH),
    "KhachHang": (["MaKH", "HoTen", "SDT", "Email", "DiaChi", "MaCN", "HanMucNo", "CongNo", "DiemTichLuy"], khach_hang),
    "NhanVien": (["MaNV", "HoTen", "ChucVu", "SDT", "MaCN", "NgaySinh", "CCCD", "Luong", "SoTaiKhoan"], nhan_vien),
    "SanPham": (["MaSP", "TenSP", "DonViTinh", "GiaBan", "MoTa"], SAN_PHAM),
    "DonHang": (["MaDH", "NgayDat", "MaKH", "MaNV", "TrangThai", "TongTien"], don_hang),
    "ChiTietDonHang": (["MaDH", "MaSP", "SoLuong", "DonGia"], chi_tiet),
}

# ---------------------------------------------------------------- kiểm tra bằng SQLite
db = sqlite3.connect(":memory:")
for t, (cols, rows) in TABLES.items():
    db.execute(f"CREATE TABLE {t} ({', '.join(cols)})")
    db.executemany(f"INSERT INTO {t} VALUES ({', '.join('?' * len(cols))})", rows)


def cnt(q):
    return db.execute(q).fetchone()[0]


expect = {}
for macn, (site, i) in SITE.items():
    expect[f"KH_{i}"] = cnt(f"SELECT COUNT(*) FROM KhachHang WHERE MaCN='{macn}'")
    expect[f"NV_CV_{i}"] = cnt(f"SELECT COUNT(*) FROM NhanVien WHERE MaCN='{macn}'")
    expect[f"DH_{i}"] = cnt(f"SELECT COUNT(*) FROM DonHang d WHERE EXISTS "
                            f"(SELECT 1 FROM KhachHang k WHERE k.MaKH=d.MaKH AND k.MaCN='{macn}')")
    expect[f"CTDH_{i}"] = cnt(f"SELECT COUNT(*) FROM ChiTietDonHang c WHERE EXISTS (SELECT 1 FROM DonHang d "
                              f"JOIN KhachHang k ON k.MaKH=d.MaKH WHERE d.MaDH=c.MaDH AND k.MaCN='{macn}')")
for t, (_, rows) in TABLES.items():
    expect[t] = len(rows)
# Nhân viên lập đơn phải cùng chi nhánh với khách (giả định của bài toán)
assert cnt("SELECT COUNT(*) FROM DonHang d JOIN KhachHang k ON k.MaKH=d.MaKH "
           "JOIN NhanVien v ON v.MaNV=d.MaNV WHERE k.MaCN<>v.MaCN") == 0


# ---------------------------------------------------------------- sinh SQL
def lit(v):
    if isinstance(v, int):
        return str(v)
    return "N'" + str(v).replace("'", "''") + "'"


def inserts(table, cols, rows):
    vals = ",\n".join("    (" + ", ".join(lit(v) for v in r) + ")" for r in rows)
    return f"INSERT INTO dbo.{table} ({', '.join(cols)}) VALUES\n{vals};\n"


HEADER = "-- File được sinh tự động bởi demo/data/gen_demo_sql.py. Sửa dữ liệu thì sửa file .py rồi chạy lại.\n"

s01 = HEADER + """/* =====================================================================
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
"""
for t, (cols, rows) in TABLES.items():
    s01 += f"\n-- {t}: {len(rows)} dòng\n" + inserts(t, cols, rows)
s01 += "GO\n\n-- Kiểm tra nhanh: số dòng mỗi bảng\nSELECT N'ChiNhanh' AS Bang, COUNT(*) AS SoDong FROM dbo.ChiNhanh\n"
s01 += "".join(f"UNION ALL SELECT N'{t}', COUNT(*) FROM dbo.{t}\n" for t in list(TABLES)[1:])
s01 += "-- Mong đợi: " + ", ".join(f"{t} = {expect[t]}" for t in TABLES) + "\n"


def drop_create(dbname):
    return f"""IF DB_ID(N'{dbname}') IS NOT NULL
BEGIN
    ALTER DATABASE {dbname} SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE {dbname};
END
GO
CREATE DATABASE {dbname};
GO
"""


REPLICA = """-- Nhân bản toàn phần: ChiNhanh, SanPham
SELECT * INTO dbo.ChiNhanh FROM QLDH_GOC.dbo.ChiNhanh;
ALTER TABLE dbo.ChiNhanh ADD CONSTRAINT PK_ChiNhanh PRIMARY KEY (MaCN);
SELECT * INTO dbo.SanPham FROM QLDH_GOC.dbo.SanPham;
ALTER TABLE dbo.SanPham ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSP);
GO
"""

s02 = HEADER + """/* =====================================================================
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
"""
for dbname in ["QLDH_TRUSO", "QLDH_HN", "QLDH_DN", "QLDH_HCM"]:
    s02 += drop_create(dbname)

for macn, (site, i) in SITE.items():
    s02 += f"""
/* ---------------------------------------------------------------------
   SITE S{i}: {site}  (chi nhánh {macn})
   --------------------------------------------------------------------- */
USE {site};
GO
{REPLICA}
-- KhachHang (hỗn hợp HV): KH_{i}_GD = π[MaKH,HoTen,SDT,Email,DiaChi,MaCN]( σ[MaCN='{macn}'](KhachHang) )
CREATE TABLE dbo.KH_{i}_GD (
    MaKH   CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50)  NOT NULL,
    SDT    VARCHAR(12)   NOT NULL,
    Email  VARCHAR(60)   NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    MaCN   CHAR(4)       NOT NULL,
    -- vị từ phân mảnh được ghi thành ràng buộc: mảnh không nhận khách của chi nhánh khác
    CONSTRAINT CK_KH_{i}_GD_MaCN CHECK (MaCN = '{macn}')
);
INSERT INTO dbo.KH_{i}_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = '{macn}';                                   -- mong đợi {expect[f'KH_{i}']} dòng

-- NhanVien (hỗn hợp VH): NV_CV_{i} = σ[MaCN='{macn}']( π[MaNV,HoTen,ChucVu,SDT,MaCN](NhanVien) )
CREATE TABLE dbo.NV_CV_{i} (
    MaNV   CHAR(4)      NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50) NOT NULL,
    ChucVu NVARCHAR(30) NOT NULL,
    SDT    VARCHAR(12)  NOT NULL,
    MaCN   CHAR(4)      NOT NULL,
    CONSTRAINT CK_NV_CV_{i}_MaCN CHECK (MaCN = '{macn}')
);
INSERT INTO dbo.NV_CV_{i} (MaNV, HoTen, ChucVu, SDT, MaCN)
SELECT MaNV, HoTen, ChucVu, SDT, MaCN
FROM QLDH_GOC.dbo.NhanVien
WHERE MaCN = '{macn}';                                   -- mong đợi {expect[f'NV_CV_{i}']} dòng

-- DonHang (ngang dẫn xuất): DH_{i} = DonHang ⋉[MaKH] KH_{i}
CREATE TABLE dbo.DH_{i} (
    MaDH      CHAR(5)       NOT NULL PRIMARY KEY,
    NgayDat   DATE          NOT NULL,
    MaKH      CHAR(5)       NOT NULL REFERENCES dbo.KH_{i}_GD(MaKH),
    MaNV      CHAR(4)       NOT NULL REFERENCES dbo.NV_CV_{i}(MaNV),
    TrangThai NVARCHAR(20)  NOT NULL,
    TongTien  DECIMAL(18,0) NOT NULL
);
INSERT INTO dbo.DH_{i} (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
SELECT d.MaDH, d.NgayDat, d.MaKH, d.MaNV, d.TrangThai, d.TongTien
FROM QLDH_GOC.dbo.DonHang AS d
WHERE EXISTS (SELECT 1 FROM QLDH_GOC.dbo.KhachHang AS k      -- phép nửa kết nối
              WHERE k.MaKH = d.MaKH AND k.MaCN = '{macn}');   -- mong đợi {expect[f'DH_{i}']} dòng

-- ChiTietDonHang (ngang dẫn xuất): CTDH_{i} = ChiTietDonHang ⋉[MaDH] DH_{i}
CREATE TABLE dbo.CTDH_{i} (
    MaDH    CHAR(5)       NOT NULL REFERENCES dbo.DH_{i}(MaDH),
    MaSP    CHAR(4)       NOT NULL REFERENCES dbo.SanPham(MaSP),
    SoLuong INT           NOT NULL CHECK (SoLuong > 0),
    DonGia  DECIMAL(18,0) NOT NULL,
    PRIMARY KEY (MaDH, MaSP)
);
INSERT INTO dbo.CTDH_{i} (MaDH, MaSP, SoLuong, DonGia)
SELECT c.MaDH, c.MaSP, c.SoLuong, c.DonGia
FROM QLDH_GOC.dbo.ChiTietDonHang AS c
WHERE EXISTS (SELECT 1 FROM dbo.DH_{i} AS d WHERE d.MaDH = c.MaDH);   -- mong đợi {expect[f'CTDH_{i}']} dòng
GO
"""

s02 += f"""
/* ---------------------------------------------------------------------
   SITE S0: QLDH_TRUSO  (trụ sở chính – phòng Kế toán, Nhân sự)
   --------------------------------------------------------------------- */
USE QLDH_TRUSO;
GO
{REPLICA}
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
FROM QLDH_GOC.dbo.NhanVien;                              -- mong đợi {expect['NhanVien']} dòng
"""
for macn, (site, i) in SITE.items():
    s02 += f"""
-- KhachHang (hỗn hợp HV): KH_{i}_TC = π[MaKH,HanMucNo,CongNo,DiemTichLuy]( σ[MaCN='{macn}'](KhachHang) )
CREATE TABLE dbo.KH_{i}_TC (
    MaKH        CHAR(5)       NOT NULL PRIMARY KEY,
    HanMucNo    DECIMAL(18,0) NOT NULL,
    CongNo      DECIMAL(18,0) NOT NULL,
    DiemTichLuy INT           NOT NULL
);
INSERT INTO dbo.KH_{i}_TC (MaKH, HanMucNo, CongNo, DiemTichLuy)
SELECT MaKH, HanMucNo, CongNo, DiemTichLuy
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = '{macn}';                                   -- mong đợi {expect[f'KH_{i}']} dòng
"""
s02 += "GO\n\n-- Tổng kết số dòng từng mảnh (chạy để chụp màn hình)\n"
parts = ["SELECT N'S0 QLDH_TRUSO' AS Site, N'NV_NS' AS Manh, COUNT(*) AS SoDong FROM QLDH_TRUSO.dbo.NV_NS"]
for macn, (site, i) in SITE.items():
    parts.append(f"SELECT N'S0 QLDH_TRUSO', N'KH_{i}_TC', COUNT(*) FROM QLDH_TRUSO.dbo.KH_{i}_TC")
for macn, (site, i) in SITE.items():
    for m in [f"KH_{i}_GD", f"NV_CV_{i}", f"DH_{i}", f"CTDH_{i}"]:
        parts.append(f"SELECT N'S{i} {site}', N'{m}', COUNT(*) FROM {site}.dbo.{m}")
s02 += "\nUNION ALL ".join(parts) + ";\n"
s02 += "-- Mong đợi: NV_NS = {}; ".format(expect["NhanVien"]) + "; ".join(
    f"S{i}: KH_{i}_GD = KH_{i}_TC = {expect[f'KH_{i}']}, NV_CV_{i} = {expect[f'NV_CV_{i}']}, "
    f"DH_{i} = {expect[f'DH_{i}']}, CTDH_{i} = {expect[f'CTDH_{i}']}" for _, (_, i) in SITE.items()) + "\n"

# utf-8-sig: SSMS đọc đúng tiếng Việt khi file có BOM
(SQL_DIR / "01_global_schema.sql").write_text(s01, encoding="utf-8-sig")
(SQL_DIR / "02_fragments.sql").write_text(s02, encoding="utf-8-sig")
for t, (cols, rows) in TABLES.items():
    with open(DATA_DIR / f"{t}.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)

print("Số dòng mong đợi:", expect)
