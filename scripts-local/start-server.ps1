# 足球AI数据分析系统 - 本地启动脚本（内置实时数据刷新）
# 启动后自动托管网站，并在后台每 60 秒抓取竞彩实时赔率/比分/状态

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# 1. 定位 Python 解释器（优先项目内置便携版）
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

# 2. 启动常驻服务（自动选择空闲端口、打开浏览器、每 60 秒刷新数据）
$env:PYTHONIOENCODING = "utf-8"
$server = Join-Path $PSScriptRoot "server.py"
& $py $server
