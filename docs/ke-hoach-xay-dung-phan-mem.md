# KẾ HOẠCH CHI TIẾT XÂY DỰNG PHẦN MỀM RÀ SOÁT HỢP ĐỒNG

## 1. Mục tiêu xây dựng phần mềm

### 1.1. Mục tiêu sản phẩm

Xây dựng phần mềm Rà soát hợp đồng dưới dạng ứng dụng desktop chạy trên Windows, phục vụ luật sư/pháp chế trong việc rà soát hợp đồng theo bộ tiêu chí pháp lý có cấu trúc.

Phần mềm phải cho phép người dùng:

Chọn file hợp đồng DOCX.

Chọn loại hợp đồng / bộ tiêu chí.

Chạy rà soát trên máy người dùng.

Xem kết quả theo nhóm tiêu chí.

Xem trạng thái từng tiêu chí: Đạt / Thiếu / Cần rà soát / Rủi ro.

Xem căn cứ đánh giá.

Xem đoạn trích liên quan nếu có.

Lưu lịch sử snapshot nếu bật lưu lịch sử.

Mở lại kết quả cũ mà không chấm lại.

Xuất báo cáo PDF / Excel cơ bản.

Chạy benchmark hàng loạt để kiểm thử engine.

Kiểm tra cập nhật phần mềm qua manifest GitHub.

### 1.2. Nguyên tắc sản phẩm bắt buộc

Phần mềm phải tuân thủ các nguyên tắc sau:

Chạy local trên máy người dùng.

Rà soát hợp đồng local/offline.

Không gửi hợp đồng ra ngoài.

Không gửi lịch sử rà soát ra ngoài.

Không gửi dữ liệu benchmark ra ngoài.

Không analytics.

Không telemetry.

Giao diện tiếng Việt.

Không phải cloud/SaaS.

Không phải hệ thống web nội bộ nhiều người dùng.

Không phải CLM.

Không thay luật sư quyết định hướng xử lý.

Không đưa gợi ý xử lý.

Không khuyến nghị đàm phán.

Phần mềm chỉ được kết nối mạng cho hai mục đích:

Kiểm tra có bản cập nhật hay không.

Tải bộ cài mới khi người dùng bấm Cập nhật.

Ngoài hai việc trên, phần mềm không được dùng mạng trong luồng rà soát hợp đồng.

## 2. Định danh phần mềm

### 2.1. Tên phần mềm

Tên hiển thị cho người dùng:

Rà soát hợp đồng

Tên kỹ thuật, tên repo, tên file cài đặt:

rasoathopdong

### 2.2. Tên bộ cài

Quy ước tên file bộ cài:

rasoathopdong-setup-[version].exe

Ví dụ:

rasoathopdong-setup-1.0.0.exe

rasoathopdong-setup-1.0.1.exe

rasoathopdong-setup-1.1.0.exe

### 2.3. Version

Dùng quy ước:

major.minor.patch

Ví dụ:

1.0.0

1.0.1

1.1.0

2.0.0

Phần mềm cần quản lý ba loại version:

App version

Engine version

Criteria catalog version

Người dùng phổ thông chỉ cần thấy:

Rà soát hợp đồng 1.0.0

Nhưng hệ thống nội bộ, lịch sử, benchmark và update phải lưu đủ:

App version

Engine version

Criteria catalog version

## 3. Phạm vi bản đầu

### 3.1. Luồng xương sống bắt buộc

Bản đầu phải chạy được trọn vẹn luồng sau:

Chọn file hợp đồng

→ Chọn bộ tiêu chí

→ Rà soát

→ Hiển thị kết quả theo nhóm tiêu chí

→ Lưu lịch sử snapshot

→ Xuất báo cáo cơ bản

→ Chạy benchmark cơ bản

Đây là luồng ưu tiên cao nhất. Mọi module khác phải phục vụ việc làm ổn định luồng này trước.

### 3.2. Bản đầu bắt buộc có

WPF + WebView2 shell.

Menu chính.

Rà soát một hợp đồng DOCX.

6 bộ tiêu chí gốc.

Nhóm tiêu chí.

Kết quả rà soát gom theo nhóm.

Bộ lọc kết quả.

Lịch sử snapshot.

Xuất báo cáo cơ bản: PDF và Excel.

Cài đặt gọn.

Khôi phục bộ tiêu chí mặc định.

Benchmark cơ bản: JSON / JSONL / CSV.

Kiểm tra cập nhật qua GitHub manifest.

Lưu trữ dữ liệu local bằng appdata.sqlite.

Bộ test tối thiểu cho file, rà soát, lịch sử, benchmark và update.

### 3.3. Chưa đưa vào bản đầu nếu chưa hoàn thiện

Các chức năng sau giữ trong kế hoạch nhưng không hiển thị như chức năng khả dụng nếu chưa làm xong:

So sánh bản trước / bản sau.

Word export.

SQLite benchmark history.

Dashboard benchmark phức tạp.

Kéo thả nhóm tiêu chí phức tạp.

Rule builder nhiều điều kiện.

Ký số bộ cài.

Nguyên tắc UI:

Chức năng nào chưa triển khai hoàn chỉnh thì không hiện như chức năng khả dụng trên UI.

Không dùng nút giả, menu giả hoặc màn hình “coming soon” trong bản phát hành chính.

### 3.4. Cách hiểu phạm vi triển khai

Để tránh nhầm giữa bản chạy thử nội bộ, bản đầu và phần nâng cao, phạm vi triển khai được hiểu như sau:

MVP kỹ thuật

MVP kỹ thuật là mốc phần mềm chạy được luồng chính để nghiệm thu nội bộ.

MVP kỹ thuật phải đạt tối thiểu:

Mở được app.

Chọn được file DOCX.

Chọn được bộ tiêu chí gốc.

Rà soát được hợp đồng.

Hiển thị kết quả theo nhóm tiêu chí.

Có trạng thái Đạt / Thiếu / Cần rà soát / Rủi ro.

Có căn cứ đánh giá.

Có đoạn trích liên quan nếu tìm được.

Lưu được lịch sử snapshot.

Mở lịch sử không chạy lại engine.

Xuất được PDF cơ bản.

Xuất được Excel cơ bản.

Chạy được benchmark JSON / JSONL / CSV.

appdata.sqlite lưu được settings, criteria, history snapshot và update metadata.

Không có mạng thì app vẫn chạy bình thường.

Không hiển thị gợi ý xử lý hoặc khuyến nghị xử lý.

Bản 1.0 hoàn chỉnh

Bản 1.0 hoàn chỉnh nên hoàn thành các giai đoạn từ Giai đoạn 0 đến Giai đoạn 7 trong kế hoạch này, gồm:

Nền desktop Windows.

Rà soát một hợp đồng DOCX.

Bộ tiêu chí gốc.

Bộ tiêu chí tùy chỉnh.

Lịch sử snapshot.

Xuất PDF / Excel cơ bản.

Benchmark JSON / JSONL / CSV.

