<#PSScriptInfo

.VERSION 0.1

.AUTHOR Tim Gudlewski

.COMPANYNAME

.COPYRIGHT

.TAGS Concatenate Notes Text Files

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
First version

#>

<#

.DESCRIPTION
Take the contents of multiple *.txt files in the current directory and
concatenate them all into one file, and open that file in vim. Pass in how many
days ago you want to start collecting file contents from.

#>

function New-NoteColl {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position = 0, Mandatory = $false)] [int]$days_ago)

    $x_days_ago = (Get-Date) - (New-TimeSpan -Days $days_ago)

    $notes_dir_contents_since_x = Get-ChildItem -Filter "*.txt" | `
            Sort-Object LastWriteTime | `
            Where-Object { $_.CreationTime -ge $x_days_ago }

    $out_path = "all_from_$($x_days_ago.ToString("yyyy-MM-dd(hh-mm-ss)"))_to_$(Get-Date -Format "yyyy-MM-dd(hh-mm-ss)")"

    $notes_dir_contents_since_x | ForEach-Object `
    { "`n******************* $($_.CreationTime) *******************`n`n$($(Get-Content $_) -Join "`n" )" } `
    | Out-File -FilePath $out_path

    vim $out_path
}


