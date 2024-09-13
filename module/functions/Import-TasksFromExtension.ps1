# <copyright file="Import-TasksFromExtension.ps1" company="Endjin Limited">
# Copyright (c) Endjin Limited. All rights reserved.
# </copyright>
function Import-TasksFromExtension {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $TasksPath
    )

    $tasksToImport = @()
    if (Test-Path $TasksPath) {
        $extensionTaskFiles = Get-ChildItem -Path $TasksPath -Filter "*.tasks.ps1" -File
        $extensionTaskFiles |
            Where-Object { $_ } |
            ForEach-Object {
                $tasksToImport += $_
            }
    }

    return $tasksToImport
}