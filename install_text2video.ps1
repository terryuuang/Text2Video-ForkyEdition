# Text2Video-ForkyEdition 一鍵安裝腳本
# PowerShell版本 - 支持中文無亂碼

# 設置控制台編碼為UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# 設置執行策略（如果需要）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Text2Video-ForkyEdition 自動安裝腳本" -ForegroundColor Yellow
Write-Host "PowerShell版 - 完全無腦安裝" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# 變數設定
$PROJECT_NAME = "Text2Video-ForkyEdition"
$REPO_URL = "https://github.com/terryuuang/Text2Video-ForkyEdition.git"
$IMAGEMAGICK_URL = "https://imagemagick.org/archive/binaries/ImageMagick-7.1.1-47-Q16-HDRI-x64-dll.exe"
$IMAGEMAGICK_INSTALLER = "ImageMagick-7.1.1-47-Q16-HDRI-x64-dll.exe"

# 檢查管理員權限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "⚠ 注意: 當前非管理員權限運行" -ForegroundColor Yellow
    Write-Host "如果遇到權限問題，請右鍵選擇 '以管理員身分執行PowerShell'" -ForegroundColor Yellow
    Write-Host ""
}

# 檢查網絡連接
Write-Host "檢查網絡連接..." -ForegroundColor Cyan
try {
    $ping = Test-Connection -ComputerName "github.com" -Count 1 -Quiet
    if ($ping) {
        Write-Host "✓ 網絡連接正常" -ForegroundColor Green
    } else {
        Write-Host "⚠ 警告: 無法連接到GitHub" -ForegroundColor Red
        $continue = Read-Host "請檢查網絡連接，按Enter繼續或Ctrl+C取消"
    }
} catch {
    Write-Host "⚠ 網絡檢查失敗，但將繼續安裝" -ForegroundColor Yellow
}
Write-Host ""

# 1. 檢查專案資料夾
Write-Host "[1/6] 檢查專案資料夾..." -ForegroundColor Cyan
if (Test-Path $PROJECT_NAME) {
    Write-Host "✓ 發現現有的 $PROJECT_NAME 資料夾" -ForegroundColor Green
    $update = Read-Host "是否要更新現有專案？ (Y/N)"
    if ($update -eq "Y" -or $update -eq "y") {
        Write-Host "更新專案中..." -ForegroundColor Yellow
        Set-Location $PROJECT_NAME
        try {
            git pull origin main
            Write-Host "✓ 專案更新完成" -ForegroundColor Green
        } catch {
            Write-Host "⚠ 更新失敗，繼續使用現有版本" -ForegroundColor Yellow
        }
        Set-Location ..
    }
} else {
    # 檢查Git
    Write-Host "檢查Git安裝狀態..." -ForegroundColor Cyan
    try {
        git --version | Out-Null
        Write-Host "✓ Git已安裝" -ForegroundColor Green
    } catch {
        Write-Host "✗ 錯誤: 未安裝Git！" -ForegroundColor Red
        Write-Host "正在打開Git下載頁面..." -ForegroundColor Yellow
        Start-Process "https://git-scm.com/download/win"
        Write-Host "請安裝Git後重新運行此腳本" -ForegroundColor Red
        Read-Host "按Enter鍵退出"
        exit 1
    }

    Write-Host "[2/6] 下載專案..." -ForegroundColor Cyan
    try {
        git clone $REPO_URL
        Write-Host "✓ 專案下載完成" -ForegroundColor Green
    } catch {
        Write-Host "✗ Git下載失敗！" -ForegroundColor Red
        Write-Host "正在打開手動下載頁面..." -ForegroundColor Yellow
        Start-Process "https://github.com/terryuuang/Text2Video-ForkyEdition/archive/main.zip"
        Write-Host "請下載ZIP檔案並解壓縮到當前目錄，重命名為 '$PROJECT_NAME'" -ForegroundColor Yellow
        Read-Host "完成後按Enter繼續"
        if (-not (Test-Path $PROJECT_NAME)) {
            Write-Host "✗ 未找到專案資料夾，安裝中止" -ForegroundColor Red
            Read-Host "按Enter鍵退出"
            exit 1
        }
    }
}

