function Register-Extensions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [array] $ExtensionsConfig,

        [Parameter(Mandatory=$true)]
        [string] $DefaultRepository
    )
    
    for ($i=0; $i -lt $ExtensionsConfig.Length; $i++) {
        # Parse the extension configuration item into its canonical form
        $extension = New-ExtensionMetadataItem -Value $ExtensionsConfig[$i]

        # Prepare the parameters needed for extension registration
        $splat = $extension.Clone()
        $splat.Remove("Process") | Out-Null
        $splat.Repository = $extension.ContainsKey("Repository") ? $extension.Repository : $DefaultRepository
        
        # Decide how the extension is being provided
        if (!$extension.ContainsKey("Path")) {
            # Call the helper that will install the extension if it's not already installed and
            # provide the resulting additional metadata that we need to use the extension
            $extension += Get-ExtensionFromRepository @splat #- $extensionName -Repository $extensionRepo -ExtensionVersion $extensionVersion -AllowPreRelease:$extensionAllowPreRelease
        }
        elseif ((Test-Path $extension.Path)) {
            $extension.Add("Enabled", $true)
            Write-Host "USING: $Name ($($extension.Path))" -f Cyan
            continue
        }
        else {
            Write-Warning "Extension '$extensionName' not found at $($extension.Path) - it has been disabled."
            $extension.Add("Enabled", $false)
            continue
        }

        # Persist the fully-populated extension metadata
        $ExtensionsConfig[$i] = $extension
    }

    return $ExtensionsConfig
}