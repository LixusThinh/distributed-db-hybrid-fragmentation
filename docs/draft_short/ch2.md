# CHƯƠNG 2. PHÂN MẢNH DỮ LIỆU TRONG CSDL PHÂN TÁN

## 2.1 Lý do và đơn vị phân mảnh

Nếu đơn vị phân tán là cả một quan hệ, sẽ có hai lựa chọn đều không hiệu quả. Đặt quan hệ ở một site thì các site khác phải truy cập từ xa. Nhân bản quan hệ ra mọi site thì tốn không gian lưu trữ, và mỗi lần cập nhật phải sửa tất cả các bản sao. Trong khi đó, mỗi ứng dụng thường chỉ dùng một **tập con** của quan hệ, ví dụ chi nhánh Hà Nội chỉ cần khách hàng ở Hà Nội. Vì vậy, đơn vị phân tán hợp lý là các **mảnh** (fragment) của quan hệ.

Phân mảnh cũng có cái giá phải trả. Những ứng dụng cần dữ liệu ở nhiều mảnh phải ghép các mảnh lại, phát sinh chi phí truyền thông và xử lý. Việc kiểm tra ràng buộc toàn vẹn liên quan đến nhiều mảnh cũng phức tạp hơn. Do đó **mức độ phân mảnh** phải vừa phải: không phân mảnh thì mất tính cục bộ, phân mảnh quá nhỏ (đến từng bộ hoặc từng thuộc tính) thì chi phí ghép lại rất lớn. Mức độ hợp lý được xác định dựa trên các ứng dụng sử dụng CSDL.

Có ba kiểu phân mảnh cơ bản (Hình 2.1): **phân mảnh ngang** (theo dòng), **phân mảnh dọc** (theo cột) và **phân mảnh hỗn hợp** (kết hợp cả hai).

![Minh họa ba kiểu phân mảnh](assets/diagrams/ba_loai_phan_manh.png)

## 2.2 Các quy tắc đúng đắn của phân mảnh

Giả sử quan hệ R được phân mảnh thành các mảnh R₁, R₂, …, Rₙ. Phân mảnh được gọi là đúng đắn nếu thỏa ba quy tắc [1]:

- **Tính đầy đủ (completeness):** mỗi mục dữ liệu của R (một bộ đối với phân mảnh ngang, một thuộc tính đối với phân mảnh dọc) đều có mặt trong ít nhất một mảnh Rᵢ. Quy tắc này đảm bảo phân mảnh không làm mất dữ liệu.
- **Tính tái thiết (reconstruction):** tồn tại một phép toán quan hệ ∇ sao cho R = ∇ Rᵢ. Với phân mảnh ngang, ∇ là phép hợp (∪); với phân mảnh dọc, ∇ là phép kết nối (⋈) trên khóa. Quy tắc này đảm bảo các ràng buộc phụ thuộc giữa dữ liệu được bảo toàn.
- **Tính rời nhau (disjointness):** với phân mảnh ngang, một bộ thuộc Rⱼ thì không thuộc Rₖ (j ≠ k). Với phân mảnh dọc, các mảnh chỉ được trùng nhau ở khóa chính; khóa phải được lặp lại ở mọi mảnh để có thể tái thiết.

## 2.3 Phân mảnh ngang nguyên thủy

Phân mảnh ngang chia quan hệ theo các bộ. Mỗi mảnh là kết quả của một phép chọn trên quan hệ:

$$ Rᵢ = σ_Fᵢ(R),   i = 1..n

trong đó Fᵢ là vị từ chọn của mảnh Rᵢ. Gọi là phân mảnh **nguyên thủy** vì vị từ được định nghĩa trên chính các thuộc tính của R.

- **Vị từ đơn giản** có dạng pⱼ: Aᵢ θ Giá_trị, với Aᵢ là thuộc tính của R và θ ∈ {=, <, ≤, >, ≥, ≠}. Ví dụ: p₁: MaCN = 'CN01'.
- **Vị từ hội sơ cấp (minterm)** trên tập vị từ đơn giản Pr = {p₁, …, pₘ} là phép hội của tất cả các vị từ trong Pr, mỗi vị từ xuất hiện ở dạng khẳng định hoặc phủ định.

