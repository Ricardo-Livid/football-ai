@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 卸载定时更新任务
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts-local\unregister-task.ps1"
echo.
pause
