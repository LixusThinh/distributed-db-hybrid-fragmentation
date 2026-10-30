# CHƯƠNG 4. ỨNG DỤNG PHÂN MẢNH HỖN HỢP CHO HỆ THỐNG QUẢN LÝ ĐƠN HÀNG

## 4.1 Mô tả bài toán

Công ty thương mại X (công ty giả định) phân phối thiết bị văn phòng qua ba chi nhánh ở ba miền và có một trụ sở chính đặt tại TP. Hồ Chí Minh. Mỗi địa điểm là một site của CSDL phân tán.

Các nghiệp vụ chính:

- Mỗi khách hàng được quản lý bởi **đúng một** chi nhánh, là nơi khách đăng ký.
- Nhân viên chi nhánh tra cứu khách hàng, lập đơn hàng và cập nhật trạng thái đơn cho khách của chi nhánh mình. Đây là nghiệp vụ diễn ra nhiều nhất.
- Phòng Kế toán quản lý hạn mức công nợ, công nợ hiện tại và điểm tích lũy của khách hàng ở cả ba miền, lập báo cáo công nợ theo từng miền.
- Phòng Nhân sự quản lý ngày sinh, số CCCD, lương và số tài khoản của nhân viên. Đây là dữ liệu nhạy cảm, chi nhánh không được truy cập.
- Danh mục sản phẩm và giá bán do trụ sở quản lý; mọi chi nhánh đều cần đọc khi lập đơn.

Lược đồ toàn cục gồm sáu quan hệ:

- ChiNhanh(**MaCN**, TenCN, KhuVuc, DiaChi, SDT)
- KhachHang(**MaKH**, HoTen, SDT, Email, DiaChi, MaCN, HanMucNo, CongNo, DiemTichLuy)
- NhanVien(**MaNV**, HoTen, ChucVu, SDT, MaCN, NgaySinh, CCCD, Luong, SoTaiKhoan)
- SanPham(**MaSP**, TenSP, DonViTinh, GiaBan, MoTa)
- DonHang(**MaDH**, NgayDat, MaKH, MaNV, TrangThai, TongTien)
- ChiTietDonHang(**MaDH, MaSP**, SoLuong, DonGia)

Ràng buộc miền giá trị MaCN ∈ {'CN01', 'CN02', 'CN03'} được khai báo bằng CHECK. Ràng buộc này là cơ sở để chứng minh tính đầy đủ của phân mảnh ngang.

## 4.2 Phân tích ứng dụng

Theo phương pháp thiết kế từ trên xuống, nhóm liệt kê các ứng dụng chính, nơi phát sinh, dữ liệu sử dụng và tần suất (Bảng 4.1).

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

Ma trận sử dụng thuộc tính của KhachHang cho thấy các thuộc tính chia thành hai nhóm tách biệt: **nhóm giao dịch** do Q1, Q2 sử dụng tại chi nhánh và **nhóm tài chính** do Q3 sử dụng tại trụ sở. Hai nhóm chỉ chung khóa MaKH và thuộc tính MaCN. Kết quả này phù hợp với ví dụ BEA và SPLIT ở mục 2.5. Đồng thời, mỗi chi nhánh chỉ truy cập các bộ của khách thuộc chi nhánh mình. Như vậy KhachHang cần được phân mảnh theo cả bộ lẫn thuộc tính. Lập luận tương tự áp dụng cho NhanVien: Q4 dùng thông tin công việc tại chi nhánh, Q5 dùng thông tin nhân sự tại trụ sở.

## 4.3 Thiết kế phân mảnh

Bảng 4.2 tóm tắt kiểu phân mảnh được chọn cho từng quan hệ.

Bảng: Kiểu phân mảnh của từng quan hệ
| Quan hệ | Kiểu phân mảnh | Số mảnh lá | Lý do |
|---|---|---|---|
| KhachHang | Hỗn hợp HV | 6 | Chi nhánh cần dòng của mình + cột giao dịch; kế toán cần cột tài chính, báo cáo theo miền |
| NhanVien | Hỗn hợp VH | 4 | Tách dữ liệu nhân sự nhạy cảm, xử lý tập trung; chỉ chia ngang phần công việc |
| DonHang | Ngang dẫn xuất theo KhachHang | 3 | Đặt đơn cùng site với khách, kết nối cục bộ |
| ChiTietDonHang | Ngang dẫn xuất theo DonHang | 3 | Đặt chi tiết cùng site với đơn |
| ChiNhanh, SanPham | Không phân mảnh, nhân bản toàn phần | — | Nhỏ, chủ yếu được đọc, ít cập nhật |

