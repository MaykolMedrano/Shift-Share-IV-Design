# SSIV: Shift-Share Instrumental Variables for Stata

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/MaykolMedrano/Shift-Share-IV-Design)
[![Stata](https://img.shields.io/badge/stata-18.0%2B-blue)](https://www.stata.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Stata package for shift-share (Bartik) instrumental variables estimation with modern inference methods and diagnostic checks.

## Overview

The `ssiv` command implements shift-share IV estimation following best practices from recent econometric research:

- **Borusyak, Hull & Jaravel (2025)**: Practical guidance on identification strategies
- **Goldsmith-Pinkham, Sorkin & Swift (2020)**: Share-based vs shock-based identification
- **Adão, Kolesár & Morales (2019)**: Inference with many shocks

### Key Features

✨ **Multiple identification strategies**: Classic, AKM, and Borusyak methods
🔍 **Automatic diagnostics**: First-stage tests, concentration measures, pre-trends
🛡️ **Robust inference**: Cluster-robust, wild bootstrap, AKM standard errors
📊 **Leave-one-out instruments**: Address mechanical correlation concerns
🔄 **Robustness checks**: Alternative share definitions, placebo tests
📚 **Comprehensive documentation**: Detailed help files, examples, and technical guides

## Installation

### Option 1: Manual Installation (Recommended for Development)

```stata
* Clone or download this repository
* Add the ado directory to your Stata path
adopath + "/path/to/Shift-Share-IV-Design/ado"

* Verify installation
which ssiv
help ssiv
```

### Option 2: Direct Installation from GitHub

```stata
* Install from GitHub (requires internet connection)
net install ssiv, from("https://raw.githubusercontent.com/MaykolMedrano/Shift-Share-IV-Design/main/ado")

* Or use the package file
net install ssiv, from("path/to/package")
```

### Option 3: Copy Files Manually

Copy `ado/ssiv.ado` and `help/ssiv.sthlp` to your personal ado directory:
- Windows: `C:\ado\plus\`
- Mac/Linux: `~/ado/plus/`

## Quick Start

### Basic Usage

```stata
* Load your data
use yourdata, clear

* Run shift-share IV estimation
ssiv wage_growth employment_growth, ///
    shares(emp_share_ind1 emp_share_ind2 emp_share_ind3) ///
    shocks(shock_ind1 shock_ind2 shock_ind3) ///
    cluster(state)
```

### What You Get

The command automatically:
1. Constructs the shift-share instrument: `Z_i = Σ_s w_is × g_s`
2. Runs first-stage regression and reports F-statistic
3. Performs diagnostic checks (concentration, correlation with size, etc.)
4. Estimates 2SLS with appropriate standard errors
5. Returns comprehensive results in `e()` for further analysis

## The Shift-Share Instrument

The shift-share (Bartik) instrument takes the form:

```
Z_i = Σ_s w_is × g_s
```

Where:
- `i` = regions (cities, states, countries)
- `s` = sectors (industries, occupations, origin countries)
- `w_is` = shares (region i's exposure to sector s)
- `g_s` = shocks (sector-level shocks assumed exogenous)

### Example: Immigration and Wages

Following Card (2009):

```stata
* Shares: Historical immigrant settlement patterns (1980)
* Shocks: National immigration inflows by origin (1980-2000)
* Instrument: Predicted immigration based on 1980 networks

ssiv native_wage_growth actual_immigration, ///
    shares(imm_share_origin*) ///
    shocks(national_inflow_origin*) ///
    cluster(state)
```

### Example: Trade and Employment

Following Autor, Dorn & Hanson (2013):

```stata
* Shares: Regional industry employment composition (1990)
* Shocks: Industry-level import competition (1990-2007)
* Instrument: Predicted trade exposure

ssiv employment_change trade_exposure, ///
    shares(emp_share_ind*) ///
    shocks(import_growth_ind*) ///
    cluster(state)
```

## Command Syntax

### Full Syntax

```stata
ssiv depvar endogvar [controls] [if] [in] [weight],
    shares(varlist)
    shocks(varlist)
    [method(classic|akm|borusyak)]
    [loo]
    [normalize]
    [vce(vcetype)]
    [cluster(varname)]
    [altshares(varlist)]
    [saveiv(newvar)]
    [nodiagnostics]
```

### Required Options

- `shares(varlist)` - Share variables (w_is), one per sector
- `shocks(varlist)` - Shock variables (g_s), one per sector or single variable

### Main Options

| Option | Description | Default |
|--------|-------------|---------|
| `method()` | Estimation method: `classic`, `akm`, or `borusyak` | `borusyak` |
| `loo` | Use leave-one-out instrument construction | off |
| `normalize` | Standardize shocks to z-scores | off |
| `cluster(var)` | Cluster standard errors by variable | region-level |
| `vce()` | Variance-covariance estimation type | `robust` |
| `altshares()` | Alternative shares for robustness check | - |
| `saveiv(name)` | Save constructed instrument as new variable | - |
| `nodiagnostics` | Suppress diagnostic output | show diagnostics |

## Examples

### Example 1: Basic Simulation

```stata
* Run the provided simulation example
do examples/example_sim_basic.do

* This generates synthetic data and demonstrates:
* - Coefficient recovery (true effect = 0.5)
* - First-stage diagnostics
* - Comparison with OLS (biased)
* - Leave-one-out robustness
```

**Expected output:**
- First-stage F-statistic > 10 ✓
- IV coefficient ≈ 0.5 (true value)
- OLS coefficient biased upward
- Diagnostics show no major concerns

### Example 2: Immigration Application

```stata
* Run immigration example (Card-style)
do examples/example_immigration.do

* Demonstrates:
* - Historical settlement patterns as shares
* - National inflows as shocks
* - Negative effect of immigration on native wages
* - Robustness to alternative share definitions
```

### Example 3: Trade Shocks Application

```stata
* Run industry growth example (ADH-style)
do examples/example_industry_growth.do

* Demonstrates:
* - Industry employment shares
* - Import competition shocks
* - Effects on unemployment, wages, population
* - Heterogeneous effects by education
```

## Diagnostic Checks

The `ssiv` command performs automatic diagnostic checks (unless `nodiagnostics` specified):

### 1. Identification Path Determination

```
Number of shocks: 15
-> Recommendation: Use share-based identification (few shocks)
```

- S ≥ 20: Many shocks → shock-based identification
- S < 20: Few shocks → share-based identification

### 2. First-Stage Strength

```
F-statistic on excluded instrument: 45.32
First stage F-statistic indicates strong instrument
```

- F > 23.1: Strong instrument ✓
- 10 < F < 23.1: Moderate strength
- F < 10: Weak instrument ⚠️

### 3. Concentration (Herfindahl Index)

```
Herfindahl index: 0.1234
Concentration acceptable (H < 0.25)
```

- H < 0.15: Low concentration (many sectors)
- 0.15 < H < 0.25: Moderate
- H > 0.25: High concentration ⚠️ (dominant sector)

### 4. Correlation with Size

```
Correlation(IV, weight): 0.134
Correlation with size acceptable
```

- |ρ| < 0.2: Good
- 0.2 < |ρ| < 0.3: Acceptable
- |ρ| > 0.3: Potential concern ⚠️

## Robustness Checks

### Leave-One-Out

```stata
* Standard specification
ssiv Y X, shares(w*) shocks(g*) cluster(state)
estimates store main

* Leave-one-out specification
ssiv Y X, shares(w*) shocks(g*) cluster(state) loo
estimates store loo

* Compare
estimates table main loo, b(%7.4f) se(%7.4f) stats(F_stat)
```

### Alternative Shares

```stata
* Test robustness to share definition
ssiv Y X, ///
    shares(emp_shares*) ///
    shocks(g*) ///
    altshares(payroll_shares*) ///
    cluster(state)

* Reports both specifications automatically
```

### Different Methods

```stata
* Classic Bartik
ssiv Y X, shares(w*) shocks(g*) method(classic) cluster(state)
estimates store classic

* Borusyak framework
ssiv Y X, shares(w*) shocks(g*) method(borusyak) cluster(state)
estimates store borusyak

* AKM inference (for many shocks)
ssiv Y X, shares(w*) shocks(g*) method(akm) cluster(state)
estimates store akm

estimates table classic borusyak akm
```

## Stored Results

The `ssiv` command stores results in `e()`:

### Scalars

```stata
e(N)            Number of observations
e(F_stat)       First-stage F-statistic
e(F_p)          First-stage p-value
e(herf_index)   Herfindahl concentration index
e(corr_size)    Correlation with region size
e(n_shocks)     Number of shocks
e(n_shares)     Number of shares
```

### Macros

```stata
e(cmd)          ssiv
e(method)       Estimation method
e(depvar)       Dependent variable
e(endogvar)     Endogenous variable
e(vcetype)      Variance-covariance type
```

### Matrices

```stata
e(b)            Coefficient vector
e(V)            Variance-covariance matrix
```

### Example Usage

```stata
ssiv Y X, shares(w*) shocks(g*) cluster(state)

* Access stored results
display "First-stage F: " e(F_stat)
display "Herfindahl index: " e(herf_index)
display "N observations: " e(N)

* Use in further analysis
if e(F_stat) < 10 {
    display "Warning: Weak instrument detected"
}
```

## Testing

### Run All Tests

```stata
* Navigate to tests directory
cd tests

* Run comprehensive test suite
do run_all.do
```

### Individual Tests

```stata
* Test 1: Basic simulation and coefficient recovery
do tests/test_sim_basic.do

* Test 2: Leave-one-out consistency
do tests/test_loo.do

* Test 3: Dominant sector detection
do tests/test_dominant_sector.do

* Test 4: Inference methods
do tests/test_inference.do

* Test 5: Alternative shares robustness
do tests/test_altshares.do
```

**Expected result:** All tests should pass with success rate ≥ 80%

## Documentation

### Quick Reference

- `help ssiv` - Command documentation in Stata
- `README.md` - This file (overview and quick start)
- `CHANGELOG.md` - Version history and changes

### Technical Documentation

- `docs/methodology.md` - Detailed methodology and formulas
- `docs/assumptions.md` - Identification assumptions and threats
- `docs/borusyak_checklist.md` - Best practices checklist

### Examples

- `examples/example_sim_basic.do` - Basic simulation
- `examples/example_immigration.do` - Immigration application
- `examples/example_industry_growth.do` - Trade/industry application

### Replication

- `replication/` - Scripts to replicate key results from the literature

## When to Use Shift-Share IV

### ✅ Good Use Cases

1. **Regional economic shocks**
   - Trade exposure (Autor, Dorn & Hanson 2013)
   - Immigration (Card 2009)
   - Industry composition effects

2. **Pre-determined exposure with exogenous shocks**
   - Historical shares + contemporary shocks
   - Many independent shocks
   - Clear identification strategy

3. **Cross-sectional variation**
   - Spatial variation in treatment intensity
   - Differential exposure to common shocks

### ⚠️ When to Be Careful

1. **Endogenous shares**
   - Recent shares that reflect anticipation
   - Shares that respond to outcomes

2. **Correlated shocks**
   - Common factors across sectors
   - Few shocks with high correlation

3. **Weak instruments**
   - Low variation in shares
   - Small shocks
   - First-stage F < 10

## Troubleshooting

### Problem: Weak First Stage (F < 10)

**Solutions:**
- Check shock variation: `summarize shock*`
- Check share variation: `summarize share*`
- Consider using stronger shocks
- Check for data errors
- Try alternative share definitions

### Problem: High Concentration (H > 0.3)

**Solutions:**
- Identify dominant sector: examine individual contributions
- Test robustness to dropping dominant sector
- Use share-based identification (few shocks)
- Consider whether dominant sector is appropriate

### Problem: High Correlation with Size

**Solutions:**
- Include size controls in regression
- Use population weights
- Consider per-capita outcomes
- Check if relationship is mechanical

### Problem: Pre-Trends Detected

**Solutions:**
- Include pre-trend controls
- Use older/lagged shares
- Revisit identification assumptions
- Consider alternative instruments

## Contributing

We welcome contributions! Please see `CONTRIBUTING.md` for guidelines on:
- Reporting bugs
- Suggesting enhancements
- Submitting pull requests
- Code style and testing requirements

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `do tests/run_all.do`
5. Submit a pull request

## Citation

If you use this package in your research, please cite:

```bibtex
@software{ssiv2025,
  author = {{Claude Code}},
  title = {SSIV: Shift-Share Instrumental Variables for Stata},
  year = {2025},
  version = {0.1.0},
  url = {https://github.com/MaykolMedrano/Shift-Share-IV-Design}
}
```

And please cite the underlying methodological papers:

```bibtex
@article{borusyak2025practical,
  title={A Practical Guide to Shift-Share Instruments},
  author={Borusyak, Kirill and Hull, Peter and Jaravel, Xavier},
  journal={Journal of Economic Perspectives},
  volume={39},
  number={1},
  pages={181--204},
  year={2025}
}

@article{goldsmith2020bartik,
  title={Bartik Instruments: What, When, Why, and How},
  author={Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
  journal={American Economic Review},
  volume={110},
  number={8},
  pages={2586--2624},
  year={2020}
}

@article{adao2019shift,
  title={Shift-Share Designs: Theory and Inference},
  author={Ad{\~a}o, Rodrigo and Koles{\'a}r, Michal and Morales, Eduardo},
  journal={The Quarterly Journal of Economics},
  volume={134},
  number={4},
  pages={1949--2010},
  year={2019}
}
```

## References

### Key Papers

- **Borusyak, K., Hull, P., & Jaravel, X. (2025)**. A Practical Guide to Shift-Share Instruments. *Journal of Economic Perspectives*, 39(1), 181-204.

- **Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020)**. Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586-2624.

- **Adão, R., Kolesár, M., & Morales, E. (2019)**. Shift-Share Designs: Theory and Inference. *The Quarterly Journal of Economics*, 134(4), 1949-2010.

### Applications

- **Autor, D. H., Dorn, D., & Hanson, G. H. (2013)**. The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121-68.

- **Bartik, T. J. (1991)**. *Who Benefits from State and Local Economic Development Policies?* W.E. Upjohn Institute for Employment Research.

- **Card, D. (2009)**. Immigration and Inequality. *American Economic Review*, 99(2), 1-21.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Support

- **Issues**: Report bugs and request features at [GitHub Issues](https://github.com/MaykolMedrano/Shift-Share-IV-Design/issues)
- **Documentation**: See `docs/` directory for detailed technical documentation
- **Examples**: See `examples/` directory for reproducible examples

## Acknowledgments

This package implements methodology developed by:
- Kirill Borusyak, Peter Hull, and Xavier Jaravel
- Paul Goldsmith-Pinkham, Isaac Sorkin, and Henry Swift
- Rodrigo Adão, Michal Kolesár, and Eduardo Morales

Special thanks to the econometrics community for advancing shift-share methodology.

---

**Version**: 0.1.0
**Last Updated**: 2025-12-04
**Stata Version**: 18.0+
**Author**: Claude Code
**Repository**: https://github.com/MaykolMedrano/Shift-Share-IV-Design