Migration dữ liệu local.

Cơ chế cập nhật phần mềm.

Đóng gói bản cài Windows.

Giai đoạn nâng cao

Giai đoạn 8 là phần nâng cao, không thuộc điều kiện bắt buộc để chốt bản đầu.

Giai đoạn nâng cao gồm:

Word export.

So sánh bản trước / bản sau.

SQLite benchmark history.

Update Helper hoàn thiện hơn.

Ký số bộ cài.

Cải thiện parser.

Cải thiện evidence selector.

## 4. Kiến trúc tổng thể

### 4.1. Công nghệ chính

WPF: desktop shell.

WebView2: render giao diện người dùng.

.NET: application services, engine, storage, export, update.

SQLite local: lưu dữ liệu nội bộ của app.

### 4.2. Vai trò của WPF

WPF phụ trách:

Cửa sổ chính.

Menu.

Chọn file.

Chọn thư mục.

Chọn nơi lưu báo cáo.

Khởi chạy bộ cài cập nhật.

Tích hợp với Windows.

Host WebView2.

### 4.3. Vai trò của WebView2

WebView2 phụ trách hiển thị UI:

Màn hình Tổng quan.

Màn hình Rà soát hợp đồng.

Màn hình Kết quả.

Màn hình Bộ tiêu chí.

Màn hình Lịch sử.

Màn hình Benchmark.

Màn hình Cài đặt.

Nguyên tắc WebView2:

Chỉ dùng tài nguyên local đóng gói cùng phần mềm.

Không CDN.

Không tải script từ internet.

Không analytics.

Không telemetry.

### 4.4. Vai trò của .NET Application / Engine

.NET phụ trách:

Đọc hợp đồng.

Tách nội dung.

Áp bộ tiêu chí.

Tìm đoạn liên quan.

Đánh trạng thái tiêu chí.

Đánh mức rủi ro nếu có.

Gom kết quả theo nhóm.

Lưu lịch sử.

Xuất báo cáo.

Chạy benchmark.

Kiểm tra cập nhật.

## 5. Cấu trúc module kỹ thuật

### 5.1. UI Layer

Module:

WPF Shell

WebView2 Host

Navigation

Theme Toggle

File Picker

Folder Picker

Save Dialog

Update Notification Dialog

Nhiệm vụ:

Tạo cửa sổ chính.

Hiển thị menu.

Điều hướng giữa các màn hình.

Nhận thao tác chọn file/chọn thư mục.

Gửi yêu cầu từ UI tới Application Layer.

Hiển thị kết quả trả về.

Hiển thị thông báo cập nhật khi có bản mới.

### 5.2. Application Layer

Bản đầu gồm:

ReviewService

CriteriaService

HistoryService

ExportService

BenchmarkService

SettingsService

UpdateService

Giai đoạn sau:

CompareService

Nhiệm vụ:

Điều phối luồng rà soát một hợp đồng.

Điều phối đọc bộ tiêu chí.

Điều phối lưu/mở lịch sử.

Điều phối xuất báo cáo.

Điều phối benchmark.

Điều phối cài đặt.

Điều phối cập nhật phần mềm.

### 5.3. Criteria Layer

Module:

CriteriaSet

CriteriaGroup

CriteriaItem

CriteriaRepository

CriteriaValidator

CriteriaRestoreService

CriteriaVersionService

Nhiệm vụ:

Lưu bộ tiêu chí gốc.

Lưu bộ tiêu chí tùy chỉnh.

Bảo vệ bộ tiêu chí gốc không bị sửa trực tiếp.

Tạo bộ tiêu chí tùy chỉnh từ bộ gốc.

Sửa/xóa bộ tiêu chí tùy chỉnh.

Thêm/sửa/xóa/sao chép tiêu chí trong bộ tùy chỉnh.

Quản lý nhóm tiêu chí.

Quản lý version bộ tiêu chí gốc.

Xóa bộ tùy chỉnh cũ khi bộ gốc đổi version.

Khôi phục bộ tiêu chí mặc định.

### 5.4. Engine Layer

Module:

DocumentReader

TextExtractor

ClauseExtractor

CriteriaMatcher

EvidenceSelector

RiskEvaluator

DecisionEngine

Nhiệm vụ:

Đọc file DOCX.

Tách nội dung văn bản.

Tách hoặc nhận diện đoạn/điều khoản liên quan.

Áp tiêu chí.

Tìm căn cứ đánh giá.

Tìm đoạn trích liên quan.

Xác định trạng thái tiêu chí.

Xác định mức rủi ro nếu có.

### 5.5. Result Layer

Module:

ReviewResult

ResultSummary

ResultGroup

ResultCriterion

Nhiệm vụ:

Lưu kết quả tổng quan.

Gom kết quả theo nhóm tiêu chí.

Tính số Đạt / Thiếu / Cần rà soát / Rủi ro toàn hợp đồng.

Tính số Đạt / Thiếu / Cần rà soát / Rủi ro theo từng nhóm.

Cung cấp dữ liệu cho UI, history, export và benchmark.

### 5.6. Export Layer

Bản đầu:

PdfExporter

ExcelExporter

JsonExporter

JsonlExporter

CsvExporter

Giai đoạn sau:

WordExporter

SQLiteBenchmarkWriter

Phân biệt rõ:

Báo cáo người dùng:

PDF

Excel

Word sau

Dữ liệu benchmark:

JSON

JSONL

CSV

SQLite benchmark history sau

### 5.7. Update Layer

Module:

UpdateService

UpdateManifestClient

VersionComparer

InstallerDownloader

InstallerVerifier

InstallerRunner

TemporaryInstallerCleaner

Nhiệm vụ:

Kiểm tra cập nhật tối đa 1 lần/ngày.

Tải manifest JSON vào bộ nhớ.

Timeout sau 10 giây.

So sánh version.

Bỏ qua im lặng nếu manifest lỗi.

Hiện thông báo khi có bản mới.

Chỉ tải installer khi người dùng bấm Cập nhật.

Kiểm tra SHA-256.

Chạy installer.

Xóa file tạm.

### 5.8. Storage Layer

Module:

SettingsStorage

CriteriaStorage

HistoryStorage

BenchmarkOutputStorage

UpdateMetadataStorage

LocalLogStorage

MigrationService

Nhiệm vụ:

Lưu settings.

Lưu criteria.

Lưu history snapshot.

Lưu update metadata.

Lưu log nội bộ local nếu cần.

Tạo appdata.sqlite.

Quản lý schemaVersion.

Chạy migration khi schema thay đổi.

## 6. Thiết kế dữ liệu local

### 6.1. Thư mục dữ liệu local

Thư mục đề xuất:

%LocalAppData%\rasoathopdong

Nguyên tắc:

Không dùng cloud storage.

Không đồng bộ qua server.

Không gửi về GitHub.

Không mặc định lưu nguyên file hợp đồng gốc trong lịch sử.

### 6.2. File dữ liệu chính

File dữ liệu nội bộ:

