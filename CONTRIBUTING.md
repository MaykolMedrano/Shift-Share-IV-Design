# Contributing to SSIV Package

Thank you for your interest in contributing to the Shift-Share IV (SSIV) Stata package! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive criticism
- Prioritize the community's best interests

## How Can I Contribute?

### Reporting Bugs

Bugs are tracked as [GitHub Issues](https://github.com/MaykolMedrano/Shift-Share-IV-Design/issues). When reporting a bug, please include:

#### Bug Report Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Load data '...'
2. Run command '...'
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened. Include error messages.

**Minimal reproducible example**
Provide minimal Stata code that reproduces the issue:

\`\`\`stata
clear all
set obs 100
gen x = rnormal()
gen y = rnormal()
* Your ssiv command that produces the error
ssiv y x, shares(...) shocks(...)
\`\`\`

**Environment**
- OS: [e.g., Windows 10, macOS 12.0, Ubuntu 20.04]
- Stata version: [e.g., Stata 17 MP, Stata 18 SE]
- SSIV package version: [e.g., 0.1.0]

**Additional context**
Any other context about the problem.

**Log output**
```
Paste relevant Stata log output here
```
```

### Suggesting Enhancements

Enhancement suggestions are also tracked as GitHub Issues. When suggesting an enhancement:

#### Enhancement Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem. Ex. "I'm always frustrated when [...]"

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Use case**
Describe a specific research application where this feature would be useful.

**Additional context**
Any other context, mockups, or examples.
```

### Good First Issues

Look for issues labeled `good first issue` if you're new to the project. These are typically:
- Documentation improvements
- Simple bug fixes
- Adding examples
- Test improvements

## Pull Requests

### Before Submitting a Pull Request

1. **Check existing issues and PRs** to avoid duplication
2. **Create an issue** describing what you plan to do (for major changes)
3. **Fork the repository** and create a feature branch
4. **Follow coding standards** (see below)
5. **Add tests** for new functionality
6. **Update documentation** as needed

### Pull Request Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding standards

3. **Test your changes**:
   ```stata
   * Run all tests
   cd tests
   do run_all.do

   * Run specific tests
   do test_sim_basic.do
   do test_loo.do
   ```

4. **Update documentation**:
   - Update `README.md` if adding new features
   - Update `help/ssiv.sthlp` if changing command syntax
   - Update `CHANGELOG.md` with your changes
   - Add comments to your code

5. **Commit your changes** with clear commit messages:
   ```bash
   git commit -m "Add feature: brief description

   - Detailed change 1
   - Detailed change 2
   - Fixes #123 (if applicable)"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request** with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference to related issues
   - Testing results
   - Documentation updates

### Pull Request Template

```markdown
**Description**
Brief description of changes

**Motivation and Context**
Why is this change needed? What problem does it solve?

**Related Issue**
Fixes #(issue number)

**Type of Change**
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

**How Has This Been Tested?**
Describe the tests you ran and their results:
- [ ] Ran `do tests/run_all.do` - all tests passed
- [ ] Added new test: `test_newfeature.do`
- [ ] Tested on Stata version(s): [e.g., 17, 18]
- [ ] Tested on OS: [e.g., Windows, macOS, Linux]

**Checklist**
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have updated CHANGELOG.md
```

## Development Setup

### Prerequisites

- Stata 18.0 or higher (may work with earlier versions)
- Git for version control
- Text editor (VS Code, Sublime Text, or Stata Do-file Editor)

### Getting Started

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Shift-Share-IV-Design.git
   cd Shift-Share-IV-Design
   ```

2. **Add the ado directory to your Stata path**:
   ```stata
   adopath + "/path/to/Shift-Share-IV-Design/ado"
   ```

3. **Test your setup**:
   ```stata
   which ssiv
   help ssiv
   do examples/example_sim_basic.do
   ```

## Coding Standards

### Stata Code Style

1. **Use descriptive variable and program names**
   ```stata
   * Good
   gen employment_growth = ...
   local first_stage_F = ...

   * Avoid
   gen x1 = ...
   local f = ...
   ```

2. **Use comments liberally**
   ```stata
   * Calculate the shift-share instrument
   * Formula: Z_i = sum_s w_is * g_s
   gen double `ssiv_instrument' = 0
   forvalues s = 1/`nshares' {
       // Add contribution of sector s
       replace `ssiv_instrument' = `ssiv_instrument' + ...
   }
   ```

3. **Use temporary variables**
   ```stata
   * Always use tempvar for temporary variables
   tempvar instrument temp_sum
   gen double `instrument' = ...

   * Never create permanent variables unless explicitly needed
   ```

