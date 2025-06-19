@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title Text2Video-ForkyEdition 自動安裝器

echo ====================================
echo Text2Video-ForkyEdition 自動安裝腳本
echo 最終增強版 - 完全無腦安裝
echo ====================================
echo.

rem 檢查管理員權限
net session >nul 2>&1
if errorlevel 1 (
    echo ⚠ 注意: 當前非管理員權限運行
    echo 如果安裝過程中遇到權限問題，請右鍵"以管理員身分執行"
    echo.
    timeout /t 3 >nul
)

rem 設定變數
set PROJECT_NAME=Text2Video-ForkyEdition
set REPO_URL=https://github.com/terryuuang/Text2Video-ForkyEdition.git
set IMAGEMAGICK_URL=https://imagemagick.org/archive/binaries/ImageMagick-7.1.1-47-Q16-HDRI-x64-dll.exe
set IMAGEMAGICK_INSTALLER=ImageMagick-7.1.1-47-Q16-HDRI-x64-dll.exe
set CURRENT_DIR=%CD%

echo 當前目錄: %CURRENT_DIR%
echo.

rem 檢查網絡連接
echo 檢查網絡連接...
ping -n 1 github.com >nul 2>&1
if errorlevel 1 (
    echo ⚠ 警告: 無法連接到GitHub
    echo 請檢查網絡連接，然後按任意鍵繼續或Ctrl+C取消
    pause >nul
) else (
    echo ✓ 網絡連接正常
)
echo.

rem 1. 檢查專案資料夾是否存在
echo [1/6] 檢查專案資料夾...
if exist "%PROJECT_NAME%" (
    echo ✓ 發現現有的 %PROJECT_NAME% 資料夾
    echo 是否要更新現有專案？ (建議選擇 Y)
    choice /c YN /m "更新專案 (Y/N)"
    if errorlevel 2 goto :check_imagemagick
    if errorlevel 1 (
        echo 更新專案中...
        cd "%PROJECT_NAME%"
        git pull origin main >nul 2>&1
        if errorlevel 1 (
            echo ⚠ Git 更新失敗，嘗試重置...
            git reset --hard HEAD >nul 2>&1
            git pull origin main >nul 2>&1
            if errorlevel 1 (
                echo ⚠ 更新失敗，繼續使用現有版本
            ) else (
                echo ✓ 專案更新完成
            )
        ) else (
            echo ✓ 專案更新完成
        )
        cd ..
    )
    goto :check_imagemagick
)

rem 檢查git是否安裝
echo 檢查Git安裝狀態...
git --version >nul 2>&1
if errorlevel 1 (
    echo ✗ 錯誤: 未安裝Git！
    echo.
    echo 正在打開Git下載頁面...
    start https://git-scm.com/download/win
    echo.
    echo 請安裝Git後重新運行此腳本
    echo 安裝時請勾選 "Add Git to PATH"
    pause
    exit /b 1
)

echo [2/6] 開始下載專案...
echo 正在從GitHub下載，請稍候...
git clone %REPO_URL%
if errorlevel 1 (
    echo ✗ 錯誤: Git下載失敗！
    echo.
    echo 備用方案：手動下載
    echo 正在打開下載頁面...
    start https://github.com/terryuuang/Text2Video-ForkyEdition/archive/main.zip
    echo.
    echo 請下載ZIP檔案並解壓縮到當前目錄
    echo 解壓後將資料夾重命名為 "%PROJECT_NAME%"
    echo 完成後按任意鍵繼續...
    pause >nul
    if not exist "%PROJECT_NAME%" (
        echo ✗ 未找到專案資料夾，安裝中止
        pause
        exit /b 1
    )
)
echo ✓ 專案下載完成

