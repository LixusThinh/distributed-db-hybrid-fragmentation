# Nội dung slide thuyết trình

**Đề tài:** Tìm hiểu Phân mảnh hỗn hợp trong CSDL Phân tán và ứng dụng cho quản lý đơn hàng
**Thời lượng:** khoảng 14 phút · 17 slide · Thịnh: slide 1–9 · Triết: slide 10–16

## Ghi chú khi dựng slide
- **Mỗi slide có 3 phần:** *Trên slide* là chữ hiển thị (chép nguyên). *Hình/bố cục* là gợi ý trình bày. *Lời thuyết trình* thì dán vào phần **Notes** của slide, không đưa lên slide.
- **Thống nhất ký hiệu:** σ (chọn), π (chiếu), ∪ (hợp), ⋈ (kết nối), ⋉ (nửa kết nối). Tên mảnh viết đúng như trong demo: `KH_1_GD`, `KH_1_TC`, `NV_CV_1`, `NV_NS`, `DH_1`…
- **Màu cố định cho 4 site** (dùng giống nhau ở slide 12, 13, 14): S0 Trụ sở = xám đậm, S1 Hà Nội = đỏ, S2 Đà Nẵng = xanh lá, S3 TP.HCM = xanh dương.
- **Sơ đồ** (đã có trong `assets/diagrams/`, dùng file `.png`; `.svg` phóng to không vỡ): `kien_truc_CSDLPT` (slide 3) · `ba_loai_phan_manh` (slide 5–7) · `cay_HV_KhachHang`, `cay_VH_NhanVien` (slide 8, 12, 13) · `luoc_do_quan_he`, `ma_tran_su_dung_KhachHang` (slide 11) · `phan_manh_dan_xuat` (slide 13) · `cap_phat_4_site` (slide 14). Ảnh demo lấy từ `assets/screenshots/` (Triết chụp ở task T5).
- **Font:** Segoe UI, Calibri, Arial và Times New Roman **đều không có** ký hiệu ⋈ ⋉ ∪, lên máy chiếu sẽ thành ô vuông. Gõ các ký hiệu này bằng font **Cambria Math** (bôi đen ký hiệu → đổi font), hoặc dùng Insert → Equation. σ, π và chữ số dưới (₁ ᵢ) thì font nào cũng có.

---

## Slide 1 – Bìa · *Thịnh*

**Trên slide**
- TRƯỜNG ĐẠI HỌC CÔNG NGHỆ TP.HCM – KHOA CÔNG NGHỆ THÔNG TIN
- Môn: Cơ Sở Dữ Liệu Nâng Cao
- **TÌM HIỂU PHÂN MẢNH HỖN HỢP TRONG CSDL PHÂN TÁN VÀ ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG**
- GVHD: ThS. Nguyễn Văn Danh
- Nhóm thực hiện: Trần Gia Thịnh – 2380602136 · Phạm Minh Triết – 2380605829

**Hình/bố cục:** logo HUTECH góc trên; tên đề tài to ở giữa; thông tin GVHD và nhóm ở dưới.

**Lời thuyết trình**
> Em chào thầy và các bạn. Nhóm em gồm Trần Gia Thịnh và Phạm Minh Triết. Hôm nay nhóm em xin trình bày đề tài: tìm hiểu phân mảnh hỗn hợp trong cơ sở dữ liệu phân tán và ứng dụng cho bài toán quản lý đơn hàng.

---

## Slide 2 – Nội dung trình bày · *Thịnh · 0:20*

**Trên slide**
1. Tổng quan CSDL phân tán
2. Phân mảnh dữ liệu: ngang và dọc
3. Phân mảnh hỗn hợp
4. Ứng dụng cho hệ thống quản lý đơn hàng + demo
5. Đánh giá và kết luận

**Hình/bố cục:** 5 mục dạng thẻ/đánh số; tô màu mục 3 và 4 là trọng tâm.

**Lời thuyết trình**
> Bài trình bày gồm 5 phần. Em sẽ trình bày phần lý thuyết, gồm tổng quan, các loại phân mảnh và phân mảnh hỗn hợp. Sau đó bạn Triết sẽ trình bày phần ứng dụng vào hệ thống quản lý đơn hàng, có demo trên SQL Server.

---

## Slide 3 – CSDL phân tán là gì? · *Thịnh · 1:00*

**Trên slide**
- Một CSDL **thống nhất về logic**, nhưng dữ liệu **nằm ở nhiều site** nối với nhau qua mạng
- Hệ quản trị CSDL phân tán (DDBMS) **che giấu sự phân tán**: người dùng thấy như một CSDL duy nhất
- Lợi ích: dữ liệu ở **gần nơi sử dụng**, tăng độ sẵn sàng, dễ mở rộng, phù hợp tổ chức có nhiều chi nhánh
- Hai bài toán thiết kế chính: **phân mảnh** (chia dữ liệu thế nào?) và **cấp phát** (đặt mảnh ở đâu?)

