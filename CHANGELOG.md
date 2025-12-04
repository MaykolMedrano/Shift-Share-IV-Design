# Changelog

All notable changes to the SSIV (Shift-Share IV) package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- Full AKM inference implementation with shock covariance matrix
- Wild bootstrap standard errors (Rademacher weights)
- Rotemberg weight decomposition (Goldsmith-Pinkham et al. 2020)
- Support for panel data with time-varying shares and shocks
- Visualization tools for diagnostic plots
- Integration with `ivreg2` for extended IV diagnostics

## [0.1.0] - 2025-12-04

### Added - Initial Release

#### Core Functionality
- **Main command `ssiv`**: Shift-share IV estimation with 2SLS
- **Three estimation methods**:
  - `classic`: Traditional Bartik IV
  - `akm`: Framework for many shocks (Adão, Kolesár & Morales 2019)
  - `borusyak`: Recommended approach (Borusyak, Hull & Jaravel 2025)
- **Instrument construction**: Automatic construction of `Z_i = Σ_s w_is × g_s`
- **Flexible syntax**: Support for multiple shares and shocks

#### Diagnostic Features
- **Automatic diagnostics**:
  - First-stage F-statistic and strength tests
  - Identification path determination (shock-based vs share-based)
  - Herfindahl concentration index
  - Correlation with region size
  - Share distribution analysis
- **Optional diagnostic suppression** with `nodiagnostics`

#### Robustness Checks
- **Leave-one-out instruments**: `loo` option for mechanical correlation concerns
- **Alternative shares**: `altshares()` option for sensitivity analysis
- **Shock normalization**: `normalize` option to standardize shocks

#### Inference Methods
- **Standard errors**:
  - Heteroskedasticity-robust (default)
  - Cluster-robust (`cluster()` option)
  - Support for analytical weights and probability weights
- **Flexible VCE specification**: `vce()` option

#### Output and Results
- **Comprehensive output**:
  - First-stage results with F-statistics
  - Second-stage IV estimates
  - Diagnostic summary
  - Method-specific guidance
- **Stored results in `e()`**:
  - Scalars: `F_stat`, `herf_index`, `corr_size`, `n_shocks`, `n_shares`
  - Matrices: coefficient vector `b`, variance-covariance matrix `V`
  - Macros: `method`, `depvar`, `endogvar`, `vcetype`
- **Save IV option**: `saveiv()` to save constructed instrument

#### Documentation
- **Help file**: Complete `ssiv.sthlp` with:
  - Syntax description
  - Detailed options
  - Reproducible examples
  - Stored results documentation
  - References
- **README.md**: Comprehensive guide with:
  - Installation instructions
  - Quick start examples
  - Diagnostic interpretation
  - Troubleshooting guide
  - Citation information
- **Technical documentation** (`docs/`):
  - `methodology.md`: Detailed technical exposition
  - `assumptions.md`: Identification assumptions and threats
  - `borusyak_checklist.md`: Best practices checklist

#### Examples
- **Example 1** (`examples/example_sim_basic.do`):
  - Basic simulation with known true effect
  - Demonstrates coefficient recovery
  - Shows OLS bias
  - Includes leave-one-out comparison
- **Example 2** (`examples/example_immigration.do`):
  - Card (2009) style immigration analysis
  - Historical settlement patterns as shares
  - National inflows as shocks
  - Multiple outcomes
  - Alternative share robustness
- **Example 3** (`examples/example_industry_growth.do`):
  - Autor, Dorn & Hanson (2013) style trade shocks
  - Industry employment shares
  - Import competition shocks
  - Heterogeneous effects analysis

#### Tests
- **Comprehensive test suite** (`tests/`):
  - `test_sim_basic.do`: Basic functionality and coefficient recovery
  - `test_loo.do`: Leave-one-out consistency
  - `test_dominant_sector.do`: Dominant sector detection
  - `test_inference.do`: Multiple inference methods
  - `test_altshares.do`: Alternative shares robustness
  - `run_all.do`: Master test runner
