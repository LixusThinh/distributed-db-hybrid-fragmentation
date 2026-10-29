# Kế hoạch thực hiện: Đồ án CSDL Nâng Cao – Phân mảnh hỗn hợp

## Tổng quan
Làm 3 sản phẩm cho đề tài *"Tìm hiểu Phân mảnh hỗn hợp trong CSDL Phân tán và ứng dụng cho quản lý đơn hàng"*:
1. **Nội dung slide** (chữ trên slide + lời thuyết trình) để nhóm dựng slide và **nộp T7 31/10/2026**.
2. **Báo cáo Word** theo mẫu đồ án HUTECH.
3. **Demo SQL Server** cho Chương 4 và slide 15.

Nhóm: Trần Gia Thịnh (2380602136), Phạm Minh Triết (2380605829). GVHD: Nguyễn Văn Danh.
Thiết kế nghiệp vụ đã được duyệt ngày 26/10: `docs/01_bai_toan_thiet_ke.md`. Đề cương: `docs/00_de_cuong.md`.

## Quyết định
- **Ai làm gì:** Claude viết toàn bộ nội dung (slide, Word, SQL). Người chỉ làm những việc Claude không làm được trên máy: chạy SQL Server và chụp màn hình, dựng file slide, tập dượt, nộp bài.
- **Ưu tiên slide trước Word**, vì slide là hạn cứng T7 còn hạn Word chưa rõ. Mọi việc nằm trên đường găng của slide được làm trước.
- **Chia thuyết trình theo 2 nửa liền mạch:** Thịnh nói slide 1–9 (lý thuyết), Triết nói slide 10–16 (ứng dụng + demo). Mỗi người dựng đúng phần slide mình nói, nên không phải bàn giao giữa chừng. Bảng phân công trong báo cáo chia theo cùng ranh giới đó.
- **Demo:** một instance SQL Server, mỗi site là một database. Không phụ thuộc mạng hay máy thứ hai.
- **Chuẩn bị sẵn để nâng lên phân tán thật:** view tái thiết ở S0 không gọi thẳng tên bảng mà đi qua **SYNONYM** (ví dụ `syn_KH_1_GD → QLDH_HN.dbo.KH_1_GD`). Khi chuyển sang 2 laptop nối bằng Linked Server, chỉ cần tạo lại synonym trỏ tới tên 4 phần `[LAPTOP_TRIET].QLDH_HN.dbo.KH_1_GD`. View, truy vấn và slide giữ nguyên. Chính điều này minh họa **tính trong suốt vị trí**.

## Đồ thị phụ thuộc

```
01_bai_toan_thiet_ke.md (xong)
   ├── T1 Nội dung slide ─────────────┬──► T6 Thịnh dựng slide 1–9 ──┐
   ├── T2 Sơ đồ (cây, cấp phát) ──────┤                              ├──► T13 Tập dượt ─► T14 Nộp (T7)
   ├── T3 SQL: lược đồ + mảnh ──┐     └──► T7 Triết dựng slide 10–17 ┘
   │                            └► T4 SQL: tái thiết + truy vấn ─► T5 Triết chạy demo + chụp ─► (T7, T10)
   ├── T8 Word: phần đầu + Ch1–2
   ├── T9 Word: Ch3
   └── T10 Word: Ch4–5 (cần T5) ─► T11 Ghép .docx ─► T12 Nhóm duyệt Word
```

Đường găng: **T3 → T4 → T5 → T7 → T13 → T14**. Rủi ro lớn nhất là demo, vì phụ thuộc vào việc SQL Server cài trên máy Triết.

## Danh sách việc (chi tiết trong `tasks/todo.md`)

### Phase 1 – Nội dung nền (T3 27/10)
- [x] T1 Nội dung slide · Claude
- [ ] T2 Sơ đồ minh họa · Claude
- [x] T3 SQL: lược đồ toàn cục + dữ liệu mẫu + tạo mảnh · Claude
- [x] T4 SQL: view tái thiết + kiểm tra đúng đắn + truy vấn · Claude
- [ ] T4b *(tùy chọn)* SQL: script Linked Server cho 2 laptop · Claude viết, Thịnh + Triết chạy
- [ ] **Checkpoint A (tối T3):** cả nhóm đọc nội dung slide; Triết cài xong SQL Server

### Phase 2 – Demo + dựng slide + viết Word (T4 28/10 – T5 29/10)
- [ ] T5 Chạy demo, chụp màn hình · Triết
- [ ] T6 Dựng slide 1–9 · Thịnh
- [ ] T7 Dựng slide 10–17 · Triết
- [ ] T8 Word: phần đầu, Lời mở đầu, Ch1–2 · Claude
- [ ] T9 Word: Ch3 · Claude
- [ ] **Checkpoint B (tối T5):** đủ 17 slide; demo có ảnh; đã có bản nháp Ch1–3

### Phase 3 – Hoàn thiện (T6 30/10 – T7 31/10)
- [ ] T10 Word: Ch4–5, Tài liệu tham khảo, Phụ lục · Claude
- [ ] T11 Ghép file .docx, rà soát định dạng · Claude
- [ ] T12 Đọc duyệt Word · Thịnh + Triết
- [ ] T13 Tập dượt có bấm giờ · Thịnh + Triết
- [ ] T14 Nộp slide · Thịnh
- [ ] **Checkpoint C:** slide đã nộp; Word sẵn sàng nộp khi có hạn

## Rủi ro & cách xử lý

| Rủi ro | Mức | Xử lý |
|--------|-----|-------|
| Script SQL chưa từng chạy trên SQL Server thật (máy Claude chỉ kiểm được bằng SQLite + parser) | Cao | Triết chạy thử **ngay T3**, gửi lại nguyên văn lỗi. Hoặc cài SQL Server LocalDB + sqlcmd trên máy Thịnh để Claude tự chạy và sửa |
| Máy Triết chưa có SQL Server, hoặc cài lỗi | Cao | Cài SQL Server 2022 Developer + SSMS ngay trong T3. Nếu không cài được thì chạy trên máy Thịnh. Phương án cuối: Azure Data Studio + Docker |
| Ảnh demo về muộn, làm chậm slide 15 và Ch4 | Trung bình | Script in sẵn kết quả mong đợi trong comment. Slide 15 để khung trống, chèn ảnh sau |
| Tổng thời gian nói vượt 15 phút | Trung bình | Lời thuyết trình viết theo ngân sách khoảng 130 từ/phút. Đã có phương án rút còn 10 phút (gộp 5+6, 12+13) |
| Thầy hỏi: "4 database trên 1 máy thì có thật sự phân tán không?" | Trung bình | (1) Slide 15 và mục 4.7 nói rõ đây là **mô phỏng**: mỗi database đóng vai một site, ranh giới giữa các site là ranh giới database. (2) Câu trả lời Q&A soạn sẵn: thiết kế phân mảnh và cấp phát không phụ thuộc hạ tầng; chuyển sang nhiều máy chỉ cần đổi synonym sang Linked Server. (3) Nếu kịp: làm T4b, chạy thật trên 2 laptop |
| Hạn nộp Word chưa rõ | Thấp | Làm Word song song, xong trước T7 |
| Thiếu thông tin lớp / học vị GVHD trên bìa | Thấp | Để chỗ trống đánh dấu, điền trước khi xuất PDF |

## Câu hỏi còn mở
- Tên lớp? Học vị GVHD (không bắt buộc: mặc định ghi tên không kèm học vị)?
- Hạn nộp báo cáo Word là ngày nào? Có phải nộp kèm script SQL không?
