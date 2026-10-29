# Đề cương chi tiết – Báo cáo & Slide

## A. Báo cáo Word (mẫu đồ án môn học HUTECH)

**Định dạng:** khổ A4; Times New Roman 13; giãn dòng 1.3; lề trên/dưới 2 cm, trái 3 cm, phải 2 cm. Heading chương 14 in đậm IN HOA; đánh số hình/bảng theo chương (Hình 3.1, Bảng 4.2). Độ dài khoảng 30–40 trang.

### Phần đầu
1. **Trang bìa:** BỘ GIÁO DỤC VÀ ĐÀO TẠO / TRƯỜNG ĐẠI HỌC CÔNG NGHỆ TP. HCM / KHOA CÔNG NGHỆ THÔNG TIN; dòng "ĐỒ ÁN MÔN HỌC CƠ SỞ DỮ LIỆU NÂNG CAO"; tên đề tài; Ngành: Công nghệ Thông tin; GVHD: Nguyễn Văn Danh *(mặc định không ghi học vị; thêm ThS./TS. khi biết)*; Sinh viên thực hiện: Trần Gia Thịnh – 2380602136, Phạm Minh Triết – 2380605829; Lớp: *(chưa có)*; TP. Hồ Chí Minh, 2026
2. Trang phụ bìa (nếu khoa yêu cầu)
3. Lời cảm ơn
4. Nhận xét của giảng viên
5. Mục lục · Danh mục hình · Danh mục bảng · Danh mục từ viết tắt (CSDL, CSDLPT, DDBMS, HV, VH, BEA…)
6. **Bảng phân công công việc** (Trần Gia Thịnh, Phạm Minh Triết: nhiệm vụ, mức độ hoàn thành)

### LỜI MỞ ĐẦU
Lý do chọn đề tài · Mục tiêu · Đối tượng & phạm vi · Phương pháp thực hiện · Bố cục báo cáo

### CHƯƠNG 1. TỔNG QUAN VỀ CƠ SỞ DỮ LIỆU PHÂN TÁN
- 1.1 Khái niệm CSDL phân tán và hệ quản trị CSDL phân tán
- 1.2 So sánh CSDL tập trung và CSDL phân tán; ưu và nhược điểm
- 1.3 Kiến trúc tham chiếu: lược đồ toàn cục → lược đồ phân mảnh → lược đồ cấp phát → lược đồ ánh xạ cục bộ
- 1.4 Tính trong suốt: phân mảnh, vị trí, nhân bản, ánh xạ cục bộ
- 1.5 Thiết kế CSDL phân tán: hướng từ trên xuống / từ dưới lên; hai bài toán phân mảnh và cấp phát

### CHƯƠNG 2. PHÂN MẢNH DỮ LIỆU TRONG CSDL PHÂN TÁN
- 2.1 Lý do phân mảnh, đơn vị phân mảnh, mức độ phân mảnh
- 2.2 Các quy tắc đúng đắn: đầy đủ, tái thiết, rời nhau
- 2.3 Phân mảnh ngang nguyên thủy: vị từ đơn giản, vị từ hội sơ cấp (minterm), tính đầy đủ & cực tiểu, thuật toán COM_MIN và PHORIZONTAL, ví dụ
- 2.4 Phân mảnh ngang dẫn xuất: quan hệ chủ/thành viên, phép nửa kết nối, ví dụ
- 2.5 Phân mảnh dọc: ma trận sử dụng thuộc tính, ma trận ái lực AA, thuật toán năng lượng liên kết BEA, thuật toán SPLIT, ví dụ
- 2.6 Nhân bản và cấp phát mảnh (tổng quan)

### CHƯƠNG 3. PHÂN MẢNH HỖN HỢP
- 3.1 Định nghĩa và động cơ sử dụng
- 3.2 Chiến lược ngang-trước-dọc (HV)
- 3.3 Chiến lược dọc-trước-ngang (VH)
- 3.4 Cây phân mảnh và biểu diễn bằng đại số quan hệ
- 3.5 Tái thiết quan hệ toàn cục
- 3.6 Kiểm tra các quy tắc đúng đắn
- 3.7 Cấp phát mảnh hỗn hợp; ảnh hưởng tới xử lý truy vấn và giao dịch
- 3.8 Ưu điểm, hạn chế; so sánh 3 loại phân mảnh (bảng)
- 3.9 Hỗ trợ trong các DBMS thực tế: SQL Server (Linked Server, Distributed Partitioned View), Oracle (Partitioning, DB Link), PostgreSQL (postgres_fdw, Citus)

