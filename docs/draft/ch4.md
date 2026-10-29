# CHƯƠNG 4. ỨNG DỤNG PHÂN MẢNH HỖN HỢP CHO HỆ THỐNG QUẢN LÝ ĐƠN HÀNG

## 4.1 Mô tả bài toán

Công ty thương mại X (công ty giả định) phân phối thiết bị văn phòng qua ba chi nhánh ở ba miền và có một trụ sở chính đặt tại TP. Hồ Chí Minh. Mỗi địa điểm là một site của CSDL phân tán (Bảng 4.1).

Bảng: Các site trong hệ thống
| Site | Địa điểm | Mã chi nhánh | Người dùng chính |
|---|---|---|---|
| S0 | Trụ sở chính (TP.HCM) | — | Phòng Kế toán, phòng Nhân sự, ban Giám đốc |
| S1 | Chi nhánh Hà Nội (miền Bắc) | CN01 | Nhân viên bán hàng, quản lý chi nhánh |
| S2 | Chi nhánh Đà Nẵng (miền Trung) | CN02 | Nhân viên bán hàng, quản lý chi nhánh |
| S3 | Chi nhánh TP.HCM (miền Nam) | CN03 | Nhân viên bán hàng, quản lý chi nhánh |

Các nghiệp vụ chính:

- Mỗi khách hàng được quản lý bởi **đúng một** chi nhánh, là nơi khách đăng ký.
- Nhân viên chi nhánh tra cứu khách hàng, lập đơn hàng và cập nhật trạng thái đơn cho khách của chi nhánh mình. Đây là nghiệp vụ diễn ra nhiều nhất.
- Phòng Kế toán quản lý hạn mức công nợ, công nợ hiện tại và điểm tích lũy của khách hàng ở cả ba miền, lập báo cáo công nợ theo từng miền.
- Phòng Nhân sự quản lý ngày sinh, số CCCD, lương và số tài khoản của nhân viên. Đây là dữ liệu nhạy cảm, chi nhánh không được truy cập.
- Ban Giám đốc xem báo cáo doanh thu toàn công ty và theo từng chi nhánh.
- Danh mục sản phẩm và giá bán do trụ sở quản lý; mọi chi nhánh đều cần đọc khi lập đơn.

**Giả định:** đơn hàng của khách nào thì do chi nhánh quản lý khách đó xử lý, và nhân viên lập đơn thuộc cùng chi nhánh; nhân viên làm việc tại trụ sở nằm ngoài phạm vi bài toán.

## 4.2 Lược đồ toàn cục

Lược đồ toàn cục gồm sáu quan hệ (khóa chính được gạch chân trong sơ đồ, đánh dấu PK trong Hình 4.1):

- ChiNhanh(**MaCN**, TenCN, KhuVuc, DiaChi, SDT)
- KhachHang(**MaKH**, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy)
- NhanVien(**MaNV**, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan)
- SanPham(**MaSP**, TenSP, DonViTinh, GiaBan, MoTa)
- DonHang(**MaDH**, NgayDat, MaKH, MaNV, TrangThai, TongTien)
- ChiTietDonHang(**MaDH, MaSP**, SoLuong, DonGia)

Ràng buộc miền giá trị MaCN ∈ {'CN01', 'CN02', 'CN03'} được khai báo bằng CHECK. Ràng buộc này là cơ sở để chứng minh tính đầy đủ của phân mảnh ngang.

![Lược đồ quan hệ toàn cục của hệ thống quản lý đơn hàng](assets/diagrams/luoc_do_quan_he.png)

## 4.3 Phân tích ứng dụng

Theo phương pháp thiết kế từ trên xuống, nhóm liệt kê các ứng dụng chính, nơi phát sinh, dữ liệu sử dụng và tần suất (Bảng 4.2).