**KhachHang – phân mảnh hỗn hợp HV.** Bước 1 – phân mảnh ngang nguyên thủy theo các vị từ pᵢ: MaCN = 'CN0i' (đã thiết kế ở mục 2.3). Bước 2 – phân mảnh dọc từng mảnh KHᵢ thành phần giao dịch và phần tài chính. Thuộc tính MaCN được giữ ở phần giao dịch vì đó là thuộc tính phân mảnh, cần cho ràng buộc CHECK tại chi nhánh:

$$ KHᵢ_GD = π_{MaKH, HoTen, SDT, Email, DiaChi, MaCN}(KHᵢ)     → đặt tại Sᵢ

$$ KHᵢ_TC = π_{MaKH, HanMucNo, CongNo, DiemTichLuy}(KHᵢ)     → đặt tại S0

Nhóm chọn HV thay vì VH vì phòng Kế toán lập báo cáo công nợ **theo từng miền**. Phần tài chính được chia sẵn theo miền nên báo cáo của mỗi miền chỉ cần đọc đúng một mảnh.

**NhanVien – phân mảnh hỗn hợp VH.** Bước 1 – phân mảnh dọc thành thông tin công việc và thông tin nhân sự:

$$ NV_CV = π_{MaNV, HoTen, ChucVu, SDT, MaCN}(NhanVien)

$$ NV_NS = π_{MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan}(NhanVien)     → đặt tại S0

Bước 2 – phân mảnh ngang chỉ trên mảnh công việc:

$$ NV_CVᵢ = σ_MaCN='CN0i'(NV_CV)     → đặt tại Sᵢ,   i = 1, 2, 3

Nhóm chọn VH vì tiêu chí phân biệt chính ở đây là **thuộc tính**, nhằm tách dữ liệu nhạy cảm. Phần nhân sự được xử lý tập trung tại trụ sở nên không cần chia ngang; hơn nữa NV_NS không chứa MaCN nên cũng không chia ngang trực tiếp theo chi nhánh được.

**DonHang, ChiTietDonHang – phân mảnh ngang dẫn xuất:**

$$ DHᵢ = DonHang ⋉_MaKH KHᵢ,     CTDHᵢ = ChiTietDonHang ⋉_MaDH DHᵢ,     i = 1, 2, 3

Nhờ phân mảnh dẫn xuất, mọi phép kết nối giữa khách hàng, đơn hàng và chi tiết đơn hàng đều thực hiện được tại chỗ ở chi nhánh.

**ChiNhanh, SanPham – nhân bản toàn phần.** Hai quan hệ này nhỏ (3 và 10 bộ trong dữ liệu mẫu), được đọc ở mọi site và chỉ trụ sở cập nhật. Chúng được nhân bản toàn phần ở cả bốn site.

## 4.4 Lược đồ cấp phát

Bảng: Lược đồ cấp phát
| Site | Mảnh được cấp phát |
|---|---|
| S0 – Trụ sở | KH₁_TC, KH₂_TC, KH₃_TC, NV_NS, ChiNhanh*, SanPham* |
| S1 – Hà Nội | KH₁_GD, NV_CV₁, DH₁, CTDH₁, ChiNhanh*, SanPham* |
| S2 – Đà Nẵng | KH₂_GD, NV_CV₂, DH₂, CTDH₂, ChiNhanh*, SanPham* |
| S3 – TP.HCM | KH₃_GD, NV_CV₃, DH₃, CTDH₃, ChiNhanh*, SanPham* |

(* bản nhân bản)

Với lược đồ cấp phát này, mức độ cục bộ của các ứng dụng như sau:

- **Q1, Q2, Q4** (tần suất cao) chạy **hoàn toàn cục bộ** tại chi nhánh: mọi mảnh cần thiết (KHᵢ_GD, DHᵢ, CTDHᵢ, NV_CVᵢ, SanPham) đều nằm tại Sᵢ.
- **Q3, Q5, Q7** chạy cục bộ tại trụ sở.
- Chỉ **Q6** (báo cáo toàn công ty, tần suất thấp) cần lấy dữ liệu từ ba chi nhánh.

## 4.5 Cài đặt thực nghiệm trên SQL Server

