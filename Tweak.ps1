# Script de Gestão de Ativos de Equipamentos no Domínio
# Autor: Daniel Vocurca Frade
# Versão: 2.0
# Data: 19/03/2025

# Função para verificar privilégios de administrador
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Este script requer privilégios de administrador. Solicitando elevação..." -ForegroundColor Yellow
        try {
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            Exit
        } catch {
            Write-Host "Erro ao tentar elevar privilégios: $_" -ForegroundColor Red
            Exit 1
        }
    }
}

# Função para processar serviços
function Disable-Services {
    param ([string[]]$ServiceList)
    foreach ($service in $ServiceList) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $service -Force -ErrorAction Stop
                Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
                Write-Host "Serviço $service desativado com sucesso." -ForegroundColor Cyan
            }
        } catch {
            Write-Host "Erro ao desativar serviço $service : $_" -ForegroundColor Yellow
        }
    }
}

# Função para processar features do Windows
function Disable-Features {
    param ([string[]]$FeatureList)
    foreach ($feature in $FeatureList) {
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction Stop
            Write-Host "Recurso $feature desativado com sucesso." -ForegroundColor Cyan
        } catch {
            Write-Host "Erro ao desativar recurso $feature : $_" -ForegroundColor Yellow
        }
    }
}

# Início do script
Clear-Host
Test-Admin
Write-Host "Iniciando otimizações avançadas extremas para seu Windows (com Wi-Fi e Spooler preservados)..." -ForegroundColor Green
Start-Sleep -Seconds 2

# 1. Otimizações visuais
Write-Host "`n[1/10] Otimizando interface visual..." -ForegroundColor Magenta
try {
    $visualSettings = @{
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" = @{ "VisualFXSetting" = 2 }
        "HKCU:\Control Panel\Desktop" = @{ 
            "UserPreferencesMask" = [byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)
            "FontSmoothing" = 0
            "DragFullWindows" = 0
        }
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = @{ 
            "TaskbarAnimations" = 0
            "ListviewShadow" = 0
            "IconsOnly" = 1
            "ListviewAlphaSelect" = 0
        }
        "HKCU:\Control Panel\Desktop\WindowMetrics" = @{ 
            "MinAnimate" = 0
            "BorderWidth" = 0
        }
        "HKCU:\Software\Microsoft\Windows\DWM" = @{ 
            "EnableAeroPeek" = 0
            "Composition" = 0
        }
    }
    
    foreach ($path in $visualSettings.Keys) {
        foreach ($key in $visualSettings[$path].Keys) {
            Set-ItemProperty -Path $path -Name $key -Value $visualSettings[$path][$key] -ErrorAction Stop
        }
    }
} catch {
    Write-Host "Erro ao otimizar interface visual: $_" -ForegroundColor Yellow
}

# 2. Desativar serviços
Write-Host "`n[2/10] Desativando serviços desnecessários..." -ForegroundColor Magenta
$servicesToDisable = @(
    "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc",
    "DiagTrack", "dmwappushservice", "DPS", "WdiServiceHost",
    "MapsBroker", "WMPNetworkSvc", "WwanSvc",
    "SysMain", "WSearch", "defragsvc",
    "Fax", "PrintNotify",
    "wuauserv", "DoSvc", "UsoSvc", "WaaSMedicSvc",
    "PcaSvc", "RetailDemo", "AppXSvc",
    "TabletInputService", "TouchKeyboard",
    "BcastDVRUserService_*", "GameDVR",
    "WerSvc", "TroubleShootingSvc",
    "lfsvc", "icssvc", "WalletService"
)
Disable-Services -ServiceList $servicesToDisable

# 3. Otimizar energia e memória
Write-Host "`n[3/10] Configurando energia e memória..." -ForegroundColor Magenta
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
    powercfg /hibernate off
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value ""
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 1
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1
    
    powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLE 0
} catch {
    Write-Host "Erro ao configurar energia e memória: $_" -ForegroundColor Yellow
}

