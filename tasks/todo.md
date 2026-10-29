# Todo – Đồ án CSDL Nâng Cao

> `[ ]` chưa làm · `[~]` đang làm · `[x]` xong. Mỗi task ghi rõ **Người làm** và **Hạn**.

---

## Phase 1 – Nội dung nền (hạn T3 27/10)

### T1: Nội dung slide ✅ (26/10 – chờ nhóm duyệt)
**Người làm:** Claude · **Hạn:** T3 27/10
**Mô tả:** Viết nội dung cho 17 slide theo bảng ở `docs/00_de_cuong.md` mục B. Mỗi slide gồm: tiêu đề, chữ hiển thị trên slide, gợi ý hình/bố cục, lời thuyết trình.
**Tiêu chí hoàn thành:**
- [x] Đủ 17 slide; mỗi slide không quá 6 gạch đầu dòng, mỗi dòng không quá khoảng 12 từ
- [x] Lời thuyết trình mỗi slide khớp thời lượng trong bảng (khoảng 130 từ/phút); tổng 13–15 phút
- [x] Ký hiệu và tên mảnh khớp đúng với `docs/01_bai_toan_thiet_ke.md`
**Kiểm tra:** ✅ đã đếm âm tiết: Thịnh khoảng 7.1 phút, Triết khoảng 5.6 phút (170 âm tiết/phút), cộng chuyển slide khoảng 14 phút · [ ] Thịnh và Triết đọc thử một lượt
**Phụ thuộc:** không · **File:** `slides/noi_dung_slide.md` · **Quy mô:** M

### T2: Sơ đồ minh họa ✅ (26/10 – 9 hình, PNG + SVG)
**Người làm:** Claude · **Hạn:** T3 27/10
**Mô tả:** Vẽ các sơ đồ dùng chung cho slide và Word.
**Tiêu chí hoàn thành:**
- [x] Cây phân mảnh HV (KhachHang, 6 lá) và VH (NhanVien, 4 lá)
- [x] Sơ đồ cấp phát 4 site (S0–S3) kèm danh sách mảnh trên từng site
- [x] Sơ đồ kiến trúc CSDL phân tán và lược đồ quan hệ toàn cục
**Kiểm tra:** mở từng file PNG, chữ đọc rõ khi thu nhỏ còn nửa slide
**Phụ thuộc:** không · **File:** `assets/diagrams/*.svg`, `*.png` · **Quy mô:** M

### T3: SQL – lược đồ toàn cục, dữ liệu mẫu, tạo mảnh ✅ (26/10 – chưa chạy trên SQL Server)
**Người làm:** Claude · **Hạn:** T3 27/10
**Tiêu chí hoàn thành:**
- [x] `01_global_schema.sql` tạo `QLDH_GOC` gồm 6 bảng, có khóa, khóa ngoại, CHECK trên MaCN; khoảng 30 khách hàng, 12 nhân viên, 10 sản phẩm, 40 đơn hàng, dữ liệu chia đều 3 miền
- [x] `02_fragments.sql` tạo `QLDH_TRUSO`, `QLDH_HN`, `QLDH_DN`, `QLDH_HCM` và đổ dữ liệu vào từng mảnh đúng như mục 4 và mục 6 của file thiết kế
- [x] Script chạy lại nhiều lần không lỗi (có DROP IF EXISTS)
**Kiểm tra:** Triết chạy thử ở T5. Comment trong script ghi sẵn số dòng mong đợi của từng mảnh
**Phụ thuộc:** không · **File:** `demo/sql/01_global_schema.sql`, `demo/sql/02_fragments.sql` · **Quy mô:** S

### T4: SQL – tái thiết, kiểm tra đúng đắn, truy vấn minh họa ✅ (26/10 – chưa chạy trên SQL Server)
**Người làm:** Claude · **Hạn:** T3 27/10
**Tiêu chí hoàn thành:**
- [x] `03_reconstruct_check.sql`: synonym tại S0 trỏ tới từng mảnh ở các site; view `v_KhachHang`, `v_NhanVien`, `v_DonHang` chỉ tham chiếu synonym, không gọi thẳng tên database; 3 nhóm truy vấn kiểm tra đầy đủ, tái thiết, rời nhau, kết quả mong đợi là chênh lệch 0 dòng
- [x] `04_queries.sql`: truy vấn cục bộ Q1, Q2, Q4 tại chi nhánh; Q3, Q5 tại S0; Q6 toàn cục qua view
**Kiểm tra:** Triết chạy ở T5, toàn bộ truy vấn kiểm tra trả về 0 dòng chênh lệch
**Phụ thuộc:** T3 · **File:** `demo/sql/03_reconstruct_check.sql`, `demo/sql/04_queries.sql` · **Quy mô:** S

