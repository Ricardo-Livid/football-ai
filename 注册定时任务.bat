@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 注册定时更新任务
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts-local\register-task.ps1"
echo.
pause