**Hình/bố cục:** bên phải vẽ 4 site (Trụ sở, Hà Nội, Đà Nẵng, TP.HCM) nối với nhau qua đám mây "Mạng". Phía trên có một người dùng nhìn thấy "1 CSDL".

**Lời thuyết trình**
> CSDL phân tán là một CSDL thống nhất về mặt logic, nhưng dữ liệu được đặt ở nhiều máy, nhiều địa điểm khác nhau, gọi là các site, nối với nhau qua mạng. Hệ quản trị CSDL phân tán có nhiệm vụ che giấu điều đó. Người dùng truy vấn như với một CSDL bình thường, không cần biết dữ liệu nằm ở đâu. Tính chất này gọi là tính trong suốt.
> Lợi ích lớn nhất là dữ liệu được đặt gần nơi sử dụng. Ví dụ, chi nhánh Hà Nội làm việc trên dữ liệu ở Hà Nội nên không phải gửi truy vấn vào TP.HCM. Ngoài ra, một site gặp sự cố thì các site khác vẫn hoạt động, và hệ thống dễ mở rộng khi thêm chi nhánh.
> Khi thiết kế một CSDL phân tán, có hai câu hỏi chính: chia dữ liệu như thế nào, tức là phân mảnh, và đặt từng phần ở đâu, tức là cấp phát. Đề tài của nhóm tập trung vào câu hỏi thứ nhất.

---

## Slide 4 – Vì sao phải phân mảnh? · *Thịnh · 1:00*

**Trên slide**
- Ứng dụng thường chỉ dùng **một phần** của bảng: một số dòng, một số cột
- Đặt nguyên bảng ở một nơi thì truy cập từ xa nhiều; nhân bản nguyên bảng thì tốn chỗ và khó cập nhật
- Phân mảnh giúp: **xử lý cục bộ**, **song song**, **bảo mật** dữ liệu nhạy cảm
- **3 quy tắc đúng đắn:**
  - **Đầy đủ:** mọi dữ liệu của R đều nằm trong ít nhất một mảnh
  - **Tái thiết:** ghép các mảnh lại được đúng R
  - **Rời nhau:** một dữ liệu không nằm ở hai mảnh (phân mảnh dọc được lặp lại khóa)

**Hình/bố cục:** nửa trên là 3 lợi ích kèm icon; nửa dưới là 3 ô màu cho 3 quy tắc.

**Lời thuyết trình**
> Vì sao không đặt nguyên cả bảng ở một nơi? Vì trong thực tế, mỗi ứng dụng chỉ dùng một phần dữ liệu. Chi nhánh Hà Nội chỉ cần khách hàng của Hà Nội. Phòng kế toán chỉ cần các cột về công nợ. Nếu đặt nguyên bảng ở trụ sở, mọi chi nhánh đều phải truy cập từ xa. Nếu nhân bản nguyên bảng về mọi nơi thì tốn chỗ, và mỗi lần cập nhật phải sửa ở tất cả các bản.
> Chia bảng thành các mảnh và đặt mỗi mảnh ở nơi dùng nó giúp đa số truy vấn chạy cục bộ. Các site có thể xử lý song song, và dữ liệu nhạy cảm có thể tách riêng để bảo vệ.
> Một cách phân mảnh muốn đúng thì phải thỏa 3 quy tắc. Đầy đủ: không mất dữ liệu. Tái thiết: ghép các mảnh lại phải ra đúng bảng ban đầu. Rời nhau: không có dữ liệu bị lặp ở hai mảnh, ngoại trừ khóa chính trong phân mảnh dọc.

---

## Slide 5 – Phân mảnh ngang · *Thịnh · 1:00*

**Trên slide**
- Chia bảng theo **dòng**, dựa trên vị từ chọn: **Rᵢ = σ_Fᵢ(R)**
- Ví dụ: `KhachHang` chia theo chi nhánh
  - KH₁ = σ_MaCN='CN01'(KhachHang), tương tự KH₂, KH₃
- Thiết kế: từ các vị từ đơn giản mà truy vấn dùng → **vị từ hội sơ cấp (minterm)**; thuật toán **COM_MIN** chọn tập vị từ đầy đủ và cực tiểu
- **Phân mảnh ngang dẫn xuất:** chia bảng con theo mảnh của bảng cha: **DHᵢ = DonHang ⋉ KHᵢ**
- Tái thiết: **R = R₁ ∪ R₂ ∪ … ∪ Rₙ**

