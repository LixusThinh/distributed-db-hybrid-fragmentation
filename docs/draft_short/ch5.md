# CHƯƠNG 5. KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN

## 5.1 Kết quả đạt được

Về mặt lý thuyết, đồ án đã hệ thống hóa các kiến thức nền tảng về cơ sở dữ liệu phân tán: khái niệm, kiến trúc tham chiếu, các mức trong suốt và hai bài toán thiết kế là phân mảnh và cấp phát. Trọng tâm là phân mảnh hỗn hợp: định nghĩa, hai chiến lược HV và VH cùng điều kiện để chúng tương đương, cây phân mảnh, công thức tái thiết, chứng minh tính đúng đắn, và ảnh hưởng của phân mảnh hỗn hợp đến cấp phát, xử lý truy vấn và giao dịch.

Về mặt ứng dụng, nhóm đã thiết kế CSDL phân tán cho hệ thống quản lý đơn hàng của một công ty có ba chi nhánh và một trụ sở: KhachHang theo chiến lược HV, NhanVien theo chiến lược VH, DonHang và ChiTietDonHang theo phân mảnh dẫn xuất, ChiNhanh và SanPham được nhân bản toàn phần. Thiết kế được cài đặt trên SQL Server với các view tái thiết đảm bảo trong suốt phân mảnh và vị trí, bộ truy vấn kiểm tra tự động ba quy tắc đúng đắn, các truy vấn minh họa và một giao dịch phân tán có kiểm tra hạn mức.

Qua đề tài, nhóm rút ra rằng phân mảnh hỗn hợp phát huy hiệu quả khi các nhóm người dùng khác nhau cần những phần dữ liệu khác nhau **cả theo dòng lẫn theo cột**. Lựa chọn giữa HV và VH phụ thuộc vào tiêu chí nào phân biệt các ứng dụng rõ hơn và phần dữ liệu nào không cần chia tiếp. Thiết kế phân mảnh luôn là sự đánh đổi giữa tính cục bộ của truy vấn và chi phí của cập nhật phân tán.

## 5.2 Hạn chế

- Thực nghiệm mô phỏng các site bằng nhiều CSDL trên cùng một máy chủ, chưa phản ánh độ trễ và sự cố mạng thực tế.
- Tần suất truy cập của các ứng dụng là giả định, chưa thu thập từ hệ thống thật.
- Chưa cài đặt cơ chế đồng bộ tự động cho các bản nhân bản, cũng như quy trình di chuyển dữ liệu khi khách hàng chuyển chi nhánh.

## 5.3 Hướng phát triển

- Triển khai trên nhiều máy thật nối bằng Linked Server, sử dụng MSDTC cho giao dịch phân tán, và đo thời gian phản hồi của các truy vấn cục bộ và toàn cục.
- Dùng SQL Server Replication để đồng bộ tự động các bản nhân bản ChiNhanh và SanPham.
- So sánh định lượng các phương án: phân mảnh ngang thuần, phân mảnh dọc thuần và phân mảnh hỗn hợp, trên cùng tập ứng dụng và dữ liệu lớn hơn.