appdata.sqlite

Dùng để lưu:

settings

criteria

history snapshot

update metadata

schema version

Cần phân biệt:

appdata.sqlite

là kho dữ liệu local của phần mềm.

benchmark_history.sqlite

là output kỹ thuật của Benchmark, để giai đoạn sau.

### 6.3. Bảng dữ liệu đề xuất trong appdata.sqlite

6.3.1. app_metadata

Lưu metadata hệ thống.

Trường đề xuất:

key

value

Dữ liệu cần có:

schemaVersion

appVersion

engineVersion

criteriaCatalogVersion

lastUpdateCheckAttemptDate

6.3.2. settings

Lưu cài đặt người dùng.

Trường đề xuất:

key

value

updatedAt

Settings cần lưu:

saveHistoryEnabled

benchmarkVisible

themeMode

Giá trị mặc định ban đầu:

saveHistoryEnabled = true

benchmarkVisible = false

themeMode = system hoặc light

Trong UI Cài đặt chỉ hiển thị:

Lưu lịch sử rà soát trên máy này: Bật / Tắt

Xóa lịch sử rà soát

Khôi phục bộ tiêu chí mặc định

Phiên bản phần mềm

Hiển thị Benchmark: Bật / Tắt

themeMode được lưu nội bộ nhưng không đặt trong Cài đặt, vì nút sáng/tối nằm ở góc dưới bên trái.

Dù mặc định lưu lịch sử là Bật, phần mềm không mặc định lưu nguyên file hợp đồng gốc. Lịch sử chỉ lưu snapshot kết quả và các đoạn trích liên quan nếu có.

Người dùng có thể tắt lưu lịch sử trong Cài đặt. Nếu tắt lưu lịch sử, phần mềm không lưu kết quả vào Lịch sử, nhưng người dùng vẫn có thể xuất báo cáo ngay tại màn hình kết quả sau khi rà soát.

6.3.3. criteria_sets

Lưu bộ tiêu chí.

Trường đề xuất:

id

name

contractType

type

parentBaseSetId

baseVersion

createdAt

updatedAt

Quy tắc:

type = base: bộ gốc, chỉ đọc.

type = custom: bộ tùy chỉnh, được sửa.

parentBaseSetId: chỉ có với bộ tùy chỉnh.

6.3.4. criteria_groups

Lưu nhóm tiêu chí.

Trường đề xuất:

id

criteriaSetId

name

description

groupOrder

6.3.5. criteria_items

Lưu tiêu chí nhỏ.

Trường đề xuất:

id

criteriaSetId

groupId

name

importance

description

checkType

checkInfo

passCondition

positiveExample

negativeExample

criteriaOrder

createdAt

updatedAt

6.3.6. history_results

Lưu lịch sử tổng quan.

Trường đề xuất:

resultId

taskType

contractFileName

contractType

criteriaSetName

criteriaSetVersion

appVersion

engineVersion

reviewedAt

totalCriteria

passedCount

missingCount

reviewNeededCount

riskCount

snapshotJson

snapshotJson lưu toàn bộ snapshot đủ để mở lại kết quả cũ mà không cần chạy engine.

6.3.7. local_logs

Lưu log nội bộ nếu cần.

Trường đề xuất:

id

createdAt

level

module

errorCode

message

Không lưu mặc định:

Toàn bộ nội dung hợp đồng.

Toàn bộ đoạn trích dài.

Dữ liệu nhạy cảm không cần thiết.

### 6.4. Chính sách dữ liệu khi gỡ cài đặt

Mặc định khi gỡ cài đặt phần mềm, không tự động xóa appdata.sqlite nếu người dùng không chọn xóa dữ liệu ứng dụng.

Dữ liệu local gồm settings, criteria, history snapshot và update metadata được lưu trong:

%LocalAppData%\rasoathopdong

Nếu cần xóa dữ liệu, phải có thao tác rõ ràng như:

Xóa lịch sử rà soát trong Cài đặt.

Khôi phục bộ tiêu chí mặc định.

Tùy chọn xóa dữ liệu ứng dụng khi gỡ cài đặt, nếu installer hỗ trợ.

Không tự động xóa dữ liệu người dùng một cách âm thầm.

Nếu installer có hỗ trợ tùy chọn xóa dữ liệu khi gỡ cài đặt, tùy chọn này phải được thể hiện rõ cho người dùng. Không được mặc định chọn xóa dữ liệu local nếu chưa có sự xác nhận rõ ràng.

Chính sách này áp dụng cho dữ liệu trong appdata.sqlite. Các báo cáo đã xuất ra thư mục riêng do người dùng chọn không thuộc dữ liệu ứng dụng nội bộ và không bị xóa bởi thao tác gỡ cài đặt phần mềm.

## 7. Thiết kế bộ tiêu chí

### 7.1. Loại bộ tiêu chí

Phần mềm có hai loại:

Bộ tiêu chí gốc

Bộ tiêu chí tùy chỉnh

### 7.2. Bộ tiêu chí gốc

Ban đầu có 6 bộ:

Hợp đồng dịch vụ

Thỏa thuận bảo mật / NDA

Hợp đồng mua bán

Hợp đồng thuê

Hợp đồng lao động

Hợp đồng BCC / hợp tác kinh doanh

Nguyên tắc:

Có sẵn theo phần mềm.

Có version.

Chỉ đọc.

Không sửa trực tiếp.

Không xóa.

Không sửa / xóa / sao chép trực tiếp tiêu chí bên trong.

Có thể dùng để rà soát.

Có thể tạo bản tùy chỉnh từ nó.

UI với bộ gốc chỉ có:

[Tùy chỉnh]

Không có:

[Sửa]

[Xóa]

[Sao chép]

### 7.3. Bộ tiêu chí tùy chỉnh

Nguyên tắc:

Được tạo từ bộ gốc.

Nằm ngay dưới bộ gốc.

Chỉ có một cấp, không tạo cây nhiều tầng.

Có thể đổi tên.

Có thể sửa.

Có thể xóa.

Có thể dùng để rà soát.

Có thể thêm / sửa / xóa / sao chép tiêu chí.

Ghi nhận version bộ gốc mà nó được tạo ra.

Cấu trúc đúng:

Hợp đồng dịch vụ

├── Hợp đồng dịch vụ - bản tùy chỉnh 01

└── Hợp đồng dịch vụ - bản tùy chỉnh phòng pháp chế

Không dùng:

Bộ gốc

└── Bộ tùy chỉnh

└── Bộ tùy chỉnh con

### 7.4. Cấu trúc một tiêu chí

Mỗi tiêu chí có 8 trường nội dung chính:

Tên tiêu chí

Mức độ

Mô tả

Kiểu kiểm tra

Thông tin kiểm tra

Điều kiện đạt

Ví dụ đạt

Ví dụ không đạt

Trường quản lý thêm:

id

groupId

groupName

groupOrder

criteriaOrder

createdAt

updatedAt

### 7.5. Mức độ