Bảng: Các ứng dụng chính của hệ thống
| Mã | Ứng dụng | Phát sinh tại | Dữ liệu sử dụng | Tần suất |
|---|---|---|---|---|
| Q1 | Tra cứu khách hàng của chi nhánh để lập đơn | S1, S2, S3 | KhachHang(MaKH, HoTen, SDT, Email, DiaChi, MaCN) | Rất cao |
| Q2 | Lập đơn, xem và cập nhật đơn hàng của chi nhánh | S1, S2, S3 | DonHang, ChiTietDonHang, SanPham | Rất cao |
| Q3 | Kiểm tra hạn mức, công nợ; báo cáo công nợ theo miền | S0 | KhachHang(MaKH, MaCN, HanMucNo, CongNo, DiemTichLuy) | Trung bình |
| Q4 | Xem danh sách nhân viên chi nhánh | S1, S2, S3 | NhanVien(MaNV, HoTen, ChucVu, SDT, MaCN) | Trung bình |
| Q5 | Tính lương, quản lý hồ sơ nhân sự | S0 | NhanVien(MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan) | Thấp |
| Q6 | Báo cáo doanh thu toàn công ty, theo chi nhánh | S0 | DonHang, ChiTietDonHang | Thấp |
| Q7 | Cập nhật danh mục và giá sản phẩm | S0 | SanPham | Thấp |

Ma trận sử dụng thuộc tính của KhachHang (Hình 4.2) cho thấy các thuộc tính chia thành hai nhóm tách biệt: **nhóm giao dịch** do Q1, Q2 sử dụng tại chi nhánh và **nhóm tài chính** do Q3 sử dụng tại trụ sở. Hai nhóm chỉ chung khóa MaKH và thuộc tính MaCN. Kết quả này phù hợp với ví dụ BEA và SPLIT ở mục 2.5.5. Đồng thời, mỗi chi nhánh chỉ truy cập các bộ của khách thuộc chi nhánh mình. Như vậy KhachHang cần được phân mảnh theo cả bộ lẫn thuộc tính. Lập luận tương tự áp dụng cho NhanVien: Q4 dùng thông tin công việc tại chi nhánh, Q5 dùng thông tin nhân sự tại trụ sở.

![Ma trận sử dụng thuộc tính của quan hệ KhachHang](assets/diagrams/ma_tran_su_dung_KhachHang.png)

## 4.4 Thiết kế phân mảnh

Bảng 4.3 tóm tắt kiểu phân mảnh được chọn cho từng quan hệ. Chi tiết được trình bày trong các mục tiếp theo.

Bảng: Kiểu phân mảnh của từng quan hệ
| Quan hệ | Kiểu phân mảnh | Số mảnh lá | Lý do |
|---|---|---|---|
| KhachHang | Hỗn hợp HV | 6 | Chi nhánh cần dòng của mình + cột giao dịch; kế toán cần cột tài chính, báo cáo theo miền |
| NhanVien | Hỗn hợp VH | 4 | Tách dữ liệu nhân sự nhạy cảm, xử lý tập trung; chỉ chia ngang phần công việc |
| DonHang | Ngang dẫn xuất theo KhachHang | 3 | Đặt đơn cùng site với khách, kết nối cục bộ |
| ChiTietDonHang | Ngang dẫn xuất theo DonHang | 3 | Đặt chi tiết cùng site với đơn |
| ChiNhanh, SanPham | Không phân mảnh, nhân bản toàn phần | — | Nhỏ, chủ yếu được đọc, ít cập nhật |

### 4.4.1 KhachHang – phân mảnh hỗn hợp HV

**Bước 1 – phân mảnh ngang nguyên thủy** theo các vị từ pᵢ: MaCN = 'CN0i' (đã thiết kế ở mục 2.3.4):

$$ KHᵢ = σ_MaCN='CN0i'(KhachHang),   i = 1, 2, 3

**Bước 2 – phân mảnh dọc** từng mảnh KHᵢ thành phần giao dịch và phần tài chính. Thuộc tính MaCN được giữ ở phần giao dịch vì đó là thuộc tính phân mảnh, cần cho ràng buộc CHECK tại chi nhánh:

$$ KHᵢ_GD = π_{MaKH, HoTen, SDT, Email, DiaChi, MaCN}(KHᵢ)     → đặt tại Sᵢ

$$ KHᵢ_TC = π_{MaKH, HanMucNo, CongNo, DiemTichLuy}(KHᵢ)     → đặt tại S0

**Tái thiết:**

$$ KhachHang = ⋃_{i=1..3} ( KHᵢ_GD ⋈_MaKH KHᵢ_TC )

Cây phân mảnh gồm sáu lá, như Hình 3.1. Nhóm chọn HV thay vì VH vì phòng Kế toán lập báo cáo công nợ **theo từng miền**. Phần tài chính được chia sẵn theo miền nên báo cáo của mỗi miền chỉ cần đọc đúng một mảnh. Mảnh TC không cần chứa MaCN: miền của khách đã được xác định bởi chính mảnh chứa nó, nhờ phép chọn ở bước 1.

