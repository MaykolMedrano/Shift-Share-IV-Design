# Borusyak, Hull & Jaravel (2025) Checklist for Shift-Share IV

This checklist is based on the practical recommendations from Borusyak, Hull & Jaravel (2025), "A Practical Guide to Shift-Share Instruments," *Journal of Economic Perspectives*, 39(1), 181-204.

Use this checklist when planning, conducting, or reviewing shift-share IV analyses.

---

## Part I: Design and Specification

### ☐ 1. Clearly Define the Shift-Share Instrument

**What to report:**
- Exact formula for the instrument: `Z_i = Σ_s w_is × g_s`
- Definition of regions (i), sectors (s), shares (w), and shocks (g)
- Time periods for shares (base period) and shocks (analysis period)
- Sample: which regions and sectors are included

**Example:**
> "We construct a shift-share instrument for predicted trade exposure to Chinese imports following Autor, Dorn & Hanson (2013). Regions are 722 commuting zones (CZs). Sectors are 397 manufacturing industries (SIC 4-digit). Shares are CZ employment shares by industry in 1990. Shocks are industry-level changes in Chinese import penetration 1990-2007."

---

### ☐ 2. State the Identification Strategy Explicitly

**Choose one and defend it:**

**Option A: Shock-Based Identification**
- Many independent shocks (typically S ≥ 20)
- Shocks are exogenous: `E[g_s × ε_i | W] = 0`
- Shares are predetermined but may be endogenous

**Option B: Share-Based Identification**
- Shares are exogenous: `E[w_is × ε_i | G] = 0`
- Shocks provide variation but need not be fully exogenous
- Can work with few shocks

**What to report:**
- Which path you're using
- Why this path is appropriate for your setting
- Key identifying assumption and why it's plausible

---

### ☐ 3. Verify Pre-determination of Shares

**Check:**
- [ ] Shares are measured BEFORE shocks occur
- [ ] Shares are measured BEFORE outcome period
- [ ] No mechanical correlation between shares and shocks

**What to report:**
- Timing: "Shares are measured in 1980; shocks occur 1980-2000; outcomes measured in 2000"
- Source of shares: "Employment data from 1980 Census"

**Red flags:**
- Shares and shocks from same time period
- Shares could have responded to anticipated shocks

---

### ☐ 4. Document Share Construction

**Report:**
- Source of data for shares
- Level of aggregation
- How shares are normalized (sum to 1? industry shares? population shares?)
- Treatment of missing or zero shares
- Any transformations applied

**Example:**
> "Shares are constructed from County Business Patterns 1980. We calculate employment share of each 3-digit SIC industry as fraction of total manufacturing employment in each CZ. Shares are normalized to sum to 1 within each CZ. Industries with <10 employees are suppressed; we impute these using state-level averages."

---

### ☐ 5. Document Shock Construction

**Report:**
- Source of data for shocks
- Exact definition and measurement
- Level of aggregation
- Time period
- Any normalizations or transformations

**If using leave-one-out:**
- Explain construction of `g_s^(-i)`
- Justify when LOO is necessary

**Example:**
> "Shocks are growth rates of Chinese imports to the U.S. by 4-digit SIC industry, 1990-2007, measured in $1000s per worker. Data from UN Comtrade. We exclude imports to CZ i when calculating shock for CZ i to avoid mechanical correlation."

---

## Part II: Diagnostics and Validation

### ☐ 6. Report First-Stage Strength

**Report:**
- First-stage F-statistic on excluded instrument
- First-stage coefficient and standard error
- First-stage R²

**Interpretation:**
- F > 23.1: Strong instrument (Stock-Yogo 5% critical value)
- 10 < F < 23.1: Moderate strength
- F < 10: Weak instrument (problematic)

**Implementation:**
```stata
ssiv Y X controls, shares(w*) shocks(g*) cluster(state)
* Check e(F_stat)
```

---

### ☐ 7. Assess Concentration

**Report:**
- Herfindahl index of instrument contributions
- Number of sectors
- Share distribution summary statistics

**Interpretation:**
- H < 0.15: Low concentration (many sectors contribute)
- 0.15 < H < 0.25: Moderate concentration
- H > 0.25: High concentration (few sectors dominate)

**If high concentration:**
- Identify which sectors drive results
- Test robustness to dropping dominant sectors
- Consider implications for identification strategy

**Implementation:**
```stata
ssiv Y X controls, shares(w*) shocks(g*) cluster(state)
* Check e(herf_index)
```

---

### ☐ 8. Check for Mechanical Relationships

**Tests:**

A. **Correlation with size:**
```stata
corr shift_share_IV region_size
```
- |ρ| < 0.3: Acceptable
- |ρ| > 0.3: Potential concern

B. **Balance test:** Regress shares on pre-period observables
```stata
reg w_is X_baseline_characteristics
```
- Significant relationships suggest shares may be endogenous

C. **Instrument variation:** Check that instrument has sufficient variation
```stata
summarize shift_share_IV, detail
```

