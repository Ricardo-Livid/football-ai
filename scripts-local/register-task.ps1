# 注册 Windows 定时任务：每日 08:00 / 12:00 / 16:00 / 20:00 自动抓取赛事数据
# 等价于 GitHub Actions 的定时抓取；注册任务计划需要管理员权限，本脚本自动申请 UAC 提权

$ErrorActionPreference = "Stop"

# --- 自动 UAC 提权 ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`""
    exit
}

$root = Split-Path -Parent $PSScriptRoot
$taskName = "足球AI-数据更新"
$runner = Join-Path $root "scripts-local\run-fetch.bat"
$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

try {
    $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"`"$runner`"`"" -WorkingDirectory $root
    $times = @("08:00","12:00","16:00","20:00")
    $triggers = $times | ForEach-Object { New-ScheduledTaskTrigger -Daily -At $_ }
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Minutes 15)
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings `
        -Description "足球AI数据分析系统：每日4次抓取竞彩赛事数据并更新data目录" -Force | Out-Null

    $check = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
    Write-Host ""
    Write-Host "定时任务 [$taskName] 已注册成功" -ForegroundColor Green
    Write-Host "运行时间: 每天 $($times -join '、')" -ForegroundColor Yellow
    Write-Host "日志文件: $(Join-Path $logDir 'fetch.log')" -ForegroundColor Gray
} catch {
    Write-Host ""
    Write-Host "注册失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "可改为手动方式：每天双击 [更新数据.bat] 抓取数据。" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "按任意键关闭窗口..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