# 2. 檢查ImageMagick
Write-Host "[3/6] 檢查ImageMagick..." -ForegroundColor Cyan
try {
    magick -version | Out-Null
    Write-Host "✓ ImageMagick已安裝" -ForegroundColor Green
    $magickPath = (Get-Command magick).Source
    $IMAGEMAGICK_INSTALL_PATH = Split-Path $magickPath
} catch {
    Write-Host "✗ 未檢測到ImageMagick，開始安裝..." -ForegroundColor Yellow
    
    # 下載ImageMagick
    if (-not (Test-Path $IMAGEMAGICK_INSTALLER)) {
        Write-Host "下載ImageMagick安裝檔案（約80MB）..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $IMAGEMAGICK_URL -OutFile $IMAGEMAGICK_INSTALLER -UseBasicParsing
            Write-Host "✓ 下載完成" -ForegroundColor Green
        } catch {
            Write-Host "✗ 自動下載失敗" -ForegroundColor Red
            Start-Process $IMAGEMAGICK_URL
            Read-Host "請手動下載後按Enter繼續"
            if (-not (Test-Path $IMAGEMAGICK_INSTALLER)) {
                Write-Host "✗ 未找到安裝檔案" -ForegroundColor Red
                Read-Host "按Enter鍵退出"
                exit 1
            }
        }
    }

    Write-Host "⚠ 重要提醒：請在安裝時勾選 'Add application directory to your system path'" -ForegroundColor Yellow
    Read-Host "按Enter開始安裝ImageMagick"
    
    Start-Process -FilePath $IMAGEMAGICK_INSTALLER -Wait
    
    # 檢查安裝結果
    Start-Sleep 3
    try {
        magick -version | Out-Null
        Write-Host "✓ ImageMagick安裝成功" -ForegroundColor Green
        $magickPath = (Get-Command magick).Source
        $IMAGEMAGICK_INSTALL_PATH = Split-Path $magickPath
    } catch {
        $IMAGEMAGICK_INSTALL_PATH = "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI"
        Write-Host "⚠ 可能需要重啟命令提示符才能使用ImageMagick" -ForegroundColor Yellow
    }
}

# 3. 設置專案
Write-Host "[4/6] 設置專案配置..." -ForegroundColor Cyan
Set-Location $PROJECT_NAME

if (-not (Test-Path "config.example.toml")) {
    Write-Host "✗ 專案檔案不完整" -ForegroundColor Red
    Read-Host "按Enter鍵退出"
    exit 1
}

# 創建配置檔案
if (-not (Test-Path "config.toml")) {
    Copy-Item "config.example.toml" "config.toml"
    Write-Host "✓ 配置檔案創建完成" -ForegroundColor Green
}

# 配置ImageMagick路徑
if (Test-Path "config.toml") {
    $configContent = Get-Content "config.toml"
    $escapedPath = $IMAGEMAGICK_INSTALL_PATH -replace "\\", "\\"
    $newConfig = $configContent -replace '.*imagemagick_path.*', "imagemagick_path = `"$escapedPath\\magick.exe`""
    $newConfig | Set-Content "config.toml"
    Write-Host "✓ ImageMagick路徑配置完成" -ForegroundColor Green
}

# 4. 檢查Python
Write-Host "[5/6] 檢查Python環境..." -ForegroundColor Cyan
try {
    python --version | Out-Null
    Write-Host "✓ Python環境正常" -ForegroundColor Green
} catch {
    Write-Host "✗ 未檢測到Python" -ForegroundColor Red
    Start-Process "https://www.python.org/downloads/"
    Write-Host "請安裝Python 3.8或更新版本，安裝時勾選 'Add Python to PATH'" -ForegroundColor Yellow
    Read-Host "安裝完成後重新運行此腳本"
    exit 1
}

# 虛擬環境
Write-Host "設置Python虛擬環境..." -ForegroundColor Cyan
if (-not (Test-Path ".venv")) {
    python -m venv .venv
    Write-Host "✓ 虛擬環境創建完成" -ForegroundColor Green
}

# 激活虛擬環境並安裝依賴
& ".\.venv\Scripts\Activate.ps1"
Write-Host "✓ 虛擬環境已激活" -ForegroundColor Green

if (Test-Path "requirements.txt") {
    Write-Host "安裝Python依賴包..." -ForegroundColor Cyan
    python -m pip install --upgrade pip --quiet
    pip install -r requirements.txt --quiet
    Write-Host "✓ 依賴安裝完成" -ForegroundColor Green
}

# 5. 啟動專案
Write-Host "[6/6] 啟動專案..." -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "安裝完成！正在啟動Web界面..." -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan

if (Test-Path "webui.bat") {
    & ".\webui.bat"
} elseif (Test-Path "webui\Main.py") {
    pip install streamlit --quiet
    streamlit run .\webui\Main.py --browser.gatherUsageStats=False --server.enableCORS=True
} else {
    Write-Host "✗ 無法找到啟動檔案" -ForegroundColor Red
}

Set-Location ..

# 清理
if (Test-Path $IMAGEMAGICK_INSTALLER) {
    Remove-Item $IMAGEMAGICK_INSTALLER -Force
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "安裝完成！" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Read-Host "按Enter鍵退出" 