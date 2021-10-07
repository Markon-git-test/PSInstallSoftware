f (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}
$7zipDownload = "https://www.7-zip.org/a/7z1604-x64.msi"
$7zipVersion = "16.04"
$7zipInstallFile = "$env:windir\Temp\7z1604-x64.msi"
If(!(Test-Path $7zipInstallFile)){
    Write-Host "Downloading $7zipDownload"
    Invoke-WebRequest -Uri $7zipDownload -OutFile $7zipInstallFile
}
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (!(Test-Path $7zipPath)){
  Write-Host "7-Zip not installed on path $7zipPath"
  Write-Host "Installing $7zipInstallFile"
  MsiExec.exe /i $7zipInstallFile /qn /L*V "$env:windir\Temp\7zip-Install.log"
} else {
  Write-Host "7-Zip is installed on path $7zipPath"
  $Current7zipVersion = (Get-Item $7zipPath).VersionInfo.FileVersion
  If($Current7zipVersion -ne $7zipVersion){
    Write-Host "Different 7-Zip version $Current7zipVersion detected $7zipPath"
    #TODO: Uninstall msi versions also
    Write-Host "Uninstalling 7-Zip $env:ProgramFiles\7-Zip\Uninstall.exe"
    & "$env:ProgramFiles\7-Zip\Uninstall.exe" /S
    Write-Host "Installing $7zipInstallFile"
    MsiExec.exe /i $7zipInstallFile /qn /L*V "$env:windir\Temp\7zip-Install.log"
  } Else {
    Write-Host "Target version $7zipVersion already installed"
  }
} 