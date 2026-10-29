/* =====================================================================
   04_queries.sql
   Truy vấn minh họa theo bảng ứng dụng Q1–Q7 (docs/01_bai_toan_thiet_ke.md).
   Chạy SAU 03_reconstruct_check.sql. Chạy lại bao nhiêu lần cũng được:
   phần D (giao dịch) tự hoàn tác nên không làm lệch dữ liệu.
     A. Truy vấn CỤC BỘ tại chi nhánh Hà Nội (S1)
     B. Truy vấn CỤC BỘ tại trụ sở (S0)
     C. Truy vấn TOÀN CỤC qua view (trong suốt phân mảnh)
     D. Giao dịch phân tán: lập đơn ở S1, cập nhật công nợ ở S0
   ===================================================================== */

/* =====================================================================
   A. TẠI CHI NHÁNH HÀ NỘI – S1 (QLDH_HN): chỉ đọc mảnh nằm tại chỗ
   ===================================================================== */
USE QLDH_HN;
GO

-- Q1: tra cứu khách hàng của chi nhánh để lập đơn             → 10 dòng
SELECT MaKH, HoTen, SDT, Email, DiaChi
FROM dbo.KH_1_GD
ORDER BY MaKH;

-- Q2: đơn đang xử lý (Mới / Đang giao) kèm chi tiết            → 6 dòng (DH020, DH027, DH028, DH036)
--     DonHang ⋈ KhachHang chạy cục bộ nhờ phân mảnh ngang DẪN XUẤT:
--     DH_1 và KH_1_GD cùng nằm ở S1
SELECT dh.MaDH, dh.NgayDat, kh.HoTen AS KhachHang, nv.HoTen AS NhanVien,
       sp.TenSP, ct.SoLuong, ct.DonGia, ct.SoLuong * ct.DonGia AS ThanhTien, dh.TrangThai
FROM dbo.DH_1    AS dh
JOIN dbo.KH_1_GD AS kh ON kh.MaKH = dh.MaKH
JOIN dbo.NV_CV_1 AS nv ON nv.MaNV = dh.MaNV
JOIN dbo.CTDH_1  AS ct ON ct.MaDH = dh.MaDH
JOIN dbo.SanPham AS sp ON sp.MaSP = ct.MaSP          -- SanPham là bản nhân bản tại S1
WHERE dh.TrangThai IN (N'Mới', N'Đang giao')
ORDER BY dh.NgayDat, dh.MaDH;

-- Q4: danh sách nhân viên chi nhánh                           → 4 dòng
SELECT MaNV, HoTen, ChucVu, SDT FROM dbo.NV_CV_1 ORDER BY MaNV;

-- Bảo mật nhờ phân mảnh dọc: chi nhánh KHÔNG có cột lương.
-- Bỏ comment dòng dưới sẽ báo lỗi: Invalid column name 'Luong'.
-- SELECT MaNV, Luong FROM dbo.NV_CV_1;

-- Vị từ phân mảnh được ràng buộc bằng CHECK: mảnh Hà Nội không nhận khách CN02.
-- Bỏ comment sẽ báo lỗi: The INSERT statement conflicted with the CHECK constraint "CK_KH_1_GD_MaCN".
-- INSERT INTO dbo.KH_1_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
-- VALUES ('KH999', N'Khách thử', '0900000000', NULL, N'Đà Nẵng', 'CN02');
GO

/* =====================================================================
   B. TẠI TRỤ SỞ – S0 (QLDH_TRUSO): chỉ đọc mảnh nằm tại chỗ
   ===================================================================== */
USE QLDH_TRUSO;
GO

-- Q3: báo cáo công nợ theo miền, chỉ dùng các mảnh KH_i_TC ở S0.
--     Mảnh TC không có cột MaCN; miền được xác định bởi chính mảnh (σ ở bước 1 của HV).
--     Mong đợi: CN01 10 KH, hạn mức 1.700.000.000, công nợ   774.500.000, 45.6%
--               CN02 10 KH, hạn mức 2.000.000.000, công nợ 1.092.100.000, 54.6%
--               CN03 10 KH, hạn mức 1.850.000.000, công nợ   967.700.000, 52.3%
SELECT cn.MaCN, cn.TenCN, x.SoKhach, x.TongHanMuc, x.TongCongNo,
       CAST(100.0 * x.TongCongNo / x.TongHanMuc AS DECIMAL(5,1)) AS TyLeSuDung
FROM (
    SELECT 'CN01' AS MaCN, COUNT(*) AS SoKhach, SUM(HanMucNo) AS TongHanMuc, SUM(CongNo) AS TongCongNo FROM dbo.KH_1_TC
    UNION ALL
    SELECT 'CN02', COUNT(*), SUM(HanMucNo), SUM(CongNo) FROM dbo.KH_2_TC
    UNION ALL
    SELECT 'CN03', COUNT(*), SUM(HanMucNo), SUM(CongNo) FROM dbo.KH_3_TC
) AS x
JOIN dbo.ChiNhanh AS cn ON cn.MaCN = x.MaCN          -- ChiNhanh là bản nhân bản tại S0
ORDER BY cn.MaCN;

