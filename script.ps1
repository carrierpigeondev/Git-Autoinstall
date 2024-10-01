<#
Installs git CLI and GitHub Desktop
#>

#Requires -RunAsAdministrator

# check if Git is installed
Write-Host "Checking if Git is installed."
if (Get-Command git.exe -ErrorAction SilentlyContinue) {
    Write-Host "Git has been found."
} else {
    Write-Host "Git has not been found or is not in PATH."

    # ask the user if they want to install git
    $installGitResponse = Read-Host "Install git? (y/n): "
    if ($installGitResponse.ToLower() -eq "y") {
        # get the latest version of git from the api, download it to temp, run the installer, then remove the installer from the temp dir
        Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" -Headers @{ "User-Agent" = "PowerShell" } |
            ForEach-Object { $_.assets | Where-Object { $_.name -like "*64-bit.exe" } | Select-Object -ExpandProperty browser_download_url } |
            ForEach-Object {
                $installerPath = "$env:TEMP\Git-Installer.exe"
                Invoke-WebRequest -Uri $_ -OutFile $installerPath
                Start-Process -FilePath $installerPath -ArgumentList "/SILENT" -Wait
                Remove-Item $installerPath
            }
    }
    else {
        exit  # leave the script as it cannot continue without git
        # no bypass for this error has the script NEEDS access to the git.exe command
    }
}

Write-Host "Cannot check to see if GitHub Desktop is installed."
$installGitHubDesktopResponse = Read-Host "Install GitHub Desktop? (y/n): "
if ($installGitHubDesktopResponse.ToLower() -eq "y") {
    $installerPath = "$env:TEMP\GitHubDesktop-Installer.exe"
    Invoke-WebRequest `
        -Uri https://central.github.com/deployments/desktop/desktop/latest/win32 `
        -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/SILENT" -Wait
    Remove-Item $installerPath
}