### CHƯƠNG 4. ỨNG DỤNG PHÂN MẢNH HỖN HỢP CHO HỆ THỐNG QUẢN LÝ ĐƠN HÀNG
*(nội dung chi tiết: `docs/01_bai_toan_thiet_ke.md`)*
- 4.1 Mô tả bài toán
- 4.2 Lược đồ toàn cục (sơ đồ ERD/quan hệ)
- 4.3 Phân tích ứng dụng và ma trận sử dụng thuộc tính
- 4.4 Thiết kế phân mảnh: KhachHang (HV), NhanVien (VH), DonHang/ChiTietDonHang (ngang dẫn xuất), ChiNhanh/SanPham (nhân bản)
- 4.5 Kiểm tra tính đúng đắn
- 4.6 Lược đồ cấp phát
- 4.7 Cài đặt thực nghiệm trên SQL Server: môi trường, script, view tái thiết, kết quả kiểm tra, truy vấn minh họa (kèm ảnh chụp)
- 4.8 Đánh giá

### CHƯƠNG 5. KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN
Kết quả đạt được · Hạn chế · Hướng phát triển (Linked Server thật, đồng bộ nhân bản, giao dịch phân tán 2PC)

### TÀI LIỆU THAM KHẢO (định dạng IEEE)
- [1] M. T. Özsu, P. Valduriez, *Principles of Distributed Database Systems*, 4th ed. Springer, 2020.
- [2] S. Ceri, G. Pelagatti, *Distributed Databases: Principles and Systems*. McGraw-Hill, 1984.
- [3] Microsoft Learn – Linked Servers; Partitioned Views (SQL Server).
- [4] Bài giảng CSDL Nâng cao / CSDL Phân tán của khoa *(bổ sung khi có)*.

### PHỤ LỤC
Toàn bộ script SQL.

---

## B. Nội dung slide (thuyết trình 10–15 phút, 17 slide)

| # | Slide | Nội dung chính | Thời gian | Người nói |
|---|-------|----------------|-----------|---------------------|
| 1 | Bìa | Đề tài, GVHD, thành viên | — | Thịnh |
| 2 | Nội dung | 4 phần: Tổng quan · Phân mảnh · Phân mảnh hỗn hợp · Ứng dụng | 0:20 | Thịnh |
| 3 | CSDL phân tán là gì | Định nghĩa, hình nhiều site nối mạng, lợi ích | 1:00 | Thịnh |
| 4 | Vì sao phải phân mảnh | Cục bộ hóa dữ liệu, song song, bảo mật; 3 quy tắc đúng đắn | 1:00 | Thịnh |
| 5 | Phân mảnh ngang | σ, ví dụ theo khu vực; nhắc ngang dẫn xuất | 1:00 | Thịnh |
| 6 | Phân mảnh dọc | π, khóa lặp lại; ma trận sử dụng → nhóm thuộc tính | 1:00 | Thịnh |
| 7 | Phân mảnh hỗn hợp – định nghĩa | Khi nào cần; kết hợp σ và π | 1:00 | Thịnh |
| 8 | HV vs VH | Hai cây phân mảnh đặt cạnh nhau + biểu thức | 1:15 | Thịnh |
| 9 | Tái thiết & đúng đắn | Công thức ∪/⋈; 3 quy tắc áp dụng cho hỗn hợp | 1:00 | Thịnh |
| 10 | Bài toán quản lý đơn hàng | Công ty X, 3 chi nhánh + trụ sở; các nhu cầu truy cập | 1:00 | Triết |
| 11 | Lược đồ toàn cục & phân tích truy vấn | 6 quan hệ; bảng Q1–Q7; ma trận sử dụng KhachHang | 1:00 | Triết |
| 12 | Thiết kế: KhachHang (HV) | Cây phân mảnh 6 lá + đại số | 1:00 | Triết |
| 13 | Thiết kế: NhanVien (VH) + DonHang dẫn xuất | Cây 4 lá; DH_i = DonHang ⋉ KH_i | 1:00 | Triết |
| 14 | Lược đồ cấp phát | Sơ đồ 4 site và các mảnh trên từng site | 0:45 | Triết |
| 15 | Demo | Ảnh chụp: view tái thiết, kiểm tra đúng đắn, truy vấn cục bộ/toàn cục | 1:30 | Triết |
| 16 | Đánh giá & kết luận | Ưu điểm, đánh đổi (cập nhật công nợ qua S0), hướng phát triển | 0:45 | Triết |
| 17 | Cảm ơn / Q&A | — | — | Cả nhóm |

Tổng khoảng 14 phút: Thịnh (slide 1–9, lý thuyết) khoảng 7.5 phút, Triết (slide 10–16, ứng dụng + demo) khoảng 7 phút. Nếu cần rút còn 10 phút: gộp slide 5+6 và 12+13, demo chỉ chiếu 1 ảnh.

**Dạng giao nộp nội dung slide:** file `slides/noi_dung_slide.md`. Mỗi slide gồm tiêu đề, gạch đầu dòng hiển thị trên slide, gợi ý hình/sơ đồ và **lời thuyết trình (speaker notes)**. Nhóm dùng file này để tự dựng file pptx.