Bắt buộc

Khuyến nghị

### 7.6. Kiểu kiểm tra

Giữ đúng thứ tự:

Chứa ít nhất một từ khóa

Chứa tất cả từ khóa

Có mục/điều khoản

Có ngày tháng

Có số tiền

Có tên chủ thể

Từ khóa cấm

Rà soát thủ công

Biểu thức chính quy (Regex)

Độ dài tối thiểu

Độ dài tối đa

Nguyên tắc bản đầu:

Một tiêu chí chọn một kiểu kiểm tra chính.

Không làm rule builder nhiều điều kiện ở bản đầu.

Muốn kiểm nhiều ý thì tách thành nhiều tiêu chí.

## 8. Thiết kế màn hình

### 8.1. Menu chính

Khi Benchmark tắt:

Tổng quan

Rà soát hợp đồng

Bộ tiêu chí

Lịch sử

Cài đặt

Khi Benchmark bật:

Tổng quan

Rà soát hợp đồng

Bộ tiêu chí

Lịch sử

Benchmark

Cài đặt

### 8.2. Nút sáng/tối

Không đặt trong Cài đặt.

Đặt ở góc dưới bên trái.

Nếu đang dark mode:

☀ Chế độ sáng

Nếu đang light mode:

🌙 Chế độ tối

Chuyển ngay, không cần khởi động lại.

### 8.3. Màn hình Tổng quan

Hiển thị:

Số hợp đồng đã rà soát.

Số hợp đồng có rủi ro.

Số kết quả cần rà soát.

Lịch sử gần đây.

Nút Rà soát hợp đồng mới.

Không hiển thị:

Log kỹ thuật.

JSON.

JSONL.

SQLite.

Benchmark nếu Benchmark đang tắt.

### 8.4. Màn hình Rà soát một hợp đồng

Bản đầu chỉ làm:

Rà soát một hợp đồng

Luồng:

Người dùng chọn hoặc kéo thả file hợp đồng.

Người dùng chọn loại hợp đồng / bộ tiêu chí.

Người dùng bấm Rà soát.

Hệ thống đọc hợp đồng trên máy người dùng.

Hệ thống áp bộ tiêu chí.

Hệ thống sinh kết quả theo nhóm.

Hệ thống hiển thị kết quả.

Hệ thống lưu lịch sử snapshot nếu bật lưu lịch sử.

Người dùng có thể xuất báo cáo.

File đầu vào bản đầu:

DOCX

Mở rộng sau:

PDF

TXT

### 8.5. Màn hình Kết quả

Tổng quan hiển thị:

Loại hợp đồng

Bộ tiêu chí đã dùng

Phiên bản bộ tiêu chí

Tổng số tiêu chí

Số tiêu chí Đạt

Số tiêu chí Thiếu

Số tiêu chí Cần rà soát

Số tiêu chí Rủi ro

Nút xuất báo cáo

Bộ lọc:

Tất cả

Đạt

Thiếu

Cần rà soát

Rủi ro

Kết quả phải gom theo nhóm.

Mỗi nhóm có:

Tên nhóm

Tổng số tiêu chí trong nhóm

Số Đạt

Số Thiếu

Số Cần rà soát

Số Rủi ro

Trạng thái mở rộng / thu gọn

### 8.6. Hiển thị từng tiêu chí

Tiêu chí Đạt:

Tên tiêu chí

Trạng thái: Đạt

Căn cứ đánh giá

Đoạn trích liên quan, nếu có

Không hiển thị:

Mức rủi ro: Không có

Tiêu chí Thiếu:

Tên tiêu chí

Trạng thái: Thiếu

Căn cứ đánh giá

Không hiện đoạn trích nếu không có.

Tiêu chí Cần rà soát:

Tên tiêu chí

Trạng thái: Cần rà soát

Mức rủi ro, nếu có

Căn cứ đánh giá

Đoạn trích liên quan, nếu có

Tiêu chí Rủi ro:

Tên tiêu chí

Trạng thái: Rủi ro

Mức rủi ro

Căn cứ đánh giá

Đoạn trích liên quan

### 8.7. Màn hình Bộ tiêu chí

Hiển thị theo cây một cấp.

Ví dụ:

Hợp đồng dịch vụ

Bộ gốc · 22 tiêu chí

[Tùy chỉnh]

Hợp đồng dịch vụ - bản tùy chỉnh 01

Bộ tùy chỉnh · 24 tiêu chí

[Sửa] [Xóa]

Với bộ gốc:

Cho xem.

Cho tạo bản tùy chỉnh.

Không cho sửa trực tiếp.

Không cho xóa.

Không cho sửa/xóa/sao chép tiêu chí trực tiếp.

Với bộ tùy chỉnh:

Sửa tên bộ.

Xóa bộ.

Thêm tiêu chí.

Sửa tiêu chí.

Xóa tiêu chí.

Sao chép tiêu chí.

Chọn nhóm cho tiêu chí.

Chuyển tiêu chí sang nhóm khác.

### 8.8. Màn hình Lịch sử

Hiển thị:

Tên file hoặc tên kết quả

Loại tác vụ

Loại hợp đồng

Bộ tiêu chí đã dùng

Ngày thực hiện

Tổng số tiêu chí

Số Đạt

Số Thiếu

Số Cần rà soát

Số Rủi ro

Mở kết quả

Xuất lại báo cáo

Khi mở kết quả cũ:

Mở snapshot đã lưu.

Không chạy lại engine.

Không phụ thuộc bộ tiêu chí hiện tại.

Không cần đọc lại file hợp đồng gốc.

### 8.9. Màn hình Benchmark

Benchmark mặc định ẩn.

Khi bật, UI bản đầu:

Thư mục hợp đồng:

[Chọn thư mục]

Đã phát hiện: ... file DOCX

Thư mục lưu kết quả:

[Chọn thư mục]

Bộ tiêu chí:

[Chọn bộ tiêu chí ▼]

Định dạng kết quả:

[x] JSON từng hợp đồng

[x] JSONL toàn batch

[x] CSV thống kê

[Chạy benchmark]

SQLite chỉ hiện sau khi triển khai.

Cảnh báo:

Tất cả hợp đồng trong thư mục sẽ được rà soát bằng bộ tiêu chí đã chọn. Vui lòng bảo đảm thư mục chỉ chứa đúng loại hợp đồng tương ứng.

### 8.10. Màn hình Cài đặt

Hiển thị:

Cài đặt

- Lưu lịch sử rà soát trên máy này: Bật / Tắt

- Xóa lịch sử rà soát

- Khôi phục bộ tiêu chí mặc định

- Phiên bản phần mềm

- Hiển thị Benchmark: Bật / Tắt

Không đưa vào Cài đặt:

Ngôn ngữ giao diện.

Chế độ sáng/tối.

Thư mục lưu báo cáo mặc định.

Cấu hình export.

Log kỹ thuật.

Cache.

Runtime.

WebView2.

.NET.

GitHub URL.

