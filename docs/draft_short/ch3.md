# CHƯƠNG 3. PHÂN MẢNH HỖN HỢP

## 3.1 Định nghĩa và động cơ sử dụng

Phân mảnh ngang phù hợp khi các ứng dụng khác nhau ở **những bộ** mà chúng truy cập. Phân mảnh dọc phù hợp khi các ứng dụng khác nhau ở **những thuộc tính** mà chúng truy cập. Trong nhiều hệ thống thực tế, hai sự khác biệt này xuất hiện đồng thời. Bảng 3.1 mô tả nhu cầu truy cập quan hệ KhachHang của các nhóm người dùng trong một công ty có ba chi nhánh.

Bảng: Nhu cầu truy cập KhachHang theo dòng và theo cột
| Nhóm người dùng | Những bộ cần truy cập | Những thuộc tính cần truy cập |
|---|---|---|
| Nhân viên chi nhánh Hà Nội | Khách của chi nhánh Hà Nội | Nhóm giao dịch: HoTen, SDT, Email, DiaChi |
| Nhân viên chi nhánh Đà Nẵng | Khách của chi nhánh Đà Nẵng | Nhóm giao dịch |
| Nhân viên chi nhánh TP.HCM | Khách của chi nhánh TP.HCM | Nhóm giao dịch |
| Phòng kế toán (trụ sở) | Khách của cả ba chi nhánh, báo cáo theo từng miền | Nhóm tài chính: HanMucNo, CongNo, DiemTichLuy |

Nếu chỉ phân mảnh ngang theo chi nhánh, mỗi chi nhánh vẫn phải lưu các cột tài chính mà mình không dùng, và phòng kế toán phải truy cập cả ba chi nhánh để lấy công nợ. Nếu chỉ phân mảnh dọc, mỗi chi nhánh phải lưu khách hàng của các chi nhánh khác. Không kiểu phân mảnh đơn lẻ nào đáp ứng được cả hai nhu cầu.

**Phân mảnh hỗn hợp** (hybrid fragmentation, còn gọi là phân mảnh lai) là việc áp dụng **nối tiếp** phân mảnh ngang và phân mảnh dọc lên một quan hệ: kết quả của một bước phân mảnh lại được phân mảnh tiếp theo kiểu còn lại [1], [2]. Một mảnh hỗn hợp vì vậy được biểu diễn bằng biểu thức kết hợp phép chọn và phép chiếu, có hai dạng:

$$ Rᵢⱼ = π_{K ∪ Aⱼ}( σ_Fᵢ(R) )        hoặc        Rⱼₖ = σ_Fₖ( π_{K ∪ Aⱼ}(R) )

trong đó K là khóa chính của R, Aⱼ là một nhóm thuộc tính, Fᵢ và Fₖ là các vị từ chọn.

## 3.2 Chiến lược ngang trước, dọc sau (HV)

Trong chiến lược HV, quan hệ được phân mảnh ngang trước, sau đó **từng** mảnh ngang được phân mảnh dọc:

1. Phân mảnh ngang nguyên thủy R thành R₁, …, Rₙ với Rᵢ = σ_Fᵢ(R), như ở mục 2.3.
2. Với mỗi Rᵢ, xác định các nhóm thuộc tính bằng ma trận ái lực, BEA và SPLIT (mục 2.5), tính trên các ứng dụng truy cập Rᵢ, rồi chia Rᵢ thành các mảnh Rᵢⱼ = π_{K ∪ Aᵢⱼ}(Rᵢ).

Đặc điểm của HV:

- Mỗi mảnh ngang có thể được chia dọc theo **cách khác nhau**, vì các ứng dụng truy cập mỗi mảnh ngang có thể khác nhau.
- Phù hợp khi tiêu chí phân biệt **chủ yếu là theo bộ** (theo địa lý, theo đơn vị quản lý), còn sự khác biệt theo thuộc tính là thứ yếu và có thể phụ thuộc vào từng nhóm bộ.

Hình 3.1 là cây phân mảnh HV của quan hệ KhachHang trong bài toán ở Chương 4: ba mảnh ngang theo chi nhánh, mỗi mảnh tách thành phần giao dịch (GD) và phần tài chính (TC), tổng cộng sáu mảnh lá.

