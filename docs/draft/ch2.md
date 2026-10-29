# CHƯƠNG 2. PHÂN MẢNH DỮ LIỆU TRONG CSDL PHÂN TÁN

## 2.1 Lý do và đơn vị phân mảnh

Nếu đơn vị phân tán là cả một quan hệ, sẽ có hai lựa chọn đều không hiệu quả. Đặt quan hệ ở một site thì các site khác phải truy cập từ xa. Nhân bản quan hệ ra mọi site thì tốn không gian lưu trữ, và mỗi lần cập nhật phải sửa tất cả các bản sao. Trong khi đó, mỗi ứng dụng thường chỉ dùng một **tập con** của quan hệ, ví dụ chi nhánh Hà Nội chỉ cần khách hàng ở Hà Nội. Vì vậy, đơn vị phân tán hợp lý là các **mảnh** (fragment) của quan hệ.

Phân mảnh mang lại các lợi ích:

- **Tăng tính cục bộ:** mỗi mảnh đặt ở nơi sử dụng nó nhiều nhất, phần lớn truy vấn được trả lời bằng dữ liệu tại chỗ.
- **Xử lý song song:** một truy vấn trên quan hệ có thể tách thành nhiều truy vấn con chạy đồng thời trên các mảnh.
- **Bảo mật:** dữ liệu nhạy cảm được tách riêng và chỉ đặt ở những site có quyền truy cập.

Phân mảnh cũng có cái giá phải trả. Những ứng dụng cần dữ liệu ở nhiều mảnh phải ghép các mảnh lại, phát sinh chi phí truyền thông và xử lý. Việc kiểm tra ràng buộc toàn vẹn liên quan đến nhiều mảnh cũng phức tạp hơn. Do đó **mức độ phân mảnh** phải vừa phải: không phân mảnh thì mất tính cục bộ, phân mảnh quá nhỏ (đến từng bộ hoặc từng thuộc tính) thì chi phí ghép lại rất lớn. Mức độ hợp lý được xác định dựa trên các ứng dụng sử dụng CSDL.

Có ba kiểu phân mảnh cơ bản (Hình 2.1): **phân mảnh ngang** (theo dòng), **phân mảnh dọc** (theo cột) và **phân mảnh hỗn hợp** (kết hợp cả hai).

![Minh họa ba kiểu phân mảnh](assets/diagrams/ba_loai_phan_manh.png)

## 2.2 Các quy tắc đúng đắn của phân mảnh

Giả sử quan hệ R được phân mảnh thành các mảnh R₁, R₂, …, Rₙ. Phân mảnh được gọi là đúng đắn nếu thỏa ba quy tắc [1]:

- **Tính đầy đủ (completeness):** mỗi mục dữ liệu của R (một bộ đối với phân mảnh ngang, một thuộc tính đối với phân mảnh dọc) đều có mặt trong ít nhất một mảnh Rᵢ. Quy tắc này đảm bảo phân mảnh không làm mất dữ liệu.
- **Tính tái thiết (reconstruction):** tồn tại một phép toán quan hệ ∇ sao cho R = ∇ Rᵢ. Với phân mảnh ngang, ∇ là phép hợp (∪); với phân mảnh dọc, ∇ là phép kết nối (⋈) trên khóa. Quy tắc này đảm bảo các ràng buộc phụ thuộc giữa dữ liệu được bảo toàn.
- **Tính rời nhau (disjointness):** với phân mảnh ngang, một bộ thuộc Rⱼ thì không thuộc Rₖ (j ≠ k). Với phân mảnh dọc, các mảnh chỉ được trùng nhau ở khóa chính; khóa phải được lặp lại ở mọi mảnh để có thể tái thiết.

## 2.3 Phân mảnh ngang nguyên thủy

### 2.3.1 Định nghĩa

Phân mảnh ngang chia quan hệ theo các bộ. Mỗi mảnh là kết quả của một phép chọn trên quan hệ:

