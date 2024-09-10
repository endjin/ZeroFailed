function Get-ExtensionFromRepository {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Name,

        [Parameter(Mandatory=$true)]
        [string] $Repository,

        [Parameter()]
        [string] $Version,

        [Parameter()]
        [switch] $PreRelease
    )

    # Setup some objects we'll use for splatting
    $extension = @{
        Name = $Name
        Repository = $Repository
        Enabled = $true
    }
    $psResourceArgs = @{
        Name = $Name
        PreRelease = $PreRelease
    }
    if ($Version) {
        $extension.Add("Version", $Version)
        $psResourceArgs.Add("Version", $Version)
    }

    # Check whether module is already installed
    $existingExtensionPath,$existingExtensionVersion = Get-InstalledExtensionDetails @psResourceArgs

    # Handle getting the module from the repository
    if (!$existingExtensionPath) {
        Write-Verbose "Extension '$Name' not found locally, checking repository"
        if (Find-PSResource @psResourceArgs -ErrorAction Ignore) {
            Write-Host "Installing extension $Name from $Repository" -f Cyan
            $installArgs = $extension.Clone()
            $installArgs.Remove("Enabled") | Out-Null
            $installArgs += @{
                Scope = "CurrentUser"
            }
            Install-PSResource @installArgs -TrustRepository | Out-Null

            $existingExtensionPath = Get-InstalledExtensionDetails @psResourceArgs
            if (!$existingExtensionPath) {
                throw "Failed to install extension $Name (v$Version) from $Repository"
            }
            Write-Host "INSTALLED: $Name (v$Version)" -f Cyan
        }
        else {
            Write-Warning "SKIPPED: Extension $Name not found in $Repository" -f Cyan
            $extension.Enabled = $false
        }
    }
    else {
        Write-Host "FOUND: $Name (v$existingExtensionVersion)" -f Cyan
    }

    $extension.Add("Path", $existingExtensionPath)

    # Return the additional extension metadata that this function has populated
    return @{
        Path = $existingExtensionPath
        Enabled = $extension.Enabled
    }
}