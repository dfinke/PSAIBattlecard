@{
    RootModule        = 'PSAIBattlecard.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '5bd1a1a9-eaf8-4817-a0be-1caab274a5ff'
    Author            = 'Doug Finke'
    CompanyName       = 'Doug Finke'
    Copyright         = '(c) 2026 Doug Finke. All rights reserved.'
    Description       = 'A PowerShell-powered dashboard for comparing AI responses across providers.'
    PowerShellVersion = '7.0'
    RequiredModules   = @(
        @{ ModuleName = 'PSAISuite'; ModuleVersion = '0.8.1' }
    )
    FunctionsToExport = @(
        'Invoke-ModelComparison'
        'Get-ModelComparison'
        'Search-ModelComparison'
        'Set-ModelComparisonRating'
        'Show-ModelComparison'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('AI', 'LLM', 'PowerShell', 'PSAISuite', 'Dashboard', 'Comparison')
            LicenseUri = 'https://github.com/dfinke/PSAIBattlecard/blob/main/LICENSE'
            ProjectUri = 'https://github.com/dfinke/PSAIBattlecard'
        }
    }
}
