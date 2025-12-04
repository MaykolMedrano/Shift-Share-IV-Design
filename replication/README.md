# Replication Scripts

This directory contains scripts to replicate key results from the shift-share IV literature using the `ssiv` package with simulated data.

## Overview

Since original datasets from published papers are often proprietary or require special access, we provide replication scripts that use **synthetic data** designed to mimic the structure and properties of the original studies.

These scripts demonstrate:
1. How to structure data for shift-share IV analysis
2. How to use the `ssiv` command to replicate published specifications
3. Expected patterns and magnitudes of results

## Available Replication Scripts

### 1. Borusyak, Hull & Jaravel (2025) - Practical Guide Examples

**File**: `replicate_borusyak2025.do`

**Purpose**: Replicate the diagnostic examples from Borusyak et al. (2025), demonstrating:
- Two paths to identification (shock-based vs share-based)
- Diagnostic checks and their interpretation
- Common pitfalls and how to detect them

**Data**: Synthetic data mimicking various scenarios discussed in the paper

**Key Results**:
- Example 1: Strong shock-based identification (many shocks)
- Example 2: Share-based identification (few shocks, exogenous shares)
- Example 3: Problematic case (dominant sector)

### 2. Autor, Dorn & Hanson (2013) - China Trade Shock

**File**: `replicate_adh2013.do`

**Purpose**: Replicate the structure of ADH (2013) analysis of trade shocks on local labor markets

**Data**: Synthetic commuting zone data with:
- Industry employment shares (1990)
- Import penetration shocks (1990-2007)
- Labor market outcomes

**Key Results**:
- Trade-induced manufacturing decline
- Effects on employment, wages, and population
- Heterogeneity by education and initial conditions

**Original Paper**:
> Autor, D. H., Dorn, D., & Hanson, G. H. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121-68.

### 3. Card (2009) - Immigration and Wages

**File**: `replicate_card2009.do`

**Purpose**: Replicate Card's (2009) immigration analysis using historical settlement patterns

**Data**: Synthetic city data with:
- Historical immigrant shares by origin (1980)
- National immigration inflows (1980-2000)
- Native wage outcomes

**Key Results**:
- Predicted immigration based on 1980 networks
- Effects on native wages
- Robustness to alternative share definitions

**Original Paper**:
> Card, D. (2009). Immigration and Inequality. *American Economic Review*, 99(2), 1-21.

### 4. Goldsmith-Pinkham, Sorkin & Swift (2020) - Bartik Decomposition

**File**: `replicate_gss2020.do`

**Purpose**: Demonstrate share-based identification and sensitivity analysis

**Data**: Synthetic data with varying share exogeneity

**Key Results**:
- Comparison of shock-based vs share-based interpretation
- Sensitivity to share definitions
- Diagnostic tests for share exogeneity

**Original Paper**:
> Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586-2624.

## How to Use These Scripts

### Running a Replication

```stata
* Navigate to replication directory
cd replication

* Add ssiv to path
adopath + "../ado"

* Run a specific replication
do replicate_borusyak2025.do
```

### Comparing with Published Results

These replications use **synthetic data**, so exact numerical results will differ from published papers. However, they should exhibit:

✓ **Similar patterns**: Signs, magnitudes, and significance
✓ **Similar diagnostics**: First-stage strength, concentration, etc.
✓ **Similar sensitivity**: Robustness to alternative specifications

❌ **Not expected**: Exact coefficient matches

### Adapting for Your Research

To adapt these scripts for your own data:

1. **Replace data generation** with your actual data loading:
   ```stata
   * Instead of:
   * do generate_synthetic_data.do

   * Use:
   use "your_data.dta", clear
   ```

2. **Modify variable names** to match your data:
   ```stata
   * Update shares and shocks variable lists
   local shares "your_share1 your_share2 ..."
   local shocks "your_shock1 your_shock2 ..."
   ```

3. **Adjust specifications** as needed:
   ```stata
   ssiv your_outcome your_treatment your_controls, ///
       shares(`shares') ///
       shocks(`shocks') ///
       cluster(your_cluster_var)
   ```

## Data Sources for Original Replications

If you want to replicate with **original data**, here are the sources:

### Autor, Dorn & Hanson (2013)
- **Data**: Available on authors' websites
- **David Dorn's website**: https://www.ddorn.net/data.htm
- Includes: Commuting zone characteristics, industry employment, trade flows

### Card (2009)
- **Data**: Census data (restricted access for microdata)
- **Public use**: IPUMS USA for aggregate statistics
- **Website**: https://usa.ipums.org/usa/

### Goldsmith-Pinkham et al. (2020)
- **Data**: Replication package on AER website
- **Link**: https://www.aeaweb.org/articles?id=10.1257/aer.20181047
- Includes: Code, data, and detailed documentation

### General Resources
- **IPUMS**: Census and survey data (https://ipums.org/)
- **County Business Patterns**: Industry employment (https://www.census.gov/programs-surveys/cbp.html)
- **BLS**: Labor market data (https://www.bls.gov/)
- **UN Comtrade**: Trade data (https://comtrade.un.org/)

## Notes on Synthetic Data

### Why Synthetic Data?

1. **Accessibility**: No need for restricted-access data or IRB approval
2. **Transparency**: Data generation process is fully documented
3. **Pedagogical**: Easier to understand with known data-generating process
4. **Legal**: No copyright or licensing issues

### Limitations

1. **Not real**: Results are illustrative, not substantive findings
2. **Simplified**: Real data has more complex structures and issues
3. **No discoveries**: Can't make new scientific claims

### Data Generation Process

Our synthetic data is generated to:
- Match key moments (means, standard deviations, correlations)
- Preserve the dimensional structure (regions × sectors)
- Include realistic sources of variation and noise
- Exhibit endogeneity patterns similar to real data

See individual replication scripts for specific DGP details.

## Contributing

If you have:
- Better synthetic data generation processes
- Additional paper replications to add
- Corrections or improvements

Please see `../CONTRIBUTING.md` for how to contribute.

## Questions?

For questions about:
- **These scripts**: Open an issue on GitHub
- **Original papers**: Contact the authors or consult their replication packages
- **Data access**: See the data sources section above

## Citation

If you use these replication scripts, please cite:

1. The original paper you're replicating
2. This package:

```bibtex
@software{ssiv2025,
  author = {{Claude Code}},
  title = {SSIV: Shift-Share Instrumental Variables for Stata},
  year = {2025},
  url = {https://github.com/MaykolMedrano/Shift-Share-IV-Design}
}
```

## License

These replication scripts are provided under the MIT License. See `../LICENSE` for details.

Note: Original papers retain their own copyright. We are replicating the **methodology**, not the **data or exact results**.