## 9. Luồng xử lý chính

### 9.1. Luồng rà soát một hợp đồng

UI nhận file DOCX.

UI nhận criteriaSetId.

ReviewService kiểm tra file.

DocumentReader đọc file DOCX.

TextExtractor trích xuất nội dung.

CriteriaService lấy bộ tiêu chí.

DecisionEngine chạy từng tiêu chí.

CriteriaMatcher xác định tiêu chí có dấu hiệu đạt/thiếu/rủi ro.

EvidenceSelector tìm đoạn trích liên quan.

RiskEvaluator xác định mức rủi ro nếu có.

Result Layer gom kết quả theo nhóm.

UI hiển thị màn hình kết quả.

Nếu saveHistoryEnabled = true, HistoryService lưu snapshot.

Người dùng có thể xuất PDF/Excel.

### 9.2. Luồng xử lý file lỗi

Các trường hợp lỗi:

File không đọc được.

File sai định dạng.

File bị khóa.

File rỗng.

File DOCX lỗi.

Thông báo người dùng:

Không thể đọc file hợp đồng. Vui lòng kiểm tra lại file và thử lại.

Không hiển thị:

stack trace

log kỹ thuật

lỗi engine chi tiết

Trong Benchmark, file lỗi ghi vào:

failed_files.csv

### 9.3. Luồng lưu lịch sử

Sau khi có ReviewResult, kiểm tra saveHistoryEnabled.

Nếu bật, tạo snapshot đầy đủ.

Lưu history_results.

Không lưu nguyên file hợp đồng gốc mặc định.

Snapshot phải đủ để mở lại kết quả cũ.

Snapshot cần chứa:

Tên file

Loại tác vụ

Loại hợp đồng

Bộ tiêu chí đã dùng

Phiên bản bộ tiêu chí

Phiên bản app

Phiên bản engine

Ngày rà soát

Tổng quan kết quả

Nhóm tiêu chí

Danh sách tiêu chí trong từng nhóm

Trạng thái từng tiêu chí

Mức rủi ro nếu có

Căn cứ đánh giá

Đoạn trích liên quan nếu có

### 9.4. Luồng mở lịch sử

Người dùng chọn một dòng lịch sử.

HistoryService đọc snapshotJson.

UI dựng lại màn hình kết quả từ snapshot.

Không chạy lại engine.

Không đọc lại file hợp đồng gốc.

Không phụ thuộc bộ tiêu chí hiện tại.

### 9.5. Luồng xuất báo cáo

Xuất từ:

Màn hình kết quả rà soát.

Màn hình mở lại lịch sử.

Bản đầu:

PDF cơ bản

Excel cơ bản

Giai đoạn sau:

Word

Báo cáo gồm:

Thông tin hợp đồng

Loại hợp đồng

Bộ tiêu chí đã dùng

Phiên bản bộ tiêu chí

Ngày rà soát

Tổng quan kết quả

Kết quả theo nhóm tiêu chí

Danh sách tiêu chí trong từng nhóm

Trạng thái từng tiêu chí

Mức rủi ro, chỉ khi có

Căn cứ đánh giá

Đoạn trích liên quan, chỉ khi có

Báo cáo nên có dòng giới hạn ngắn:

Kết quả rà soát được tạo tự động theo bộ tiêu chí đã chọn và chỉ có giá trị hỗ trợ kiểm tra. Người dùng cần tự đánh giá lại trước khi sử dụng trong công việc pháp lý.

Dòng này không phải là gợi ý xử lý, không phải khuyến nghị đàm phán và không thay thế đánh giá của luật sư/pháp chế.

Không có:

Gợi ý xử lý

Khuyến nghị xử lý

Log kỹ thuật

JSON

Confidence score

## 10. Benchmark

### 10.1. Mục tiêu Benchmark

Benchmark dùng để:

Chạy hàng loạt hợp đồng.

Kiểm thử engine.

Regression test.

So sánh chất lượng qua phiên bản.

Benchmark không phải luồng người dùng phổ thông.

Mặc định:

Ẩn

Bật bằng:

Cài đặt → Hiển thị Benchmark: Bật

### 10.2. Luồng Benchmark

Người dùng chọn thư mục hợp đồng.

Hệ thống quét file DOCX.

Hệ thống đếm số file DOCX.

Người dùng chọn thư mục output.

Người dùng chọn bộ tiêu chí.

Người dùng chọn định dạng output.

Người dùng bấm Chạy benchmark.

BenchmarkService chạy từng file.

File nào lỗi thì ghi failed_files.csv.

File nào chạy được thì sinh ReviewResult.

Xuất JSON từng hợp đồng.

Ghi JSONL toàn batch.

Ghi CSV thống kê.

### 10.3. Output Benchmark bản đầu

benchmark-output/

manifest.json

results-json/

contract_001.result.json

contract_002.result.json

results-jsonl/

results.jsonl

summary-csv/

summary_by_contract.csv

summary_by_status.csv

summary_by_group.csv

risk_findings.csv

failed_files.csv

Giai đoạn sau thêm:

benchmark_history.sqlite

## 11. Cơ chế cập nhật phần mềm

### 11.1. Manifest URL

Đường dẫn cố định nội bộ:

https://raw.githubusercontent.com/ngotuannd92/rasoathopdong/main/releases/latest-version.json

Không hiển thị đường dẫn này trong UI người dùng phổ thông.

### 11.2. Manifest JSON

Cấu trúc:

```json
{
"latestVersion": "1.0.1",
"minimumSupportedVersion": "1.0.0",
"engineVersion": "1.0.1",
"criteriaCatalogVersion": "1.0.1",
"fileName": "rasoathopdong-setup-1.0.1.exe",
"installerUrl": "https://github.com/ngotuannd92/rasoathopdong/releases/download/v1.0.1/rasoathopdong-setup-1.0.1.exe",
"sha256": "...",
"releaseNotes": "Cập nhật bộ tiêu chí và sửa lỗi engine."
}
```

### 11.3. Quy tắc kiểm tra cập nhật

Kiểm tra khi mở phần mềm.

Chạy nền.

Không chặn giao diện.

Tối đa 1 lần/ngày.

Timeout 10 giây.

Manifest tải vào bộ nhớ.

Không lưu manifest xuống máy.

Kiểm tra xong thì giải phóng dữ liệu manifest.

Lưu nội bộ:

lastUpdateCheckAttemptDate

Ý nghĩa:

Ngày gần nhất phần mềm đã thử kiểm tra cập nhật, dù thành công hay thất bại.

### 11.4. Khi không có cập nhật hoặc lỗi

Các trường hợp:

Không có bản cập nhật.

Không có mạng.

GitHub không truy cập được.

Timeout quá 10 giây.

Manifest lỗi.

Manifest thiếu trường bắt buộc.

Version không hợp lệ.

Xử lý:

Không hiện thông báo.

Không báo lỗi.

Không làm phiền người dùng.

Phần mềm tiếp tục chạy bình thường.

