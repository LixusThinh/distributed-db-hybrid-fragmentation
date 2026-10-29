# Đồ án môn Cơ Sở Dữ Liệu Nâng Cao

**Đề tài:** Tìm hiểu Phân mảnh hỗn hợp trong CSDL Phân tán và ứng dụng cho quản lý đơn hàng
**Trường:** HUTECH – Khoa Công nghệ Thông tin
**GVHD:** Th.S Nguyễn Văn Danh
**Nhóm (2 người):** Trần Gia Thịnh (2380602136) · Phạm Minh Triết (2380605829)
**Lớp:** *(chưa có)*
**Ngày lập kế hoạch:** 26/10/2026

---

## 1. Phạm vi & quyết định đã chốt

| Hạng mục | Quyết định |
|----------|------------|
| Claude làm | **Báo cáo Word (.docx)** + **nội dung slide** (chữ trên slide + lời thuyết trình) + script demo SQL |
| Nhóm tự làm | Dựng file slide (pptx/Canva) từ `slides/noi_dung_slide.md`, chạy demo và chụp màn hình, thuyết trình |
| Hạn nộp slide | **Thứ 7, 31/10/2026** |
| Thời lượng thuyết trình | 10–15 phút → 17 slide (Thịnh nói 1–9, Triết nói 10–16) |
| Hạn nộp báo cáo Word | *(chưa rõ, tạm coi là cùng ngày)* |
| Mẫu trình bày | Theo mẫu đồ án môn học HUTECH (link Studocu chỉ để tham khảo hình thức, không mở được nội dung) |
| DBMS demo | SQL Server 2019/2022 + SSMS; mỗi site là 1 database trên cùng instance; Linked Server là phần tùy chọn |

## 2. Cấu trúc thư mục

```
CSDLNC-PhanManhHonHop/
├── PLAN.md                         ← tổng quan + quyết định + nhật ký
├── tasks/plan.md, tasks/todo.md    ← task breakdown chi tiết + bảng phân công
├── docs/
│   ├── 00_de_cuong.md              ← đề cương báo cáo + bảng nội dung slide
│   ├── 01_bai_toan_thiet_ke.md     ← bài toán, lược đồ, thiết kế phân mảnh, cấp phát
│   └── (BaoCao_PhanManhHonHop.docx)
├── slides/(noi_dung_slide.md)
├── demo/sql, demo/data
├── assets/diagrams/
└── references/
```

## 3. Công việc & phân công

Toàn bộ task, người làm, hạn và tiêu chí hoàn thành nằm ở **`tasks/todo.md`**. Đồ thị phụ thuộc và rủi ro nằm ở **`tasks/plan.md`**.

| Ngày | Claude | Thịnh | Triết |
|------|--------|-------|-------|
| T2 26/10 | ✅ Đề cương, thiết kế, kế hoạch | ✅ Duyệt thiết kế | |
| T3 27/10 | Nội dung slide, sơ đồ, 4 script SQL | Đọc góp ý nội dung slide | **Cài SQL Server + SSMS**, đọc góp ý |
| T4 28/10 | Word: phần đầu, Ch1–2 | Chốt template slide | Chạy demo, chụp ảnh |
| T5 29/10 | Word: Ch3 | Dựng slide 1–9 | Dựng slide 10–17 |
| T6 30/10 | Word: Ch4–5, ghép .docx | Duyệt Word, tập dượt | Duyệt Word, tập dượt |
| T7 31/10 | | **Nộp slide** | |

## 6. Nhật ký

- **26/10/2026** — Tạo thư mục, lập kế hoạch. Chốt tên nhóm, deadline (T7 31/10), thời lượng 10–15 phút, DBMS SQL Server, Claude làm Word và nội dung slide. Viết `00_de_cuong.md` và `01_bai_toan_thiet_ke.md`.
- **26/10/2026 (2)** — Có GVHD và MSSV; sửa tên thành viên thành Phạm Minh Triết. Làm lại task breakdown và phân công theo skill planning-and-task-breakdown → `tasks/plan.md`, `tasks/todo.md`.
- **26/10/2026 (3)** — Xong T1 (`slides/noi_dung_slide.md`: 17 slide + lời thuyết trình + 8 câu hỏi Q&A), T3–T4 (`demo/sql/01`–`04`, `demo/README.md`, bộ sinh dữ liệu `demo/data/gen_demo_sql.py`). SQL mới kiểm bằng SQLite + parser, **chưa chạy trên SQL Server**.
- **26/10/2026 (4)** — Xong T2: 9 sơ đồ trong `assets/diagrams/` (sinh bằng `gen_diagrams.py`). Xong bản nháp 1 báo cáo Word `docs/BaoCao_PhanManhHonHop.docx` + `.pdf`: 59 trang (bìa + 9 trang đầu + 41 trang nội dung + 8 trang phụ lục). Nội dung soạn trong `docs/draft/*.md`; build bằng `docs/build/build_docx.js`, rồi chạy `finalize_word.ps1` (MS Word cập nhật mục lục, xuất PDF). Còn thiếu: 6 ảnh demo (đánh dấu vàng `[ẢNH: …]`), logo HUTECH, tên lớp. Bảng 4.7–4.10 và kết quả kiểm tra trong Ch4 là số liệu tính trước từ dữ liệu, **cần đối chiếu sau khi Triết chạy demo**.

- **29/10/2026** — Claude dựng luôn file slide (thay cho T6, T7 nhóm tự dựng): `slides/Slide_PhanManhHonHop.pptx` + `.pdf`, 17 slide 16:9, lời thuyết trình nằm sẵn trong Notes. Build bằng `slides/build/build_pptx.js` (đọc Notes từ `noi_dung_slide.md`, hình từ `assets/diagrams/`); `slides/build/render.ps1` xuất PNG/PDF qua PowerPoint để soát. Còn thiếu: 4 khung ảnh demo ở slide 15 (nét đứt, ghi tên file cần chèn), logo HUTECH ở bìa (chưa chèn). Báo cáo Word không đổi so với bản nháp 1 (26/10). Vẫn chưa ai chạy SQL trên SQL Server, nên "13/13 ĐẠT" ở slide 15 và các bảng số liệu Ch4 **chưa được kiểm chứng**.
- **29/10/2026 (2)** — Chốt học vị GVHD: **Th.S Nguyễn Văn Danh**. Sửa ở bìa và lời cảm ơn của Word, bìa slide, nội dung slide, README, kế hoạch; build lại `.docx`, `.pptx` và cả hai `.pdf`.
