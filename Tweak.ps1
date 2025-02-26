# Verifica se o script está sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilégios de administrador. Solicitando elevação..." -ForegroundColor Yellow
    # Reinicia o script com permissões de administrador
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# Após a verificação, o script continua normalmente
Write-Host "Iniciando otimizações avançadas para seu Windows..." -ForegroundColor Green

# 1. Desativar efeitos visuais completamente para máximo desempenho
Write-Host "Desativando todos os efeitos visuais..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "Composition" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "BorderWidth" -Value 0

# 2. Desativar serviços desnecessários (ampliado e otimizado)
Write-Host "Desativando serviços desnecessários..."
$services = @(
    "XblAuthManager", "XblGameSave", "XboxNetApiSvc", # Serviços Xbox
    "DiagTrack", "dmwappushservice",                  # Telemetria e Push
    "MapsBroker", "WMPNetworkSvc",                    # Mapas e Media Player
    "SysMain", "WSearch",                             # Superfetch e Indexação
    "Spooler", "Fax",                                 # Impressão e Fax
    "wuauserv", "DoSvc",                              # Windows Update e Otimização de Entrega
    "PcaSvc", "RetailDemo",                           # Compatibilidade e Demo
    "TabletInputService"                              # Suporte a tablets (se não usado)
)
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Serviço $service desativado."
    }
}

# 3. Desativar inicialização rápida, hibernação e swap desnecessário
Write-Host "Desativando inicialização rápida, hibernação e otimizando memória..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
powercfg /hibernate off
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value ""

# 4. Configurar plano de energia para desempenho máximo
Write-Host "Configurando plano de energia para desempenho máximo..."
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100

# 5. Limpeza profunda de arquivos temporários e caches
Write-Host "Executando limpeza profunda de arquivos temporários..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait

# 6. Desativar tarefas agendadas desnecessárias (ampliado)
Write-Host "Desativando tarefas agendadas desnecessárias..."
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Defrag\ScheduledDefrag",
    "\Microsoft\Windows\Maintenance\WinSAT",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
    "\Microsoft\Windows\WindowsUpdate\Scheduled Start",
    "\Microsoft\Windows\DiskCleanup\SilentCleanup"
)
foreach ($task in $tasks) {
    schtasks /change /tn $task /disable -ErrorAction SilentlyContinue
    Write-Host "Tarefa $task desativada."
}

# 7. Desativar recursos adicionais do Windows (ampliado)
Write-Host "Desativando recursos adicionais..."
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaFeatures" -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -ErrorAction SilentlyContinue

# 8. Otimizar desempenho do processador e memória
Write-Host "Otimizando desempenho do processador e memória..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" -Name "Value" -Value 100
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1

# 9. Verificar e reparar arquivos de sistema
Write-Host "Verificando e reparando integridade do sistema..."
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth

# 10. Desativar notificações, dicas e otimizações visuais adicionais
Write-Host "Desativando notificações, dicas e otimizações visuais adicionais..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableBalloonTips" -Value 0

Write-Host "Otimização avançada concluída! Reinicie o sistema para aplicar todas as mudanças." -ForegroundColor Green
