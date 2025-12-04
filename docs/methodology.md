# Shift-Share IV Methodology

## Overview

This document provides technical details on the shift-share instrumental variables (SSIV) methodology implemented in the `ssiv` Stata package.

## The Shift-Share Instrument

### Basic Formula

The shift-share instrument (also called Bartik instrument) takes the form:

```
Z_i = Σ_s w_is × g_s
```

Where:
- `i` indexes regions (e.g., cities, commuting zones, countries)
- `s` indexes sectors (e.g., industries, origin countries)
- `w_is` are **shares**: region i's exposure to sector s (pre-determined)
- `g_s` are **shocks**: sector-level shocks (assumed exogenous)
- `Z_i` is the constructed instrument for region i

### Example: Immigration

Following Card (2009) and Goldsmith-Pinkham et al. (2020):

- **Shares**: Distribution of immigrants from origin country `o` across cities in a base year (e.g., 1980)
  - `w_{i,o}` = proportion of city i's population from origin o in 1980
- **Shocks**: National immigration inflows from each origin country (1980-2000)
  - `g_o` = total immigration from origin o between 1980-2000
- **Instrument**: Predicted immigration to city i based on 1980 settlement patterns

```
Z_i = Σ_o (share_{i,o,1980} × inflow_{o,1980-2000})
```

### Example: Trade Shocks

Following Autor, Dorn & Hanson (2013):

- **Shares**: Region's employment composition by industry (base year)
  - `w_{i,s}` = employment share of industry s in region i
- **Shocks**: Industry-level import competition growth
  - `g_s` = growth in imports in industry s
- **Instrument**: Predicted trade exposure

```
Z_i = Σ_s (emp_share_{i,s} × import_growth_s)
```

## Two Paths to Identification

Recent work by Borusyak, Hull & Jaravel (2025) clarifies that shift-share designs can achieve identification through two distinct paths:

### 1. Shock-Based Identification ("Many Shocks")

**When to use:**
- Many independent shocks (typically S ≥ 20)
- Shocks are exogenous and uncorrelated with unobservables
- Shares are predetermined but may correlate with unobservables

**Key assumption:**
```
E[g_s × ε_i | W] = 0   for all s
```

Where `ε_i` is the error term and `W` is the matrix of shares.

**Intuition:**
- Identification comes from variation across many sectors
- Even if shares correlate with local characteristics, averaging over many independent shocks purges this correlation
- Similar to "many instruments" in standard IV

**Inference:**
- Standard cluster-robust standard errors typically suffice
- Cluster at region level if errors are correlated within regions
- May need to account for correlation across shocks if they are not independent

### 2. Share-Based Identification ("Few Shocks, Exogenous Shares")

**When to use:**
- Few shocks (typically S < 20)
- Shares are exogenous: predetermined AND uncorrelated with unobservables
- Shocks may have some correlation structure

**Key assumption:**
```
E[w_is × ε_i | G] = 0   for all s
```

Where `G` is the vector of shocks.

**Intuition:**
- Identification comes from quasi-random variation in shares
- Shocks are still required for relevance, but identification logic differs
- Shares act as "exposure lottery"

**Inference:**
- Need to account for correlation of shocks
- Goldsmith-Pinkham et al. (2020) show this is equivalent to an over-identified IV with shares as instruments
- Can use Rotemberg weights to assess which shares drive identification

## Leave-One-Out Instruments

### Motivation

A concern with shift-share instruments is **mechanical correlation**: if the same regions that appear in `i` also affect the calculation of shocks `g_s`, the instrument may be mechanically correlated with region-specific errors.

### Construction

The leave-one-out (LOO) instrument excludes region i when calculating the shock:

```
Z_i^LOO = Σ_s w_is × g_s^(-i)
```

Where `g_s^(-i)` is the shock calculated excluding region i.

### When LOO Matters

LOO adjustment is important when:
1. Regions in the sample are large enough to affect aggregate shocks
2. There is potential feedback from region i's outcomes to the shock
3. Shocks are calculated from the same sample being analyzed

### When LOO Doesn't Matter Much

LOO makes little difference when:
1. Regions are small relative to the aggregate (e.g., cities in national aggregates)
2. Shocks are truly external (e.g., international shocks for domestic regions)
3. Sample size is large

## Diagnostic Checks

The `ssiv` command implements several diagnostic checks automatically:

### 1. First-Stage Strength

**Test:** F-statistic on excluded instrument in first-stage regression

**Interpretation:**
- F > 23.1: Strong instrument (Stock-Yogo critical value for 5% maximal IV size)
- 10 < F < 23.1: Moderate instrument (acceptable but not ideal)
- F < 10: Weak instrument (results unreliable)

**Formula:**
```
First stage: X_i = π_0 + π_1 Z_i + γ' C_i + ν_i
Test: H_0: π_1 = 0
```

### 2. Concentration (Herfindahl Index)

**Test:** Measure concentration of instrument contributions across sectors

**Formula:**
```
H = Σ_s (contribution_s)^2

where contribution_s = (average of w_is × g_s) / (average of Z_i)
```

**Interpretation:**
- H < 0.15: Low concentration (identification from many sectors)
- 0.15 < H < 0.25: Moderate concentration
- H > 0.25: High concentration (identification from few sectors)
  - Warning: Results may be sensitive to specific sectors
  - Consider examining individual sector contributions

### 3. Correlation with Size

**Test:** Correlation between instrument `Z_i` and region size (population or weights)