:check_imagemagick
rem 2. 檢查ImageMagick是否已安裝
echo [3/6] 檢查ImageMagick安裝狀態...
magick -version >nul 2>&1
if errorlevel 1 (
    echo ✗ 未檢測到ImageMagick，需要安裝
    goto :install_imagemagick_auto
) else (
    echo ✓ 檢測到ImageMagick已安裝
    for /f "tokens=*" %%i in ('where magick 2^>nul') do set MAGICK_PATH=%%i
    if defined MAGICK_PATH (
        for %%i in ("!MAGICK_PATH!") do set IMAGEMAGICK_INSTALL_PATH=%%~dpi
        echo ImageMagick路徑: !IMAGEMAGICK_INSTALL_PATH!
    ) else (
        set IMAGEMAGICK_INSTALL_PATH=C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\
    )
    goto :setup_project
)

:install_imagemagick_auto
echo [4/6] 安裝ImageMagick...

rem 檢查是否已下載安裝檔案
if exist "%IMAGEMAGICK_INSTALLER%" (
    echo ✓ 發現安裝檔案
) else (
    echo 下載ImageMagick安裝檔案（約80MB）...
    echo 請稍候，下載中...
    
    rem 使用PowerShell下載
    powershell -Command "& {try {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host '下載進行中...'; Invoke-WebRequest -Uri '%IMAGEMAGICK_URL%' -OutFile '%IMAGEMAGICK_INSTALLER%' -UseBasicParsing} catch {Write-Host '下載失敗'; exit 1}}"
    
    if errorlevel 1 (
        echo ✗ 自動下載失敗
        echo 正在打開手動下載頁面...
        start "" "%IMAGEMAGICK_URL%"
        echo.
        echo 請手動下載後按任意鍵繼續...
        pause >nul
        if not exist "%IMAGEMAGICK_INSTALLER%" (
            echo ✗ 未找到安裝檔案
            pause
            exit /b 1
        )
    ) else (
        echo ✓ 下載完成
    )
)

echo.
echo ⚠ 重要提醒：
echo 1. 即將自動啟動ImageMagick安裝程式
echo 2. 請在安裝時勾選 "Add application directory to your system path"
echo 3. 其他選項保持預設即可
echo.
echo 按任意鍵開始安裝...
pause >nul

echo 正在安裝ImageMagick...
start /wait "" "%IMAGEMAGICK_INSTALLER%"

rem 等待並檢查安裝結果
echo 檢查安裝結果...
timeout /t 3 >nul

rem 嘗試刷新PATH環境變數
set "PATH=%PATH%;C:\Program Files\ImageMagick-7.1.1-Q16-HDRI"

magick -version >nul 2>&1
if errorlevel 1 (
    echo ⚠ 無法在命令行中找到ImageMagick
    echo 嘗試查找安裝位置...
    
    if exist "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" (
        set IMAGEMAGICK_INSTALL_PATH=C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\
        echo ✓ 找到ImageMagick安裝
    ) else (
        rem 搜尋其他可能的安裝位置
        for /d %%i in ("C:\Program Files\ImageMagick*") do (
            if exist "%%i\magick.exe" (
                set IMAGEMAGICK_INSTALL_PATH=%%i\
                echo ✓ 找到ImageMagick: %%i
                goto :found_imagemagick
            )
        )
        echo ✗ 無法找到ImageMagick，請手動檢查安裝
        :found_imagemagick
    )
) else (
    echo ✓ ImageMagick安裝成功
    for /f "tokens=*" %%i in ('where magick 2^>nul') do set MAGICK_PATH=%%i
    if defined MAGICK_PATH (
        for %%i in ("!MAGICK_PATH!") do set IMAGEMAGICK_INSTALL_PATH=%%~dpi
    )
)

echo ImageMagick路徑: !IMAGEMAGICK_INSTALL_PATH!

:setup_project
rem 3. 進入專案目錄並設置
echo [5/6] 設置專案配置...
cd "%PROJECT_NAME%"

rem 檢查專案完整性
if not exist "config.example.toml" (
    echo ✗ 專案檔案不完整，缺少config.example.toml
    echo 請重新下載專案
    pause
    exit /b 1
)