### 11.5. Khi có cập nhật

Hiển thị:

Đã có bản cập nhật mới

Phiên bản hiện tại: 1.0.0

Phiên bản mới: 1.0.1

[Cập nhật] [Không cập nhật]

Nếu chọn Không cập nhật:

Không tải gì.

Không cài gì.

Không hỏi lại trong phiên hiện tại.

Không kiểm tra lại trong cùng ngày.

Nếu chọn Cập nhật:

Tải file .exe từ installerUrl.

Lưu tạm.

Kiểm tra SHA-256.

Nếu hợp lệ, khởi chạy quá trình cài đặt.

App chính đóng khi cần.

Cài xong, phần mềm mở lại.

Xóa file cài tạm.

Không hứa cài đặt im lặng hoàn toàn. Câu đúng:

Phần mềm tự tải, kiểm tra và khởi chạy quá trình cài đặt. Sau khi cài xong, phần mềm tự mở lại.

## 12. Migration dữ liệu local

### 12.1. Lý do cần migration

Vì phần mềm dùng:

appdata.sqlite

và sẽ có thay đổi theo version, cần có cơ chế migration để tránh hỏng dữ liệu người dùng.

### 12.2. Metadata tối thiểu

Trong appdata.sqlite cần có:

schemaVersion

appVersion

criteriaCatalogVersion

### 12.3. Luồng migration khi app khởi động

Mở appdata.sqlite.

Kiểm tra schemaVersion.

Nếu schema cũ, chạy migration.

Nếu schema hợp lệ, tiếp tục mở app.

### 12.4. Nguyên tắc migration

Không làm mất lịch sử.

Không làm mất settings.

Không làm mất dữ liệu benchmark output.

Không làm hỏng bộ tiêu chí gốc.

Nếu criteriaCatalogVersion đổi, xử lý theo cơ chế cập nhật bộ tiêu chí gốc.

Nếu migration lỗi:

Không hiện log kỹ thuật dài cho người dùng.

Hiển thị thông báo đơn giản.

Ghi log nội bộ local nếu cần.

Thông báo người dùng:

Không thể mở dữ liệu ứng dụng. Vui lòng khởi động lại phần mềm hoặc liên hệ bộ phận hỗ trợ.

## 13. Đóng gói, runtime và dependency

### 13.1. Nội dung cần quyết định

Khi lập kế hoạch triển khai, phải xác định:

App đóng gói self-contained hay phụ thuộc .NET Runtime có sẵn.

Cách xử lý WebView2 Runtime.

Bộ cài có cài kèm runtime cần thiết hay không.

Danh sách thư viện bên thứ ba.

License của thư viện bên thứ ba.

Cách build file rasoathopdong-setup-[version].exe.

### 13.2. Nguyên tắc dependency

Không dùng CDN.

Không tải thư viện UI từ internet khi chạy app.

Tài nguyên UI phải đóng gói local.

Thư viện bên thứ ba phải rõ nguồn gốc.

Không dùng thư viện không rõ license.

### 13.3. Runtime cần kiểm tra

.NET Runtime hoặc self-contained publish.

WebView2 Runtime.

SQLite.

Thư viện đọc DOCX.

Thư viện xuất PDF.

Thư viện xuất Excel.

### 13.4. Tiêu chí đóng gói bản cài

Bản cài đạt yêu cầu khi:

Cài được phần mềm trên Windows.

Mở được app sau khi cài.

Không thiếu WebView2 Runtime hoặc có cách xử lý rõ.

Bộ tiêu chí gốc có sẵn sau khi cài.

Tên file cài đặt đúng chuẩn.

Cài đặt xong chạy được luồng rà soát DOCX.

Có thể kiểm tra cập nhật từ bản cũ.

## 14. Kế hoạch triển khai theo giai đoạn

### Giai đoạn 0 — Khởi tạo nền

#### Mục tiêu

App mở được, menu chạy được, dữ liệu local tạo được.

#### Công việc

Tạo solution/project.

Tạo WPF shell.

Nhúng WebView2.

Tạo navigation.

Tạo layout cơ bản.

Tạo theme sáng/tối.

Tạo SettingsStorage.

Tạo cấu trúc thư mục dữ liệu local.

Tạo appdata.sqlite.

Tạo schemaVersion ban đầu.

#### Hoàn thành khi

Mở được app.

Chuyển được menu.

Chuyển được sáng/tối.

Không lỗi WebView2.

Đọc/ghi được settings local.

Tạo được appdata.sqlite.

### Giai đoạn 1 — Luồng rà soát một hợp đồng

#### Mục tiêu

Chạy được end-to-end luồng rà soát một hợp đồng DOCX.

#### Công việc

Tạo model CriteriaSet / CriteriaGroup / CriteriaItem.

Seed 6 bộ tiêu chí gốc.

Tạo DocumentReader cho DOCX.

Tạo TextExtractor.

Tạo ReviewService bản đầu.

Tạo CriteriaMatcher bản đầu.

Tạo EvidenceSelector bản đầu.

Tạo RiskEvaluator bản đầu.

Tạo DecisionEngine bản đầu.

Tạo màn hình Rà soát một hợp đồng.

Tạo màn hình Kết quả theo nhóm.

Tạo bộ lọc kết quả.

Xử lý file lỗi bằng thông báo đơn giản.

#### Hoàn thành khi

Chọn được DOCX.

Chọn được bộ tiêu chí.

Bấm Rà soát chạy được.

Kết quả có nhóm.

Có Đạt / Thiếu / Cần rà soát / Rủi ro.

Có căn cứ đánh giá.

Có đoạn trích nếu tìm được.

Tiêu chí Đạt không hiển thị mức rủi ro.

Không có gợi ý xử lý.

File lỗi được xử lý bằng thông báo đơn giản.

### Giai đoạn 2 — Lịch sử và xuất báo cáo

#### Mục tiêu

Rà soát xong lưu được snapshot và xuất được báo cáo cơ bản.

#### Công việc

Tạo HistoryService.

Tạo HistoryStorage.

Lưu history snapshot.

Mở lại kết quả cũ từ snapshot.

Đảm bảo mở lịch sử không chạy lại engine.

Đảm bảo mở lịch sử không cần file hợp đồng gốc.

Tạo PdfExporter.

Tạo ExcelExporter.

Tạo nút xuất báo cáo từ màn hình kết quả.

Tạo nút xuất lại báo cáo từ lịch sử.

#### Hoàn thành khi

Rà soát xong có thể lưu lịch sử.

Mở lịch sử thấy đúng kết quả cũ.

Bộ tiêu chí hiện tại thay đổi không làm sai lịch sử cũ.

Mở lịch sử không cần đọc lại file hợp đồng.

Xuất được PDF cơ bản.

Xuất được Excel cơ bản.

### Giai đoạn 3 — Bộ tiêu chí tùy chỉnh

#### Mục tiêu

Người dùng tạo và dùng được bộ tiêu chí tùy chỉnh từ bộ gốc.