4. **Proper indentation** (4 spaces)
   ```stata
   program define myprogram, eclass
       syntax varlist [if] [in], shares(varlist)

       marksample touse

       if "`touse'" != "" {
           quietly {
               // Indented code
           }
       }
   end
   ```

5. **Error handling**
   ```stata
   * Check inputs
   if "`shares'" == "" {
       di as error "shares() option required"
       exit 198
   }

   * Validate data
   capture assert `variable' >= 0
   if _rc {
       di as error "Variable must be non-negative"
       exit 459
   }
   ```

6. **Use `quietly` judiciously**
   ```stata
   * Use quietly for intermediate steps
   quietly {
       gen temp = ...
       replace temp = ...
   }

   * But show important output
   di as text "First-stage F-statistic: " %8.2f `F_stat'
   ```

### Documentation Standards

1. **Header comments** for programs:
   ```stata
   *! version 0.1.0  04dec2025
   *! Shift-Share IV Estimation
   *! Author: Your Name

   program define ssiv, eclass
       version 18.0
       // Program code
   end
   ```

2. **Inline comments** for complex logic:
   ```stata
   * Check if using shock-based or share-based identification
   * Rule: >= 20 shocks -> shock-based; < 20 -> share-based
   if `nshocks' >= 20 {
       local id_path "shocks"
   }
   else {
       local id_path "shares"
   }
   ```

3. **Update help files** when changing syntax
   - Modify `help/ssiv.sthlp` for any syntax changes
   - Include examples for new options
   - Update stored results section

## Testing

### Running Tests

Before submitting a PR, run all tests:

```stata
* Navigate to tests directory
cd tests

* Run all tests
do run_all.do

* Should see: "Tests passed: 5 / 5"
```

### Adding Tests

When adding new features, add corresponding tests:

1. **Create a new test file**: `tests/test_yourfeature.do`

2. **Follow the test template**:
   ```stata
   ********************************************************************************
   * SSIV Package - Test N: Your Feature
   * Purpose: Test description
   * Expected: What should happen
   ********************************************************************************

   clear all
   set more off
   set seed [seed]

   di ""
   di "====================================================================="
   di "TEST N: Your Feature"
   di "====================================================================="
   di ""

   * Add ado path
   adopath + "../ado"

   * Generate test data
   // ... data generation code ...

   * Run test
   // ... test code ...

   * Assertions
   di "TEST ASSERTIONS:"

   scalar test1_pass = ...
   scalar test2_pass = ...

   * Summary
   di "TEST SUMMARY:"
   scalar total_pass = test1_pass + test2_pass + ...
   di "Tests passed: " total_pass " / " total_tests

   if total_pass == total_tests {
       scalar exit_code = 0
   }
   else {
       scalar exit_code = 1
   }

   exit `=exit_code'
   ```

3. **Add test to `run_all.do`**

### Test Categories

- **Unit tests**: Test individual functions/components
- **Integration tests**: Test full command workflow
- **Regression tests**: Ensure bug fixes stay fixed
- **Edge case tests**: Test boundary conditions

## Documentation Updates

When contributing, update relevant documentation:

1. **README.md**: For new features, usage changes
2. **help/ssiv.sthlp**: For syntax changes
3. **CHANGELOG.md**: Always describe your changes
4. **docs/*.md**: For methodological additions

## Questions?

If you have questions:

1. Check existing documentation in `docs/`
2. Search existing issues
3. Open a new issue with your question
4. Tag it with `question` label

## Attribution

Contributors will be acknowledged in:
- `CHANGELOG.md` for their specific contributions
- A `CONTRIBUTORS.md` file (if created)
- Git history

Thank you for contributing to SSIV!