### 4.4.2 NhanVien – phân mảnh hỗn hợp VH

**Bước 1 – phân mảnh dọc** thành thông tin công việc và thông tin nhân sự:

$$ NV_CV = π_{MaNV, HoTen, ChucVu, SDT, MaCN}(NhanVien)

$$ NV_NS = π_{MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan}(NhanVien)     → đặt tại S0

**Bước 2 – phân mảnh ngang** chỉ trên mảnh công việc:

$$ NV_CVᵢ = σ_MaCN='CN0i'(NV_CV)     → đặt tại Sᵢ,   i = 1, 2, 3

**Tái thiết:**

$$ NhanVien = ( NV_CV₁ ∪ NV_CV₂ ∪ NV_CV₃ ) ⋈_MaNV NV_NS

Cây phân mảnh gồm bốn lá, như Hình 3.2. Nhóm chọn VH vì tiêu chí phân biệt chính ở đây là **thuộc tính**, nhằm tách dữ liệu nhạy cảm. Phần nhân sự được xử lý tập trung tại trụ sở nên không cần chia ngang; hơn nữa NV_NS không chứa MaCN nên cũng không chia ngang trực tiếp theo chi nhánh được. Việc dùng HV cho KhachHang và VH cho NhanVien cũng cho phép so sánh hai chiến lược trên cùng một hệ thống.

### 4.4.3 DonHang, ChiTietDonHang – phân mảnh ngang dẫn xuất

$$ DHᵢ = DonHang ⋉_MaKH KHᵢ,     CTDHᵢ = ChiTietDonHang ⋉_MaDH DHᵢ,     i = 1, 2, 3

Trong đó KHᵢ là mảnh ngang ở bước 1 của mục 4.4.1, có chứa MaKH. Nhờ phân mảnh dẫn xuất, mọi phép kết nối giữa khách hàng, đơn hàng và chi tiết đơn hàng đều thực hiện được tại chỗ ở chi nhánh.

### 4.4.4 ChiNhanh, SanPham – nhân bản toàn phần

Hai quan hệ này nhỏ (3 và 10 bộ trong dữ liệu mẫu), được đọc ở mọi site và chỉ trụ sở cập nhật. Chúng được nhân bản toàn phần ở cả bốn site. Mọi cập nhật thực hiện tại S0 rồi đồng bộ xuống các chi nhánh.

## 4.5 Kiểm tra tính đúng đắn

Bảng 4.4 tóm tắt việc kiểm tra ba quy tắc cho hai quan hệ được phân mảnh hỗn hợp.

Bảng: Kiểm tra tính đúng đắn của phân mảnh hỗn hợp
| Quy tắc | KhachHang (HV) | NhanVien (VH) |
|---|---|---|
| Đầy đủ | Bước ngang: {MaCN='CN01', 'CN02', 'CN03'} phủ toàn miền giá trị MaCN (có CHECK). Bước dọc: GD ∪ TC = toàn bộ thuộc tính | Bước dọc: CV ∪ NS = toàn bộ thuộc tính. Bước ngang: các vị từ phủ miền giá trị MaCN |
| Tái thiết | ⋈ trên khóa MaKH không mất, không thừa bộ; ∪ các kết quả cho lại KhachHang | ∪ các NV_CVᵢ cho lại NV_CV; ⋈ với NV_NS trên khóa MaNV |
| Rời nhau | Các vị từ loại trừ nhau nên các KHᵢ rời nhau; GD ∩ TC = {MaKH} | Các NV_CVᵢ rời nhau; CV ∩ NS = {MaNV} |

Với DonHang và ChiTietDonHang, tính đầy đủ được đảm bảo bởi ràng buộc khóa ngoại. Tính rời nhau được đảm bảo vì mỗi đơn hàng có đúng một khách hàng, và mỗi khách hàng thuộc đúng một chi nhánh. Ngoài lập luận lý thuyết, cả ba quy tắc được kiểm tra trên dữ liệu bằng truy vấn SQL ở mục 4.7.3.

## 4.6 Lược đồ cấp phát

Bảng 4.5 và Hình 4.3 trình bày lược đồ cấp phát các mảnh cho bốn site.

