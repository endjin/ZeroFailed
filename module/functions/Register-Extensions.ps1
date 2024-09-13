# <copyright file="Register-Extensions.ps1" company="Endjin Limited">
# Copyright (c) Endjin Limited. All rights reserved.
# </copyright>
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

        $registeredExtensions = Register-ExtensionAndDependencies -ExtensionConfig $ExtensionsConfig[$i]
        
        # Persist the fully-populated extension metadata
        $processedExtensionConfig += $registeredExtensions
    }

    return $processedExtensionConfig
}