rem 創建配置檔案
if not exist "config.toml" (
    echo 創建配置檔案...
    copy "config.example.toml" "config.toml" >nul
    if errorlevel 1 (
        echo ✗ 配置檔案創建失敗
        pause
        exit /b 1
    )
    echo ✓ 配置檔案創建完成
)

rem 配置ImageMagick路徑
if exist "config.toml" (
    echo 配置ImageMagick路徑...
    
    set ESCAPED_PATH=!IMAGEMAGICK_INSTALL_PATH:\=\\!
    
    rem 檢查是否已存在imagemagick_path配置
    findstr /c:"imagemagick_path" "config.toml" >nul
    if errorlevel 1 (
        echo 添加ImageMagick路徑配置...
        echo imagemagick_path = "!ESCAPED_PATH!magick.exe" >> "config.toml"
    ) else (
        echo 更新ImageMagick路徑配置...
        powershell -Command "(Get-Content 'config.toml') -replace '.*imagemagick_path.*', 'imagemagick_path = \"!ESCAPED_PATH!magick.exe\"' | Set-Content 'config.toml'" 2>nul
    )
    echo ✓ ImageMagick路徑配置完成
)

rem 檢查Python環境
echo 檢查Python環境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ✗ 錯誤: 未檢測到Python
    echo.
    echo 正在打開Python下載頁面...
    start https://www.python.org/downloads/
    echo.
    echo 請安裝Python 3.8或更新版本
    echo 安裝時請勾選 "Add Python to PATH"
    echo 安裝完成後重新運行此腳本
    pause
    exit /b 1
) else (
    echo ✓ Python環境正常
)

rem 虛擬環境處理
echo 設置Python虛擬環境...
if exist ".venv" (
    echo ✓ 發現現有虛擬環境
) else (
    echo 創建虛擬環境...
    python -m venv .venv
    if errorlevel 1 (
        echo ✗ 虛擬環境創建失敗
        pause
        exit /b 1
    )
    echo ✓ 虛擬環境創建完成
)

echo 激活虛擬環境...
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo ✗ 虛擬環境激活失敗
    pause
    exit /b 1
)
echo ✓ 虛擬環境已激活

rem 安裝依賴
if exist "requirements.txt" (
    echo 安裝Python依賴包...
    echo 這可能需要幾分鐘，請耐心等待...
    
    python -m pip install --upgrade pip --quiet
    pip install -r requirements.txt --quiet
    if errorlevel 1 (
        echo ⚠ 部分依賴安裝可能失敗，但會嘗試繼續
    ) else (
        echo ✓ 依賴安裝完成
    )
) else (
    echo ⚠ 未找到requirements.txt
)

rem 4. 啟動專案
echo [6/6] 啟動專案...

rem 確保在虛擬環境中
where python | findstr ".venv" >nul
if errorlevel 1 (
    call .venv\Scripts\activate.bat
)

echo 檢查啟動方式...
if exist "webui.bat" (
    echo ✓ 使用webui.bat啟動
    echo.
    echo ====================================
    echo 安裝完成！正在啟動Web界面...
    echo ====================================
    echo.
    call webui.bat
) else (
    rem 備用啟動方式
    pip show streamlit >nul 2>&1
    if errorlevel 1 (
        echo 安裝streamlit...
        pip install streamlit --quiet
    )
    
    if exist "webui\Main.py" (
        echo ✓ 使用streamlit啟動
        echo.
        echo ====================================
        echo 安裝完成！正在啟動Web界面...
        echo ====================================
        echo.
        streamlit run .\webui\Main.py --browser.gatherUsageStats=False --server.enableCORS=True
    ) else (
        echo ✗ 無法找到啟動檔案
        echo 請檢查專案完整性
    )
)

cd ..

rem 清理
if exist "%IMAGEMAGICK_INSTALLER%" (
    echo 清理臨時檔案...
    del "%IMAGEMAGICK_INSTALLER%" 2>nul
)

echo.
echo ====================================
echo 安裝完成！
echo ====================================
echo.
echo 下次可以直接使用 run_text2video.bat 快速啟動
echo.
pause 