### T4b *(tùy chọn)*: Phân tán thật trên 2 laptop bằng Linked Server
**Người làm:** Claude viết script · Thịnh + Triết chạy · **Hạn:** T5 29/10 (chỉ làm khi T5 đã xong)
**Mô tả:** Laptop Triết giữ S0 (trụ sở) và S3; laptop Thịnh giữ S1 và S2, hoặc chia theo cách khác miễn có ít nhất 1 site nằm ở máy kia. Tạo Linked Server từ máy S0 sang máy còn lại, rồi tạo lại synonym trỏ tới tên 4 phần.
**Tiêu chí hoàn thành:**
- [ ] `05_linked_server.sql`: bật TCP/IP, tạo login SQL, `sp_addlinkedserver` + `sp_addlinkedsrvlogin`, tạo lại synonym
- [ ] Các view và truy vấn trong `03`, `04` chạy **không phải sửa** và cho cùng kết quả
- [ ] Ảnh chụp: Object Explorer của 2 máy + 1 truy vấn toàn cục lấy dữ liệu từ máy kia
**Kiểm tra:** truy vấn kiểm tra đúng đắn vẫn trả 0 dòng chênh lệch
**Phụ thuộc:** T5; 2 laptop cùng mạng Wi-Fi, mở firewall port 1433 · **File:** `demo/sql/05_linked_server.sql` · **Quy mô:** S

### ✅ Checkpoint A – tối T3 27/10
- [ ] Thịnh và Triết đọc `slides/noi_dung_slide.md`, góp ý gửi cho Claude
- [ ] **Triết cài xong SQL Server 2022 Developer + SSMS** (việc này làm ngay từ T3, không đợi)

---

## Phase 2 – Demo, dựng slide, Word (T4 28/10 – T5 29/10)

### T5: Chạy demo và chụp màn hình
**Người làm:** Triết · **Hạn:** **chạy thử ngay T3 27/10**, chụp ảnh T4 28/10
> ⚠️ Script chưa từng chạy trên SQL Server (máy Claude không có), nên lần chạy đầu của Triết là lần thử thật. Chạy càng sớm càng tốt; lỗi gì thì **chụp hoặc copy nguyên thông báo lỗi** (tab Messages) gửi lại cho Claude sửa.
**Tiêu chí hoàn thành:**
- [ ] Chạy lần lượt 4 script không có lỗi
- [ ] Chụp ít nhất 6 ảnh: Object Explorer hiện 5 database; nội dung 1 mảnh GD và 1 mảnh TC; view tái thiết; kết quả kiểm tra đúng đắn (0 dòng); 1 truy vấn cục bộ; 1 truy vấn toàn cục
- [ ] Lưu ảnh vào `assets/screenshots/` theo tên `demo_01_....png`
**Kiểm tra:** số dòng của từng mảnh khớp với comment trong script
**Phụ thuộc:** T3, T4, Checkpoint A · **Quy mô:** S

### T6: Dựng slide 1–9 (lý thuyết)
**Người làm:** Thịnh · **Hạn:** T5 29/10
**Tiêu chí hoàn thành:**
- [ ] Dùng chung template/theme với Triết (chốt template trước khi chia nhau làm)
- [ ] Chèn sơ đồ từ T2; lời thuyết trình dán vào phần Notes của từng slide
**Phụ thuộc:** T1, T2 · **Quy mô:** M

### T7: Dựng slide 10–17 (ứng dụng + demo)
**Người làm:** Triết · **Hạn:** T5 29/10
**Tiêu chí hoàn thành:**
- [ ] Cùng template với T6; chèn sơ đồ T2 và ảnh demo T5 vào slide 15
- [ ] Lời thuyết trình dán vào Notes
**Phụ thuộc:** T1, T2, T5 · **Quy mô:** M