**Interpretation:**
- |ρ| < 0.2: Low correlation (good)
- 0.2 < |ρ| < 0.3: Moderate correlation (acceptable)
- |ρ| > 0.3: High correlation (concern)
  - May indicate mechanical relationship
  - Large regions may be driving results
  - Consider size controls or weighted regression

### 4. Share Variation

**Test:** Coefficient of variation for each share variable

**Formula:**
```
CV_s = σ(w_is) / μ(w_is)
```

**Interpretation:**
- CV > 0.20: Good variation
- 0.05 < CV < 0.20: Moderate variation
- CV < 0.05: Low variation (limited identification from this share)

## Inference Methods

### Standard Robust

Heteroskedasticity-robust standard errors (Huber-White):
```
V_robust = (X'X)^(-1) X'Ω X (X'X)^(-1)
```

**Use when:**
- No clustering structure
- Errors are heteroskedastic but independent

### Cluster-Robust

Standard errors clustered at specified level:
```
V_cluster = (X'X)^(-1) [Σ_c X_c'ε_c ε_c'X_c] (X'X)^(-1)
```

**Use when:**
- Errors correlated within clusters (e.g., states, regions)
- Most common choice for shift-share applications
- Typically cluster at region or higher level

### AKM (Adão-Kolesár-Morales)

Specialized inference for settings with many shocks that may be correlated:

**Use when:**
- Many sectors/shocks (S ≥ 20)
- Shocks may be correlated (e.g., industry linkages)
- Using shock-based identification path

**Key insight:**
- Standard clustering may under-estimate standard errors
- Need to account for shock correlation structure
- Typically produces larger standard errors than conventional clustering

**Implementation:**
- Requires shock-level data and covariance structure
- Full implementation beyond scope of basic `ssiv` command
- See Adão et al. (2019) for details

## Robustness Checks

### Alternative Share Definitions

Test sensitivity to how shares are measured:

**Example 1: Employment vs. Payroll**
- Main: `w_is` = employment share
- Alternative: `w_is` = payroll share
- Payroll weights industries by wage levels

**Example 2: Different Time Periods**
- Main: 1980 shares
- Alternative: 1970 or 1990 shares
- Tests persistence of share patterns

**Interpretation:**
- If results similar: robust to share definition
- If results differ: sensitivity indicates which shares matter for identification

### Leave-One-Out

Compare standard instrument to LOO version:
- Similar results → mechanical correlation not a concern
- Different results → feedback effects important

### Pre-Trends / Placebo Tests

Regress pre-period outcomes on instrument:
- Significant relationship → parallel trends violated
- No relationship → supports identification

## Common Pitfalls and Solutions

### 1. Weak Instruments

**Problem:** First-stage F < 10

**Solutions:**
- Use stronger shocks (larger variation)
- Focus on subsample with more exposure
- Consider alternative share definitions
- Check for data errors

### 2. Dominant Sector

**Problem:** High Herfindahl index (H > 0.3)

**Solutions:**
- Examine individual sector contributions
- Test robustness to excluding dominant sector
- Consider whether dominant sector is appropriate for identification
- Use share-based identification approach

### 3. Size Correlation

**Problem:** High correlation with region size

**Solutions:**
- Include size controls
- Use population weights
- Consider per-capita outcomes
- Check if relationship is mechanical

### 4. Share Endogeneity

**Problem:** Shares correlate with unobservables

**Solutions:**
- Use older/lagged shares (further predetermined)
- Condition on share-related observables
- Use shock-based identification (if many shocks available)
- Consider alternative identification strategy

## Formulas and Estimators

### Two-Stage Least Squares (2SLS)

**First stage:**
```
X_i = π_0 + π_1 Z_i + γ' C_i + ν_i
```

**Second stage:**
```
Y_i = β_0 + β_1 X̂_i + δ' C_i + ε_i
```

Where:
- `Y_i` = outcome
- `X_i` = endogenous variable
- `Z_i` = shift-share instrument
- `C_i` = controls
- `X̂_i` = fitted values from first stage

**2SLS estimator:**
```
β̂_1^IV = (X̂'X̂)^(-1) X̂'Y = (Z'X)^(-1) Z'Y
```

### Reduced Form

Direct effect of instrument on outcome:
```
Y_i = α_0 + α_1 Z_i + θ' C_i + u_i
```

**Interpretation:**
- `α_1` = reduced-form effect
- `β_1^IV = α_1 / π_1` (Wald estimator)

## References

- Adão, R., Kolesár, M., & Morales, E. (2019). Shift-Share Designs: Theory and Inference. *The Quarterly Journal of Economics*, 134(4), 1949-2010.

- Autor, D. H., Dorn, D., & Hanson, G. H. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121-68.

- Bartik, T. J. (1991). *Who Benefits from State and Local Economic Development Policies?* W.E. Upjohn Institute for Employment Research.

- Borusyak, K., Hull, P., & Jaravel, X. (2025). A Practical Guide to Shift-Share Instruments. *Journal of Economic Perspectives*, 39(1), 181-204.

- Card, D. (2009). Immigration and Inequality. *American Economic Review*, 99(2), 1-21.

- Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586-2624.

- Stock, J. H., & Yogo, M. (2005). Testing for Weak Instruments in Linear IV Regression. In D. W. K. Andrews & J. H. Stock (Eds.), *Identification and Inference for Econometric Models* (pp. 80-108). Cambridge University Press.
