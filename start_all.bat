@echo off
echo =======================================================================
echo    WeatherGPT: Conversational AI for Weather & Climate Information
echo    Ministry of Earth Sciences (MoES) / IMD (SIH26068)
echo =======================================================================
echo.
echo [1/2] Launching FastAPI Backend on http://127.0.0.1:8000 ...
start "WeatherGPT Backend" cmd /k "cd /d %~dp0backend && py -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

echo [2/2] Launching WeatherGPT Flutter Application ...
start "WeatherGPT Flutter App" cmd /k "cd /d %~dp0flutter_app && flutter run -d chrome"

echo.
echo [+] All microservices and frontend launched!
echo [+] Backend Swagger Docs: http://127.0.0.1:8000/docs
echo [+] Health Check:         http://127.0.0.1:8000/health
echo =======================================================================
pause
