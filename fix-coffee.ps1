# dism fix it run as admin+coffee -.ps1
# Requires Administrator privileges

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "This script requires Administrator privileges!"
    Write-Host "Please run this script as Administrator." -ForegroundColor Yellow
    
    # Attempt to relaunch as admin
    try {
        $process = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait -PassThru
        exit $process.ExitCode
    } catch {
        Write-Error "Failed to elevate permissions: $_"
        exit 1
    }
}

# Set console colors for better visibility
$host.UI.RawUI.WindowTitle = "DISM Health Repair & Coffee"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       HELLO WORLD" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to run DISM command with status
function Invoke-DismOperation {
    param(
        [string]$Description,
        [string]$Arguments
    )
    
    Write-Host ""
    Write-Host "--- $Description ---" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $process = Start-Process -FilePath "dism.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[SUCCESS] $Description completed successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Host "[WARNING] $Description completed with exit code: $($process.ExitCode)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "[ERROR] Failed to execute: $_" -ForegroundColor Red
        return $false
    }
}

# Step 1: Scanning Health
Write-Host "Scanning Health..." -ForegroundColor White
$result1 = Invoke-DismOperation -Description "Scanning System Health" -Arguments "/online /Cleanup-Image /scanhealth"

# Step 2: Checking Health
Write-Host "`nChecking Health..." -ForegroundColor White
$result2 = Invoke-DismOperation -Description "Checking System Health" -Arguments "/online /Cleanup-Image /checkhealth"

# Step 3: Restoring Health (this may take a while)
Write-Host "`nRestoring Health..." -ForegroundColor White
Write-Host "(This may take several minutes, please be patient...)" -ForegroundColor Gray
$result3 = Invoke-DismOperation -Description "Restoring System Health" -Arguments "/online /Cleanup-Image /Restorehealth"

# Step 4: Analyzing Component Store
Write-Host "`nAnalyzing Component Store..." -ForegroundColor White
$result4 = Invoke-DismOperation -Description "Analyzing Component Store" -Arguments "/Online /Cleanup-Image /AnalyzeComponentStore"

# Step 5: Cleaning Component Store
Write-Host "`nStartComponentCleanup" -ForegroundColor White
Write-Host "Cleaning Component Store..." -ForegroundColor White
Write-Host "(Cleaning up component store, this may take some time...)" -ForegroundColor Gray
$result5 = Invoke-DismOperation -Description "Cleaning Component Store" -Arguments "/Online /Cleanup-Image /StartComponentCleanup"

# Final Status
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     OPERATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Summary of operations
Write-Host "Operation Summary:" -ForegroundColor Yellow
Write-Host "  Scan Health:      $(if($result1){'OK'}else{'Issues Found'})" -ForegroundColor $(if($result1){'Green'}else{'Red'})
Write-Host "  Check Health:     $(if($result2){'OK'}else{'Issues Found'})" -ForegroundColor $(if($result2){'Green'}else{'Red'})
Write-Host "  Restore Health:   $(if($result3){'OK'}else{'Failed'})" -ForegroundColor $(if($result3){'Green'}else{'Red'})
Write-Host "  Analyze Store:    $(if($result4){'OK'}else{'Failed'})" -ForegroundColor $(if($result4){'Green'}else{'Red'})
Write-Host "  Cleanup Store:    $(if($result5){'OK'}else{'Failed'})" -ForegroundColor $(if($result5){'Green'}else{'Red'})
Write-Host ""

# Coffee/Caffeine Prompt
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "     You Want Caffeine?" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Enter Y for Yes" -ForegroundColor White
Write-Host "Enter N for No" -ForegroundColor White
Write-Host ""

do {
    $choice = Read-Host "Yes or No (Y/N)"
    $choice = $choice.ToUpper().Trim()
} while ($choice -ne 'Y' -and $choice -ne 'N')

if ($choice -eq 'Y') {
    Write-Host ""
    Write-Host "☕ Enjoy your coffee! ☕" -ForegroundColor DarkYellow
    Write-Host "   (╯°□°）╯︵ ┻━┻" -ForegroundColor DarkGray
    
    # Optional: Open a fun coffee image or website
    # Start-Process "https://coffee.ink"
} else {
    Write-Host ""
    Write-Host "No coffee? Stay strong! 💪" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