#### Công việc

Tạo bộ tùy chỉnh từ bộ gốc.

Sửa tên bộ tùy chỉnh.

Xóa bộ tùy chỉnh.

Thêm tiêu chí.

Sửa tiêu chí.

Xóa tiêu chí.

Sao chép tiêu chí.

Chọn nhóm cho tiêu chí.

Chuyển tiêu chí sang nhóm khác.

Đảm bảo bộ gốc không sửa trực tiếp được.

#### Hoàn thành khi

Bộ gốc không sửa trực tiếp được.

Bộ tùy chỉnh sửa được.

Bộ tùy chỉnh dùng được để rà soát.

Xóa bộ tùy chỉnh không ảnh hưởng lịch sử.

### Giai đoạn 4 — Khôi phục, version bộ tiêu chí và migration

#### Mục tiêu

Quản lý được version bộ tiêu chí, khôi phục mặc định và migration dữ liệu.

#### Công việc

Lưu version bộ tiêu chí gốc.

Tạo CriteriaRestoreService.

Khôi phục bộ tiêu chí mặc định.

Xóa bộ tùy chỉnh khi khôi phục.

Nạp lại bộ gốc theo version app hiện tại.

Khi app cập nhật và criteriaCatalogVersion đổi, xóa bộ tùy chỉnh cũ.

Tạo MigrationService.

Kiểm tra schemaVersion khi mở app.

Chạy migration khi cần.

Hiển thị thông báo đơn giản nếu migration lỗi.

#### Hoàn thành khi

Khôi phục không xóa lịch sử.

Khôi phục không xóa benchmark.

Khôi phục không xóa báo cáo đã xuất.

Bộ gốc được nạp lại đúng.

Bộ tùy chỉnh cũ bị xóa đúng khi version bộ gốc đổi.

Migration không làm mất settings.

Migration không làm mất history snapshot.

### Giai đoạn 5 — Benchmark cơ bản

#### Mục tiêu

Chạy được benchmark nhiều DOCX và xuất JSON / JSONL / CSV.

#### Công việc

Bật/tắt Benchmark trong Cài đặt.

Chọn thư mục hợp đồng.

Đếm DOCX.

Chọn thư mục output.

Chọn bộ tiêu chí.

Chạy batch.

Xuất JSON từng hợp đồng.

Xuất JSONL toàn batch.

Xuất CSV thống kê.

Ghi failed_files.csv.

Ghi manifest.json cho lần benchmark.

#### Hoàn thành khi

Benchmark chạy được nhiều file.

File lỗi không làm dừng toàn bộ batch.

Có output JSON / JSONL / CSV.

Có summary_by_contract.csv.

Có summary_by_group.csv.

Có risk_findings.csv.

Có failed_files.csv nếu có lỗi.

### Giai đoạn 6 — Cập nhật phần mềm

#### Mục tiêu

Kiểm tra và cập nhật phần mềm an toàn, không làm phiền người dùng.

#### Công việc

Tạo UpdateManifestClient.

Đọc manifest vào bộ nhớ.

Timeout 10 giây.

Kiểm tra tối đa 1 lần/ngày.

Lưu lastUpdateCheckAttemptDate.

So sánh version.

Bỏ qua im lặng nếu manifest lỗi.

Hiện Cập nhật / Không cập nhật nếu có bản mới.

Tải installer khi người dùng bấm Cập nhật.

Kiểm tra SHA-256.

Chạy installer.

Xóa file tạm.

#### Hoàn thành khi

Không có mạng thì app vẫn mở bình thường.

Manifest lỗi thì không hiện lỗi cho người dùng.

Không có update thì không hiện gì.

Có update thì hiện thông báo.

Không tải installer trước khi người dùng bấm Cập nhật.

File tải về được kiểm tra SHA-256.

File cài tạm được xóa sau quá trình cập nhật.

### Giai đoạn 7 — Đóng gói bản cài

#### Mục tiêu

Tạo được bộ cài Windows có thể cài và chạy phần mềm.

#### Công việc

Chọn cơ chế đóng gói.

Xác định .NET Runtime.

Xác định WebView2 Runtime.

Đóng gói tài nguyên UI local.

Đóng gói bộ tiêu chí gốc.

Tạo installer.

Đặt tên installer theo chuẩn rasoathopdong-setup-[version].exe.

Kiểm tra cài mới.

Kiểm tra cập nhật từ bản cũ.

#### Hoàn thành khi

Cài được phần mềm trên Windows.

Mở được app sau khi cài.

Không thiếu WebView2 Runtime hoặc có cách xử lý rõ.

Bộ tiêu chí gốc có sẵn sau khi cài.

Tên file cài đặt đúng chuẩn.

### Giai đoạn 8 — Nâng cao

Làm sau:

Word export.

So sánh bản trước / bản sau.

SQLite benchmark history.

Update Helper hoàn thiện hơn.

Ký số bộ cài.

Cải thiện parser.

Cải thiện evidence selector.

## 15. Kiểm thử tối thiểu

### 15.1. Test file đầu vào

DOCX đọc được.

DOCX rỗng.

DOCX bị lỗi.

DOCX bị khóa.

File sai định dạng.

### 15.2. Test rà soát

Hợp đồng có điều khoản thanh toán.

Hợp đồng thiếu điều khoản giải quyết tranh chấp.

Hợp đồng có từ khóa rủi ro.

Tiêu chí Đạt không hiển thị Mức rủi ro.

Tiêu chí Thiếu không hiện đoạn trích nếu không có.

Tiêu chí Rủi ro có mức rủi ro và căn cứ đánh giá.

### 15.3. Test bộ tiêu chí

Bộ gốc không sửa được.

Bộ gốc không xóa được.

Tạo được bộ tùy chỉnh từ bộ gốc.

Sửa được bộ tùy chỉnh.

Xóa được bộ tùy chỉnh.

Sao chép được tiêu chí trong bộ tùy chỉnh.

Bộ tùy chỉnh dùng được để rà soát.

### 15.4. Test lịch sử

Rà soát xong lưu được snapshot.

Mở lịch sử không chạy lại engine.

Mở lịch sử không phụ thuộc bộ tiêu chí hiện tại.

Mở lịch sử không cần đọc lại file hợp đồng gốc.

Khôi phục bộ tiêu chí mặc định không làm hỏng lịch sử cũ.

Xóa bộ tùy chỉnh không làm hỏng lịch sử cũ.

### 15.5. Test benchmark

Benchmark chạy nhiều file DOCX.

File lỗi không làm dừng toàn batch.

Sinh JSON từng hợp đồng.

Sinh JSONL toàn batch.

Sinh summary_by_contract.csv.

Sinh summary_by_group.csv.

Sinh risk_findings.csv.

Sinh failed_files.csv nếu có lỗi.

### 15.6. Test cập nhật

Không có mạng khi mở app.

GitHub không truy cập được.

Manifest lỗi.

Manifest thiếu trường bắt buộc.

Version không hợp lệ.