Bảng: Lược đồ cấp phát
| Site | Mảnh được cấp phát |
|---|---|
| S0 – Trụ sở | KH₁_TC, KH₂_TC, KH₃_TC, NV_NS, ChiNhanh*, SanPham* |
| S1 – Hà Nội | KH₁_GD, NV_CV₁, DH₁, CTDH₁, ChiNhanh*, SanPham* |
| S2 – Đà Nẵng | KH₂_GD, NV_CV₂, DH₂, CTDH₂, ChiNhanh*, SanPham* |
| S3 – TP.HCM | KH₃_GD, NV_CV₃, DH₃, CTDH₃, ChiNhanh*, SanPham* |

(* bản nhân bản)

![Lược đồ cấp phát các mảnh cho bốn site](assets/diagrams/cap_phat_4_site.png)

Với lược đồ cấp phát này, mức độ cục bộ của các ứng dụng như sau:

- **Q1, Q2, Q4** (tần suất cao) chạy **hoàn toàn cục bộ** tại chi nhánh: mọi mảnh cần thiết (KHᵢ_GD, DHᵢ, CTDHᵢ, NV_CVᵢ, SanPham) đều nằm tại Sᵢ.
- **Q3, Q5, Q7** chạy cục bộ tại trụ sở.
- Chỉ **Q6** (báo cáo toàn công ty, tần suất thấp) cần lấy dữ liệu từ ba chi nhánh.

## 4.7 Cài đặt thực nghiệm trên SQL Server

### 4.7.1 Môi trường và cách mô phỏng

- Hệ quản trị: Microsoft SQL Server 2022 (bản Developer), công cụ SQL Server Management Studio.
- Mỗi site được mô phỏng bằng một CSDL riêng trên cùng một instance: QLDH_TRUSO (S0), QLDH_HN (S1), QLDH_DN (S2), QLDH_HCM (S3). Thêm CSDL QLDH_GOC chứa lược đồ toàn cục và dữ liệu ban đầu, dùng làm chuẩn để đối chiếu.
- Dữ liệu mẫu: 3 chi nhánh, 30 khách hàng (10 khách mỗi chi nhánh), 12 nhân viên (4 người mỗi chi nhánh), 10 sản phẩm, 45 đơn hàng (15 đơn mỗi chi nhánh) với 97 dòng chi tiết. Dữ liệu được sinh bằng một chương trình Python với seed cố định, nên chạy lại luôn cho cùng kết quả.
- Bốn script được chạy theo thứ tự (Bảng 4.6).

Bảng: Các script cài đặt
| Script | Nội dung |
|---|---|
| 01_global_schema.sql | Tạo QLDH_GOC: sáu bảng, khóa, khóa ngoại, CHECK; nạp dữ liệu mẫu |
| 02_fragments.sql | Tạo bốn site, tạo các bảng mảnh và nạp dữ liệu theo đúng biểu thức phân mảnh |
| 03_reconstruct_check.sql | Tạo synonym, view tái thiết; kiểm tra ba quy tắc đúng đắn |
| 04_queries.sql | Truy vấn cục bộ, truy vấn toàn cục, giao dịch phân tán |

Việc dùng nhiều CSDL trên một máy là **mô phỏng**: ranh giới giữa các site là ranh giới giữa các CSDL. Thiết kế phân mảnh và cấp phát không phụ thuộc vào hạ tầng này. Như trình bày ở mục 4.7.3, nhờ dùng synonym, có thể chuyển sang nhiều máy thật bằng Linked Server mà không phải sửa view và truy vấn.

### 4.7.2 Tạo các mảnh

Mỗi mảnh được tạo thành một bảng có khóa chính, và dữ liệu được nạp bằng câu lệnh tương ứng với biểu thức đại số của mảnh. Vị từ phân mảnh được ghi thành ràng buộc CHECK, nên mảnh không thể nhận dữ liệu sai chi nhánh. Ví dụ tại site Hà Nội:

