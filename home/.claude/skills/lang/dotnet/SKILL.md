---
name: dotnet
description:
  Guide for working with .NET and C# using the dotnet CLI - building, testing,
  formatting, managing packages, and configuring analyzers. Use this when
  editing .csproj/.sln files, running dotnet commands, or setting up build,
  lint, and dependency conventions in a C# project.
---

# dotnet

The `dotnet` CLI builds, tests, runs, formats, and packages C# projects. This
skill covers idiomatic project configuration and the everyday commands.

## When to use this skill

Use it for any C#/.NET work, especially when you see:

- SDK-style `.csproj` (`<Project Sdk="Microsoft.NET.Sdk">`) or a `.sln`.
- `global.json`, `Directory.Build.props`, `Directory.Packages.props`,
  `.editorconfig`, or `nuget.config`.
- A `dotnet` invocation in scripts/CI.

## Commands

```bash
# Build / run / test
dotnet restore                      # restore NuGet packages
dotnet build                        # build (implies restore)
dotnet build -c Release             # release build
dotnet run --project src/App        # run a project
dotnet test                         # run tests
dotnet test --collect:"XPlat Code Coverage"

# Packages
dotnet add package Newtonsoft.Json              # add latest
dotnet add package Newtonsoft.Json -v 13.0.3    # pin version
dotnet remove package Newtonsoft.Json
dotnet list package --outdated                  # find updates
dotnet list package --vulnerable                # security check

# Formatting / analysis
dotnet format                       # apply .editorconfig formatting + fixes
dotnet format --verify-no-changes   # CI check: fail if unformatted
dotnet format style                 # only code-style fixes
dotnet format analyzers             # only analyzer fixes

# Solution / project scaffolding
dotnet new console -n MyApp
dotnet new classlib -n MyLib
dotnet new gitignore                # standard .NET .gitignore
dotnet sln add src/MyLib/MyLib.csproj
```

## Project configuration

Prefer SDK-style projects with modern defaults turned on:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <!-- Treat warnings as errors in CI/Release to keep the bar high -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <!-- Turn on the full .NET analyzer set -->
    <EnableNETAnalyzers>true</EnableNETAnalyzers>
    <AnalysisLevel>latest-recommended</AnalysisLevel>
  </PropertyGroup>
</Project>
```

Guidance:

- **Enable nullable reference types** (`<Nullable>enable</Nullable>`) and fix
  warnings rather than suppressing them. Use `?`, `!`, and null checks
  deliberately.
- **Don't suppress analyzer/nullable warnings blanket-style.** When a suppression
  is truly needed, scope it: `#pragma warning disable CA1822` around the minimum
  span, or a targeted `[SuppressMessage]`, with a reason - not project-wide
  `<NoWarn>`.
- **Pin the SDK** with `global.json` for reproducible builds across machines/CI.
- **Don't commit `bin/` or `obj/`.** Use `dotnet new gitignore`.

## Central configuration

For multi-project repos, factor shared settings out:

- **`Directory.Build.props`** (repo root) - shared MSBuild properties applied to
  every project (TargetFramework, Nullable, analyzer settings, common metadata).
- **`Directory.Packages.props`** with `<ManagePackageVersionsCentrally>true</...>`
  - Central Package Management. Versions are declared once at the root via
  `<PackageVersion ... />`; individual projects use `<PackageReference Include="..." />`
  with no version. This keeps versions consistent and prevents drift.

```xml
<!-- Directory.Packages.props -->
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Newtonsoft.Json" Version="13.0.3" />
  </ItemGroup>
</Project>
```

## Formatting and style

`.editorconfig` is the single source of truth for formatting and analyzer
severity; `dotnet format` reads it. Commit one at the repo root and enforce it.

- Run `dotnet format --verify-no-changes` in CI to block unformatted code.
- Set analyzer severities (`dotnet_diagnostic.<ID>.severity = warning|error`) in
  `.editorconfig` rather than per-project `<NoWarn>`.
- Scope fixes to the code you're changing. If `dotnet format --verify-no-changes`
  reports churn across the whole repo, the project likely isn't using
  `dotnet format` - don't reformat everything in an unrelated change.

## Common patterns

### Fix warnings, don't hide them

Nullable and analyzer warnings usually point at real bugs. Resolve the
underlying issue. Only suppress with a scoped pragma or `[SuppressMessage]` and a
justification when the analyzer is genuinely wrong for that case.

### Lint/format order in CI

```bash
dotnet restore
dotnet format --verify-no-changes   # style gate
dotnet build -c Release             # warnings-as-errors gate
dotnet test
```

### Keep dependencies lean and current

Audit with `dotnet list package --outdated` and `--vulnerable` regularly. Fewer,
current packages mean fewer load-time conflicts - especially important for
plugin/host scenarios where the host already ships shared libraries.

## Documentation

- .NET CLI: https://learn.microsoft.com/dotnet/core/tools/
- Code analysis: https://learn.microsoft.com/dotnet/fundamentals/code-analysis/overview
- Central Package Management: https://learn.microsoft.com/nuget/consume-packages/central-package-management