-- Q5: bảng lương – dữ liệu nhạy cảm chỉ có ở S0               → 12 dòng
SELECT MaNV, CCCD, Luong, SoTaiKhoan FROM dbo.NV_NS ORDER BY MaNV;
GO

/* =====================================================================
   C. TOÀN CỤC QUA VIEW (S0): người dùng không cần biết mảnh nằm ở đâu
   ===================================================================== */

-- Q3b: khách sắp vượt hạn mức (công nợ >= 80%). Cần HoTen (ở chi nhánh) + CongNo (ở S0),
--      nên phải ghép mảnh của nhiều site → truy vấn phân tán.
--      Mong đợi 3 dòng: KH011 Bùi Bảo Lan (CN02) 90.1% · KH025 Hoàng Bảo Yến (CN01) 80.7%
--                       · KH015 Ngô Minh Ngân (CN03) 80.4%
SELECT MaKH, HoTen, MaCN, HanMucNo, CongNo,
       CAST(100.0 * CongNo / HanMucNo AS DECIMAL(5,1)) AS TyLe
FROM dbo.v_KhachHang
WHERE CongNo >= 0.8 * HanMucNo
ORDER BY 1.0 * CongNo / HanMucNo DESC;

-- Q6a: doanh thu theo chi nhánh (không tính đơn đã hủy), viết trên view toàn cục.
--      Mong đợi: CN01 14 đơn 262.670.000 · CN02 13 đơn 256.960.000 · CN03 15 đơn 171.350.000
SELECT kh.MaCN, cn.TenCN, COUNT(*) AS SoDon, SUM(dh.TongTien) AS DoanhThu
FROM dbo.v_DonHang   AS dh
JOIN dbo.v_KhachHang AS kh ON kh.MaKH = dh.MaKH
JOIN dbo.ChiNhanh    AS cn ON cn.MaCN = kh.MaCN
WHERE dh.TrangThai <> N'Đã hủy'
GROUP BY kh.MaCN, cn.TenCN
ORDER BY kh.MaCN;

-- Q6b: cùng kết quả, nhưng viết theo cách phân rã truy vấn: mỗi site tự tính trên mảnh
--      của mình, S0 chỉ gộp 3 dòng. Không cần phép kết nối nào, vì đơn hàng đã được
--      phân mảnh dẫn xuất theo chi nhánh của khách.
SELECT 'CN01' AS MaCN, COUNT(*) AS SoDon, SUM(TongTien) AS DoanhThu FROM dbo.syn_DH_1 WHERE TrangThai <> N'Đã hủy'
UNION ALL
SELECT 'CN02', COUNT(*), SUM(TongTien) FROM dbo.syn_DH_2 WHERE TrangThai <> N'Đã hủy'
UNION ALL
SELECT 'CN03', COUNT(*), SUM(TongTien) FROM dbo.syn_DH_3 WHERE TrangThai <> N'Đã hủy';

-- Q6c: doanh thu toàn công ty theo tháng
--      Mong đợi: 2026-09 22 đơn 279.000.000 · 2026-10 20 đơn 411.980.000
SELECT YEAR(NgayDat) AS Nam, MONTH(NgayDat) AS Thang, COUNT(*) AS SoDon, SUM(TongTien) AS DoanhThu
FROM dbo.v_DonHang
WHERE TrangThai <> N'Đã hủy'
GROUP BY YEAR(NgayDat), MONTH(NgayDat)
ORDER BY Nam, Thang;

-- Q6d: top 3 sản phẩm theo doanh thu
--      Mong đợi: SP01 (390.770.000) · SP05 (110.160.000) · SP02 (69.090.000)
SELECT TOP (3) sp.MaSP, sp.TenSP, SUM(ct.SoLuong) AS SoLuong, SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM dbo.v_ChiTietDonHang AS ct
JOIN dbo.v_DonHang        AS dh ON dh.MaDH = ct.MaDH
JOIN dbo.SanPham          AS sp ON sp.MaSP = ct.MaSP
WHERE dh.TrangThai <> N'Đã hủy'
GROUP BY sp.MaSP, sp.TenSP
ORDER BY DoanhThu DESC;

-- Tổng quỹ lương theo chi nhánh: ghép NV_CV (ở chi nhánh) với NV_NS (ở S0)
--      Mong đợi: CN01 61.000.000 · CN02 62.000.000 · CN03 62.000.000
SELECT MaCN, COUNT(*) AS SoNhanVien, SUM(Luong) AS QuyLuong
FROM dbo.v_NhanVien
GROUP BY MaCN
ORDER BY MaCN;
GO

