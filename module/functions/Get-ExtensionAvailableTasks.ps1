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
    $tasksToImport = Get-TasksFileListFromExtension -TasksPath $tasksDir
    $availableTasks = @()
    $tasksToImport |
        # Treat tasks with a '_' prefix as private and exclude them
        Where-Object { !$_.BaseName.StartsWith("_") } |
        ForEach-Object {
            Write-Verbose "Importing task '$($_.FullName)'"
            # This is probably a sign that we should have a different approach for enumerating the
            # tasks in each extension, but for now we'll just suppress any errors that might occur
            # when trying to dotsource the file.  For example, since this function is running in a
            # module scope, certain values referenced in the task files may not be available.
            $availableTasks += try { . $_ } catch {}
        }
    return $availableTasks
}