```sql
-- KH_1_GD = π[MaKH,HoTen,SDT,Email,DiaChi,MaCN]( σ[MaCN='CN01'](KhachHang) )
CREATE TABLE dbo.KH_1_GD (
    MaKH   CHAR(5)       NOT NULL PRIMARY KEY,
    HoTen  NVARCHAR(50)  NOT NULL,
    SDT    VARCHAR(12)   NOT NULL,
    Email  VARCHAR(60)   NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    MaCN   CHAR(4)       NOT NULL,
    CONSTRAINT CK_KH_1_GD_MaCN CHECK (MaCN = 'CN01')
);
INSERT INTO dbo.KH_1_GD (MaKH, HoTen, SDT, Email, DiaChi, MaCN)
SELECT MaKH, HoTen, SDT, Email, DiaChi, MaCN
FROM QLDH_GOC.dbo.KhachHang
WHERE MaCN = 'CN01';

-- DH_1 = DonHang ⋉[MaKH] KH_1  (phép nửa kết nối viết bằng EXISTS)
INSERT INTO dbo.DH_1 (MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien)
SELECT d.MaDH, d.NgayDat, d.MaKH, d.MaNV, d.TrangThai, d.TongTien
FROM QLDH_GOC.dbo.DonHang AS d
WHERE EXISTS (SELECT 1 FROM QLDH_GOC.dbo.KhachHang AS k
              WHERE k.MaKH = d.MaKH AND k.MaCN = 'CN01');
```

Sau khi chạy script, số bộ trong các mảnh được thống kê ở Bảng 4.7.

Bảng: Số bộ trong các mảnh sau khi phân mảnh
| Site | Mảnh và số bộ |
|---|---|
| S0 – QLDH_TRUSO | KH₁_TC: 10 · KH₂_TC: 10 · KH₃_TC: 10 · NV_NS: 12 |
| S1 – QLDH_HN | KH₁_GD: 10 · NV_CV₁: 4 · DH₁: 15 · CTDH₁: 29 |
| S2 – QLDH_DN | KH₂_GD: 10 · NV_CV₂: 4 · DH₂: 15 · CTDH₂: 37 |
| S3 – QLDH_HCM | KH₃_GD: 10 · NV_CV₃: 4 · DH₃: 15 · CTDH₃: 31 |

[[ẢNH: demo_01_object_explorer.png – Object Explorer hiển thị 5 CSDL và các bảng mảnh]]

[[ẢNH: demo_03_manh_GD_TC.png – Nội dung mảnh KH_1_GD (tại S1) và KH_1_TC (tại S0)]]

### 4.7.3 Tái thiết và kiểm tra tính đúng đắn

Tại S0, nhóm tạo **synonym** cho từng mảnh nằm ở chi nhánh, rồi xây dựng **view tái thiết** trên các synonym đó. View v_KhachHang cài đặt đúng công thức tái thiết của chiến lược HV:

```sql
CREATE SYNONYM dbo.syn_KH_1_GD FOR QLDH_HN.dbo.KH_1_GD;   -- tương tự cho các mảnh khác

-- KhachHang = ⋃ i=1..3 ( KH_i_GD ⋈[MaKH] KH_i_TC )
CREATE OR ALTER VIEW dbo.v_KhachHang AS
    SELECT gd.MaKH, gd.HoTen, gd.SDT, gd.Email, gd.DiaChi, gd.MaCN,
           tc.HanMucNo, tc.CongNo, tc.DiemTichLuy
    FROM dbo.syn_KH_1_GD AS gd JOIN dbo.KH_1_TC AS tc ON tc.MaKH = gd.MaKH
    UNION ALL
    SELECT ... FROM dbo.syn_KH_2_GD AS gd JOIN dbo.KH_2_TC AS tc ON tc.MaKH = gd.MaKH
    UNION ALL
    SELECT ... FROM dbo.syn_KH_3_GD AS gd JOIN dbo.KH_3_TC AS tc ON tc.MaKH = gd.MaKH;
```

View v_NhanVien cài đặt công thức của chiến lược VH: hợp ba mảnh NV_CVᵢ trước, sau đó kết nối với NV_NS. View v_DonHang và v_ChiTietDonHang là phép hợp các mảnh dẫn xuất. Người dùng tại trụ sở truy vấn các view này như truy vấn trên quan hệ toàn cục, không cần biết dữ liệu được chia thành những mảnh nào và nằm ở site nào. Đó là **trong suốt phân mảnh** và **trong suốt vị trí**.

Việc dùng synonym thay vì viết thẳng tên CSDL có một lợi ích quan trọng. Khi chuyển sang chạy trên nhiều máy thật, chỉ cần tạo Linked Server và tạo lại synonym trỏ tới tên bốn phần, chẳng hạn [MAY_HN].QLDH_HN.dbo.KH_1_GD. Các view và truy vấn giữ nguyên.

Để kiểm tra tính đúng đắn, nhóm viết 13 truy vấn so sánh dữ liệu trong các mảnh với CSDL gốc QLDH_GOC:

