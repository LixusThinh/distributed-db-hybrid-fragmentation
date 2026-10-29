# Demo phân mảnh hỗn hợp trên SQL Server

## Cần cài
- SQL Server 2019 hoặc 2022, bản **Developer** hoặc **Express** (miễn phí)
- SQL Server Management Studio (SSMS)

## Chạy theo thứ tự (mở từng file trong SSMS → F5)

| # | File | Làm gì | Kết quả mong đợi |
|---|------|--------|------------------|
| 1 | `sql/01_global_schema.sql` | Tạo `QLDH_GOC` (lược đồ toàn cục) + dữ liệu mẫu | Bảng cuối: ChiNhanh 3, KhachHang 30, NhanVien 12, SanPham 10, DonHang 45, ChiTietDonHang 97 |
| 2 | `sql/02_fragments.sql` | Tạo 4 site `QLDH_TRUSO`, `QLDH_HN`, `QLDH_DN`, `QLDH_HCM` và đổ dữ liệu vào các mảnh | Bảng cuối có 16 dòng: mỗi KH_i_GD / KH_i_TC 10, NV_CV_i 4, DH_i 15, CTDH 29 / 37 / 31, NV_NS 12 |
| 3 | `sql/03_reconstruct_check.sql` | Synonym + view tái thiết + kiểm tra 3 quy tắc đúng đắn | 13 dòng, tất cả **ĐẠT** |
| 4 | `sql/04_queries.sql` | Truy vấn cục bộ, toàn cục, giao dịch phân tán | Kết quả mong đợi ghi trong comment ngay trên từng truy vấn |

Chạy lại từ bước nào thì chạy tiếp các bước sau. Ví dụ chạy lại 02 thì phải chạy lại 03 và 04.

## Ảnh cần chụp → `../assets/screenshots/`

| Tên file | Chụp gì |
|----------|---------|
| `demo_01_object_explorer.png` | Object Explorer mở rộng 5 database và các bảng mảnh |
| `demo_02_so_dong_manh.png` | Bảng tổng kết số dòng ở cuối `02` |
| `demo_03_manh_GD_TC.png` | `SELECT * FROM QLDH_HN.dbo.KH_1_GD` và `SELECT * FROM QLDH_TRUSO.dbo.KH_1_TC` đặt cạnh nhau |
| `demo_04_view_tai_thiet.png` | Kết quả `SELECT TOP (6) * FROM v_KhachHang` |
| `demo_05_kiem_tra_dung_dan.png` | Bảng 13 dòng ĐẠT ở cuối `03` |
| `demo_06_truy_van_cuc_bo.png` | Q2 tại S1 |
| `demo_07_truy_van_toan_cuc.png` | Q6a hoặc Q3b |
| `demo_08_giao_dich.png` | Phần D: công nợ trước/sau, thông báo lỗi 50002 |

## Lỗi hay gặp
- **Tiếng Việt bị lỗi font trong SSMS:** file đã lưu UTF-8 có BOM. Nếu vẫn lỗi thì vào File → Save As → Save with Encoding → *Unicode (UTF-8 with signature)*.
- **"Cannot drop database because it is currently in use":** đóng các tab query đang `USE` database đó, hoặc chuyển ô chọn database trên thanh công cụ về `master`.
- **`CREATE OR ALTER` / `DROP ... IF EXISTS` báo lỗi:** SQL Server quá cũ (trước 2016 SP1), cần cài bản 2019 hoặc 2022.

## Sinh lại dữ liệu
`python demo/data/gen_demo_sql.py` sẽ sinh lại `01`, `02` và các file CSV. Dữ liệu cố định theo seed, nên chạy lại vẫn ra đúng như cũ.
