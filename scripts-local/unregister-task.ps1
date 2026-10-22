# 删除本地定时任务（自动申请 UAC 提权）
$ErrorActionPreference = "Stop"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`""
    exit
}

$taskName = "足球AI-数据更新"
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing) {
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "定时任务 [$taskName] 已删除。" -ForegroundColor Green
    } catch {
        Write-Host "删除失败: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "未找到定时任务 [$taskName]，无需删除。" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "按任意键关闭窗口..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