---

### ☐ 9. Test for Pre-Trends

**Test:**
Regress pre-period outcome changes on instrument

```stata
reg delta_Y_pre shift_share_IV controls, cluster(state)
test shift_share_IV
```

**Interpretation:**
- p > 0.10: No evidence of pre-trends (good)
- p < 0.10: Pre-trends present (problematic)

**If pre-trends detected:**
- Include pre-trend controls
- Revisit identification assumptions
- Consider alternative instruments

---

### ☐ 10. Conduct Robustness Checks

**Essential robustness checks:**

A. **Alternative share definitions:**
```stata
ssiv Y X controls, shares(w_main*) shocks(g*) altshares(w_alt*) cluster(state)
```
- Try: different years, different measures (employment vs payroll), different aggregations

B. **Leave-one-out:**
```stata
ssiv Y X controls, shares(w*) shocks(g*) loo cluster(state)
```
- Check if results change substantially

C. **Subsamples:**
- Exclude largest regions
- Exclude dominant sectors
- Split by covariates

D. **Alternative inference:**
```stata
* Try different clustering
ssiv Y X controls, shares(w*) shocks(g*) cluster(state)
ssiv Y X controls, shares(w*) shocks(g*) cluster(region)

* If many shocks, try AKM
ssiv Y X controls, shares(w*) shocks(g*) method(akm) cluster(state)
```

---

## Part III: Inference

### ☐ 11. Use Appropriate Standard Errors

**Guidelines:**

**If shock-based identification:**
- Cluster at region level (minimum)
- If few clusters (<30), consider wild bootstrap
- If shocks are correlated, consider AKM inference

**If share-based identification:**
- Standard errors should account for correlation in shares
- Can use over-identification tests

**If regions are large:**
- Use leave-one-out instrument
- Cluster at higher level

**Report:**
- Clustering level and justification
- Number of clusters
- Sensitivity to clustering choice

---

### ☐ 12. Report Uncertainty Appropriately

**Report:**
- Coefficient estimate
- Standard error
- 95% confidence interval
- P-value

**Interpretation:**
- Be clear about economic vs statistical significance
- Discuss magnitude relative to means/standard deviations
- Acknowledge uncertainty, especially if F-statistic is moderate

---

## Part IV: Presentation and Interpretation

### ☐ 13. Present Estimates Clearly

**Standard table structure:**

| | (1) OLS | (2) 2SLS | (3) First Stage |
|---|---|---|---|
| Endogenous variable | βOLS | βIV | — |
| Shift-share IV | — | — | π |
| Controls | Yes | Yes | Yes |
| F-statistic | — | F | F |
| N | N | N | N |

**Additional panels for robustness:**
- Show LOO results
- Show alternative shares
- Show subsamples

---

### ☐ 14. Interpret Results Carefully

**Address:**

A. **Magnitude:**
- Put coefficient in context
- Compare to OLS
- Discuss economic significance

B. **Direction of bias:**
- Is IV > OLS or IV < OLS?
- What does this imply about endogeneity?
- Is direction consistent with expectations?

C. **Local Average Treatment Effect:**
- IV estimates LATE for compliers
- Who are the compliers in your setting?
- How do they differ from full sample?

---

### ☐ 15. Discuss Threats to Identification

**Be honest about:**
- Potential violations of key assumptions
- Alternative explanations for results
- Limitations of the research design

**Common threats:**
1. Endogenous shares (if using shock-based ID)
2. Correlated shocks (if using shock-based ID)
3. Share endogeneity (if using share-based ID)
4. Mechanical correlation
5. Confounding shocks

**For each threat:**
- Acknowledge it
- Explain why it's not concerning (with evidence), OR
- Acknowledge as limitation

---

## Summary: Minimum Reporting Standards

**Must report:**
1. ✓ Exact instrument definition (shares, shocks, formula)
2. ✓ Identification strategy (shock-based or share-based)
3. ✓ First-stage F-statistic
4. ✓ Number of regions and sectors
5. ✓ Clustering level
6. ✓ Pre-trends test results

**Should report:**
7. ✓ Concentration measure
8. ✓ Alternative shares robustness
9. ✓ Leave-one-out comparison
10. ✓ Balance tests

---

## Additional Resources

**Replication files:**
- Share your code and data (when possible)
- Document data construction carefully
- Make instrument construction transparent

**Online appendix:**
- Additional robustness checks
- Alternative specifications
- Diagnostic plots

**Visualization:**
- Map of instrument variation
- Scatter plots (first stage, reduced form)
- Distribution of shares and shocks

---

## Reference

Borusyak, K., Hull, P., & Jaravel, X. (2025). A Practical Guide to Shift-Share Instruments. *Journal of Economic Perspectives*, 39(1), 181-204.

For the complete methodological details, see:
- `docs/methodology.md` - Technical details on shift-share IV
- `docs/assumptions.md` - Identification assumptions
- `help/ssiv.sthlp` - Stata command documentation
