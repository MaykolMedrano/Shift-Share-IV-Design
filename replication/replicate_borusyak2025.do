********************************************************************************
* Replication: Borusyak, Hull & Jaravel (2025) - Practical Guide Examples
* Purpose: Demonstrate the two paths to identification with synthetic data
* Date: 2025-12-04
********************************************************************************

clear all
set more off
set seed 20251204

di ""
di "=========================================================================="
di "Replication: Borusyak, Hull & Jaravel (2025)"
di "A Practical Guide to Shift-Share Instruments"
di "=========================================================================="
di ""
di "Note: Using synthetic data to illustrate methodology"
di "Results are illustrative, not exact replications"
di ""

* Add ado path
adopath + "../ado"

********************************************************************************
* EXAMPLE 1: SHOCK-BASED IDENTIFICATION (Many Shocks)
********************************************************************************

di ""
di "=========================================================================="
di "EXAMPLE 1: Shock-Based Identification (Many Independent Shocks)"
di "=========================================================================="
di ""
di "Setting: Regional exposure to 30 industry shocks"
di "Identification: Through many quasi-random shocks"
di "Key assumption: E[g_s × ε_i | W] = 0"
di ""

* Parameters
local N = 400      // Regions
local S = 30       // Sectors (many shocks)

* Generate regions
set obs `N'
gen region = _n
gen state = ceil(_n/20)

* Generate shares (may be endogenous - correlated with unobservables)
* Shares reflect regional specialization based on historical factors
gen region_type = runiform()  // Regional characteristic

forvalues s = 1/`S' {
	* Shares depend on region type (endogenous)
	gen temp_share`s' = rexponential(1) * (1 + 0.3*region_type)
}
egen share_total = rowtotal(temp_share*)
forvalues s = 1/`S' {
	gen share`s' = temp_share`s' / share_total
	drop temp_share`s'
}
drop share_total

* Generate MANY independent shocks (exogenous)
* These are national/sectoral shocks uncorrelated with local ε
forvalues s = 1/`S' {
	gen shock`s' = rnormal(0, 1)
}

* Generate unobservables
* Note: ε is correlated with region_type (which affects shares)
gen epsilon = rnormal(0, 1.5) + 0.5*region_type

* Construct instrument (many shocks purge correlation with ε)
gen Z_many = 0
forvalues s = 1/`S' {
	replace Z_many = Z_many + share`s' * shock`s'
}

* Generate endogenous X and outcome Y
gen X_many = 0.7*Z_many + 0.4*epsilon + rnormal(0, 1)
gen Y_many = 0.6*X_many + epsilon + rnormal(0, 1)

* Run ssiv with shock-based identification
di "Running ssiv with 30 shocks (shock-based identification)..."
di ""

ssiv Y_many X_many, ///
	shares(share*) ///
	shocks(shock*) ///
	method(borusyak) ///
	cluster(state)

di ""
di "Key points for shock-based identification:"
di "  - Many shocks (S = 30 ≥ 20) enable shock-based identification"
di "  - Shares can be endogenous (correlated with unobservables)"
di "  - Averaging over many shocks purges correlation"
di "  - First-stage should be strong due to many sources of variation"
di "  - Herfindahl should be low (not dominated by few sectors)"
di ""

estimates store shock_based

********************************************************************************
* EXAMPLE 2: SHARE-BASED IDENTIFICATION (Few Shocks, Exogenous Shares)
********************************************************************************

di ""
di "=========================================================================="
di "EXAMPLE 2: Share-Based Identification (Few Shocks, Exogenous Shares)"
di "=========================================================================="
di ""
di "Setting: Historical shares with few contemporary shocks"
di "Identification: Through quasi-random historical shares"
di "Key assumption: E[w_is × ε_i | G] = 0"
di ""

clear
set obs 400
gen region = _n
gen state = ceil(_n/20)

* Parameters
local S_few = 5  // Few shocks

* Generate EXOGENOUS shares
* These are historical shares from distant past, uncorrelated with current ε
* Example: 1900 industry composition
forvalues s = 1/`S_few' {
	* Shares based on historical accident, uncorrelated with modern economy
	gen temp_share`s' = rexponential(1)
}
egen share_total = rowtotal(temp_share*)
forvalues s = 1/`S_few' {
	gen share_exog`s' = temp_share`s' / share_total
	drop temp_share`s'
}
drop share_total

* Generate shocks (few, may have some correlation structure)
forvalues s = 1/`S_few' {
	gen shock_exog`s' = rnormal(0, 1.2)
}

* Generate unobservables (uncorrelated with historical shares)
gen epsilon_exog = rnormal(0, 1.5)

* Construct instrument
gen Z_few = 0
forvalues s = 1/`S_few' {
	replace Z_few = Z_few + share_exog`s' * shock_exog`s'
}

* Generate endogenous X and outcome Y
gen X_few = 0.75*Z_few + 0.5*epsilon_exog + rnormal(0, 1)
gen Y_few = 0.5*X_few + epsilon_exog + rnormal(0, 1.2)

