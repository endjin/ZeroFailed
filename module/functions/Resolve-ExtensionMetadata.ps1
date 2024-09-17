# <copyright file="Resolve-ExtensionMetadata.ps1" company="Endjin Limited">
# Copyright (c) Endjin Limited. All rights reserved.
# </copyright>
function Resolve-ExtensionMetadata {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Value
    )

    Write-Verbose "Unresolved extension metadata: $($Value | ConvertTo-Json)"

    if ($Value -is [string]) {
        $extension = @{}
        # Check if the value is a path by looking for directory separators
        # NOTE: On Windows we can use either the backslash or forward slash as a directory separator, so 
        #       we need to account for both.
        $regex = "{0}|{1}" -f [System.Text.RegularExpressions.Regex]::Escape([IO.Path]::DirectorySeparatorChar),
                              [IO.Path]::AltDirectorySeparatorChar
        if ($Value -imatch $regex) {
            # Handle the Simple syntax referencing a file path to the module
            $extension.Add("Path", $Value)
            # Locate the module manifest to derive the module name.  We need this name 
            # to be accurate to ensure our duplicate extension detection works correctly.
            $moduleManifestPaths = Get-ChildItem -Path $Value -Filter "*.psd1" | Where-Object { $_.BaseName -ne "dependencies" }
            $moduleManifestPath = $moduleManifestPaths | Select-Object -First 1
            if ($moduleManifestPath.Count -gt 1) {
                Write-Warning "Found multiple module manifest files in '$Value' - using the first one found ($moduleManifestPath.BaseName)"
            }
            $extension.Add("Name", $moduleManifestPath.BaseName)
        }   
        else {
            # Simple syntax referencing a module name
            $extension.Add("Name", $Value)
        }
    }
    elseif ($Value -is [hashtable]) {
        # Assume full object-based syntax
        $extension = $Value
    }
    else {
        throw "Invalid extension configuration syntax. Expected a string or hashtable, but found $($Value.GetType().Name)"
    }

    Write-Verbose "Resolved extension metadata: $($extension | ConvertTo-Json)"
    return $extension
}