**Hình/bố cục:** một bảng KhachHang nhỏ, các dòng tô 3 màu theo chi nhánh, mũi tên tách thành 3 bảng con. Bên cạnh là bảng DonHang có dòng tô màu theo khách tương ứng.

**Lời thuyết trình**
> Loại thứ nhất là phân mảnh ngang, tức là chia bảng theo dòng. Mỗi mảnh là kết quả của một phép chọn với một điều kiện. Ví dụ, bảng khách hàng được chia theo chi nhánh: khách của Hà Nội vào một mảnh, Đà Nẵng một mảnh, TP.HCM một mảnh.
> Các điều kiện được lấy từ chính các truy vấn mà ứng dụng hay dùng, rồi kết hợp lại thành vị từ hội sơ cấp. Thuật toán COM_MIN chọn ra tập điều kiện vừa đủ, không thừa, không thiếu.
> Có một biến thể quan trọng là phân mảnh ngang dẫn xuất. Đơn hàng không tự chia theo điều kiện riêng mà đi theo khách hàng: đơn của khách Hà Nội nằm ở mảnh Hà Nội. Biểu thức là phép nửa kết nối. Lợi ích là khi kết nối đơn hàng với khách hàng, phép kết nối chạy hoàn toàn tại chỗ. Muốn có lại bảng ban đầu thì hợp các mảnh lại.

---

## Slide 6 – Phân mảnh dọc · *Thịnh · 1:00*

**Trên slide**
- Chia bảng theo **cột**: **Rᵢ = π_Aᵢ(R)**, mỗi mảnh **đều chứa khóa chính**
- Ví dụ: `NhanVien`
  - Thông tin công việc: MaNV, HoTen, ChucVu, SDT, MaCN
  - Thông tin nhân sự: MaNV, NgaySinh, CCCD, Luong, SoTaiKhoan
- Cách nhóm cột: **ma trận sử dụng thuộc tính** → **ma trận ái lực** → thuật toán **BEA** gom cụm → **SPLIT** chọn điểm cắt
- Tái thiết: **R = R₁ ⋈_khóa R₂**

**Hình/bố cục:** bảng NhanVien với đường cắt dọc tách 2 nhóm cột; cột MaNV xuất hiện ở cả hai phía (tô đậm). Góc phải là ma trận sử dụng nhỏ 2×9.

**Lời thuyết trình**
> Loại thứ hai là phân mảnh dọc, tức là chia bảng theo cột. Mỗi mảnh là một phép chiếu lên một nhóm cột. Điểm bắt buộc là mảnh nào cũng phải giữ khóa chính, để sau này ghép lại được.
> Ví dụ với bảng nhân viên: chi nhánh chỉ cần thông tin công việc như họ tên, chức vụ, số điện thoại. Còn lương, CCCD, số tài khoản là dữ liệu nhạy cảm, chỉ phòng nhân sự dùng. Vì vậy ta tách thành hai mảnh, cả hai đều có mã nhân viên.
> Muốn biết nên nhóm cột nào với nhau, ta lập ma trận ghi truy vấn nào dùng cột nào, tính độ ái lực giữa từng cặp cột, rồi dùng thuật toán BEA gom các cột hay được dùng cùng nhau và SPLIT chọn chỗ cắt. Tái thiết bằng phép kết nối trên khóa chính.

---

## Slide 7 – Phân mảnh hỗn hợp · *Thịnh · 1:00*

**Trên slide**
- **Kết hợp** phân mảnh ngang và dọc: áp dụng nối tiếp σ và π
- Vì sao cần? Ứng dụng thực tế vừa chỉ dùng **một số dòng**, vừa chỉ dùng **một số cột**
  - Chi nhánh Hà Nội: chỉ **khách Hà Nội** + chỉ **cột giao dịch**
  - Kế toán trụ sở: **mọi khách** + chỉ **cột công nợ**
- Chỉ chia ngang hoặc chỉ chia dọc → vẫn chuyển và lưu dữ liệu thừa
- Mảnh hỗn hợp: **π_A(σ_F(R))** hoặc **σ_F(π_A(R))**

**Hình/bố cục:** một bảng được lưới cắt cả ngang lẫn dọc thành các ô màu; ô "Hà Nội × Giao dịch" được làm nổi bật.