* Run ssiv with share-based identification
di "Running ssiv with 5 shocks (share-based identification)..."
di ""

ssiv Y_few X_few, ///
	shares(share_exog*) ///
	shocks(shock_exog*) ///
	method(borusyak) ///
	cluster(state)

di ""
di "Key points for share-based identification:"
di "  - Few shocks (S = 5 < 20) suggests share-based identification"
di "  - Shares must be truly exogenous (historical, predetermined)"
di "  - Identification from quasi-random variation in shares"
di "  - First-stage relies on differential exposure, not many shocks"
di "  - Concentration may be higher (fewer sectors)"
di ""

estimates store share_based

********************************************************************************
* EXAMPLE 3: PROBLEMATIC CASE (Dominant Sector + Endogenous Shares)
********************************************************************************

di ""
di "=========================================================================="
di "EXAMPLE 3: Problematic Case (Dominant Sector, Few Shocks)"
di "=========================================================================="
di ""
di "Setting: One dominant sector, few shocks, potentially endogenous shares"
di "Problem: Neither path to identification is clearly satisfied"
di ""

clear
set obs 400
gen region = _n
gen state = ceil(_n/20)

local S_problem = 6

* Generate shares with ONE DOMINANT sector
* Sector 1 accounts for ~70% of employment
gen share_dom1 = runiform(0.65, 0.75)

* Remaining sectors split the rest
gen remaining = 1 - share_dom1
forvalues s = 2/`S_problem' {
	gen temp_share`s' = rexponential(1)
}
egen temp_total = rowtotal(temp_share*)
forvalues s = 2/`S_problem' {
	gen share_dom`s' = (temp_share`s' / temp_total) * remaining
	drop temp_share`s'
}
drop temp_total remaining

* Generate shocks
forvalues s = 1/`S_problem' {
	gen shock_dom`s' = rnormal(0, 1)
}

* Unobservables
gen epsilon_dom = rnormal(0, 1.5)

* Instrument
gen Z_problem = 0
forvalues s = 1/`S_problem' {
	replace Z_problem = Z_problem + share_dom`s' * shock_dom`s'
}

* Endogenous X and outcome Y
gen X_problem = 0.6*Z_problem + 0.5*epsilon_dom + rnormal(0, 1)
gen Y_problem = 0.4*X_problem + epsilon_dom + rnormal(0, 1.2)

* Run ssiv
di "Running ssiv with dominant sector problem..."
di ""

ssiv Y_problem X_problem, ///
	shares(share_dom*) ///
	shocks(shock_dom*) ///
	method(borusyak) ///
	cluster(state)

di ""
di "Problems with this specification:"
di "  - High Herfindahl index (dominant sector)"
di "  - Too few shocks for shock-based identification"
di "  - Shares likely endogenous (recent specialization)"
di "  - Results driven by single sector (sector 1)"
di ""
di "Recommendations:"
di "  1. Examine individual sector contributions"
di "  2. Test robustness to excluding dominant sector"
di "  3. Seek more shocks or older shares"
di "  4. Consider alternative identification strategy"
di ""

estimates store problematic

********************************************************************************
* COMPARISON
********************************************************************************

di ""
di "=========================================================================="
di "COMPARISON OF THREE APPROACHES"
di "=========================================================================="
di ""

estimates table shock_based share_based problematic, ///
	b(%8.4f) se(%8.4f) ///
	stats(N F_stat herf_index n_shocks) ///
	title("Comparison of Identification Strategies")

di ""
di "=========================================================================="
di "KEY TAKEAWAYS FROM BORUSYAK ET AL. (2025)"
di "=========================================================================="
di ""
di "1. TWO PATHS TO IDENTIFICATION"
di "   a) Shock-based: Many (S≥20) independent shocks"
di "      - Shares can be endogenous"
di "      - Requires shock exogeneity and independence"
di ""
di "   b) Share-based: Exogenous predetermined shares"
di "      - Can work with few shocks"
di "      - Requires strong share exogeneity"
di ""
di "2. DIAGNOSTIC CHECKS ARE CRITICAL"
di "   - First-stage F-statistic (instrument strength)"
di "   - Herfindahl index (concentration)"
di "   - Number of shocks (which path?)"
di "   - Pre-trends tests (validate exogeneity)"
di ""
di "3. COMMON PITFALLS"
di "   - Using few shocks with endogenous shares (neither path works)"
di "   - Dominant sector driving results (high Herfindahl)"
di "   - Ignoring correlation of shocks (overstates effective S)"
di "   - Not testing robustness to alternative specifications"
di ""
di "4. BEST PRACTICES"
di "   - Be explicit about identification strategy"
di "   - Report all diagnostic checks"
di "   - Test robustness (LOO, alternative shares, subsamples)"
di "   - Use appropriate inference (cluster, AKM if needed)"
di ""
di "=========================================================================="
di "Replication complete!"
di ""
di "For more details, see:"
di "  - docs/methodology.md"
di "  - docs/assumptions.md"
di "  - docs/borusyak_checklist.md"
di "=========================================================================="
di ""
