@echo off
chcp 65001 >nul
cd /d "%~dp0.."
if not exist logs mkdir logs
set PYTHONIOENCODING=utf-8
set "PY=%~dp0..\runtime\python\python.exe"
if not exist "%PY%" set "PY=python"
echo. >> "logs\fetch.log"
echo ========== %date% %time% ========== >> "logs\fetch.log"
"%PY%" "scripts\fetch_data.py" >> "logs\fetch.log" 2>&1