$$ Rᵢ = σ_Fᵢ(R),   i = 1..n

trong đó Fᵢ là vị từ chọn của mảnh Rᵢ. Gọi là phân mảnh **nguyên thủy** vì vị từ được định nghĩa trên chính các thuộc tính của R.

### 2.3.2 Vị từ đơn giản và vị từ hội sơ cấp

- **Vị từ đơn giản** có dạng pⱼ: Aᵢ θ Giá_trị, với Aᵢ là thuộc tính của R và θ ∈ {=, <, ≤, >, ≥, ≠}. Ví dụ: p₁: MaCN = 'CN01'.
- **Vị từ hội sơ cấp (minterm)** trên tập vị từ đơn giản Pr = {p₁, …, pₘ} là phép hội của tất cả các vị từ trong Pr, mỗi vị từ xuất hiện ở dạng khẳng định hoặc phủ định:

$$ mₖ = p₁* ∧ p₂* ∧ … ∧ pₘ*,   với pᵢ* ∈ {pᵢ, ¬pᵢ}

Mỗi minterm xác định một mảnh ngang, gọi là **mảnh hội sơ cấp**. Với m vị từ sẽ có 2ᵐ minterm, nhưng nhiều minterm mâu thuẫn và bị loại bỏ dựa trên ngữ nghĩa của thuộc tính.

Thông tin cần thu thập để thiết kế gồm: các vị từ đơn giản mà ứng dụng dùng trong điều kiện truy vấn; độ chọn của từng minterm (tỉ lệ bộ thỏa minterm); và tần suất truy cập của ứng dụng.

### 2.3.3 Tính đầy đủ và cực tiểu của tập vị từ

- Tập vị từ Pr là **đầy đủ** nếu hai bộ bất kỳ thuộc cùng một mảnh hội sơ cấp luôn có cùng xác suất được truy cập bởi mọi ứng dụng. Nói cách khác, mỗi mảnh phải đồng nhất về cách được sử dụng.
- Một vị từ là **có liên quan** (relevant) nếu nó tách một mảnh f thành hai mảnh f₁, f₂ được ít nhất một ứng dụng truy cập khác nhau. Tập Pr là **cực tiểu** nếu mọi vị từ trong đó đều có liên quan.

**Thuật toán COM_MIN** [1] sinh ra tập vị từ đầy đủ và cực tiểu Pr' từ tập vị từ ứng viên Pr:

1. Chọn một vị từ pᵢ ∈ Pr chia quan hệ R thành hai phần được ít nhất một ứng dụng truy cập khác nhau; đưa pᵢ vào Pr'.
2. Lần lượt xét các vị từ còn lại. Vị từ nào chia một mảnh hiện có thành hai phần được truy cập khác nhau thì đưa vào Pr'.
3. Khi thêm vị từ mới, loại khỏi Pr' những vị từ đã trở nên không còn liên quan.
4. Lặp lại cho đến khi Pr' đầy đủ.

**Thuật toán PHORIZONTAL** dùng kết quả của COM_MIN: tính Pr' = COM_MIN(R, Pr), xác định tập minterm M trên Pr', rồi dùng các phép kéo theo (implication) giữa các vị từ để loại bỏ những minterm mâu thuẫn. Mỗi minterm còn lại cho một mảnh ngang.

### 2.3.4 Ví dụ

Xét quan hệ KhachHang(MaKH, HoTen, SDT, DiaChi, MaCN, HanMucNo, CongNo), với MaCN ∈ {'CN01', 'CN02', 'CN03'}. Ứng dụng tra cứu khách hàng ở mỗi chi nhánh chỉ truy cập khách thuộc chi nhánh đó, nên tập vị từ ứng viên là:

$$ p₁: MaCN = 'CN01'     p₂: MaCN = 'CN02'     p₃: MaCN = 'CN03'