### T8: Word – phần đầu, Lời mở đầu, Chương 1–2 ✅ (26/10)
**Người làm:** Claude · **Hạn:** T4 28/10
**Tiêu chí hoàn thành:**
- [x] Bìa (GVHD Th.S Nguyễn Văn Danh, 2 SV + MSSV), lời cảm ơn, nhận xét GV, bảng phân công, danh mục từ viết tắt
- [x] Chương 1–2 đủ các mục trong đề cương, mỗi loại phân mảnh có ví dụ
**Kiểm tra:** đối chiếu từng mục với đề cương
**Phụ thuộc:** không · **File:** `docs/draft/ch0_ch1_ch2.md` · **Quy mô:** M

### T9: Word – Chương 3 ✅ (26/10)
**Người làm:** Claude · **Hạn:** T5 29/10
**Tiêu chí hoàn thành:**
- [x] Đủ mục 3.1–3.9; có ví dụ HV và VH dạng biểu thức + cây; có bảng so sánh 3 loại phân mảnh
**Phụ thuộc:** T2 · **File:** `docs/draft/ch3.md` · **Quy mô:** M

### ✅ Checkpoint B – tối T5 29/10
- [ ] Đủ 17 slide (ghép phần của 2 người), ảnh demo đã có trên slide 15
- [ ] Bản nháp Ch1–3 đã xong

---

## Phase 3 – Hoàn thiện (T6 30/10 – T7 31/10)

### T10: Word – Chương 4–5, Tài liệu tham khảo, Phụ lục 🟡 (26/10 – đã viết, còn chèn 6 ảnh demo)
**Người làm:** Claude · **Hạn:** T6 30/10
**Tiêu chí hoàn thành:**
- [ ] Ch4 đủ các mục 4.1–4.8, chèn ảnh demo; Ch5; TLTK định dạng IEEE; Phụ lục chứa toàn bộ script
**Phụ thuộc:** T4, T5 · **File:** `docs/draft/ch4_ch5.md` · **Quy mô:** M

### T11: Ghép file .docx và rà soát 🟡 (26/10 – bản nháp 1 đã build, build lại sau khi có ảnh + tên lớp)
**Người làm:** Claude · **Hạn:** T6 30/10
**Tiêu chí hoàn thành:**
- [ ] `docs/BaoCao_PhanManhHonHop.docx`: Times New Roman 13, giãn dòng 1.3, lề 3/2/2/2 cm; mục lục tự động; đánh số hình/bảng theo chương; có số trang
- [ ] Bản PDF xuất kèm
**Kiểm tra:** mở file, kiểm tra mục lục và danh mục hình; tổng 30–40 trang
**Phụ thuộc:** T8, T9, T10 · **Quy mô:** S

### T12: Đọc duyệt Word
**Người làm:** Thịnh + Triết · **Hạn:** T6 30/10
- [ ] Điền tên lớp, học vị GVHD; báo lại cho Claude các chỗ cần sửa
**Phụ thuộc:** T11

### T13: Tập dượt
**Người làm:** Thịnh + Triết · **Hạn:** T6 30/10
- [ ] Tập 2 lượt có bấm giờ; tổng 13–15 phút; mỗi người khoảng 7 phút
- [ ] Đọc trước phần câu hỏi Q&A dự kiến (Claude ghi cuối `slides/noi_dung_slide.md`), trong đó có câu **"4 database trên 1 máy có thật sự phân tán không?"**
**Phụ thuộc:** T6, T7

### T14: Nộp slide
**Người làm:** Thịnh · **Hạn:** T7 31/10
- [ ] Nộp file slide (và Word nếu cùng hạn)
**Phụ thuộc:** T13

### ✅ Checkpoint C – T7 31/10
- [ ] Slide đã nộp
- [ ] Word + PDF sẵn sàng

---

## Bảng phân công (chèn vào báo cáo)

| STT | Thành viên | MSSV | Nhiệm vụ | Mức độ hoàn thành |
|-----|------------|------|----------|-------------------|
| 1 | Trần Gia Thịnh | 2380602136 | Tìm hiểu tổng quan CSDL phân tán, phân mảnh ngang/dọc và phân mảnh hỗn hợp (Chương 1–3); dựng slide và thuyết trình phần lý thuyết | 100% |
| 2 | Phạm Minh Triết | 2380605829 | Phân tích bài toán quản lý đơn hàng, thiết kế phân mảnh & cấp phát, cài đặt demo SQL Server (Chương 4); dựng slide và thuyết trình phần ứng dụng | 100% |
| | Cả nhóm | | Lời mở đầu, kết luận (Chương 5), rà soát báo cáo | 100% |