Mỗi minterm xác định một mảnh ngang, gọi là **mảnh hội sơ cấp**. Với m vị từ sẽ có 2ᵐ minterm, nhưng nhiều minterm mâu thuẫn và bị loại bỏ dựa trên ngữ nghĩa của thuộc tính.

**Ví dụ.** Xét quan hệ KhachHang(MaKH, HoTen, SDT, DiaChi, MaCN, HanMucNo, CongNo), với MaCN ∈ {'CN01', 'CN02', 'CN03'}. Ứng dụng tra cứu khách hàng ở mỗi chi nhánh chỉ truy cập khách thuộc chi nhánh đó, nên tập vị từ ứng viên là:

$$ p₁: MaCN = 'CN01'     p₂: MaCN = 'CN02'     p₃: MaCN = 'CN03'

Có 2³ = 8 minterm. Vì MaCN chỉ nhận một giá trị nên có các phép kéo theo p₁ ⇒ ¬p₂ ∧ ¬p₃ (tương tự cho p₂, p₃). Mọi minterm chứa từ hai vị từ khẳng định trở lên đều mâu thuẫn. Minterm ¬p₁ ∧ ¬p₂ ∧ ¬p₃ cũng mâu thuẫn vì miền giá trị của MaCN chỉ gồm ba giá trị trên. Còn lại ba minterm, rút gọn được thành p₁, p₂, p₃, cho ba mảnh:

$$ KHᵢ = σ_MaCN='CN0i'(KhachHang),   i = 1, 2, 3

Ba mảnh KH₁, KH₂, KH₃ thỏa các quy tắc đúng đắn: **đầy đủ** vì p₁ ∨ p₂ ∨ p₃ luôn đúng trên miền giá trị của MaCN; **rời nhau** vì các vị từ loại trừ lẫn nhau; **tái thiết** được bằng KhachHang = KH₁ ∪ KH₂ ∪ KH₃.

## 2.4 Phân mảnh ngang dẫn xuất

Phân mảnh ngang dẫn xuất áp dụng cho một quan hệ **thành viên** (member), dựa trên phân mảnh của quan hệ **chủ** (owner) mà nó tham chiếu tới. Quan hệ chủ và thành viên được nối với nhau bằng một liên kết, thường là khóa ngoại. Nếu S là quan hệ chủ đã được phân mảnh thành S₁, …, Sₙ, thì quan hệ thành viên R được phân mảnh bằng phép nửa kết nối:

$$ Rᵢ = R ⋉ Sᵢ,   i = 1..n

Quan hệ DonHang(MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien) tham chiếu KhachHang qua MaKH. Để đơn hàng nằm cùng site với khách hàng, DonHang được phân mảnh dẫn xuất theo các mảnh KHᵢ ở mục 2.3:

$$ DHᵢ = DonHang ⋉_MaKH KHᵢ,   i = 1, 2, 3

Tương tự, ChiTietDonHang được phân mảnh dẫn xuất theo DonHang: CTDHᵢ = ChiTietDonHang ⋉_MaDH DHᵢ.

Lợi ích quan trọng nhất: các mảnh KHᵢ, DHᵢ, CTDHᵢ cùng đặt tại một site, nên phép kết nối KhachHang ⋈ DonHang ⋈ ChiTietDonHang được thực hiện **cục bộ** tại từng site rồi hợp kết quả lại, không cần truyền dữ liệu giữa các site. Nhờ vậy đồ thị kết nối giữa các mảnh trở nên **đơn giản**: mỗi mảnh của quan hệ thành viên chỉ kết nối với đúng một mảnh của quan hệ chủ.

