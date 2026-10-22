# 足球AI数据分析系统 - 本地启动脚本
# 自动选择 Python（优先项目内置便携版），寻找空闲端口，启动服务并打开浏览器

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# 1. 定位 Python 解释器
$py = Join-Path $root "runtime\python\python.exe"
if (-not (Test-Path -LiteralPath $py)) {
    $sys = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($sys) {
        $py = $sys.Source
    } else {
        $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
        if ($launcher) { $py = "py" }
    }
}
if (-not $py) {
    Write-Host "未找到 Python：项目内 runtime\python 缺失，且系统未安装 Python。" -ForegroundColor Red
    Write-Host "请重新解压完整部署包，或安装 Python 3.10+。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 2. 寻找空闲端口（8899 起，被占用则顺延）
$port = 0
foreach ($p in 8899..8999) {
    $busy = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
    if (-not $busy) { $port = $p; break }
}
if ($port -eq 0) { Write-Host "8899-8999 端口均被占用，请关闭后重试。" -ForegroundColor Red; Read-Host "按回车退出"; exit 1 }

$url = "http://localhost:$port"

# 3. 2 秒后自动打开浏览器
$openCode = "Start-Sleep -Seconds 2; Start-Process '$url'"
Start-Process powershell -ArgumentList @("-NoProfile","-WindowStyle","Hidden","-Command",$openCode)

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  足球AI数据分析系统 已启动" -ForegroundColor Green
Write-Host "  访问地址: $url" -ForegroundColor Yellow
Write-Host "  数据更新: 双击 [更新数据.bat] 或等待定时任务" -ForegroundColor Gray
Write-Host "  关闭服务: 直接关闭本窗口" -ForegroundColor Gray
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# 4. 前台运行 HTTP 服务（仅本机访问）
& $py -m http.server $port --bind 127.0.0.1
