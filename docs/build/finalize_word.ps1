# Mở báo cáo bằng MS Word: cập nhật mục lục, danh mục hình/bảng, lưu lại và xuất PDF.
#   powershell -ExecutionPolicy Bypass -File docs/build/finalize_word.ps1
$docx = Resolve-Path (Join-Path $PSScriptRoot "..\BaoCao_PhanManhHonHop.docx")
$pdf = [IO.Path]::ChangeExtension($docx, ".pdf")
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
    $doc = $word.Documents.Open([string]$docx)
    $doc.Repaginate()
    foreach ($t in $doc.TablesOfContents) { [void]$t.Update() }
    # cập nhật lần hai: mục lục dài thêm làm số trang phía sau dịch đi
    $doc.Repaginate()
    foreach ($t in $doc.TablesOfContents) { [void]$t.Update() }
    $doc.Save()
    $doc.ExportAsFixedFormat([string]$pdf, 17)
    "Trang: " + $doc.ComputeStatistics(2)
    $doc.Close()
    "Đã cập nhật mục lục và xuất $pdf"
} finally {
    $word.Quit()
}
