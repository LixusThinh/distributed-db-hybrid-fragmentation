# LỜI MỞ ĐẦU

## Lý do chọn đề tài

Các doanh nghiệp hiện nay thường hoạt động trên nhiều địa điểm: trụ sở chính, chi nhánh ở nhiều tỉnh thành, kho hàng, cửa hàng. Nếu toàn bộ dữ liệu đặt tập trung tại một máy chủ, mọi giao dịch ở chi nhánh đều phải gửi về trung tâm. Điều đó làm tăng thời gian phản hồi và tải trên đường truyền, và cả hệ thống ngừng hoạt động khi máy chủ trung tâm gặp sự cố. Cơ sở dữ liệu phân tán giải quyết vấn đề này bằng cách đặt dữ liệu tại nhiều site, gần nơi dữ liệu được sử dụng, nhưng vẫn cho người dùng thấy như một cơ sở dữ liệu thống nhất.

Vấn đề cốt lõi khi thiết kế cơ sở dữ liệu phân tán là **phân mảnh**: chia mỗi quan hệ thành những phần nhỏ hơn để đặt ở các site khác nhau. Phân mảnh ngang chia theo dòng, phân mảnh dọc chia theo cột. Tuy nhiên, trong thực tế, các nhóm người dùng thường vừa chỉ quan tâm đến một số dòng, vừa chỉ quan tâm đến một số cột. Khi đó, chỉ dùng một kiểu phân mảnh là không đủ, và **phân mảnh hỗn hợp**, tức là kết hợp cả hai kiểu, là lựa chọn phù hợp.

Bài toán quản lý đơn hàng của một công ty có nhiều chi nhánh là ví dụ điển hình. Chi nhánh chỉ làm việc với khách hàng và đơn hàng của mình. Phòng kế toán ở trụ sở cần thông tin công nợ của khách hàng ở mọi chi nhánh. Phòng nhân sự quản lý dữ liệu lương nhạy cảm, không được để lộ ra chi nhánh. Vì vậy nhóm chọn đề tài **"Tìm hiểu Phân mảnh hỗn hợp trong CSDL Phân tán và ứng dụng cho quản lý đơn hàng"** để vừa nắm vững lý thuyết, vừa thấy được cách áp dụng vào một bài toán cụ thể.

## Mục tiêu đề tài

- Trình bày các khái niệm cơ bản về cơ sở dữ liệu phân tán và bài toán thiết kế phân tán.
- Tìm hiểu các kiểu phân mảnh ngang, dọc và các quy tắc đúng đắn của phân mảnh.
- Tìm hiểu sâu về phân mảnh hỗn hợp: định nghĩa, hai chiến lược HV và VH, cây phân mảnh, cách tái thiết và kiểm tra tính đúng đắn.
- Thiết kế phân mảnh hỗn hợp và cấp phát cho hệ thống quản lý đơn hàng, sau đó cài đặt thực nghiệm trên SQL Server.