- **Đầy đủ:** đếm số bộ của quan hệ gốc không thuộc mảnh ngang nào; đếm số thuộc tính của quan hệ gốc không thuộc mảnh dọc nào, bằng cách so sánh danh sách cột trong sys.columns với EXCEPT.
- **Tái thiết:** đếm số bộ lệch giữa quan hệ gốc và view tái thiết theo cả hai chiều bằng EXCEPT, cộng thêm chênh lệch về số lượng bộ.
- **Rời nhau:** đếm số khóa xuất hiện ở nhiều hơn một mảnh ngang bằng GROUP BY … HAVING COUNT(*) > 1; đếm số thuộc tính không khóa có mặt ở cả hai mảnh dọc bằng INTERSECT.

Bảng 4.8 là kết quả kiểm tra. Cả 13 phép kiểm tra đều cho số dòng lệch bằng 0, khẳng định phân mảnh đúng đắn trên dữ liệu thực.

Bảng: Kết quả kiểm tra tính đúng đắn
| STT | Quan hệ | Quy tắc | Nội dung kiểm tra | Số lệch | Kết quả |
|---|---|---|---|---|---|
| 1 | KhachHang | Đầy đủ | Bộ không thuộc mảnh ngang nào | 0 | ĐẠT |
| 2 | KhachHang | Đầy đủ | Thuộc tính không thuộc mảnh dọc nào (GD ∪ TC) | 0 | ĐẠT |
| 3 | KhachHang | Tái thiết | Bộ lệch giữa KhachHang gốc và v_KhachHang | 0 | ĐẠT |
| 4 | KhachHang | Rời nhau | MaKH thuộc nhiều hơn một mảnh ngang | 0 | ĐẠT |
| 5 | KhachHang | Rời nhau | Thuộc tính không khóa lặp ở cả GD và TC | 0 | ĐẠT |
| 6 | NhanVien | Đầy đủ | Thuộc tính không thuộc mảnh dọc nào (CV ∪ NS) | 0 | ĐẠT |
| 7 | NhanVien | Đầy đủ | Bộ của NV_CV không thuộc mảnh ngang nào | 0 | ĐẠT |
| 8 | NhanVien | Tái thiết | Bộ lệch giữa NhanVien gốc và v_NhanVien | 0 | ĐẠT |
| 9 | NhanVien | Rời nhau | MaNV thuộc nhiều hơn một mảnh ngang | 0 | ĐẠT |
| 10 | NhanVien | Rời nhau | Thuộc tính không khóa lặp ở cả CV và NS | 0 | ĐẠT |
| 11 | DonHang | Đầy đủ | Đơn hàng không thuộc mảnh nào | 0 | ĐẠT |
| 12 | DonHang | Tái thiết | Bộ lệch giữa DonHang gốc và v_DonHang | 0 | ĐẠT |
| 13 | DonHang | Rời nhau | MaDH thuộc nhiều hơn một mảnh | 0 | ĐẠT |

[[ẢNH: demo_05_kiem_tra_dung_dan.png – Kết quả chạy phần kiểm tra trong 03_reconstruct_check.sql]]

Ngoài ra, script còn kiểm tra quan hệ ChiTietDonHang (tái thiết từ ba mảnh CTDHᵢ), nằm trong cùng bảng kết quả trên màn hình.

### 4.7.4 Truy vấn minh họa

**Truy vấn cục bộ tại chi nhánh (S1).** Truy vấn Q2 liệt kê các đơn đang xử lý của chi nhánh Hà Nội, kèm tên khách, nhân viên và sản phẩm. Nó kết nối năm bảng nhưng tất cả đều nằm tại S1: DH₁, KH₁_GD, NV_CV₁, CTDH₁ và bản nhân bản SanPham. Kết quả gồm 6 dòng chi tiết của 4 đơn hàng DH020, DH027, DH028, DH036.

```sql
SELECT dh.MaDH, dh.NgayDat, kh.HoTen AS KhachHang, sp.TenSP, ct.SoLuong, dh.TrangThai
FROM dbo.DH_1 AS dh
JOIN dbo.KH_1_GD AS kh ON kh.MaKH = dh.MaKH
JOIN dbo.CTDH_1  AS ct ON ct.MaDH = dh.MaDH
JOIN dbo.SanPham AS sp ON sp.MaSP = ct.MaSP
WHERE dh.TrangThai IN (N'Mới', N'Đang giao');
```

