# CHƯƠNG 1. TỔNG QUAN VỀ CƠ SỞ DỮ LIỆU PHÂN TÁN

## 1.1 Khái niệm cơ sở dữ liệu phân tán

Theo Özsu và Valduriez [1], **cơ sở dữ liệu phân tán** (CSDLPT) là một tập hợp nhiều cơ sở dữ liệu có liên quan với nhau về mặt logic, được phân bố trên các nút của một mạng máy tính. **Hệ quản trị cơ sở dữ liệu phân tán** (DDBMS) là phần mềm quản lý CSDLPT, đồng thời làm cho sự phân tán trở nên **trong suốt** đối với người dùng.

Từ định nghĩa trên, có thể rút ra hai đặc điểm quan trọng:

- **Phân tán về vật lý:** dữ liệu không nằm trên một máy mà được lưu tại nhiều *site*. Mỗi site có hệ quản trị CSDL cục bộ, có khả năng xử lý độc lập, và các site trao đổi dữ liệu qua mạng.
- **Thống nhất về logic:** dữ liệu ở các site không rời rạc mà thuộc về cùng một lược đồ toàn cục. Một tập hợp file đặt rải rác trên nhiều máy, hay nhiều CSDL độc lập không liên quan đến nhau, đều không phải là CSDLPT.

Hình 1.1 minh họa một CSDLPT gồm bốn site. Người dùng làm việc với DDBMS như với một CSDL duy nhất; DDBMS chịu trách nhiệm xác định dữ liệu nằm ở site nào và phối hợp các site để trả lời truy vấn.

![Mô hình cơ sở dữ liệu phân tán gồm bốn site](assets/diagrams/kien_truc_CSDLPT.png)

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

**Ưu điểm** của CSDLPT gồm:

- **Dữ liệu đặt gần nơi sử dụng:** giảm thời gian phản hồi và lưu lượng mạng, vì đa số truy vấn được trả lời bằng dữ liệu cục bộ.
- **Tăng độ tin cậy và độ sẵn sàng:** khi dữ liệu được nhân bản, sự cố ở một site không làm gián đoạn toàn hệ thống.
- **Xử lý song song:** một truy vấn lớn có thể được tách thành nhiều truy vấn con chạy đồng thời trên các site.
- **Phù hợp với cơ cấu tổ chức:** mỗi đơn vị quản lý dữ liệu của mình nhưng vẫn chia sẻ được với toàn tổ chức.
- **Dễ mở rộng:** khi mở thêm chi nhánh chỉ cần bổ sung site mới.

Bên cạnh đó, CSDLPT cũng có những **nhược điểm**: thiết kế phức tạp hơn; xử lý truy vấn và giao dịch phải tính đến chi phí truyền thông; việc đảm bảo nhất quán giữa các bản nhân bản và thực hiện giao dịch trên nhiều site đòi hỏi các giao thức như cam kết hai pha (2PC); chi phí quản trị cao hơn.

## 1.3 Kiến trúc tham chiếu của CSDL phân tán

Kiến trúc tham chiếu của CSDLPT [1], [2] mô tả dữ liệu qua nhiều mức lược đồ (Hình 1.2):

- **Lược đồ toàn cục:** định nghĩa toàn bộ dữ liệu của hệ thống dưới dạng các quan hệ, giống như một CSDL tập trung. Người dùng và ứng dụng làm việc ở mức này.
- **Lược đồ phân mảnh:** mô tả cách mỗi quan hệ toàn cục được chia thành các mảnh, bằng các phép chọn (σ) và phép chiếu (π) của đại số quan hệ.
- **Lược đồ cấp phát:** xác định mỗi mảnh được đặt ở site nào. Một mảnh có thể được đặt ở một site (không nhân bản) hoặc ở nhiều site (nhân bản).
- **Lược đồ ánh xạ cục bộ:** ánh xạ các mảnh vật lý tại mỗi site sang các đối tượng của DBMS cục bộ, chẳng hạn bảng của SQL Server hoặc Oracle.

