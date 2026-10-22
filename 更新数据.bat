@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 更新赛事数据
set PYTHONIOENCODING=utf-8
set "PY=%~dp0runtime\python\python.exe"
if not exist "%PY%" set "PY=python"
echo 正在抓取最新赛事数据，请稍候...
echo.
"%PY%" "%~dp0scripts\fetch_data.py"
echo.
echo ========================================
echo 数据更新完成，刷新浏览器页面即可看到最新赛事。
echo ========================================
pause