- **Automated assertions**: Each test includes pass/fail criteria
- **Expected success rate**: ≥ 80% pass rate

#### Project Infrastructure
- **Version control**: Git repository structure
- **License**: MIT License
- **Contributing guidelines**: `CONTRIBUTING.md`
- **Issue templates**: Bug reports and feature requests
- **CI/CD preparation**: GitHub Actions workflow template

### Known Limitations (v0.1.0)

1. **AKM inference**: Current implementation recognizes `method(akm)` but uses standard cluster-robust SEs. Full AKM correction with shock covariance matrix to be implemented in future version.

2. **Leave-one-out**: Current LOO implementation is simplified. Full LOO requiring sector-level data recalculation to be enhanced.

3. **Bootstrap**: Wild bootstrap and standard bootstrap not yet implemented. Use `vce(cluster)` for now.

4. **Rotemberg weights**: Decomposition of IV estimator into Rotemberg weights not implemented. See Goldsmith-Pinkham et al. (2020) for manual calculation.

5. **Panel data**: Current version optimized for cross-sectional data. Panel extensions planned.

6. **Visualization**: No built-in plotting. Users should export results for external visualization.

### Technical Notes (v0.1.0)

- **Stata version**: Requires Stata 18.0+ (may work with 16.0+, not tested)
- **Dependencies**: None (uses built-in Stata commands)
- **Data structure**: Expects region-level (wide format) data with share variables
- **Missing values**: Handled via `marksample`
- **Temporary variables**: All temporary objects use `tempvar`, `tempname`, `tempfile`
- **Estimation**: Uses `ivregress 2sls` for IV estimation

### Methodological Basis

This package implements methods from:

- **Borusyak, K., Hull, P., & Jaravel, X. (2025)**. A Practical Guide to Shift-Share Instruments. *Journal of Economic Perspectives*, 39(1), 181-204.
  - Two paths to identification (shock-based vs share-based)
  - Diagnostic checks and best practices
  - When to use which identification strategy

- **Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020)**. Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586-2624.
  - Share-based identification interpretation
  - Rotemberg weights decomposition
  - Exposure-robust inference

- **Adão, R., Kolesár, M., & Morales, E. (2019)**. Shift-Share Designs: Theory and Inference. *The Quarterly Journal of Economics*, 134(4), 1949-2010.
  - Many shocks framework
  - Inference with correlated shocks
  - Asymptotic theory

### Acknowledgments

Initial development: Claude Code (December 2025)

Based on methodological contributions by:
- Kirill Borusyak (University of Chicago)
- Peter Hull (Brown University)
- Xavier Jaravel (London School of Economics)
- Paul Goldsmith-Pinkham (Yale SOM)
- Isaac Sorkin (Stanford University)
- Henry Swift (Federal Reserve)
- Rodrigo Adão (University of Chicago)
- Michal Kolesár (Princeton University)
- Eduardo Morales (Princeton University)

---

## Version History

- **0.1.0** (2025-12-04): Initial release with core functionality, diagnostics, and documentation

---

## How to Report Issues

Please report bugs and suggest features at:
https://github.com/MaykolMedrano/Shift-Share-IV-Design/issues

When reporting issues, please include:
1. SSIV package version (`ssiv` command header shows version)
2. Stata version and flavor (MP/SE/IC)
3. Operating system
4. Minimal reproducible example
5. Expected vs actual behavior

---

## How to Contribute

See `CONTRIBUTING.md` for guidelines on contributing to this project.

---

## Citation

If you use this package, please cite:

```bibtex
@software{ssiv2025,
  author = {{Claude Code}},
  title = {SSIV: Shift-Share Instrumental Variables for Stata},
  year = {2025},
  version = {0.1.0},
  url = {https://github.com/MaykolMedrano/Shift-Share-IV-Design}
}
```

And cite the underlying methodology papers as appropriate for your application.