Phân mảnh dọc còn đóng vai trò bảo mật. Mảnh NV_CV₁ tại chi nhánh không có cột lương, nên câu lệnh SELECT MaNV, Luong FROM NV_CV₁ báo lỗi *Invalid column name 'Luong'*. Tương tự, khi thêm vào KH_1_GD một khách hàng có MaCN = 'CN02', câu lệnh bị ràng buộc CHECK từ chối.

[[ẢNH: demo_06_truy_van_cuc_bo.png – Kết quả truy vấn Q2 tại S1]]

**Truy vấn cục bộ tại trụ sở (S0).** Báo cáo công nợ theo miền (Q3) chỉ dùng ba mảnh KHᵢ_TC tại S0, không cần truy cập chi nhánh nào (Bảng 4.9).

Bảng: Báo cáo công nợ theo miền (Q3)
| Chi nhánh | Số khách | Tổng hạn mức (đồng) | Tổng công nợ (đồng) | Tỉ lệ sử dụng |
|---|---|---|---|---|
| CN01 – Hà Nội | 10 | 1.700.000.000 | 774.500.000 | 45,6% |
| CN02 – Đà Nẵng | 10 | 2.000.000.000 | 1.092.100.000 | 54,6% |
| CN03 – TP.HCM | 10 | 1.850.000.000 | 967.700.000 | 52,3% |

**Truy vấn toàn cục qua view.** Danh sách khách hàng có công nợ từ 80% hạn mức trở lên cần họ tên (ở chi nhánh) và công nợ (ở trụ sở), nên phải ghép mảnh của nhiều site. Truy vấn viết trên v_KhachHang như với một bảng bình thường. Kết quả gồm ba khách: KH011 (CN02, 90,1%), KH025 (CN01, 80,7%) và KH015 (CN03, 80,4%).

Báo cáo doanh thu theo chi nhánh (Q6) được viết theo hai cách cho cùng một kết quả (Bảng 4.10):

- **Cách 1**, trên view toàn cục: v_DonHang ⋈ v_KhachHang ⋈ ChiNhanh, nhóm theo chi nhánh.
- **Cách 2**, phân rã theo mảnh: mỗi site tự tính tổng trên mảnh DHᵢ của mình, trụ sở chỉ hợp ba dòng kết quả. Cách này không cần phép kết nối nào, vì đơn hàng đã được phân mảnh dẫn xuất theo chi nhánh của khách. Đây chính là phép rút gọn chương trình định vị đã trình bày ở mục 3.7.2.

Bảng: Doanh thu theo chi nhánh, không tính đơn đã hủy (Q6)
| Chi nhánh | Số đơn | Doanh thu (đồng) |
|---|---|---|
| CN01 – Hà Nội | 14 | 262.670.000 |
| CN02 – Đà Nẵng | 13 | 256.960.000 |
| CN03 – TP.HCM | 15 | 171.350.000 |
| **Tổng** | **42** | **690.980.000** |

[[ẢNH: demo_07_truy_van_toan_cuc.png – Kết quả truy vấn toàn cục qua view]]

### 4.7.5 Giao dịch phân tán

Thiết kế cũng có cái giá phải trả. Khi lập đơn hàng, chi nhánh ghi vào DHᵢ và CTDHᵢ tại Sᵢ, nhưng đồng thời phải kiểm tra hạn mức và cộng công nợ vào KHᵢ_TC tại S0. Một thao tác nghiệp vụ vì vậy ghi lên hai site và phải đảm bảo tính nguyên tử. Nhóm cài đặt thủ tục usp_LapDonHang tại S1:

```sql
CREATE OR ALTER PROCEDURE dbo.usp_LapDonHang
    @MaDH CHAR(5), @MaKH CHAR(5), @MaNV CHAR(4), @MaSP CHAR(4), @SoLuong INT
AS
BEGIN
    SET XACT_ABORT ON;   -- lỗi bất kỳ → hủy toàn bộ giao dịch trên cả hai site
    DECLARE @DonGia DECIMAL(18,0) = (SELECT GiaBan FROM dbo.SanPham WHERE MaSP = @MaSP);
    DECLARE @Tien   DECIMAL(18,0) = @DonGia * @SoLuong;
    BEGIN TRANSACTION;
        DECLARE @HanMuc DECIMAL(18,0), @CongNo DECIMAL(18,0);
        SELECT @HanMuc = HanMucNo, @CongNo = CongNo
        FROM QLDH_TRUSO.dbo.KH_1_TC WITH (UPDLOCK, ROWLOCK)     -- đọc tại S0
        WHERE MaKH = @MaKH;
        IF @CongNo + @Tien > @HanMuc
            THROW 50002, N'Đơn hàng vượt hạn mức công nợ.', 1;
        INSERT INTO dbo.DH_1 (...) VALUES (...);                -- ghi tại S1
        INSERT INTO dbo.CTDH_1 (...) VALUES (...);
        UPDATE QLDH_TRUSO.dbo.KH_1_TC                            -- ghi tại S0
        SET CongNo = CongNo + @Tien WHERE MaKH = @MaKH;
    COMMIT TRANSACTION;
END
```

