<table>
  <tr>
    <td width="86">
      <img src="./Assets/model-comparison-icon.svg" alt="PSAIBattlecard icon" width="72" height="72">
    </td>
    <td>
      <h1>PSAIBattlecard</h1>
      <p>Compare AI responses across providers from PowerShell.</p>
    </td>
  </tr>
</table>

PSAIBattlecard is a standalone model comparison dashboard for PowerShell. It uses
[PSAISuite](https://www.powershellgallery.com/packages/PSAISuite) for multi-provider
model execution, then stores prompts, responses, latency, errors, and human ratings
in a local JSON file.

## Install

```powershell
Install-PSResource PSAIBattlecard
```

During local development from this repository:

```powershell
Import-Module .\PSAIBattlecard.psd1 -Force
```

To install the current checkout into your user module path:

```powershell
.\InstallModule.ps1 -Clean
Import-Module PSAIBattlecard -Force
```

PSAIBattlecard depends on `PSAISuite` `0.8.1` or later.

## Launch The Dashboard

```powershell
Show-ModelComparison -Open
```

By default, the dashboard uses:

```powershell
$env:LOCALAPPDATA\PSAIBattlecard\model-comparisons.json
```

You can point it at another JSON store:

```powershell
Show-ModelComparison -StorePath .\model-comparisons.json -Open
```

## Compare Models

The dashboard prompt box accepts a single prompt. The models box accepts one
provider/model pair per line:

```text
openai:gpt-4o-mini
anthropic:claude-sonnet-4-6
deepseek:deepseek-v4-flash
google:gemini-3.1-flash-lite
```

Click **Run Comparison** or press `Ctrl+Enter`. Results appear as side-by-side
cards with provider, model, latency, status, response text, and human rating
controls.

## Run From PowerShell

```powershell
$models = @(
    'openai:gpt-4o-mini'
    'anthropic:claude-sonnet-4-6'
)

Invoke-ModelComparison -Prompt 'capital of france iceland sweden in json' -Models $models
```

Search previous runs:

```powershell
Search-ModelComparison -Query 'Paris'
```

Rate a response:

```powershell
Set-ModelComparisonRating -RunId '<run id>' -Model 'openai:gpt-4o-mini' -Accuracy Up -Relevance Up
```

## Commands

- `Show-ModelComparison`: Launch or render the dashboard.
- `Invoke-ModelComparison`: Run a prompt against multiple models.
- `Get-ModelComparison`: Read the JSON store.
- `Search-ModelComparison`: Search prompts, responses, models, tags, and notes.
- `Set-ModelComparisonRating`: Store human ratings on a model response.

## Demo Materials

The `docs/demo-script.md` file has a three-minute read-aloud demo script.
Paste-ready model and prompt lists live in `examples/`.

## Publish To PowerShell Gallery

Set your Gallery API key, run tests, stage a clean module package, and publish:

```powershell
$env:PSGALLERY_API_KEY = '<your API key>'
.\PublishToGallery.ps1
```

To preview the publish operation without sending it:

```powershell
.\PublishToGallery.ps1 -WhatIf
```

The publish script packages only the module files needed by Gallery into
`artifacts/PSAIBattlecard` before calling `Publish-PSResource`.