![Cây phân mảnh hỗn hợp HV của quan hệ KhachHang](assets/diagrams/cay_HV_KhachHang.png)

## 3.3 Chiến lược dọc trước, ngang sau (VH)

Trong chiến lược VH, quan hệ được phân mảnh dọc trước, sau đó **một số** mảnh dọc được phân mảnh ngang tiếp:

1. Phân mảnh dọc R thành các mảnh Rⱼ = π_{K ∪ Aⱼ}(R) bằng BEA và SPLIT, tính trên toàn bộ ứng dụng.
2. Với những mảnh dọc mà các ứng dụng sử dụng chúng chỉ truy cập một phần các bộ, phân mảnh ngang tiếp: Rⱼₖ = σ_Fⱼₖ(Rⱼ).

Đặc điểm của VH:

- Chỉ những mảnh dọc **cần thiết** mới bị chia ngang; các mảnh dọc khác được giữ nguyên. Nhờ vậy số mảnh ít hơn và việc quản lý đơn giản hơn.
- Phù hợp khi tiêu chí phân biệt **chủ yếu là theo thuộc tính**, chẳng hạn tách dữ liệu nhạy cảm để bảo mật. Phần nhạy cảm thường được xử lý tập trung nên không cần chia ngang.

Hình 3.2 là cây phân mảnh VH của quan hệ NhanVien. Thông tin nhân sự NV_NS (ngày sinh, CCCD, lương, số tài khoản) được tách ra và giữ tập trung tại trụ sở. Chỉ phần thông tin công việc NV_CV được chia tiếp theo chi nhánh.

![Cây phân mảnh hỗn hợp VH của quan hệ NhanVien](assets/diagrams/cay_VH_NhanVien.png)

Phép chọn và phép chiếu giao hoán với nhau khi các thuộc tính của vị từ nằm trong tập thuộc tính được chiếu. Vì vậy, nếu **mọi** mảnh dọc đều chứa thuộc tính của vị từ và đều được chia ngang theo **cùng** các vị từ, HV và VH cho cùng một tập mảnh lá. Hai chiến lược chỉ thực sự khác nhau khi cây phân mảnh **không cân đối**: chỉ một số nút được chia tiếp (VH), hoặc mỗi nút được chia theo cách khác nhau (HV).

## 3.4 Cây phân mảnh và tái thiết quan hệ toàn cục

**Cây phân mảnh** là cách biểu diễn trực quan một lược đồ phân mảnh hỗn hợp:

- **Gốc** là quan hệ toàn cục R.
- Mỗi **nút trong** là một mảnh trung gian. Các cạnh từ một nút trong xuống các con của nó đều cùng một kiểu phân mảnh: hoặc đều là phép chọn σ (chia ngang), hoặc đều là phép chiếu π (chia dọc).
- Mỗi **lá** là một mảnh cuối cùng, được lưu trữ vật lý và cấp phát cho site.

Quan hệ toàn cục được tái thiết bằng cách duyệt cây phân mảnh **từ lá lên gốc**. Tại mỗi nút trong:

- nếu các con được tạo bằng phép chọn σ: nút = **hợp (∪)** các con;
- nếu các con được tạo bằng phép chiếu π: nút = **kết nối (⋈) trên khóa K** các con.

Với hai ví dụ ở trên:

$$ KhachHang = ⋃_{i=1..3} ( KHᵢ_GD ⋈_MaKH KHᵢ_TC )

$$ NhanVien = ( NV_CV₁ ∪ NV_CV₂ ∪ NV_CV₃ ) ⋈_MaNV NV_NS

Trong cài đặt bằng SQL, phép hợp các mảnh ngang rời nhau có thể dùng UNION ALL thay cho UNION. Vì các mảnh đã rời nhau, không có bộ trùng cần loại bỏ, nên UNION ALL cho cùng kết quả mà không tốn chi phí sắp xếp hay băm để khử trùng lặp.

## 3.5 Kiểm tra tính đúng đắn

