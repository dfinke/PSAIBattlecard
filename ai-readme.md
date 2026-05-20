# AI Context: PSAIBattlecard

This file gives AI coding agents and automated review tools the local context needed to make changes that fit this repository.

## Purpose

PSAIBattlecard is a PowerShell module for comparing AI model responses across providers. It uses `PSAISuite` for provider abstraction, runs prompts against one or more `provider:model` entries, and stores prompts, responses, latency, errors, and human ratings in a local JSON file.

This is a dashboard and command-line utility, not a general agent framework. Keep changes focused on the model comparison workflow unless a task explicitly expands the scope.

## Repository Map

- `PSAIBattlecard.psd1`: Module manifest. Declares PowerShell `7.0`, `PSAISuite` `0.8.1`, exported functions, tags, and Gallery metadata.
- `PSAIBattlecard.psm1`: Dot-sources `Public/*.ps1` and exports the public command surface.
- `Public/Invoke-ModelComparison.ps1`: Store helpers, schema initialization, model parsing, summary projection, and the main comparison command.
- `Public/Show-ModelComparison.ps1`: Dashboard HTML renderer and local `HttpListener` API server.
- `Public/Get-ModelComparison.ps1`: Reads previous comparison runs.
- `Public/Search-ModelComparison.ps1`: Searches prompts, responses, models, categories, and tags.
- `Public/Set-ModelComparisonRating.ps1`: Updates response ratings and user notes.
- `__tests__/ModelComparison.Tests.ps1`: Pester coverage for store behavior, dashboard rendering, server API behavior, ratings, and failure capture.
- `examples/`: Paste-ready prompt and model rosters.
- `docs/`: Demo notes and screenshot assets.
- `artifacts/`: Packaging output. Treat as generated unless the user asks otherwise.

## Public Commands

- `Show-ModelComparison`: Render or launch the dashboard.
- `Invoke-ModelComparison`: Run a prompt against multiple models.
- `Get-ModelComparison`: Read stored comparison runs.
- `Search-ModelComparison`: Search stored runs.
- `Set-ModelComparisonRating`: Store human ratings and notes on a response.

When adding a public command, update `PSAIBattlecard.psm1`, `PSAIBattlecard.psd1`, tests, and README usage examples together.

## Runtime Model

- Model entries use `provider:model` text, for example `openai:gpt-4o-mini`.
- Provider calls must go through `PSAISuite` and `Invoke-ChatCompletion`.
- Do not implement direct REST calls to OpenAI, Anthropic, Google, DeepSeek, or other providers unless the user explicitly asks for that architecture change.
- `Invoke-ModelComparison` captures successful responses and provider errors as response objects. Provider failures should become `status = 'Failed'`, `needsReview = $true`, and include a concrete error message.
- `Show-ModelComparison -Open` starts a local dashboard server with `/api/health`, `/api/store`, `/api/compare`, `/api/rating`, and `/api/shutdown`.

## JSON Store Contract

The default store path is:

```powershell
$env:LOCALAPPDATA\PSAIBattlecard\model-comparisons.json
```

When `LOCALAPPDATA` is unavailable, the fallback is:

```powershell
$HOME\.psaibattlecard\model-comparisons.json
```

Preserve `schemaVersion = 1` compatibility. Store files contain:

- `schemaVersion`
- `createdAt`
- `updatedAt`
- `ratingCategories`
- `runs`

Each run contains prompt metadata, model list, tags, optional benchmark fields, and `responses`. Each response contains provider/model identity, response text, error text, status, latency, review flags, notes, and ratings.

Rating values are tri-state:

- `Up` maps to `$true`
- `Down` maps to `$false`
- `Clear` maps to `$null`

Use `ConvertTo-Json -Depth 64` when writing the store. After reading JSON, normalize scalar-or-array properties with `@(...)` before iterating.

## PowerShell Conventions

- Public and helper functions should use `[CmdletBinding()]`.
- Parameters should be explicitly typed.
- Use `ValidateSet` for finite user-facing choices.
- Emit clean `PSCustomObject` values that flatten well in the PowerShell pipeline and spreadsheet workflows.
- Prefer stable object property names over display-only formatting.
- Keep internal JSON keys compatible with the existing lower-camel-case shape.
- Keep summary output pipeline-friendly and avoid hidden host-only behavior.

## Error Handling

- Do not use silent failures or empty `catch` blocks.
- Provider-facing calls should catch exceptions and surface concrete messages in response objects.
- User-facing commands should throw clear selector or validation errors, for example when no run or response matches.
- Do not swallow dashboard server errors that would make tests or calling automation believe a run succeeded.

## Dashboard Guidance

The dashboard HTML, CSS, JavaScript, and local API server live in `Public/Show-ModelComparison.ps1`. When changing this file:

- Preserve the one-screen compare, review, history, and rating workflow.
- Keep the API shape compatible with the existing frontend and tests.
- Avoid adding external frontend build steps unless explicitly requested.
- Update Pester assertions when intentional HTML or API behavior changes.
- Verify that generated HTML still renders the prompt box, model list, response cards, history, and rating controls.

## Testing

Use Pester for validation:

```powershell
Import-Module .\PSAIBattlecard.psd1 -Force
Invoke-Pester .\__tests__
```

For dashboard server work, include tests or manual verification for:

- store creation
- `/api/store`
- `/api/compare`
- `/api/rating`
- shutdown cleanup
- failed provider calls becoming failed responses

## Publishing Notes

Publishing is handled by `PublishToGallery.ps1`, which stages a clean module package under `artifacts/PSAIBattlecard` and calls `Publish-PSResource`.

Use:

```powershell
.\PublishToGallery.ps1 -WhatIf
```

before an actual Gallery publish unless the user gives direct publish instructions.

## Change Checklist For Agents

Before finishing a code change:

- Keep the scope limited to the requested behavior.
- Preserve `PSAISuite` as the provider abstraction layer.
- Preserve JSON schema compatibility or document the migration clearly.
- Add or update Pester tests for changed behavior.
- Run the relevant tests when possible.
- Mention any tests that could not be run.
