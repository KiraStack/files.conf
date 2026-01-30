# Copyright (c) 2025, Kira Hasegawa
# Licensed under the MIT license.

# Handle version-dependent settings
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # Handle predictions
    Set-PSReadLineOption -PredictionViewStyle InlineView -Colors @{
            InlinePrediction = $PSStyle.Foreground.White # old: $PSStyle.Foreground.Green
        }
} else {
    # Can not handle predictions
}

# Handle prompt displays
function prompt {
    $cwd = (Get-Location).Path.ToLower() `
        -replace '^([a-z]):', '/$1' `
        -replace '\\', '/' `
        -replace '\s+', '-'      # no drive, less slashes, no spaces

    Write-Host "`n$cwd`n>" -NoNewline -ForegroundColor Green
    return " "
}