/* =====================================================================
   D. GIAO DỊCH PHÂN TÁN – cái giá của thiết kế
   Lập đơn ở S1 (DH_1, CTDH_1), nhưng công nợ nằm ở S0 (KH_1_TC).
   Một thao tác nghiệp vụ phải ghi lên 2 site và cần tính nguyên tử: cả hai
   cùng thành công hoặc cùng hủy.
   (Cùng instance thì SQL Server tự bảo đảm. Qua Linked Server cần MSDTC
    và BEGIN DISTRIBUTED TRANSACTION, tức giao thức cam kết 2 pha 2PC.)
   ===================================================================== */
USE QLDH_HN;
GO
CREATE OR ALTER PROCEDURE dbo.usp_LapDonHang
    @MaDH CHAR(5), @MaKH CHAR(5), @MaNV CHAR(4), @MaSP CHAR(4), @SoLuong INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- lỗi bất kỳ → hủy toàn bộ giao dịch trên cả 2 site

    DECLARE @DonGia DECIMAL(18,0) = (SELECT GiaBan FROM dbo.SanPham WHERE MaSP = @MaSP);
    DECLARE @Tien   DECIMAL(18,0) = @DonGia * @SoLuong;

    IF NOT EXISTS (SELECT 1 FROM dbo.KH_1_GD WHERE MaKH = @MaKH)
        THROW 50001, N'Khách hàng không thuộc chi nhánh Hà Nội.', 1;

    BEGIN TRANSACTION;
        -- Đọc hạn mức ở S0, khóa dòng để không ai cập nhật chen ngang
        DECLARE @HanMuc DECIMAL(18,0), @CongNo DECIMAL(18,0);
        SELECT @HanMuc = HanMucNo, @CongNo = CongNo
        FROM QLDH_TRUSO.dbo.KH_1_TC WITH (UPDLOCK, ROWLOCK)
        WHERE MaKH = @MaKH;

        IF @CongNo + @Tien > @HanMuc
            THROW 50002, N'Đơn hàng vượt hạn mức công nợ – giao dịch bị hủy trên cả 2 site.', 1;

        -- Ghi tại S1
        INSERT INTO dbo.DH_1 (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
        VALUES (@MaDH, CAST(GETDATE() AS DATE), @MaKH, @MaNV, N'Mới', @Tien);
        INSERT INTO dbo.CTDH_1 (MaDH, MaSP, SoLuong, DonGia)
        VALUES (@MaDH, @MaSP, @SoLuong, @DonGia);

        -- Ghi tại S0
        UPDATE QLDH_TRUSO.dbo.KH_1_TC
        SET CongNo = CongNo + @Tien
        WHERE MaKH = @MaKH;
    COMMIT TRANSACTION;
END
GO

-- Trường hợp 1: THÀNH CÔNG. KH007 (hạn mức 200.000.000, công nợ 86.100.000) mua 1 máy in 4.590.000.
-- Bọc trong giao dịch ngoài rồi ROLLBACK để demo chạy lại được và không làm lệch so với QLDH_GOC.
-- (Đổi ROLLBACK thành COMMIT nếu muốn lưu thật; khi đó 03 sẽ báo lệch vì QLDH_GOC không đổi.)
BEGIN TRANSACTION;
    SELECT N'Trước' AS Luc, MaKH, HanMucNo, CongNo FROM QLDH_TRUSO.dbo.KH_1_TC WHERE MaKH = 'KH007';

    EXEC dbo.usp_LapDonHang @MaDH = 'DH046', @MaKH = 'KH007', @MaNV = 'NV02', @MaSP = 'SP05', @SoLuong = 1;

    SELECT N'Sau' AS Luc, MaKH, HanMucNo, CongNo FROM QLDH_TRUSO.dbo.KH_1_TC WHERE MaKH = 'KH007';   -- công nợ 90.690.000
    SELECT * FROM QLDH_TRUSO.dbo.v_DonHang WHERE MaDH = 'DH046';      -- đơn mới thấy được qua view toàn cục
ROLLBACK TRANSACTION;
GO

-- Trường hợp 2: THẤT BẠI. KH022 (hạn mức 50.000.000, công nợ 30.900.000) mua 2 laptop 33.980.000.
BEGIN TRY
    EXEC dbo.usp_LapDonHang @MaDH = 'DH047', @MaKH = 'KH022', @MaNV = 'NV03', @MaSP = 'SP01', @SoLuong = 2;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;   -- 50002
END CATCH;

-- Kiểm chứng tính nguyên tử: không site nào bị ghi dở
SELECT (SELECT COUNT(*) FROM dbo.DH_1 WHERE MaDH = 'DH047')                     AS DonDH047_TaiS1,   -- 0
       (SELECT CongNo  FROM QLDH_TRUSO.dbo.KH_1_TC WHERE MaKH = 'KH022')        AS CongNoKH022_TaiS0; -- 30.900.000
GO
