@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 足球AI数据分析系统（本地服务）
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts-local\start-server.ps1"
pause