Có 2³ = 8 minterm. Vì MaCN chỉ nhận một giá trị nên có các phép kéo theo p₁ ⇒ ¬p₂ ∧ ¬p₃ (tương tự cho p₂, p₃). Mọi minterm chứa từ hai vị từ khẳng định trở lên đều mâu thuẫn. Minterm ¬p₁ ∧ ¬p₂ ∧ ¬p₃ cũng mâu thuẫn vì miền giá trị của MaCN chỉ gồm ba giá trị trên. Còn lại ba minterm, rút gọn được thành p₁, p₂, p₃, cho ba mảnh:

$$ KHᵢ = σ_MaCN='CN0i'(KhachHang),   i = 1, 2, 3

Giả sử có thêm vị từ ứng viên p₄: HanMucNo ≥ 200.000.000. Nếu có một ứng dụng truy cập riêng nhóm khách có hạn mức lớn thường xuyên hơn, p₄ là vị từ có liên quan và mỗi mảnh trên sẽ tách đôi, tổng cộng sáu mảnh. Ngược lại, nếu mọi ứng dụng truy cập khách hàng như nhau bất kể hạn mức, p₄ không có liên quan và COM_MIN sẽ không đưa nó vào Pr'. Bài toán ở Chương 4 thuộc trường hợp thứ hai.

Ba mảnh KH₁, KH₂, KH₃ thỏa các quy tắc đúng đắn: **đầy đủ** vì p₁ ∨ p₂ ∨ p₃ luôn đúng trên miền giá trị của MaCN; **rời nhau** vì các vị từ loại trừ lẫn nhau; **tái thiết** được bằng KhachHang = KH₁ ∪ KH₂ ∪ KH₃.

## 2.4 Phân mảnh ngang dẫn xuất

### 2.4.1 Định nghĩa

Phân mảnh ngang dẫn xuất áp dụng cho một quan hệ **thành viên** (member), dựa trên phân mảnh của quan hệ **chủ** (owner) mà nó tham chiếu tới. Quan hệ chủ và thành viên được nối với nhau bằng một liên kết, thường là khóa ngoại. Nếu S là quan hệ chủ đã được phân mảnh thành S₁, …, Sₙ, thì quan hệ thành viên R được phân mảnh bằng phép nửa kết nối:

$$ Rᵢ = R ⋉ Sᵢ,   i = 1..n

Phép nửa kết nối R ⋉ Sᵢ giữ lại những bộ của R kết nối được với ít nhất một bộ của Sᵢ, và chỉ giữ các thuộc tính của R.

### 2.4.2 Ví dụ

Quan hệ DonHang(MaDH, NgayDat, MaKH, MaNV, TrangThai, TongTien) tham chiếu KhachHang qua MaKH. Để đơn hàng nằm cùng site với khách hàng, DonHang được phân mảnh dẫn xuất theo các mảnh KHᵢ ở mục 2.3.4:

$$ DHᵢ = DonHang ⋉_MaKH KHᵢ,   i = 1, 2, 3

Tương tự, ChiTietDonHang được phân mảnh dẫn xuất theo DonHang: CTDHᵢ = ChiTietDonHang ⋉_MaDH DHᵢ. Kết quả là một chuỗi phân mảnh dẫn xuất (Hình 2.2).

![Chuỗi phân mảnh ngang dẫn xuất KhachHang – DonHang – ChiTietDonHang](assets/diagrams/phan_manh_dan_xuat.png)

Lợi ích quan trọng nhất: các mảnh KHᵢ, DHᵢ, CTDHᵢ cùng đặt tại một site, nên phép kết nối KhachHang ⋈ DonHang ⋈ ChiTietDonHang được thực hiện **cục bộ** tại từng site rồi hợp kết quả lại, không cần truyền dữ liệu giữa các site. Nhờ vậy đồ thị kết nối giữa các mảnh trở nên **đơn giản**: mỗi mảnh của quan hệ thành viên chỉ kết nối với đúng một mảnh của quan hệ chủ.

