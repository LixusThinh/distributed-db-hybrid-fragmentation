# Xuất từng slide ra PNG bằng PowerPoint để kiểm tra hình thức.
#   pwsh -File slides/build/render.ps1 [thư mục ra]
param([string]$OutDir = (Join-Path $PSScriptRoot "render"))
$pptx = Resolve-Path (Join-Path $PSScriptRoot "..\Slide_PhanManhHonHop.pptx")
New-Item -ItemType Directory -Force $OutDir | Out-Null
Get-ChildItem $OutDir -Filter "slide-*.png" | Remove-Item
$app = New-Object -ComObject PowerPoint.Application
try {
    $pres = $app.Presentations.Open([string]$pptx, $true, $false, $false)
    foreach ($s in $pres.Slides) {
        $s.Export((Join-Path $OutDir ("slide-{0:D2}.png" -f $s.SlideIndex)), "PNG", 1600, 900)
    }
    $pres.SaveCopyAs([string]([IO.Path]::ChangeExtension($pptx, ".pdf")), 32)
    "Đã xuất $($pres.Slides.Count) slide vào $OutDir"
    $pres.Close()
} finally {
    $app.Quit()
}