# 4. Limpeza de arquivos
Write-Host "`n[4/10] Realizando limpeza de arquivos..." -ForegroundColor Magenta
$pathsToClean = @(
    "$env:TEMP\*", 
    "C:\Windows\Temp\*", 
    "C:\Windows\Prefetch\*", 
    "C:\Windows\SoftwareDistribution\*",
    "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\*",
    "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*"
)
foreach ($path in $pathsToClean) {
    try {
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
        Write-Host "Limpeza concluída em: $path" -ForegroundColor Cyan
    } catch {
        Write-Host "Erro ao limpar $path : $_" -ForegroundColor Yellow
    }
}
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait -ErrorAction SilentlyContinue

# 5. Desativar tarefas agendadas
Write-Host "`n[5/10] Desativando tarefas agendadas..." -ForegroundColor Magenta
$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\*",
    "\Microsoft\Windows\Customer Experience Improvement Program\*",
    "\Microsoft\Windows\Defrag\*",
    "\Microsoft\Windows\Maintenance\*",
    "\Microsoft\Windows\Power Efficiency Diagnostics\*",
    "\Microsoft\Windows\WindowsUpdate\*",
    "\Microsoft\Windows\DiskCleanup\*",
    "\Microsoft\Windows\CloudExperienceHost\*",
    "\Microsoft\Windows\Feedback\*",
    "\Microsoft\Windows\Maps\*"
)
foreach ($task in $tasksToDisable) {
    try {
        schtasks /change /tn $task /disable -ErrorAction Stop
        Write-Host "Tarefa $task desativada." -ForegroundColor Cyan
    } catch {
        Write-Host "Erro ao desativar tarefa $task : $_" -ForegroundColor Yellow
    }
}

# 6. Desativar recursos do Windows
Write-Host "`n[6/10] Desativando recursos do Windows..." -ForegroundColor Magenta
$featuresToDisable = @(
    "WindowsMediaFeatures", "Internet-Explorer-Optional-amd64",
    "Microsoft-Windows-Subsystem-Linux", "WorkFolders-Client",
    "Microsoft-Hyper-V-All", "Windows-Defender-Default-Definitions",
    "SMB1Protocol"
)
Disable-Features -FeatureList $featuresToDisable

# 7. Otimizar processador e rede
Write-Host "`n[7/10] Otimizando processador e rede..." -ForegroundColor Magenta
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" -Name "Value" -Value 100
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "DisableBandwidthThrottling" -Value 1
} catch {
    Write-Host "Erro ao otimizar processador e rede: $_" -ForegroundColor Yellow
}

# 8. Desativar notificações e telemetria
Write-Host "`n[8/10] Desativando notificações e telemetria..." -ForegroundColor Magenta
try {
    $notificationSettings = @{
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" = @{ "ToastEnabled" = 0 }
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = @{ "ShowSyncProviderNotifications" = 0 }
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" = @{ "SystemPaneSuggestionsEnabled" = 0 }
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{ "AllowTelemetry" = 0 }
    }
    
    foreach ($path in $notificationSettings.Keys) {
        foreach ($key in $notificationSettings[$path].Keys) {
            Set-ItemProperty -Path $path -Name $key -Value $notificationSettings[$path][$key] -ErrorAction Stop
        }
    }
} catch {
    Write-Host "Erro ao desativar notificações e telemetria: $_" -ForegroundColor Yellow
}

# 9. Verificação do sistema
Write-Host "`n[9/10] Verificando integridade do sistema..." -ForegroundColor Magenta
try {
    Write-Host "Executando SFC..." -ForegroundColor Cyan
    sfc /scannow | Out-Null
    Write-Host "Executando DISM..." -ForegroundColor Cyan
    DISM /Online /Cleanup-Image /RestoreHealth | Out-Null
} catch {
    Write-Host "Erro durante verificação do sistema: $_" -ForegroundColor Yellow
}

# 10. Finalização
Write-Host "`n[10/10] Otimização concluída!" -ForegroundColor Green
Write-Host "Reinicie o sistema para aplicar todas as mudanças." -ForegroundColor Yellow
Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
