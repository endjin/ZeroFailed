# <copyright file="Get-ExtensionDependencies.ps1" company="Endjin Limited">
# Copyright (c) Endjin Limited. All rights reserved.
# </copyright>
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
