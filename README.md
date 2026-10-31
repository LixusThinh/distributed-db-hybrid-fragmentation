# Phân mảnh hỗn hợp trong CSDL phân tán – ứng dụng cho quản lý đơn hàng

Đồ án môn **Cơ Sở Dữ Liệu Nâng Cao** 
GVHD: ThS. Nguyễn Văn Danh · Nhóm: Trần Gia Thịnh (2380602136), Phạm Minh Triết (2380605829).

## Nội dung

| Thư mục | Nội dung |
|---------|----------|
| `docs/` | Đề cương, thiết kế bài toán, báo cáo Word (`BaoCao_PhanManhHonHop_final.docx` / `.pdf`; bản < 30 trang: `BaoCao_PhanManhHonHop_cutfinal.docx` / `.pdf`) |
| `docs/draft/` | Nội dung báo cáo dạng Markdown, `docs/build/` dựng ra file .docx |
| `demo/` | Script SQL Server: lược đồ toàn cục, tạo mảnh, view tái thiết, kiểm tra đúng đắn, truy vấn – xem `demo/README.md` |
| `assets/diagrams/` | Sơ đồ (PNG + SVG), sinh bằng `gen_diagrams.py` |
| `slides/` | Nội dung slide + lời thuyết trình (`noi_dung_slide.md`) và file trình chiếu |
| `PLAN.md`, `tasks/` | Kế hoạch, phân công, nhật ký |

## Dựng lại tài liệu

```bash
cd docs/build && npm install && node build_docx.js          # báo cáo Word
pwsh -File docs/build/finalize_word.ps1                      # cập nhật mục lục, xuất PDF (cần MS Word)
cd slides/build && npm install && node build_pptx.js         # file slide
```