Hai trường hợp được thử nghiệm:

- **Thành công:** khách KH007 (hạn mức 200.000.000 đồng, công nợ 86.100.000 đồng) mua một máy in giá 4.590.000 đồng. Đơn DH046 xuất hiện ở S1, đồng thời công nợ tại S0 tăng lên 90.690.000 đồng. Đơn mới cũng thấy được ngay qua view toàn cục v_DonHang.
- **Thất bại:** khách KH022 (hạn mức 50.000.000 đồng, công nợ 30.900.000 đồng) mua hai laptop, tổng 33.980.000 đồng, vượt hạn mức. Thủ tục báo lỗi 50002 và giao dịch bị hủy trên **cả hai** site: không có đơn DH047 ở S1, công nợ tại S0 giữ nguyên 30.900.000 đồng.

Trên cùng một instance, SQL Server tự đảm bảo tính nguyên tử cho giao dịch trên nhiều CSDL. Khi các site là các máy khác nhau nối qua Linked Server, giao dịch được điều phối bởi MSDTC theo giao thức cam kết hai pha (2PC).

[[ẢNH: demo_08_giao_dich.png – Công nợ trước và sau giao dịch, thông báo lỗi khi vượt hạn mức]]

## 4.8 Đánh giá

**Kết quả đạt được:**

- Các ứng dụng có tần suất cao (Q1, Q2, Q4) chạy hoàn toàn cục bộ tại chi nhánh. Các ứng dụng của trụ sở (Q3, Q5, Q7) chạy cục bộ tại S0. Chỉ báo cáo toàn công ty (Q6) cần truy cập nhiều site, và nhờ phân mảnh dẫn xuất, nó được phân rã thành các phép tính cục bộ cộng một phép hợp nhỏ.
- Dữ liệu nhân sự nhạy cảm chỉ tồn tại ở trụ sở; chi nhánh không thể truy cập kể cả khi cố ý.
- Vị từ phân mảnh được ràng buộc bằng CHECK, nên dữ liệu không thể bị đặt sai mảnh.
- Tính đúng đắn được chứng minh về lý thuyết và kiểm tra tự động trên dữ liệu.
- Người dùng ở trụ sở có trong suốt phân mảnh và trong suốt vị trí nhờ view và synonym.

**Hạn chế và đánh đổi:**

- Lập đơn hàng trở thành giao dịch phân tán vì công nợ nằm ở trụ sở. Nếu đường truyền đến trụ sở gián đoạn, chi nhánh không lập được đơn. Có thể cân nhắc để công nợ tại chi nhánh và định kỳ đồng bộ về trụ sở, nhưng khi đó phải chấp nhận dữ liệu báo cáo có độ trễ.
- Khách hàng chuyển chi nhánh đòi hỏi di chuyển bộ dữ liệu giữa các mảnh ở cả hai nhánh dọc và các đơn hàng dẫn xuất.
- Bản nhân bản SanPham phải được đồng bộ mỗi khi trụ sở đổi giá.
- Thực nghiệm mô phỏng các site bằng nhiều CSDL trên một máy, chưa đo được độ trễ mạng thực tế.

## 4.9 Kết chương

Chương 4 đã áp dụng phân mảnh hỗn hợp cho hệ thống quản lý đơn hàng: phân tích ứng dụng, thiết kế phân mảnh HV cho KhachHang, VH cho NhanVien, phân mảnh dẫn xuất cho DonHang và ChiTietDonHang, nhân bản ChiNhanh và SanPham, lập lược đồ cấp phát, và cài đặt trên SQL Server kèm kiểm tra tính đúng đắn, truy vấn và giao dịch phân tán. Kết quả cho thấy thiết kế giúp đa số truy vấn chạy cục bộ, đổi lại một số thao tác cập nhật trở thành giao dịch phân tán.
