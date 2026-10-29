# Bài toán & thiết kế phân mảnh – Hệ thống quản lý đơn hàng

> Tài liệu gốc cho Chương 4 của báo cáo và phần "Ứng dụng" trên slide. Mọi script demo trong `demo/sql/` bám theo file này.

## 1. Mô tả bài toán

Công ty thương mại **X** phân phối hàng hóa qua 3 chi nhánh ở 3 miền và có một trụ sở chính:

| Mã CN | Chi nhánh | Khu vực | Site |
|-------|-----------|---------|------|
| CN01 | Chi nhánh Hà Nội | Bắc | S1 |
| CN02 | Chi nhánh Đà Nẵng | Trung | S2 |
| CN03 | Chi nhánh TP.HCM | Nam | S3 |
| — | Trụ sở chính (TP.HCM): phòng Kế toán, phòng Nhân sự, ban Giám đốc | — | S0 |

Nghiệp vụ:
- Mỗi khách hàng được quản lý bởi **đúng một** chi nhánh (chi nhánh nơi khách đăng ký).
- Nhân viên chi nhánh tra cứu khách hàng, lập đơn hàng, cập nhật trạng thái đơn **cho khách của chi nhánh mình**.
- Phòng Kế toán (trụ sở) quản lý **hạn mức công nợ, công nợ hiện tại, điểm tích lũy** của khách hàng ở cả 3 miền, lập báo cáo công nợ theo từng miền.
- Phòng Nhân sự (trụ sở) quản lý **lương, CCCD, số tài khoản** của toàn bộ nhân viên. Đây là dữ liệu nhạy cảm, chi nhánh không được thấy.
- Ban Giám đốc xem báo cáo doanh thu toàn công ty và theo từng chi nhánh.
- Danh mục sản phẩm và giá bán do trụ sở quản lý và cập nhật; mọi chi nhánh đều cần đọc khi lập đơn.

**Giả định:** đơn hàng của khách nào thì thuộc chi nhánh quản lý khách đó; nhân viên trụ sở nằm ngoài phạm vi.

## 2. Lược đồ toàn cục

```
ChiNhanh      (MaCN, TenCN, KhuVuc, DiaChi, SDT)
KhachHang     (MaKH, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy)
NhanVien      (MaNV, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan)
SanPham       (MaSP, TenSP, DonViTinh, GiaBan, MoTa)
DonHang       (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
ChiTietDonHang(MaDH, MaSP, SoLuong, DonGia)
```

Khóa ngoại: `KhachHang.MaCN → ChiNhanh`, `NhanVien.MaCN → ChiNhanh`, `DonHang.MaKH → KhachHang`, `DonHang.MaNV → NhanVien`, `ChiTietDonHang.MaDH → DonHang`, `ChiTietDonHang.MaSP → SanPham`.

Ràng buộc miền giá trị: `MaCN ∈ {'CN01','CN02','CN03'}` (CHECK). Đây là cơ sở để chứng minh tính đầy đủ của phân mảnh ngang.

## 3. Phân tích ứng dụng (truy vấn chính)

| Mã | Ứng dụng | Phát sinh tại | Thuộc tính / bảng dùng | Tần suất |
|----|----------|---------------|------------------------|----------|
| Q1 | Tra cứu khách hàng của chi nhánh để lập đơn | S1, S2, S3 | KhachHang(MaKH, HoTen, SDT, Email, DiaChi, MaCN) | Rất cao |
| Q2 | Lập đơn, xem/cập nhật đơn hàng của chi nhánh | S1, S2, S3 | DonHang, ChiTietDonHang, SanPham | Rất cao |
| Q3 | Kiểm tra hạn mức & công nợ khách hàng, báo cáo công nợ theo miền | S0 | KhachHang(MaKH, MaCN, HanMucNo, CongNo, DiemTichLuy) | Trung bình |
| Q4 | Xem danh sách nhân viên chi nhánh | S1, S2, S3 | NhanVien(MaNV, HoTen, ChucVu, SDT, MaCN) | Trung bình |
| Q5 | Tính lương, quản lý hồ sơ nhân sự | S0 | NhanVien(MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan) | Thấp (theo tháng) |
| Q6 | Báo cáo doanh thu toàn công ty / theo chi nhánh | S0 | DonHang, ChiTietDonHang | Thấp |
| Q7 | Cập nhật danh mục, giá sản phẩm | S0 | SanPham | Thấp |