Ba mức trên cùng không phụ thuộc vào vị trí và hệ quản trị cụ thể; mức ánh xạ cục bộ phụ thuộc vào từng site. Sự tách biệt này là cơ sở để đạt được tính trong suốt.

![Các mức lược đồ trong kiến trúc tham chiếu của CSDL phân tán](assets/diagrams/muc_luoc_do_CSDLPT.png)

## 1.4 Tính trong suốt trong CSDL phân tán

Tính trong suốt nghĩa là người dùng không cần biết các chi tiết cài đặt của hệ thống phân tán. Có thể phân biệt các mức trong suốt sau, theo thứ tự từ cao xuống thấp:

- **Trong suốt phân mảnh:** người dùng truy vấn trên quan hệ toàn cục mà không cần biết quan hệ đó đã bị chia thành những mảnh nào. Đây là mức trong suốt cao nhất.
- **Trong suốt vị trí:** người dùng biết các mảnh nhưng không cần biết mỗi mảnh nằm ở site nào.
- **Trong suốt nhân bản:** người dùng không cần biết một mảnh có bao nhiêu bản sao, cũng không phải tự cập nhật từng bản sao.
- **Trong suốt ánh xạ cục bộ:** người dùng không cần biết mỗi site dùng hệ quản trị nào và lưu dữ liệu ra sao.

Mức trong suốt càng cao thì việc viết ứng dụng càng đơn giản, nhưng DDBMS phải đảm nhận nhiều việc hơn, ví dụ phải tự phân rã một truy vấn toàn cục thành các truy vấn trên từng mảnh. Trong thực nghiệm ở Chương 4, nhóm đạt được trong suốt phân mảnh và trong suốt vị trí bằng view và synonym của SQL Server.

## 1.5 Thiết kế cơ sở dữ liệu phân tán

### 1.5.1 Hai hướng tiếp cận

- **Thiết kế từ trên xuống (top-down):** xuất phát từ yêu cầu của hệ thống, xây dựng lược đồ toàn cục, sau đó thiết kế phân mảnh và cấp phát, cuối cùng là lược đồ cục bộ tại mỗi site. Hướng này phù hợp khi xây dựng hệ thống mới, và cũng là hướng đề tài áp dụng.
- **Thiết kế từ dưới lên (bottom-up):** khi đã có sẵn nhiều CSDL độc lập, cần tích hợp chúng thành một lược đồ toàn cục chung. Hướng này thường gặp khi hợp nhất các hệ thống có sẵn.

### 1.5.2 Hai bài toán chính: phân mảnh và cấp phát

Trong thiết kế từ trên xuống, sau khi có lược đồ toàn cục, người thiết kế phải giải quyết hai bài toán:

- **Phân mảnh:** chia mỗi quan hệ thành các mảnh sao cho mỗi mảnh chứa đúng phần dữ liệu mà một nhóm ứng dụng cần. Đây là nội dung chính của Chương 2 và Chương 3.
- **Cấp phát:** đặt các mảnh lên các site sao cho tối thiểu hóa chi phí truy cập và truyền thông, đồng thời đáp ứng yêu cầu về độ sẵn sàng. Có ba phương án: không nhân bản (mỗi mảnh ở đúng một site), nhân bản một phần, và nhân bản toàn phần.

Cả hai bài toán đều cần thông tin đầu vào về dữ liệu và ứng dụng: các truy vấn chính, thuộc tính và vị từ mà chúng sử dụng, nơi phát sinh, tần suất thực hiện. Phân mảnh tốt mà cấp phát không hợp lý thì vẫn phát sinh nhiều truy cập từ xa, nên hai bài toán phải được xem xét cùng nhau.

## 1.6 Kết chương

Chương 1 đã trình bày khái niệm, ưu nhược điểm, kiến trúc tham chiếu và các mức trong suốt của CSDL phân tán, cùng hai bài toán thiết kế là phân mảnh và cấp phát. Chương 2 sẽ đi vào chi tiết bài toán phân mảnh với hai kiểu cơ bản là phân mảnh ngang và phân mảnh dọc.
