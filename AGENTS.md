# Quy tắc bắt buộc cho Codex

- Chỉ làm đúng task được giao; không tự mở rộng phạm vi.
- Không thêm chức năng, màn hình, module hoặc dependency ngoài bản kế hoạch.
- Giai đoạn nào thì chỉ làm đúng phạm vi giai đoạn đó; không tự bắt đầu giai đoạn tiếp theo.
- Không triển khai cloud, SaaS, web server nội bộ nhiều người dùng hoặc CLM.
- Không gửi hợp đồng, lịch sử rà soát, benchmark hoặc dữ liệu người dùng ra ngoài.
- Không analytics.
- Không telemetry.
- Không dùng CDN hoặc tải script từ internet trong luồng app.
- Không đưa gợi ý xử lý, khuyến nghị đàm phán hoặc kết luận thay luật sư.
- Không tạo nút giả, menu giả hoặc màn hình "coming soon" trong bản phát hành chính.
- Không sửa `releases/latest-version.json` trừ khi task được giao rõ là cập nhật manifest.
