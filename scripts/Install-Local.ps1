[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$DestinationRoot,

    [Parameter(Mandatory = $false)]
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$manifestPath = Join-Path -Path $repoRoot -ChildPath 'PSAIBattlecard.psd1'
$manifest = Test-ModuleManifest -Path $manifestPath

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $documents = [Environment]::GetFolderPath('MyDocuments')
    $DestinationRoot = Join-Path -Path $documents -ChildPath 'PowerShell\Modules'
}

$moduleRoot = Join-Path -Path $DestinationRoot -ChildPath $manifest.Name
$destination = Join-Path -Path $moduleRoot -ChildPath $manifest.Version.ToString()

if ($Clean -and (Test-Path -LiteralPath $moduleRoot)) {
    if ($PSCmdlet.ShouldProcess($moduleRoot, 'Remove existing local module installation')) {
        Remove-Item -LiteralPath $moduleRoot -Recurse -Force
    }
}

if ($PSCmdlet.ShouldProcess($destination, 'Install PSAIBattlecard locally')) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null

    foreach ($item in @(
            'Assets'
            'Public'
            'PSAIBattlecard.psd1'
            'PSAIBattlecard.psm1'
            'README.md'
            'LICENSE'
        )) {
        $source = Join-Path -Path $repoRoot -ChildPath $item
        $target = Join-Path -Path $destination -ChildPath $item
        if (Test-Path -LiteralPath $source) {
            Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
        }
    }

    Import-Module (Join-Path -Path $destination -ChildPath 'PSAIBattlecard.psd1') -Force
    Get-Module PSAIBattlecard | Select-Object Name, Version, Path
}