- **Đầy đủ:** cần ràng buộc toàn vẹn tham chiếu. Nếu một đơn hàng có MaKH không tồn tại trong KhachHang, đơn đó sẽ không thuộc mảnh nào.
- **Rời nhau:** được đảm bảo khi mỗi bộ của quan hệ thành viên chỉ kết nối với bộ của đúng một mảnh chủ. Ở đây mỗi đơn hàng có đúng một MaKH, và mỗi khách hàng thuộc đúng một chi nhánh.
- **Tái thiết:** DonHang = DH₁ ∪ DH₂ ∪ DH₃.

## 2.5 Phân mảnh dọc

Phân mảnh dọc chia quan hệ theo các thuộc tính. Mỗi mảnh là phép chiếu của R lên một tập thuộc tính, và **mọi mảnh đều chứa khóa chính** K của R:

$$ Rᵢ = π_{K ∪ Aᵢ}(R),   i = 1..n

Tái thiết bằng phép kết nối trên khóa: R = R₁ ⋈_K R₂ ⋈_K … ⋈_K Rₙ. Mục tiêu của phân mảnh dọc là gom vào cùng một mảnh những thuộc tính thường được truy cập cùng nhau, để mỗi ứng dụng chỉ cần đọc một mảnh.

Bài toán phân mảnh dọc phức tạp hơn phân mảnh ngang: với m thuộc tính không khóa, số cách chia là số Bell B(m), tăng rất nhanh (B(10) ≈ 115.000). Vì vậy người ta dùng các phương pháp heuristic, phổ biến nhất là thuật toán năng lượng liên kết BEA [4], [5] kết hợp với thuật toán SPLIT.

**Ví dụ.** Xét các thuộc tính không khóa của KhachHang: A₁ = HoTen, A₂ = SDT, A₃ = DiaChi, A₄ = HanMucNo, A₅ = CongNo (khóa MaKH được lặp lại ở mọi mảnh nên không tham gia gom cụm). Có bốn ứng dụng: q₁ tra cứu khách hàng, q₂ in phiếu giao hàng, q₃ kiểm tra hạn mức, q₄ báo cáo công nợ. Ma trận sử dụng cho ở Bảng 2.1.

Bảng: Ma trận sử dụng thuộc tính use(qᵢ, Aⱼ)
| | HoTen | SDT | DiaChi | HanMucNo | CongNo |
|---|---|---|---|---|---|
| q₁ | 1 | 1 | 1 | 0 | 0 |
| q₂ | 1 | 0 | 1 | 0 | 0 |
| q₃ | 0 | 0 | 0 | 1 | 1 |
| q₄ | 0 | 0 | 0 | 0 | 1 |

Áp dụng BEA và SPLIT, điểm cắt tốt nhất nằm sau HanMucNo. Kết quả là hai mảnh dọc, mỗi mảnh đều chứa khóa MaKH:

$$ KH_TC = π_{MaKH, HanMucNo, CongNo}(KhachHang),   KH_GD = π_{MaKH, HoTen, SDT, DiaChi}(KhachHang)

Mảnh KH_GD phục vụ các ứng dụng tại chi nhánh; mảnh KH_TC phục vụ phòng kế toán tại trụ sở. Không có ứng dụng nào phải dùng cả hai mảnh.

## 2.6 Cấp phát và nhân bản

Sau khi phân mảnh, mỗi mảnh cần được đặt lên một hoặc nhiều site. Bài toán cấp phát tối ưu là bài toán NP-khó, nên trong thực tế thường dùng các nguyên tắc heuristic:

- Đặt mảnh tại site truy cập nó nhiều nhất.
- Mảnh chủ yếu được đọc và ít được cập nhật thì nên **nhân bản** ra nhiều site để tăng tính cục bộ và độ sẵn sàng.
- Mảnh được cập nhật thường xuyên thì nên giữ **một bản duy nhất**, tránh chi phí đồng bộ giữa các bản sao.
- Các mảnh thường được kết nối với nhau (như các mảnh dẫn xuất) nên đặt cùng site.