**Lời thuyết trình**
> Trong thực tế, nhu cầu thường phức tạp hơn. Chi nhánh Hà Nội chỉ cần khách của Hà Nội, và cũng chỉ cần các cột phục vụ giao dịch như tên, số điện thoại, địa chỉ. Còn phòng kế toán ở trụ sở cần khách của cả ba miền, nhưng chỉ cần các cột công nợ.
> Nếu chỉ chia ngang thì chi nhánh vẫn phải giữ cả cột công nợ mà mình không dùng. Nếu chỉ chia dọc thì chi nhánh lại phải giữ khách của các miền khác. Giải pháp là phân mảnh hỗn hợp: dùng nối tiếp cả phép chọn và phép chiếu. Mỗi mảnh khi đó là một ô trên lưới dòng và cột, đúng với phần dữ liệu mà một nhóm ứng dụng cần.

---

## Slide 8 – Hai chiến lược: HV và VH · *Thịnh · 1:15*

**Trên slide**

| Ngang trước, dọc sau (HV) | Dọc trước, ngang sau (VH) |
|---|---|
| R → σ thành R₁…Rₙ → π từng Rᵢ | R → π thành nhóm cột → σ trên nhóm cần chia |
| Mỗi mảnh ngang có thể chia dọc **khác nhau** | Chỉ chia ngang **những nhóm cột cần** |
| Ví dụ: `KhachHang` | Ví dụ: `NhanVien` |

- Biểu diễn bằng **cây phân mảnh**: gốc là R, nút trong là σ hoặc π, **lá là mảnh được cấp phát**

**Hình/bố cục:** hai cây phân mảnh đặt cạnh nhau (dùng `cay_HV_KhachHang` và `cay_VH_NhanVien` ở dạng thu nhỏ). Tô nhãn σ màu cam, π màu tím.

**Lời thuyết trình**
> Có hai cách kết hợp. Cách thứ nhất là ngang trước, dọc sau, gọi tắt là HV. Ta chia bảng theo dòng trước, rồi chia tiếp từng mảnh ngang theo cột. Bảng khách hàng của nhóm làm theo cách này: chia theo chi nhánh trước, sau đó mỗi mảnh chi nhánh tách thành phần giao dịch và phần tài chính.
> Cách thứ hai là dọc trước, ngang sau, gọi tắt là VH. Ta chia theo cột trước, rồi chỉ chia ngang những nhóm cột cần chia. Bảng nhân viên làm theo cách này. Tách thông tin nhân sự ra trước; phần này để tập trung ở trụ sở nên không chia nữa. Chỉ phần thông tin công việc được chia tiếp theo chi nhánh.
> Cả hai cách đều được biểu diễn bằng một cây phân mảnh. Gốc là bảng ban đầu, mỗi nút trong là một phép chọn hoặc phép chiếu, và các lá là những mảnh thực sự được lưu ở các site.

---

## Slide 9 – Tái thiết & tính đúng đắn · *Thịnh · 1:00*

**Trên slide**
- **Tái thiết** từ lá lên gốc: nút σ → **∪**, nút π → **⋈ trên khóa**
  - HV: **R = ⋃ᵢ (Rᵢ₁ ⋈ Rᵢ₂)**
  - VH: **R = (R₁₁ ∪ … ∪ R₁ₙ) ⋈ R₂**
- **Đúng đắn:** mỗi bước ngang và dọc thỏa *đầy đủ – tái thiết – rời nhau* ⇒ cả cây thỏa
- Lưu ý ở VH: chỉ chia ngang được mảnh dọc **có chứa thuộc tính của vị từ** (ví dụ MaCN)

**Hình/bố cục:** cây phân mảnh có mũi tên đi ngược từ lá lên gốc, ghi ∪ và ⋈ trên các cạnh.

**Lời thuyết trình**
> Để lấy lại bảng ban đầu, ta đi ngược cây từ lá lên gốc. Gặp nút chia ngang thì hợp các mảnh con. Gặp nút chia dọc thì kết nối các mảnh con theo khóa chính. Với HV, ta kết nối hai phần dọc của từng mảnh trước, rồi hợp các kết quả lại. Với VH thì ngược lại: hợp các mảnh ngang trước, sau đó kết nối với phần dọc còn lại.
> Về tính đúng đắn: nếu mỗi bước chia ngang và mỗi bước chia dọc đều thỏa ba quy tắc, thì cả cây phân mảnh hỗn hợp cũng thỏa.
> Một lưu ý với VH: chỉ chia ngang được những mảnh dọc có chứa cột dùng trong điều kiện. Ví dụ phần nhân sự không có cột mã chi nhánh, nên không chia theo chi nhánh trực tiếp được. Phần tiếp theo, bạn Triết sẽ trình bày cách nhóm áp dụng vào bài toán quản lý đơn hàng.

---

## Slide 10 – Bài toán quản lý đơn hàng · *Triết · 1:00*