### 2.4.3 Tính đúng đắn và lựa chọn quan hệ chủ

- **Đầy đủ:** cần ràng buộc toàn vẹn tham chiếu. Nếu một đơn hàng có MaKH không tồn tại trong KhachHang, đơn đó sẽ không thuộc mảnh nào.
- **Rời nhau:** được đảm bảo khi mỗi bộ của quan hệ thành viên chỉ kết nối với bộ của đúng một mảnh chủ. Ở đây mỗi đơn hàng có đúng một MaKH, và mỗi khách hàng thuộc đúng một chi nhánh.
- **Tái thiết:** DonHang = DH₁ ∪ DH₂ ∪ DH₃.

Khi quan hệ thành viên có nhiều quan hệ chủ (DonHang tham chiếu cả KhachHang và NhanVien), ta chọn phân mảnh nào được nhiều ứng dụng sử dụng hơn, hoặc cho đặc tính kết nối tốt hơn. Trong bài toán của đề tài, nhân viên lập đơn luôn thuộc cùng chi nhánh với khách hàng, nên hai cách chọn cho cùng kết quả; nhóm chọn KhachHang vì ứng dụng lập đơn kết nối DonHang với KhachHang thường xuyên nhất.

## 2.5 Phân mảnh dọc

### 2.5.1 Định nghĩa

Phân mảnh dọc chia quan hệ theo các thuộc tính. Mỗi mảnh là phép chiếu của R lên một tập thuộc tính, và **mọi mảnh đều chứa khóa chính** K của R:

$$ Rᵢ = π_{K ∪ Aᵢ}(R),   i = 1..n

Tái thiết bằng phép kết nối trên khóa: R = R₁ ⋈_K R₂ ⋈_K … ⋈_K Rₙ. Mục tiêu của phân mảnh dọc là gom vào cùng một mảnh những thuộc tính thường được truy cập cùng nhau, để mỗi ứng dụng chỉ cần đọc một mảnh.

Bài toán phân mảnh dọc phức tạp hơn phân mảnh ngang: với m thuộc tính không khóa, số cách chia là số Bell B(m), tăng rất nhanh (B(10) ≈ 115.000). Vì vậy người ta dùng các phương pháp heuristic, phổ biến nhất là thuật toán năng lượng liên kết BEA kết hợp với thuật toán SPLIT.

### 2.5.2 Ma trận sử dụng và ma trận ái lực

Cho tập ứng dụng Q = {q₁, …, qₖ} và các thuộc tính A₁, …, Aₘ:

- **Giá trị sử dụng:** use(qᵢ, Aⱼ) = 1 nếu qᵢ dùng Aⱼ, ngược lại bằng 0.
- **Tần suất truy cập:** accₗ(qᵢ) là số lần qᵢ được thực hiện tại site Sₗ trong một khoảng thời gian.
- **Độ ái lực** giữa hai thuộc tính Aᵢ, Aⱼ đo mức độ chúng được truy cập cùng nhau:

$$ aff(Aᵢ, Aⱼ) = Σ_{k: use(qₖ,Aᵢ)=1 ∧ use(qₖ,Aⱼ)=1}  Σ_l accₗ(qₖ)

Các giá trị aff tạo thành **ma trận ái lực AA** kích thước m × m.

### 2.5.3 Thuật toán BEA

Thuật toán năng lượng liên kết (Bond Energy Algorithm) do McCormick và cộng sự đề xuất [4], được Navathe và cộng sự áp dụng cho phân mảnh dọc [5], hoán vị các cột và dòng của AA để các thuộc tính có ái lực cao đứng cạnh nhau, tạo thành ma trận ái lực gom cụm CA. Độ liên kết giữa hai thuộc tính được định nghĩa:

$$ bond(Aₓ, Aᵧ) = Σ_{z=1..m} aff(A_z, Aₓ) × aff(A_z, Aᵧ)

