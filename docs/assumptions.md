# Shift-Share IV: Assumptions and Identification

## Core IV Assumptions

For the shift-share instrument `Z_i = Σ_s w_is × g_s` to be valid, we need:

### 1. Relevance (First-Stage)

**Assumption:**
```
Cov(Z_i, X_i | C_i) ≠ 0
```

The instrument must predict the endogenous variable.

**In practice:**
- First-stage F-statistic > 10 (rule of thumb)
- Shocks must actually affect the endogenous variable
- Shares must capture heterogeneous exposure

**How to verify:**
- Check first-stage F-statistic
- Examine first-stage coefficient and t-statistic
- Verify that shocks have meaningful variation

**Common violations:**
- Shocks are too small or have little variation
- Shares are nearly uniform across regions
- Measurement error attenuates relationships

---

### 2. Exogeneity (Exclusion Restriction)

**Assumption:**
```
Cov(Z_i, ε_i | C_i) = 0
```

The instrument affects the outcome ONLY through its effect on the endogenous variable.

**In shift-share context:**

This assumption can be satisfied through two different paths:

#### Path A: Shock-Based Identification (Many Shocks)

**Assumption:**
```
E[g_s × ε_i | W, C] = 0   for all s
```

Shocks are exogenous conditional on shares and controls.

**Requirements:**
1. **Many independent shocks** (typically S ≥ 20)
2. **Shock exogeneity**: Each shock `g_s` is uncorrelated with regional unobservables `ε_i`
3. **Pre-determined shares**: `w_is` are fixed before period of analysis

**What this allows:**
- Shares CAN be correlated with unobservables
- Identification comes from averaging over many quasi-random shocks
- Similar logic to "many weak instruments"

**Example:** Trade shocks (Autor et al. 2013)
- 100+ manufacturing industries (many shocks)
- Import competition in each industry is exogenous to U.S. local labor markets
- Regional industry composition may reflect past comparative advantage (endogenous)
- But averaging over 100+ industries purges correlation with local unobservables

#### Path B: Share-Based Identification (Few Shocks, Exogenous Shares)

**Assumption:**
```
E[w_is × ε_i | G, C] = 0   for all s
```

Shares are exogenous conditional on shocks and controls.

**Requirements:**
1. **Exogenous shares**: `w_is` are uncorrelated with regional unobservables
2. **Pre-determined shares**: Fixed before shocks occur
3. **Can work with few shocks** (even S = 1)

**What this allows:**
- Shocks CAN have some correlation structure
- Identification comes from quasi-random variation in shares
- Similar logic to standard IV

**Example:** Immigration (Card 2009)
- Historical settlement patterns as shares (driven by factors decades ago)
- Shares reflect "ethnic enclave" formation that's uncorrelated with recent economic shocks
- National immigration inflows as shocks (few origin countries)

---

## Additional Assumptions by Identification Path

### For Shock-Based Identification

#### A1. Shock Independence

**Assumption:**
```
Cov(g_s, g_s' | controls) = 0   for s ≠ s'
```

Shocks are uncorrelated across sectors.

**Why it matters:**
- Ensures effective number of instruments is large
- If shocks are highly correlated, effective S is smaller

**How to verify:**
- Examine correlation matrix of shocks
- Check for common factors (e.g., aggregate business cycle)
- Consider industry linkages

**What to do if violated:**
- Use AKM inference (accounts for shock correlation)
- Consider grouping correlated sectors
- Include controls for common factors

#### A2. No Shock Anticipation

**Assumption:**

Shocks are not anticipated based on pre-period information.

**Why it matters:**
- If shocks are anticipated, shares may adjust endogenously
- Pre-trends would appear

**How to verify:**
- Test for pre-trends (regress pre-period outcome on instrument)
- Check timing: shocks should be realized after shares are fixed

#### A3. Sufficient Number of Shocks

**Rule of thumb:**
- S ≥ 20 for shock-based identification
- More is better

**Why it matters:**
- Need enough shocks for averaging to eliminate correlation with unobservables
- Analogous to "many instruments" requirement

### For Share-Based Identification

#### B1. Share Exogeneity

**Assumption:**

Shares are uncorrelated with unobservables affecting the outcome.

**This is STRONG:**
- Requires shares to be "as good as random" conditional on controls
- Often implausible for recent shares

**How to verify:**
- Balance tests: regress shares on pre-period observables
- Check for correlation with pre-trends
- Use shares from distant past (e.g., 1900 shares for 1980-2000 analysis)

**Common strategies:**
- Use historical shares (lag by decades)
- Condition on rich set of controls
- Provide narrative evidence for share exogeneity

#### B2. Stable Share Effects

**Assumption:**

The effect of having high share `w_is` is constant over time (or absorbed by controls).

**Why it matters:**
- Share-based identification relies on comparing high-share vs low-share regions
- If high-share regions differ in unobserved ways that change over time, bias results

#### B3. Independent Variation Across Shares

**Assumption:**

Different shares provide independent sources of variation.

**Why it matters:**
- Over-identification tests require this
- Allows testing validity using subset of shares

---

## Threats to Identification

### 1. Endogenous Shares

**Problem:**
- Shares reflect past endogenous responses
- E.g., declining regions have different industry mix

