function Register-Extensions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [array] $ExtensionsConfig,

        [Parameter(Mandatory=$true)]
        [string] $DefaultRepository
    )
    
    [hashtable[]]$processedExtensionConfig = @()

    for ($i=0; $i -lt $ExtensionsConfig.Length; $i++) {

        $registeredExtensions = _recursive -ExtensionConfig $ExtensionsConfig[$i]
        
        # Persist the fully-populated extension metadata
        $processedExtensionConfig += $registeredExtensions
    }

    return $processedExtensionConfig
}

function _recursive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $ExtensionConfig
    )

    [hashtable[]]$processedExtensionConfig = @()

    # Parse the extension configuration item into its canonical form
    $extension = New-ExtensionMetadataItem -Value $ExtensionConfig -Verbose:$VerbosePreference

    # Prepare the parameters needed for extension registration
    $splat = $extension.Clone()
    $splat.Remove("Process") | Out-Null
    $splat.Add("Repository", $extension.ContainsKey("Repository") ? $extension.Repository : $DefaultRepository)
    
    # Decide how the extension is being provided
    if (!$extension.ContainsKey("Path")) {
        # Call the helper that will install the extension if it's not already installed and
        # provide the resulting additional metadata that we need to use the extension
        $extension += Get-ExtensionFromRepository @splat
    }
    elseif ((Test-Path $extension.Path)) {
        $extension.Add("Enabled", $true)
        Write-Host "USING PATH: $($extension.Name) ($($extension.Path))" -f Cyan
    }
    else {
        Write-Warning "Extension '$($extension.Name)' not found at $($extension.Path) - it has been disabled."
        $extension.Add("Enabled", $false)
        continue
    }
    
    # Interrogate the extension for its dependencies and exported tasks? recursive?
    $extension.Add("dependencies", (Get-ExtensionDependencies -Extension $extension))
    $extension.Add("availableTasks", (Get-ExtensionAvailableTasks -Extension $extension))

    $processedExtensionConfig += $extension

    foreach ($dependency in $extension.dependencies) {
        Write-Host "Processing dependency: $dependency"
        $processedExtensionConfig += _recursive -ExtensionConfig $dependency
    }

    return $processedExtensionConfig
}

function Get-ExtensionDependencies {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable] $Extension
    )

    if ($Extension.Name -eq "endjin-devops-firecracker") {
        return @("Endjin.RecommendedPractices.Build")
    }
    return @()
}

function Get-ExtensionAvailableTasks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable] $Extension
    )

    return @("$($Extension.Name)-placeholderTask")
}