**Trên slide**
- Công ty thương mại X: **3 chi nhánh** (Hà Nội, Đà Nẵng, TP.HCM) + **trụ sở chính**
- Mỗi khách hàng do **một** chi nhánh quản lý
- **Chi nhánh:** tra cứu khách, lập và xử lý đơn hàng của khách mình
- **Kế toán (trụ sở):** quản lý hạn mức và công nợ khách ở cả 3 miền
- **Nhân sự (trụ sở):** quản lý lương, CCCD, tài khoản ngân hàng, là dữ liệu nhạy cảm
- **Ban giám đốc:** báo cáo doanh thu toàn công ty

**Hình/bố cục:** bản đồ Việt Nam đơn giản có 3 chấm chi nhánh và 1 chấm trụ sở. Mỗi chấm có nhãn "ai dùng – dùng gì".

**Lời thuyết trình**
> Em xin trình bày phần ứng dụng. Nhóm em đặt ra bài toán một công ty thương mại có ba chi nhánh ở Hà Nội, Đà Nẵng, TP.HCM và một trụ sở chính.
> Mỗi khách hàng thuộc về đúng một chi nhánh. Nhân viên chi nhánh chủ yếu tra cứu khách và lập đơn cho khách của mình; đây là việc diễn ra nhiều nhất. Ở trụ sở, phòng kế toán theo dõi hạn mức và công nợ của khách ở cả ba miền. Phòng nhân sự quản lý lương, CCCD, số tài khoản; đây là thông tin nhạy cảm, chi nhánh không được thấy. Ban giám đốc cần báo cáo doanh thu toàn công ty.
> Có thể thấy mỗi nơi cần một phần dữ liệu khác nhau, cả về dòng lẫn về cột. Đây là tình huống phù hợp để áp dụng phân mảnh hỗn hợp.

---

## Slide 11 – Lược đồ toàn cục & phân tích truy vấn · *Triết · 1:00*

**Trên slide**
- 6 quan hệ: `ChiNhanh`, `KhachHang`, `NhanVien`, `SanPham`, `DonHang`, `ChiTietDonHang`
- Truy vấn chính:

| | Ứng dụng | Tại | Tần suất |
|---|---|---|---|
| Q1–Q2 | Tra cứu khách, lập/xử lý đơn | Chi nhánh | Rất cao |
| Q3 | Hạn mức, công nợ theo miền | Trụ sở | Trung bình |
| Q4 | Danh sách nhân viên chi nhánh | Chi nhánh | Trung bình |
| Q5 | Tính lương | Trụ sở | Thấp |
| Q6 | Báo cáo doanh thu | Trụ sở | Thấp |

- Ma trận sử dụng `KhachHang` → 2 nhóm cột: **giao dịch** và **tài chính**

**Hình/bố cục:** trái là sơ đồ quan hệ 6 bảng có mũi tên khóa ngoại; phải là bảng truy vấn. Dưới là ma trận sử dụng KhachHang (3 dòng Q1–Q3 × 9 cột), tô 2 khối 1.

**Lời thuyết trình**
> Lược đồ toàn cục có sáu bảng: chi nhánh, khách hàng, nhân viên, sản phẩm, đơn hàng và chi tiết đơn hàng.
> Theo nguyên tắc thiết kế, nhóm liệt kê các truy vấn chính, nơi phát sinh và tần suất. Truy vấn nhiều nhất là tra cứu khách và lập đơn, xảy ra ở chi nhánh. Truy vấn công nợ, tính lương và báo cáo doanh thu xảy ra ở trụ sở với tần suất thấp hơn.
> Nhìn vào ma trận sử dụng của bảng khách hàng, các truy vấn ở chi nhánh chỉ dùng nhóm cột giao dịch, còn truy vấn kế toán chỉ dùng nhóm cột tài chính. Hai nhóm này gần như không dùng chung cột nào ngoài khóa. Kết hợp với việc mỗi chi nhánh chỉ dùng khách của mình, bảng khách hàng cần được chia theo cả dòng và cột.

---

## Slide 12 – Thiết kế: KhachHang (HV) · *Triết · 1:00*

**Trên slide**
- Bước 1 – ngang: **KHᵢ = σ_MaCN='CN0i'(KhachHang)**, i = 1..3
- Bước 2 – dọc trên từng KHᵢ:
  - **KHᵢ_GD = π_MaKH, HoTen, SDT, Email, DiaChi, MaCN(KHᵢ)** → đặt tại chi nhánh i
  - **KHᵢ_TC = π_MaKH, HanMucNo, CongNo, DiemTichLuy(KHᵢ)** → đặt tại trụ sở
