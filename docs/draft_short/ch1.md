# CHƯƠNG 1. TỔNG QUAN VỀ CƠ SỞ DỮ LIỆU PHÂN TÁN

## 1.1 Khái niệm cơ sở dữ liệu phân tán

Theo Özsu và Valduriez [1], **cơ sở dữ liệu phân tán** (CSDLPT) là một tập hợp nhiều cơ sở dữ liệu có liên quan với nhau về mặt logic, được phân bố trên các nút của một mạng máy tính. **Hệ quản trị cơ sở dữ liệu phân tán** (DDBMS) là phần mềm quản lý CSDLPT, đồng thời làm cho sự phân tán trở nên **trong suốt** đối với người dùng.

Từ định nghĩa trên, có thể rút ra hai đặc điểm quan trọng:

- **Phân tán về vật lý:** dữ liệu không nằm trên một máy mà được lưu tại nhiều *site*. Mỗi site có hệ quản trị CSDL cục bộ, có khả năng xử lý độc lập, và các site trao đổi dữ liệu qua mạng.
- **Thống nhất về logic:** dữ liệu ở các site không rời rạc mà thuộc về cùng một lược đồ toàn cục. Một tập hợp file đặt rải rác trên nhiều máy, hay nhiều CSDL độc lập không liên quan đến nhau, đều không phải là CSDLPT.

## 1.2 So sánh CSDL tập trung và CSDL phân tán

Trong mô hình tập trung, toàn bộ dữ liệu đặt tại một máy chủ, các máy khách ở xa truy cập qua mạng. Mô hình này đơn giản nhưng có những hạn chế rõ ràng khi tổ chức trải rộng về địa lý. Bảng 1.1 so sánh hai mô hình theo các tiêu chí chính.

Bảng: So sánh CSDL tập trung và CSDL phân tán
| Tiêu chí | CSDL tập trung | CSDL phân tán |
|---|---|---|
| Vị trí dữ liệu | Một máy chủ duy nhất | Nhiều site nối mạng |
| Truy cập từ chi nhánh | Luôn phải truy cập từ xa | Phần lớn truy cập cục bộ |
| Độ sẵn sàng | Máy chủ hỏng thì cả hệ thống dừng | Một site hỏng, các site khác vẫn hoạt động |
| Khả năng mở rộng | Nâng cấp máy chủ (mở rộng theo chiều dọc) | Thêm site mới (mở rộng theo chiều ngang) |
| Độ phức tạp | Thấp | Cao: thiết kế phân tán, truy vấn và giao dịch phân tán |
| Kiểm soát và bảo mật | Tập trung, dễ quản lý | Phải bảo vệ dữ liệu ở nhiều nơi và trên đường truyền |

## 1.3 Kiến trúc tham chiếu của CSDL phân tán

Kiến trúc tham chiếu của CSDLPT [1], [2] mô tả dữ liệu qua nhiều mức lược đồ:

- **Lược đồ toàn cục:** định nghĩa toàn bộ dữ liệu của hệ thống dưới dạng các quan hệ, giống như một CSDL tập trung. Người dùng và ứng dụng làm việc ở mức này.
- **Lược đồ phân mảnh:** mô tả cách mỗi quan hệ toàn cục được chia thành các mảnh, bằng các phép chọn (σ) và phép chiếu (π) của đại số quan hệ.
- **Lược đồ cấp phát:** xác định mỗi mảnh được đặt ở site nào. Một mảnh có thể được đặt ở một site (không nhân bản) hoặc ở nhiều site (nhân bản).
- **Lược đồ ánh xạ cục bộ:** ánh xạ các mảnh vật lý tại mỗi site sang các đối tượng của DBMS cục bộ, chẳng hạn bảng của SQL Server hoặc Oracle.

## 1.4 Tính trong suốt trong CSDL phân tán

Tính trong suốt nghĩa là người dùng không cần biết các chi tiết cài đặt của hệ thống phân tán. Có thể phân biệt các mức trong suốt sau, theo thứ tự từ cao xuống thấp:

- **Trong suốt phân mảnh:** người dùng truy vấn trên quan hệ toàn cục mà không cần biết quan hệ đó đã bị chia thành những mảnh nào. Đây là mức trong suốt cao nhất.
- **Trong suốt vị trí:** người dùng biết các mảnh nhưng không cần biết mỗi mảnh nằm ở site nào.
- **Trong suốt nhân bản:** người dùng không cần biết một mảnh có bao nhiêu bản sao, cũng không phải tự cập nhật từng bản sao.
- **Trong suốt ánh xạ cục bộ:** người dùng không cần biết mỗi site dùng hệ quản trị nào và lưu dữ liệu ra sao.

Mức trong suốt càng cao thì việc viết ứng dụng càng đơn giản, nhưng DDBMS phải đảm nhận nhiều việc hơn, ví dụ phải tự phân rã một truy vấn toàn cục thành các truy vấn trên từng mảnh. Trong thực nghiệm ở Chương 4, nhóm đạt được trong suốt phân mảnh và trong suốt vị trí bằng view và synonym của SQL Server.

## 1.5 Thiết kế cơ sở dữ liệu phân tán

Trong thiết kế từ trên xuống, sau khi có lược đồ toàn cục, người thiết kế phải giải quyết hai bài toán:

- **Phân mảnh:** chia mỗi quan hệ thành các mảnh sao cho mỗi mảnh chứa đúng phần dữ liệu mà một nhóm ứng dụng cần. Đây là nội dung chính của Chương 2 và Chương 3.
- **Cấp phát:** đặt các mảnh lên các site sao cho tối thiểu hóa chi phí truy cập và truyền thông, đồng thời đáp ứng yêu cầu về độ sẵn sàng. Có ba phương án: không nhân bản (mỗi mảnh ở đúng một site), nhân bản một phần, và nhân bản toàn phần.