### Ma trận sử dụng thuộc tính của `KhachHang` (để biện minh phân mảnh dọc)

| | MaKH | HoTen | SDT | Email | DiaChi | MaCN | HanMucNo | CongNo | DiemTichLuy |
|---|---|---|---|---|---|---|---|---|---|
| Q1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |
| Q2 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | 0 |
| Q3 | 1 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 |

→ Thuộc tính tách thành 2 nhóm rõ ràng: **nhóm giao dịch** (Q1, Q2 dùng tại chi nhánh) và **nhóm tài chính** (Q3 dùng tại trụ sở). Đồng thời mỗi chi nhánh chỉ dùng **dòng** của khách thuộc chi nhánh mình → cần phân mảnh **cả ngang lẫn dọc**, tức là **phân mảnh hỗn hợp**. Lập luận tương tự áp dụng cho `NhanVien` (Q4 ở chi nhánh, Q5 ở trụ sở).

## 4. Thiết kế phân mảnh

### 4.1 `KhachHang` – Phân mảnh hỗn hợp ngang-trước-dọc (HV)

**Bước 1 – ngang nguyên thủy** theo vị từ `p_i: MaCN = 'CN0i'`:
```
KH_i = σ_{MaCN='CN0i'} (KhachHang)            i = 1, 2, 3
```
**Bước 2 – dọc** trên từng mảnh ngang (lặp lại khóa MaKH):
```
KH_i_GD = π_{MaKH, HoTen, SDT, Email, DiaChi, MaCN} (KH_i)     → đặt tại S_i
KH_i_TC = π_{MaKH, HanMucNo, CongNo, DiemTichLuy}   (KH_i)     → đặt tại S0
```
**Tái thiết:**
```
KhachHang = ⋃_{i=1..3} ( KH_i_GD ⋈_{MaKH} KH_i_TC )
```
Cây phân mảnh: gốc `KhachHang` → 3 nút σ (KH_1, KH_2, KH_3) → mỗi nút tách 2 lá π (GD, TC). Tổng cộng 6 mảnh lá.

### 4.2 `NhanVien` – Phân mảnh hỗn hợp dọc-trước-ngang (VH)

**Bước 1 – dọc:**
```
NV_CV = π_{MaNV, HoTen, ChucVu, SDT, MaCN}          (NhanVien)   -- thông tin công việc
NV_NS = π_{MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan} (NhanVien)   -- thông tin nhân sự (nhạy cảm) → S0
```
**Bước 2 – ngang** trên mảnh công việc:
```
NV_CV_i = σ_{MaCN='CN0i'} (NV_CV)    → đặt tại S_i,  i = 1, 2, 3
```
**Tái thiết:**
```
NhanVien = ( NV_CV_1 ∪ NV_CV_2 ∪ NV_CV_3 ) ⋈_{MaNV} NV_NS
```
Cây phân mảnh: gốc → 2 nút π → nút `NV_CV` tách 3 lá σ, nút `NV_NS` là lá. Tổng cộng 4 mảnh lá.

> **Vì sao chọn 2 chiến lược khác nhau:** với `KhachHang`, trụ sở cần báo cáo công nợ **theo từng miền**, nên giữ phần tài chính tách theo miền (HV) có lợi. Với `NhanVien`, phần nhân sự được xử lý tập trung, không cần chia theo chi nhánh, nên chỉ chia ngang phần công việc (VH). Đây là ví dụ để so sánh HV và VH trên slide.

### 4.3 `DonHang`, `ChiTietDonHang` – Phân mảnh ngang dẫn xuất

```
DH_i   = DonHang        ⋉_{MaKH} KH_i       → S_i
CTDH_i = ChiTietDonHang ⋉_{MaDH} DH_i       → S_i
```
(KH_i là mảnh ngang ở bước 1 của mục 4.1, chứa MaKH.)

### 4.4 `ChiNhanh`, `SanPham` – Nhân bản toàn phần

Hai bảng này nhỏ, đọc nhiều và ít cập nhật, nên được nhân bản đầy đủ ở cả 4 site. Mọi cập nhật thực hiện ở S0 rồi đồng bộ xuống các chi nhánh.