- Tái thiết: **KhachHang = ⋃ᵢ (KHᵢ_GD ⋈_MaKH KHᵢ_TC)**
- Vì sao HV: kế toán cần **báo cáo công nợ theo từng miền**, nên giữ phần TC tách theo miền

**Hình/bố cục:** cây phân mảnh HV đầy đủ: gốc → 3 nút σ → 6 lá. Lá GD tô màu chi nhánh, lá TC tô xám (trụ sở).

**Lời thuyết trình**
> Với bảng khách hàng, nhóm dùng chiến lược ngang trước, dọc sau. Bước một, chia theo mã chi nhánh thành ba mảnh. Bước hai, mỗi mảnh chi nhánh được tách dọc thành phần giao dịch, đặt tại chính chi nhánh đó, và phần tài chính gồm hạn mức, công nợ, điểm tích lũy, đặt tại trụ sở.
> Kết quả là sáu mảnh lá. Muốn lấy lại bảng khách hàng ban đầu, ta kết nối hai phần của từng chi nhánh theo mã khách, rồi hợp ba kết quả lại.
> Nhóm chọn HV vì kế toán cần báo cáo công nợ theo từng miền. Phần tài chính vẫn được chia theo miền nên báo cáo theo miền chỉ cần đọc đúng mảnh của miền đó, không phải lọc lại.

---

## Slide 13 – Thiết kế: NhanVien (VH) và DonHang · *Triết · 1:00*

**Trên slide**
- **NhanVien, chiến lược VH:**
  - Dọc: **NV_CV** (công việc) và **NV_NS** (nhân sự, nhạy cảm) → NV_NS đặt tại trụ sở
  - Ngang trên NV_CV: **NV_CVᵢ = σ_MaCN='CN0i'(NV_CV)** → đặt tại chi nhánh i
  - Tái thiết: **NhanVien = (NV_CV₁ ∪ NV_CV₂ ∪ NV_CV₃) ⋈_MaNV NV_NS**
- **DonHang, ChiTietDonHang:** ngang dẫn xuất: **DHᵢ = DonHang ⋉ KHᵢ**, **CTDHᵢ = ChiTietDonHang ⋉ DHᵢ**
- **ChiNhanh, SanPham:** nhỏ, đọc nhiều → **nhân bản** ở cả 4 site

**Hình/bố cục:** trái là cây VH (gốc → 2 nút π → NV_CV tách 3 lá, NV_NS là lá). Phải là sơ đồ nhỏ KHᵢ ──⋉── DHᵢ ──⋉── CTDHᵢ.

**Lời thuyết trình**
> Với bảng nhân viên, nhóm dùng chiến lược dọc trước, ngang sau. Thông tin nhân sự như lương, CCCD, số tài khoản được tách riêng và chỉ đặt tại trụ sở; chi nhánh không có các cột này nên không thể xem được. Phần thông tin công việc thì chia tiếp theo chi nhánh, để mỗi chi nhánh giữ danh sách nhân viên của mình.
> Đơn hàng và chi tiết đơn hàng dùng phân mảnh ngang dẫn xuất: đơn đi theo khách, chi tiết đi theo đơn. Vì vậy phép kết nối khách với đơn với chi tiết luôn chạy tại chỗ ở chi nhánh.
> Cuối cùng, bảng chi nhánh và sản phẩm nhỏ, chủ yếu được đọc, nên được nhân bản đầy đủ ở cả bốn site.

---

## Slide 14 – Lược đồ cấp phát · *Triết · 0:45*

**Trên slide**

| Site | Mảnh |
|---|---|
| **S0 – Trụ sở** | KH₁_TC, KH₂_TC, KH₃_TC, NV_NS |
| **S1 – Hà Nội** | KH₁_GD, NV_CV₁, DH₁, CTDH₁ |
| **S2 – Đà Nẵng** | KH₂_GD, NV_CV₂, DH₂, CTDH₂ |
| **S3 – TP.HCM** | KH₃_GD, NV_CV₃, DH₃, CTDH₃ |
| *Mọi site* | ChiNhanh, SanPham (nhân bản) |

- **Q1, Q2, Q4** (tần suất cao) → chạy **cục bộ** tại chi nhánh
- **Q3, Q5** → chạy **cục bộ** tại trụ sở
- Chỉ **Q6** (báo cáo toàn công ty) cần dữ liệu từ nhiều site

**Hình/bố cục:** sơ đồ 4 site (dùng `cap_phat_4_site`), mỗi site là một khối màu liệt kê các mảnh.