Thuật toán đặt hai cột đầu tiên, sau đó lần lượt chèn từng cột Aₖ còn lại vào vị trí (giữa Aᵢ và Aⱼ) làm cực đại **đóng góp**:

$$ cont(Aᵢ, Aₖ, Aⱼ) = 2·bond(Aᵢ, Aₖ) + 2·bond(Aₖ, Aⱼ) − 2·bond(Aᵢ, Aⱼ)

với quy ước bond với cột ở ngoài biên bằng 0. Khi các cột đã được sắp, các dòng được sắp theo cùng thứ tự.

### 2.5.4 Thuật toán SPLIT

Trên ma trận CA, chọn một điểm cắt chia các thuộc tính thành nhóm trên TA và nhóm dưới BA. Gọi TQ là tập ứng dụng chỉ dùng thuộc tính trong TA, BQ là tập ứng dụng chỉ dùng thuộc tính trong BA, OQ là các ứng dụng dùng cả hai nhóm; CTQ, CBQ, COQ là tổng tần suất truy cập tương ứng. Điểm cắt tốt nhất là điểm làm cực đại:

$$ z = CTQ × CBQ − COQ²

Giá trị z lớn nghĩa là nhiều truy cập chỉ cần một mảnh và ít truy cập phải dùng cả hai mảnh.

### 2.5.5 Ví dụ

Xét các thuộc tính không khóa của KhachHang: A₁ = HoTen, A₂ = SDT, A₃ = DiaChi, A₄ = HanMucNo, A₅ = CongNo (khóa MaKH được lặp lại ở mọi mảnh nên không tham gia gom cụm). Có bốn ứng dụng: q₁ tra cứu khách hàng, q₂ in phiếu giao hàng, q₃ kiểm tra hạn mức, q₄ báo cáo công nợ. Ma trận sử dụng và tần suất truy cập mỗi tháng tại các site cho ở Bảng 2.1 và Bảng 2.2.

Bảng: Ma trận sử dụng thuộc tính use(qᵢ, Aⱼ)
| | HoTen | SDT | DiaChi | HanMucNo | CongNo |
|---|---|---|---|---|---|
| q₁ | 1 | 1 | 1 | 0 | 0 |
| q₂ | 1 | 0 | 1 | 0 | 0 |
| q₃ | 0 | 0 | 0 | 1 | 1 |
| q₄ | 0 | 0 | 0 | 0 | 1 |

Bảng: Tần suất truy cập accₗ(qᵢ) tại các site (lần/tháng)
| | S0 Trụ sở | S1 Hà Nội | S2 Đà Nẵng | S3 TP.HCM | Tổng |
|---|---|---|---|---|---|
| q₁ | 0 | 300 | 200 | 400 | 900 |
| q₂ | 0 | 150 | 100 | 200 | 450 |
| q₃ | 80 | 0 | 0 | 0 | 80 |
| q₄ | 30 | 0 | 0 | 0 | 30 |

Ví dụ, aff(HoTen, DiaChi) = 900 + 450 = 1350 vì cả q₁ và q₂ đều dùng hai thuộc tính này; aff(HanMucNo, CongNo) = 80 vì chỉ q₃ dùng cả hai. Ma trận ái lực đầy đủ ở Bảng 2.3.

Bảng: Ma trận ái lực AA
| | HoTen | SDT | DiaChi | HanMucNo | CongNo |
|---|---|---|---|---|---|
| HoTen | 1350 | 900 | 1350 | 0 | 0 |
| SDT | 900 | 900 | 900 | 0 | 0 |
| DiaChi | 1350 | 900 | 1350 | 0 | 0 |
| HanMucNo | 0 | 0 | 0 | 80 | 80 |
| CongNo | 0 | 0 | 0 | 80 | 110 |

