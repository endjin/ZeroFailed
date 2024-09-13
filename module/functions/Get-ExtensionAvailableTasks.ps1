# <copyright file="Get-ExtensionAvailableTasks.ps1" company="Endjin Limited">
# Copyright (c) Endjin Limited. All rights reserved.
# </copyright>
function Get-ExtensionAvailableTasks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable] $Extension
    )

    # Define a private override implementation for the 'task' keyword used in in '*.tasks.ps1' files that
    # simply returns the task name as a string.  We will use this as a simple mechanism to discover
    # all of the tasks defined by an extension.
    function task {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory, Position = 0)]
            [string] $TaskName,
    
            [Parameter(ValueFromRemainingArguments)]
            $Remaining
        )
    
        return $TaskName
    }

    $tasksDir = Join-Path $Extension.Path "tasks"
    $tasksToImport = Import-TasksFromExtension -TasksPath $tasksDir
    $availableTasks = @()
    $tasksToImport |
        # Treat tasks with a '_' prefix as private and exclude them
        Where-Object { !$_.BaseName.StartsWith("_") } |
        ForEach-Object {
            Write-Verbose "Importing task '$($_.FullName)'"
            $availableTasks += . $_
        }

    return $availableTasks
}