**Lời thuyết trình**
> Đây là lược đồ cấp phát. Trụ sở giữ ba mảnh tài chính của khách hàng và mảnh nhân sự. Mỗi chi nhánh giữ phần giao dịch của khách mình, danh sách nhân viên, đơn hàng và chi tiết đơn hàng của chi nhánh.
> Với cách đặt này, các truy vấn tần suất cao ở chi nhánh và các truy vấn của kế toán, nhân sự đều chạy hoàn toàn tại chỗ. Chỉ có báo cáo toàn công ty, vốn chạy ít, là phải lấy dữ liệu từ nhiều site.

---

## Slide 15 – Demo trên SQL Server · *Triết · 1:30*

**Trên slide**
- Mô phỏng: mỗi site là **một database**: `QLDH_TRUSO`, `QLDH_HN`, `QLDH_DN`, `QLDH_HCM`
- Trụ sở dùng **synonym** + **view tái thiết** (`v_KhachHang`, `v_NhanVien`, `v_DonHang`), tức là **trong suốt phân mảnh và vị trí**
- Kiểm tra tự động **3 quy tắc đúng đắn**: 13/13 **ĐẠT**
- Vị từ phân mảnh được ràng buộc bằng **CHECK**; chi nhánh **không có cột lương**
- Giao dịch phân tán: lập đơn ở chi nhánh + cập nhật công nợ ở trụ sở, **cùng thành công hoặc cùng hủy**

**Hình/bố cục:** lưới 2×2 ảnh chụp: (1) `demo_01_object_explorer`, (2) `demo_05_kiem_tra_dung_dan`, (3) `demo_04_view_tai_thiet` hoặc `demo_07_truy_van_toan_cuc`, (4) `demo_08_giao_dich`. Nếu thầy cho chạy trực tiếp thì mở SSMS, chạy cuối file `03` và phần D của `04`.

**Lời thuyết trình**
> Nhóm cài đặt thiết kế này trên SQL Server. Mỗi site được mô phỏng bằng một database riêng: trụ sở, Hà Nội, Đà Nẵng và TP.HCM. Dữ liệu được phân mảnh từ một CSDL gốc, đúng theo các biểu thức đại số vừa trình bày.
> Ở trụ sở, nhóm tạo synonym trỏ tới các mảnh ở chi nhánh, rồi tạo view tái thiết dựa trên synonym đó. Người dùng chỉ cần truy vấn view khách hàng như một bảng bình thường, không cần biết dữ liệu nằm ở mảnh nào hay ở site nào.
> Để chứng minh phân mảnh đúng, nhóm viết các truy vấn tự kiểm tra ba quy tắc. Kết quả là cả 13 phép kiểm tra đều đạt. Nhóm cũng ghi điều kiện phân mảnh thành ràng buộc CHECK, nên mảnh Hà Nội không nhận khách của chi nhánh khác. Chi nhánh truy vấn cột lương sẽ bị báo lỗi, vì cột đó không tồn tại ở chi nhánh.
> Cuối cùng là một giao dịch phân tán: chi nhánh lập đơn và trụ sở cập nhật công nợ. Nếu đơn vượt hạn mức, cả hai site cùng hủy, không có site nào bị ghi dở.

---

## Slide 16 – Đánh giá & kết luận · *Triết · 0:45*

**Trên slide**
- **Ưu điểm:** đa số truy vấn chạy cục bộ · bảo mật dữ liệu nhân sự · báo cáo theo miền nhanh
- **Đánh đổi:** lập đơn phải cập nhật công nợ ở trụ sở → **giao dịch phân tán** (cần 2PC khi nhiều máy); thay đổi thiết kế khi đổi cơ cấu chi nhánh
- **Kết luận:** phân mảnh hỗn hợp phù hợp khi nhu cầu truy cập khác nhau **cả theo dòng lẫn theo cột**
- **Hướng phát triển:** chạy trên nhiều máy bằng Linked Server, đồng bộ bản nhân bản, tối ưu truy vấn phân tán

**Hình/bố cục:** 2 cột Ưu điểm (xanh) / Đánh đổi (cam); dưới là 1 dòng kết luận nổi bật.

**Lời thuyết trình**
> Đánh giá lại: thiết kế giúp phần lớn truy vấn chạy tại chỗ, bảo vệ được dữ liệu nhân sự, và báo cáo theo miền rất nhanh. Cái giá phải trả là thao tác lập đơn phải cập nhật công nợ ở trụ sở, tức là thành một giao dịch phân tán; khi chạy trên nhiều máy thật cần giao thức cam kết hai pha.
> Kết luận, phân mảnh hỗn hợp phù hợp khi các nhóm người dùng khác nhau cần những phần dữ liệu khác nhau, cả theo dòng lẫn theo cột. Hướng phát triển là triển khai trên nhiều máy thật bằng Linked Server và nghiên cứu đồng bộ các bản nhân bản.