- Hệ quản trị: Microsoft SQL Server 2022 Express (phiên bản 16.0.1000), công cụ SQL Server Management Studio 21. Toàn bộ kết quả trong mục này là kết quả chạy thật trên môi trường đó.
- Mỗi site được mô phỏng bằng một CSDL riêng trên cùng một instance: QLDH_TRUSO (S0), QLDH_HN (S1), QLDH_DN (S2), QLDH_HCM (S3). Thêm CSDL QLDH_GOC chứa lược đồ toàn cục và dữ liệu ban đầu, dùng làm chuẩn để đối chiếu.
- Dữ liệu mẫu: 3 chi nhánh, 30 khách hàng (10 khách mỗi chi nhánh), 12 nhân viên (4 người mỗi chi nhánh), 10 sản phẩm, 45 đơn hàng (15 đơn mỗi chi nhánh) với 97 dòng chi tiết.

Tại S0, nhóm tạo **synonym** [7] cho từng mảnh nằm ở chi nhánh, rồi xây dựng **view tái thiết** trên các synonym đó. Người dùng tại trụ sở truy vấn các view này như truy vấn trên quan hệ toàn cục, không cần biết dữ liệu được chia thành những mảnh nào và nằm ở site nào. Đó là **trong suốt phân mảnh** và **trong suốt vị trí**.

Để kiểm tra tính đúng đắn, nhóm viết 14 truy vấn so sánh dữ liệu trong các mảnh với CSDL gốc QLDH_GOC. Cả 14 phép kiểm tra đều cho số dòng lệch bằng 0, khẳng định phân mảnh đúng đắn trên dữ liệu thực (Hình 4.1).

![Kết quả chạy phần kiểm tra trong 03_reconstruct_check.sql: 14/14 phép kiểm tra ĐẠT](assets/screenshots/demo_05_kiem_tra_dung_dan.png)

**Truy vấn cục bộ tại chi nhánh (S1).** Truy vấn Q2 liệt kê các đơn đang xử lý của chi nhánh Hà Nội, kèm tên khách, nhân viên và sản phẩm. Nó kết nối năm bảng nhưng tất cả đều nằm tại S1: DH₁, KH₁_GD, NV_CV₁, CTDH₁ và bản nhân bản SanPham. Phân mảnh dọc còn đóng vai trò bảo mật. Mảnh NV_CV₁ tại chi nhánh không có cột lương, nên câu lệnh SELECT MaNV, Luong FROM NV_CV₁ báo lỗi *Invalid column name 'Luong'*.

**Truy vấn toàn cục qua view.** Danh sách khách hàng có công nợ từ 80% hạn mức trở lên cần họ tên (ở chi nhánh) và công nợ (ở trụ sở), nên phải ghép mảnh của nhiều site. Truy vấn viết trên v_KhachHang như với một bảng bình thường. Kết quả gồm ba khách: KH011 (CN02, 90,1%), KH025 (CN01, 80,7%) và KH015 (CN03, 80,4%).

**Giao dịch phân tán.** Khi lập đơn hàng, chi nhánh ghi vào DHᵢ và CTDHᵢ tại Sᵢ, nhưng đồng thời phải kiểm tra hạn mức và cộng công nợ vào KHᵢ_TC tại S0. Một thao tác nghiệp vụ vì vậy ghi lên hai site và phải đảm bảo tính nguyên tử. Hai trường hợp được thử nghiệm (Hình 4.2):

- **Thành công:** khách KH007 (hạn mức 200.000.000 đồng, công nợ 86.100.000 đồng) mua một máy in giá 4.590.000 đồng. Đơn DH046 xuất hiện ở S1, đồng thời công nợ tại S0 tăng lên 90.690.000 đồng.
- **Thất bại:** khách KH022 (hạn mức 50.000.000 đồng, công nợ 30.900.000 đồng) mua hai laptop, tổng 33.980.000 đồng, vượt hạn mức. Thủ tục báo lỗi 50002 và giao dịch bị hủy trên **cả hai** site: không có đơn DH047 ở S1, công nợ tại S0 giữ nguyên 30.900.000 đồng.

![Giao dịch phân tán: công nợ KH007 trước và sau khi lập đơn DH046; đơn vượt hạn mức của KH022 bị hủy với lỗi 50002 và không site nào bị ghi dở](assets/screenshots/demo_08_giao_dich.png)