**Mệnh đề.** Nếu phân mảnh tại mọi nút trong của cây phân mảnh đều thỏa ba quy tắc đầy đủ, tái thiết và rời nhau, thì phân mảnh hỗn hợp tương ứng với toàn bộ cây cũng thỏa ba quy tắc đó.

**Chứng minh (phác thảo)** bằng quy nạp theo chiều cao của cây:

- **Đầy đủ:** mỗi mục dữ liệu của nút cha có mặt trong ít nhất một nút con (giả thiết tại nút cha). Theo giả thiết quy nạp, mỗi mục dữ liệu của nút con có mặt trong ít nhất một lá của cây con. Vậy mọi mục dữ liệu của R đều có mặt trong ít nhất một lá.
- **Tái thiết:** mỗi nút con tái thiết được từ các lá của nó (giả thiết quy nạp), và nút cha tái thiết được từ các con bằng ∪ hoặc ⋈ (giả thiết tại nút cha). Hợp thành các phép toán đó cho biểu thức tái thiết R từ các lá, như ở mục 3.4.
- **Rời nhau:** hai lá bất kỳ có một nút tổ tiên chung gần nhất, và chúng nằm trong hai cây con của hai nút con khác nhau. Nếu nút tổ tiên đó chia ngang, hai lá chứa các tập bộ rời nhau. Nếu nút đó chia dọc, hai lá chỉ có chung thuộc tính khóa K. Trường hợp nào thì quy tắc rời nhau cũng thỏa.

## 3.6 Ảnh hưởng đến xử lý truy vấn và giao dịch

Khi nhận một truy vấn trên quan hệ toàn cục, DDBMS thay quan hệ đó bằng biểu thức tái thiết (gọi là **chương trình định vị**, localization program), rồi rút gọn [1]. Ví dụ với quan hệ KhachHang:

- Truy vấn SELECT HoTen, SDT FROM KhachHang WHERE MaCN = 'CN01' chỉ cần mảnh KH₁_GD, chạy hoàn toàn tại chi nhánh Hà Nội.
- Truy vấn SELECT SUM(CongNo) FROM KhachHang WHERE MaCN = 'CN02' chỉ cần mảnh KH₂_TC, chạy hoàn toàn tại trụ sở.
- Truy vấn SELECT HoTen, CongNo FROM KhachHang WHERE MaCN = 'CN02' cần KH₂_GD ⋈ KH₂_TC: hai mảnh nằm ở hai site khác nhau, phải truyền dữ liệu qua mạng.

Một thao tác cập nhật chạm đến thuộc tính thuộc nhiều mảnh dọc (ví dụ lập đơn hàng ở chi nhánh và cộng công nợ ở trụ sở) trở thành **giao dịch phân tán**, cần giao thức cam kết hai pha (2PC) để đảm bảo tính nguyên tử.

## 3.7 Ưu điểm, hạn chế và so sánh

Bảng 3.2 tóm tắt so sánh ba kiểu phân mảnh.

Bảng: So sánh ba kiểu phân mảnh
| Tiêu chí | Phân mảnh ngang | Phân mảnh dọc | Phân mảnh hỗn hợp |
|---|---|---|---|
| Đơn vị chia | Tập bộ | Tập thuộc tính + khóa | Tập bộ × tập thuộc tính |
| Phép toán | σ (hoặc ⋉ nếu dẫn xuất) | π | Kết hợp σ và π |
| Tái thiết | ∪ | ⋈ trên khóa | ∪ và ⋈ theo cây phân mảnh |
| Phù hợp khi | Ứng dụng khác nhau theo bộ (địa lý, đơn vị) | Ứng dụng khác nhau theo thuộc tính, cần bảo mật cột | Ứng dụng khác nhau theo cả bộ lẫn thuộc tính |
| Độ phức tạp | Thấp | Trung bình | Cao |

Để cài đặt phân mảnh hỗn hợp, cách phổ biến là: dùng cơ chế chia ngang (bảng riêng có CHECK, hoặc partitioning) cho bước ngang; dùng các bảng riêng chứa khóa chung cho bước dọc; và dùng view kết hợp UNION ALL và JOIN để tái thiết [3], [6]. Đây là cách nhóm áp dụng ở Chương 4.