## 5. Kiểm tra tính đúng đắn

| Quy tắc | KhachHang (HV) | NhanVien (VH) |
|---------|----------------|---------------|
| **Đầy đủ** | Bước ngang: tập vị từ {MaCN='CN01', 'CN02', 'CN03'} phủ toàn miền giá trị của MaCN (nhờ CHECK) nên mọi bộ đều thuộc một KH_i. Bước dọc: GD ∪ TC = toàn bộ thuộc tính. | Bước dọc: CV ∪ NS = toàn bộ thuộc tính. Bước ngang: tương tự KhachHang. |
| **Tái thiết** | ⋈ theo khóa MaKH (có trong cả GD và TC) không mất và không thừa bộ; ∪ các mảnh ngang cho lại quan hệ ban đầu. | ∪ các NV_CV_i được NV_CV; ⋈ với NV_NS theo khóa MaNV. |
| **Rời nhau** | Các vị từ loại trừ nhau nên KH_i rời nhau. GD ∩ TC chỉ chứa khóa MaKH (được phép lặp lại). | Tương tự, chỉ lặp lại khóa MaNV. |

Trong demo, mỗi quy tắc được kiểm tra bằng một truy vấn SQL: so sánh `COUNT`, dùng `EXCEPT` giữa bảng gốc và view tái thiết, và tìm khóa xuất hiện ở hai mảnh ngang.

## 6. Lược đồ cấp phát

| Site | Mảnh |
|------|------|
| **S0 – Trụ sở** | KH_1_TC, KH_2_TC, KH_3_TC, NV_NS, ChiNhanh*, SanPham* |
| **S1 – Hà Nội** | KH_1_GD, NV_CV_1, DH_1, CTDH_1, ChiNhanh*, SanPham* |
| **S2 – Đà Nẵng** | KH_2_GD, NV_CV_2, DH_2, CTDH_2, ChiNhanh*, SanPham* |
| **S3 – TP.HCM** | KH_3_GD, NV_CV_3, DH_3, CTDH_3, ChiNhanh*, SanPham* |

\* bản nhân bản.

**Hiệu quả:** Q1, Q2, Q4 (tần suất cao) chạy **hoàn toàn cục bộ** tại chi nhánh. Q3, Q5 chạy cục bộ tại S0. Chỉ Q6 (báo cáo toàn công ty) cần gom dữ liệu từ 3 site.

**Đánh đổi:** khi chi nhánh lập đơn mà cần kiểm tra hoặc cộng `CongNo`, thao tác phải truy cập S0, tức là phát sinh giao dịch phân tán. Phần này sẽ được nêu trong mục đánh giá.

## 7. Phương án demo

- **DBMS:** Microsoft SQL Server 2019/2022 + SSMS (trường dạy và dễ cài trên Windows).
- **Mô phỏng site:** mỗi site là một database trên cùng một instance: `QLDH_TRUSO` (S0), `QLDH_HN` (S1), `QLDH_DN` (S2), `QLDH_HCM` (S3). Thêm `QLDH_GOC` chứa lược đồ toàn cục và dữ liệu mẫu ban đầu.
- **Trong suốt phân mảnh và vị trí:** tại S0 tạo **synonym** cho từng mảnh (`syn_KH_1_GD → QLDH_HN.dbo.KH_1_GD`), rồi tạo view tái thiết `v_KhachHang`, `v_NhanVien`, `v_DonHang` dựa trên các synonym đó. Người dùng truy vấn view mà không cần biết dữ liệu nằm ở mảnh nào hay ở site nào.
- **Lưu ý khi trình bày:** 4 database trên 1 máy là **mô phỏng** các site. Thiết kế phân mảnh và cấp phát không phụ thuộc hạ tầng: muốn chạy trên nhiều máy thì chỉ tạo lại synonym trỏ sang Linked Server, view giữ nguyên.
- **Tùy chọn nâng cao (T4b):** chạy trên 2 laptop. Tạo Linked Server sang máy kia và trỏ synonym tới tên 4 phần `[LAPTOP].QLDH_HN.dbo.KH_1_GD`, như vậy là phân tán thật.
- **Script:** `01_global_schema.sql` → `02_fragments.sql` → `03_reconstruct_check.sql` → `04_queries.sql` → (`05_linked_server.sql`, tùy chọn).