Áp dụng BEA: đặt trước HoTen, SDT. Chèn DiaChi: cont tại vị trí đầu (trước HoTen) bằng 2·bond(DiaChi, HoTen) = 2 × (1350·1350 + 900·900 + 1350·1350) = 8.910.000, bằng với vị trí giữa HoTen và SDT và lớn hơn vị trí cuối (6.480.000); chọn vị trí đầu, được thứ tự DiaChi, HoTen, SDT. Chèn HanMucNo: vị trí đầu và cuối cho cont = 0, các vị trí giữa cho giá trị âm; chọn vị trí đầu. Chèn CongNo: vị trí đầu và vị trí giữa HanMucNo – DiaChi cùng cho cont = 30.400, lớn nhất; chọn vị trí đầu (khi bằng nhau, chọn vị trí xuất hiện trước). Thứ tự cuối cùng là CongNo, HanMucNo, DiaChi, HoTen, SDT, cho ma trận CA ở Bảng 2.4. Có thể thấy hai khối ái lực cao tách biệt rõ trên đường chéo.

Bảng: Ma trận ái lực gom cụm CA
| | CongNo | HanMucNo | DiaChi | HoTen | SDT |
|---|---|---|---|---|---|
| CongNo | 110 | 80 | 0 | 0 | 0 |
| HanMucNo | 80 | 80 | 0 | 0 | 0 |
| DiaChi | 0 | 0 | 1350 | 1350 | 900 |
| HoTen | 0 | 0 | 1350 | 1350 | 900 |
| SDT | 0 | 0 | 900 | 900 | 900 |

Áp dụng SPLIT với bốn điểm cắt (Bảng 2.5): điểm cắt sau HanMucNo cho z lớn nhất.

Bảng: Giá trị z tại các điểm cắt
| Nhóm trên TA | CTQ | CBQ | COQ | z |
|---|---|---|---|---|
| {CongNo} | 30 | 1350 | 80 | 34.100 |
| {CongNo, HanMucNo} | 110 | 1350 | 0 | **148.500** |
| {CongNo, HanMucNo, DiaChi} | 110 | 0 | 1350 | −1.822.500 |
| {CongNo, HanMucNo, DiaChi, HoTen} | 560 | 0 | 900 | −810.000 |

Kết quả là hai mảnh dọc, mỗi mảnh đều chứa khóa MaKH:

$$ KH_TC = π_{MaKH, HanMucNo, CongNo}(KhachHang),   KH_GD = π_{MaKH, HoTen, SDT, DiaChi}(KhachHang)

Mảnh KH_GD phục vụ các ứng dụng tại chi nhánh; mảnh KH_TC phục vụ phòng kế toán tại trụ sở. Không có ứng dụng nào phải dùng cả hai mảnh (COQ = 0).

## 2.6 Cấp phát và nhân bản

Sau khi phân mảnh, mỗi mảnh cần được đặt lên một hoặc nhiều site. Bài toán cấp phát tối ưu là bài toán NP-khó, nên trong thực tế thường dùng các nguyên tắc heuristic:

- Đặt mảnh tại site truy cập nó nhiều nhất.
- Mảnh chủ yếu được đọc và ít được cập nhật thì nên **nhân bản** ra nhiều site để tăng tính cục bộ và độ sẵn sàng.
- Mảnh được cập nhật thường xuyên thì nên giữ **một bản duy nhất**, tránh chi phí đồng bộ giữa các bản sao.
- Các mảnh thường được kết nối với nhau (như các mảnh dẫn xuất) nên đặt cùng site.

## 2.7 Kết chương

Chương 2 đã trình bày các quy tắc đúng đắn, phân mảnh ngang nguyên thủy với COM_MIN, phân mảnh ngang dẫn xuất và phân mảnh dọc với BEA và SPLIT, kèm ví dụ trên dữ liệu quản lý khách hàng. Các ví dụ cho thấy KhachHang vừa cần chia theo chi nhánh, vừa cần tách nhóm thuộc tính giao dịch và tài chính. Để thỏa đồng thời cả hai nhu cầu cần đến phân mảnh hỗn hợp, nội dung của Chương 3.