---

## Slide 17 – Cảm ơn & Hỏi đáp · *Cả nhóm*

**Trên slide**
- CẢM ƠN THẦY VÀ CÁC BẠN ĐÃ LẮNG NGHE
- Hỏi & Đáp

**Lời thuyết trình**
> Phần trình bày của nhóm em đến đây là kết thúc. Nhóm em cảm ơn thầy và các bạn đã lắng nghe, mong nhận được câu hỏi và góp ý.

---

## Câu hỏi dự kiến (chuẩn bị cho phần hỏi đáp)

**1. "4 database trên 1 máy thì có thật sự phân tán không?"**
> Đây là mô phỏng: mỗi database đóng vai một site, và ranh giới giữa các site là ranh giới database. Thiết kế phân mảnh và cấp phát không phụ thuộc hạ tầng. Ở trụ sở, view chỉ tham chiếu synonym, nên muốn chạy trên nhiều máy thì chỉ cần tạo Linked Server và cho synonym trỏ tới tên 4 phần `[MayKhac].QLDH_HN.dbo.KH_1_GD`; view và truy vấn giữ nguyên. *(Nếu làm được T4b thì mở ảnh chụp chạy trên 2 laptop.)*

**2. "HV và VH khác nhau thế nào, sao không dùng một kiểu cho cả hai bảng?"**
> Khác nhau ở chỗ nút nào được chia tiếp. Với KhachHang, phần tài chính cũng cần tách theo miền để kế toán báo cáo theo miền, nên chia ngang trước rồi mới chia dọc từng mảnh (HV). Với NhanVien, phần nhân sự xử lý tập trung, không cần chia theo chi nhánh, nên chia dọc trước và chỉ chia ngang phần công việc (VH). Hơn nữa, NV_NS không có cột MaCN nên cũng không chia ngang trực tiếp theo chi nhánh được.

**3. "Làm sao chứng minh phân mảnh là đúng?"**
> Đầy đủ: tập vị từ MaCN = CN01/CN02/CN03 phủ hết miền giá trị (có ràng buộc CHECK), và hợp các nhóm cột bằng toàn bộ cột. Tái thiết: ghép theo khóa chính thì không mất và không thừa bộ. Rời nhau: các vị từ loại trừ nhau, và hai mảnh dọc chỉ dùng chung khóa. Demo kiểm tra cả ba quy tắc bằng EXCEPT và GROUP BY … HAVING, kết quả 13/13 đạt.

**4. "Sao dùng UNION ALL chứ không dùng UNION trong view?"**
> Vì các mảnh ngang rời nhau nên không có bộ trùng để loại. UNION ALL cho cùng kết quả mà không tốn chi phí sắp xếp để khử trùng lặp.

**5. "Nếu khách chuyển từ chi nhánh Hà Nội sang Đà Nẵng thì sao?"**
> Phải chuyển bộ đó từ mảnh KH_1 sang KH_2, gồm cả phần GD ở site chi nhánh và phần TC ở trụ sở, kèm các đơn hàng dẫn xuất nếu muốn đơn đi theo khách. Thao tác này là một giao dịch phân tán. Ràng buộc CHECK bảo đảm không thể sửa MaCN tại chỗ mà để sai mảnh.

**6. "Tại sao SanPham nhân bản mà không phân mảnh?"**
> Bảng nhỏ, mọi chi nhánh đều đọc khi lập đơn, và chỉ trụ sở cập nhật giá. Nhân bản giúp lập đơn không phải truy cập từ xa; đổi lại, mỗi lần đổi giá phải đồng bộ xuống 3 chi nhánh. Vì giá ít thay đổi nên chi phí đó chấp nhận được.

**7. "Phân mảnh hỗn hợp có nhược điểm gì?"**
> Truy vấn cần đầy đủ thông tin phải ghép nhiều mảnh, vừa phép hợp vừa phép kết nối, nên chi phí cao hơn. Cập nhật đụng cả hai phần dọc thì thành giao dịch phân tán. Thiết kế gắn với các truy vấn hiện tại, nên khi nghiệp vụ thay đổi thì phải thiết kế lại.

**8. "Cập nhật công nợ ở site khác thì bảo đảm nhất quán thế nào?"**
> Bằng giao dịch: lập đơn ở S1 và cộng công nợ ở S0 nằm trong cùng một giao dịch, có XACT_ABORT. Lỗi ở bất kỳ bước nào thì cả hai cùng hủy; demo trường hợp vượt hạn mức cho thấy không site nào bị ghi dở. Khi chạy trên nhiều máy thì SQL Server dùng MSDTC với giao thức cam kết hai pha (2PC).
