---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

A clear and concise description of what the bug is.

## To Reproduce

Steps to reproduce the behavior:

1. Load data: `use ...`
2. Run command: `ssiv ...`
3. See error

## Minimal Reproducible Example

Please provide minimal Stata code that reproduces the issue:

```stata
clear all
set seed 12345

* Generate minimal data
set obs 100
gen region_id = _n
gen y = rnormal()
gen x = rnormal()
gen share1 = runiform()
gen share2 = 1 - share1
gen shock1 = rnormal()
gen shock2 = rnormal()

* Command that produces error
ssiv y x, shares(share1 share2) shocks(shock1 shock2)
```

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened. Please include the complete error message:

```
[Paste error message here]
```

## Environment

- **Operating System**: [e.g., Windows 10, macOS 12.0, Ubuntu 20.04]
- **Stata Version**: [e.g., Stata 17 MP, Stata 18 SE, Stata 17 IC]
- **Stata Flavor**: [MP/SE/IC]
- **SSIV Package Version**: [e.g., 0.1.0 - check with `which ssiv`]

## Log Output

If applicable, paste relevant Stata log output:

```
[Paste log output here]
```

## Additional Context

Add any other context about the problem here. For example:
- Does it work with other datasets?
- Did it work in a previous version?
- Any unusual data characteristics?

## Possible Solution

If you have suggestions for how to fix the issue, please describe them here.
