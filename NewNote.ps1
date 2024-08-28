function New-Note {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position = 0, Mandatory = $false)] [String]$new_win_flag)

    # The date of the chosen file name is set to today's date.
    $file_name_base = Get-Date -Format "MM-dd-yy"

    $file_name_suffix = 'a'

    $file_name_ext = 'txt'

    $file_name = "$($file_name_base)_$($file_name_suffix).$($file_name_ext)"

    $fnl = $file_name.Length

    $base_matches = [System.Collections.ArrayList]@()

    # Script block for opening the note.
    $sb = {
        # file name; new window flag
        param($fn, $nwf)
        # s for same window
        if ($nwf -eq 's') {
            vim $fn
        }
        else {
            Start-Process powershell.exe `
            -ArgumentList "-NoExit -Command vim $($fn); exit"
        }
    }

    $contains_collision = $false

    $notes_dir_contents = Get-ChildItem

    # Check if any child item (ci) of the current directory will cause a name
    # collision with the chosen file name.
    foreach ($ci in $notes_dir_contents) {
        if ($ci.Name -eq $file_name) {
            $contains_collision = $true
            break
        }
    }

    # If there will not be a name collision, run the script block.
    if (-not $contains_collision) {
        & $sb $file_name $new_win_flag
    }

    # If there will be a collision, collect all the file name suffixes that
    # exist for the same date as the chosen file name.
    else {
        foreach ($ci in $notes_dir_contents) {
            $n = $ci.Name
            if (($n.Length -eq $fnl) `
                    -and ($n.Substring(0, 8) -eq $file_name_base) `
                    -and ($n.Substring(11) -eq $file_name_ext)) {
                $arrayID = $base_matches.Add($([byte][char]$n[-5]))
            }
        }

        # Store the max file name suffix for notes with the same date as the
        # chosen file name.
        $max_fns = $base_matches[$base_matches.Count - 1]

        # 121 is 'z'
        if ($max_fns -gt 121) {
            "too many notes today"
            return
        }

        # Set file_name_suffix to the next available letter.
        $file_name_suffix = [char]($max_fns + 1)

        $file_name = "$($file_name_base)_$($file_name_suffix).$($file_name_ext)"
        & $sb $file_name $new_win_flag
    }
}

