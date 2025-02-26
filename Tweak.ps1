# Script Avançado de Otimização para Windows 11 - Máxima Velocidade e Responsividade
Write-Host "Iniciando otimizações avançadas para Windows 11..." -ForegroundColor Green

# 1. Desativar efeitos visuais completamente para máximo desempenho
Write-Host "Desativando todos os efeitos visuais..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 0

# 2. Desativar serviços desnecessários (ampliado)
Write-Host "Desativando serviços desnecessários..."
$services = @(
    "XblAuthManager",           # Xbox Live Auth Manager
    "XblGameSave",              # Xbox Game Save
    "XboxNetApiSvc",            # Xbox Network Service
    "DiagTrack",                # Telemetria
    "dmwappushservice",         # Push WAP
    "MapsBroker",               # Mapas
    "WMPNetworkSvc",            # Windows Media Player Network Sharing
    "SysMain",                  # Superfetch (desnecessário em SSDs)
    "WSearch",                  # Indexação do Windows
    "Spooler",                  # Spooler de impressão (se não usa impressora)
    "Fax",                      # Fax
    "wuauserv",                 # Windows Update (temporariamente)
    "DoSvc",                    # Delivery Optimization
    "PcaSvc"                    # Assistente de Compatibilidade
)
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Serviço $service desativado."
    }
}

# 3. Desativar inicialização rápida e hibernação
Write-Host "Desativando inicialização rápida e hibernação..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
powercfg /hibernate off

# 4. Configurar plano de energia para desempenho máximo
Write-Host "Configurando plano de energia para desempenho máximo..."
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# 5. Limpar arquivos temporários e caches
Write-Host "Executando limpeza profunda de arquivos temporários..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
CleanMgr /sagerun:1

# 6. Desativar tarefas agendadas desnecessárias
Write-Host "Desativando tarefas agendadas desnecessárias..."
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Defrag\ScheduledDefrag",
    "\Microsoft\Windows\Maintenance\WinSAT",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
)
foreach ($task in $tasks) {
    schtasks /change /tn $task /disable -ErrorAction SilentlyContinue
    Write-Host "Tarefa $task desativada."
}

# 7. Desativar recursos adicionais do Windows
Write-Host "Desativando recursos adicionais..."
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaFeatures" -NoRestart -ErrorAction SilentlyContinue
Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart -ErrorAction SilentlyContinue

# 8. Ajustar configurações de desempenho do processador (11ª geração Intel)
Write-Host "Otimizando desempenho do processador..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" -Name "Value" -Value 100

# 9. Verificar e reparar arquivos de sistema
Write-Host "Verificando e reparando integridade do sistema..."
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth

# 10. Desativar notificações e dicas do Windows
Write-Host "Desativando notificações e dicas..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0

Write-Host "Otimização avançada concluída! Reinicie o notebook para aplicar todas as mudanças." -ForegroundColor Green
