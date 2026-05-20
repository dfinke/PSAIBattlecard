[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey = $env:PSGALLERY_API_KEY,

    [Parameter(Mandatory = $false)]
    [string]$Repository = 'PSGallery',

    [Parameter(Mandatory = $false)]
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$manifestPath = Join-Path -Path $repoRoot -ChildPath 'PSAIBattlecard.psd1'
$manifest = Test-ModuleManifest -Path $manifestPath

if (-not $SkipTests) {
    Invoke-Pester -Path (Join-Path -Path $repoRoot -ChildPath '__tests__') -Output Detailed
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'Provide -ApiKey or set PSGALLERY_API_KEY before publishing.'
}

$artifactRoot = Join-Path -Path $repoRoot -ChildPath 'artifacts'
$packageRoot = Join-Path -Path $artifactRoot -ChildPath $manifest.Name

if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force -WhatIf:$false
}

New-Item -ItemType Directory -Path $packageRoot -Force -WhatIf:$false | Out-Null

foreach ($item in @(
        'Assets'
        'Public'
        'PSAIBattlecard.psd1'
        'PSAIBattlecard.psm1'
        'README.md'
        'LICENSE'
    )) {
    $source = Join-Path -Path $repoRoot -ChildPath $item
    $target = Join-Path -Path $packageRoot -ChildPath $item
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $target -Recurse -Force -WhatIf:$false
    }
}

Test-ModuleManifest -Path (Join-Path -Path $packageRoot -ChildPath 'PSAIBattlecard.psd1') | Out-Null

if ($PSCmdlet.ShouldProcess("$($manifest.Name) $($manifest.Version)", "Publish to $Repository")) {
    Publish-PSResource -Path $packageRoot -Repository $Repository -ApiKey $ApiKey
}