Không có update.

Có update nhưng người dùng bấm Không cập nhật.

Có update và người dùng bấm Cập nhật.

File tải về sai SHA-256.

File tải về đúng SHA-256.

### 15.7. Test migration

appdata.sqlite schema cũ.

appdata.sqlite schema mới.

Migration không mất settings.

Migration không mất history snapshot.

Migration không làm hỏng criteria.

### 15.8. Test đóng gói

Cài mới trên máy sạch.

Mở app sau khi cài.

WebView2 hoạt động.

Bộ tiêu chí gốc có sẵn.

Xuất PDF hoạt động.

Xuất Excel hoạt động.

Gỡ cài đặt không làm hỏng dữ liệu người dùng nếu chính sách giữ dữ liệu được chọn.

## 16. Tiêu chí hoàn thành MVP

MVP được xem là hoàn thành khi:

Cài được phần mềm trên Windows.

Mở app không lỗi.

Menu hoạt động.

Chế độ sáng/tối hoạt động.

Chọn được file DOCX.

Chọn được bộ tiêu chí gốc.

Rà soát ra kết quả theo nhóm.

Kết quả có Đạt / Thiếu / Cần rà soát / Rủi ro.

Tiêu chí Đạt không hiển thị mức rủi ro.

Không có gợi ý xử lý hoặc khuyến nghị xử lý.

Lưu được lịch sử snapshot.

Mở lịch sử không chạy lại engine.

Mở lịch sử không phụ thuộc bộ tiêu chí hiện tại.

Không mặc định lưu nguyên file hợp đồng gốc trong lịch sử.

Xuất được PDF cơ bản.

Xuất được Excel cơ bản.

Benchmark chạy được nhiều DOCX.

Benchmark xuất JSON / JSONL / CSV.

File lỗi trong benchmark không làm dừng toàn batch.

Không có mạng thì app vẫn chạy bình thường.

Update check không làm chậm mở app.

Manifest lỗi thì bỏ qua im lặng.

Chỉ tải installer khi người dùng bấm Cập nhật.

appdata.sqlite lưu được settings, criteria, history snapshot và update metadata.

## 17. Rủi ro kỹ thuật và cách kiểm soát

### 17.1. Rủi ro đọc DOCX không ổn định

Nguyên nhân:

File DOCX bị lỗi.

File bị khóa.

File có định dạng phức tạp.

File chứa bảng, header/footer, track changes.

Kiểm soát:

Bản đầu tập trung DOCX chuẩn.

Có xử lý file lỗi.

Có test DOCX rỗng, DOCX lỗi, DOCX bị khóa.

Không để lỗi file làm sập app.

### 17.2. Rủi ro engine đánh giá quá chắc

Nguyên nhân:

Tiêu chí pháp lý có nhiều vùng xám.

Từ khóa có thể xuất hiện nhưng không đủ nghĩa.

Có điều khoản nhưng diễn đạt gián tiếp.

Kiểm soát:

Dùng trạng thái Cần rà soát.

Không đưa gợi ý xử lý.

Không kết luận thay luật sư.

Luôn hiển thị căn cứ đánh giá.

Có đoạn trích liên quan nếu tìm được.

### 17.3. Rủi ro lịch sử sai khi tiêu chí thay đổi

Nguyên nhân:

Bộ tiêu chí gốc cập nhật.

Bộ tùy chỉnh bị xóa.

Người dùng mở lại kết quả cũ.

Kiểm soát:

Lịch sử lưu snapshot đầy đủ.

Không chỉ lưu criteriaSetId.

Mở lịch sử không chạy lại engine.

Mở lịch sử không phụ thuộc bộ tiêu chí hiện tại.

### 17.4. Rủi ro benchmark làm rối UI phổ thông

Nguyên nhân:

Benchmark có JSON, JSONL, CSV.

Người dùng phổ thông không cần dữ liệu kỹ thuật.

Kiểm soát:

Benchmark ẩn mặc định.

Bật/tắt trong Cài đặt.

Không hiển thị JSON/JSONL/SQLite ngoài Benchmark.

### 17.5. Rủi ro cập nhật làm phiền người dùng

Nguyên nhân:

Mất mạng.

GitHub bị chặn.

Manifest lỗi.

Timeout.

Kiểm soát:

Kiểm tra nền.

Timeout 10 giây.

Tối đa 1 lần/ngày.

Lỗi thì bỏ qua im lặng.

Không có update thì không hiện gì.

### 17.6. Rủi ro cài đặt thiếu runtime

Nguyên nhân:

Máy chưa có .NET Runtime.

Máy chưa có WebView2 Runtime.

Kiểm soát:

Quyết định self-contained hoặc runtime phụ thuộc.

Kiểm tra WebView2 Runtime.

Test cài mới trên máy sạch.

Đóng gói tài nguyên UI local.

## 18. Phạm vi không làm

Không làm trong bản đầu:

Cloud/SaaS.

Web server nội bộ nhiều người dùng.

CLM.

Đăng nhập tài khoản.

Phân quyền người dùng.

Đồng bộ cloud.

Gửi dữ liệu hợp đồng ra server.

Analytics.

Telemetry.

Gợi ý xử lý.

Khuyến nghị đàm phán.

Kết luận thay luật sư.

Rule builder phức tạp ở bản đầu.

Dashboard benchmark phức tạp ở bản đầu.

Kéo thả nhóm tiêu chí phức tạp ở bản đầu.

Hiển thị log kỹ thuật cho người dùng phổ thông.

Cho người dùng nhập GitHub URL trong UI.

Tự tải bộ cài khi người dùng chưa bấm Cập nhật.

## 19. Kết luận kế hoạch

Bản kế hoạch xây dựng phần mềm Rà soát hợp đồng được triển khai theo hướng:

Làm chắc nền desktop Windows trước.

Làm chắc luồng rà soát một hợp đồng DOCX.

Làm chắc kết quả theo nhóm tiêu chí.

Làm chắc lịch sử snapshot.

Làm xuất PDF/Excel cơ bản.

Làm benchmark JSON/JSONL/CSV.

Làm update qua GitHub manifest.

Làm migration và đóng gói bản cài.

Sau đó mới mở rộng Word export, so sánh bản trước/bản sau, SQLite benchmark history, ký số bộ cài và cải thiện engine.

Bản kế hoạch này dùng làm bản chính thức để triển khai phần mềm. Khi xây dựng thực tế, không dùng toàn bộ tài liệu này như một yêu cầu viết phần mềm trong một lần, mà phải chia thành từng task nhỏ theo các giai đoạn đã nêu.

Sau khi bổ sung bốn điểm chốt gồm: cách hiểu phạm vi triển khai, mặc định lưu lịch sử, chính sách dữ liệu khi gỡ cài đặt và dòng giới hạn trách nhiệm trong báo cáo, bản kế hoạch này được xem là đủ để chuyển sang bước tiếp theo: chia task triển khai, viết prompt cho Codex và lập checklist nghiệm thu.