**Example:**
- Regions with high manufacturing share in 1980 may be declining for reasons unrelated to trade
- If using manufacturing share × trade shock, instrument captures pre-existing decline

**Solutions:**
- Use older shares (e.g., 1970 instead of 1980)
- Control for pre-trends
- Use shock-based identification with many shocks

### 2. Correlated Shocks

**Problem:**
- Shocks are correlated across sectors
- E.g., all manufacturing industries decline together

**Example:**
- If all manufacturing industries face similar trade shocks, effective number of shocks is small
- Shock-based identification weakens

**Solutions:**
- Use AKM inference
- Group correlated shocks
- Include aggregate controls

### 3. Mechanical Correlation

**Problem:**
- Instrument mechanically correlated with outcome through sample composition

**Example:**
- If calculating national shock from same sample, large regions affect both shock and outcome

**Solutions:**
- Use leave-one-out instruments
- Use shocks from different sample/country
- Verify results robust to LOO adjustment

### 4. Confounding Shocks

**Problem:**
- Other shocks correlated with instrument

**Example:**
- Immigration shock correlated with technology adoption
- Both affect labor markets, hard to separate

**Solutions:**
- Control for potential confounders
- Use variation in timing or geography
- Provide robustness checks

### 5. Violation of Exclusion Restriction

**Problem:**
- Instrument affects outcome through channels other than endogenous variable

**Example:**
- Immigration instrument may affect outcomes through changes in local amenities, not just labor supply

**Solutions:**
- Specify mechanism clearly
- Test alternative mechanisms
- Use narrow outcome definitions

---

## Testing Assumptions

### 1. First-Stage Strength (Relevance)

**Test:** F-statistic on excluded instrument

**Null:** Instrument is irrelevant

**Implementation:**
```stata
reg X Z C
test Z
```

**Interpretation:**
- F > 10: Pass
- F < 10: Weak instrument

### 2. Over-identification Test (Share-Based ID)

**Test:** Hansen J-test / Sargan test

**Null:** All shares are valid instruments

**Implementation:**
```stata
ivreg2 Y (X = w1*g w2*g w3*g ... wK*g) C, cluster(...)
estat overid
```

**Interpretation:**
- Cannot reject null: Consistent with validity
- Reject null: At least one share is invalid

**Caveat:**
- Low power if all shares invalid in same direction
- Requires share-based identification logic

### 3. Pre-Trends / Parallel Trends

**Test:** Regress pre-period outcome on instrument

**Null:** No relationship

**Implementation:**
```stata
reg Y_pre Z C
test Z
```

**Interpretation:**
- Cannot reject null: Consistent with validity
- Reject null: Pre-trends present, validity questionable

### 4. Placebo Outcomes

**Test:** Use outcome that should NOT be affected

**Null:** No effect on placebo outcome

**Example:**
- If studying labor markets, use outcomes in non-exposed sectors
- If studying local outcomes, use outcomes in other regions

### 5. Alternative Share Definitions

**Test:** Sensitivity to share measurement

**Implementation:**
```stata
ssiv Y X, shares(main_shares) shocks(g) altshares(alternative_shares)
```

**Interpretation:**
- Similar results: Robust
- Different results: Sensitive to shares, interpretation depends on identification strategy

---

## Practical Guidelines

### Choosing Identification Strategy

**Use shock-based identification when:**
- Many sectors (S ≥ 20)
- Confident in shock exogeneity
- Shares may be endogenous
- Example: Trade shocks with detailed industry data

**Use share-based identification when:**
- Few sectors (S < 20)
- Shares are clearly exogenous (historical, institutional)
- Can defend share exogeneity
- Example: Historical immigration shares

### Strengthening Credibility

1. **Be explicit** about identification strategy
2. **Show diagnostics**: first-stage, concentration, correlations
3. **Test assumptions**: pre-trends, placebo tests
4. **Provide robustness**: alternative shares, LOO, subsamples
5. **Discuss threats**: acknowledge limitations, explain why not concerning

### Common Mistakes

1. ❌ Claiming "shift-share is exogenous" without specifying identification path
2. ❌ Using recent/endogenous shares with few shocks
3. ❌ Ignoring correlation of shocks
4. ❌ Not testing first-stage strength
5. ❌ Mechanical correlation not addressed
6. ❌ No robustness checks

### Checklist Before Publishing

- [ ] Clear statement of identification strategy (shock vs share based)
- [ ] First-stage F-statistic reported and strong
- [ ] Appropriate inference method (clustering, AKM if needed)
- [ ] Pre-trends tested and discussed
- [ ] Robustness to alternative shares shown
- [ ] Leave-one-out check if relevant
- [ ] Concentration index reported
- [ ] Threats to identification discussed
- [ ] Placebo tests where applicable
- [ ] Share and shock definitions clearly explained

---

## References

Borusyak, K., Hull, P., & Jaravel, X. (2025). A Practical Guide to Shift-Share Instruments. *Journal of Economic Perspectives*, 39(1), 181-204.

Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586-2624.

Adão, R., Kolesár, M., & Morales, E. (2019). Shift-Share Designs: Theory and Inference. *The Quarterly Journal of Economics*, 134(4), 1949-2010.
