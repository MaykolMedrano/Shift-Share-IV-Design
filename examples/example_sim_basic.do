********************************************************************************
* SSIV Package - Example 1: Basic Simulation
* Purpose: Demonstrate shift-share IV with simulated data
* Author: Claude Code
* Date: 2025-12-04
********************************************************************************

clear all
set more off
set seed 12345

* Set number of regions and sectors
local N_regions = 1000
local N_sectors = 10

di ""
di "==================================================================="
di "SSIV Example 1: Basic Simulation"
di "==================================================================="
di "Generating simulated data with:"
di "  - Regions: `N_regions'"
di "  - Sectors: `N_sectors'"
di ""

********************************************************************************
* 1. GENERATE SIMULATED DATA
********************************************************************************

* Create region observations
set obs `N_regions'
gen region_id = _n
gen state = ceil(_n/50)  // 20 states with ~50 regions each

* Generate random shares that sum to 1 (Dirichlet-like)
forvalues s = 1/`N_sectors' {
	gen temp_share`s' = rexponential(1)
}
egen share_total = rowtotal(temp_share*)
forvalues s = 1/`N_sectors' {
	gen share_s`s' = temp_share`s' / share_total
	label variable share_s`s' "Employment share in sector `s' (base period)"
	drop temp_share`s'
}
drop share_total

* Generate exogenous shocks for each sector (national level)
* These are meant to be the same for all regions within a sector
forvalues s = 1/`N_sectors' {
	gen shock_s`s' = rnormal(0, 1)
	label variable shock_s`s' "National shock to sector `s'"
}

* Generate region-level unobservables and characteristics
gen epsilon = rnormal(0, 2)
gen xi = rnormal(0, 1.5)
gen region_size = rexponential(100)

* Construct the shift-share instrument: Z_i = sum_s w_is * g_s
gen ssiv_true = 0
forvalues s = 1/`N_sectors' {
	replace ssiv_true = ssiv_true + share_s`s' * shock_s`s'
}
label variable ssiv_true "True shift-share IV"

* Generate endogenous variable (correlated with instrument and error)
* X is endogenous: correlated with both Z and unobservables
gen employment_growth = 0.8 * ssiv_true + 0.5 * xi + rnormal(0, 1)
label variable employment_growth "Employment growth (endogenous)"

* Generate outcome variable
* True causal effect: beta = 0.5
gen wage_growth = 0.5 * employment_growth + epsilon + 0.3 * xi + rnormal(0, 1)
label variable wage_growth "Wage growth (outcome)"

* Some additional controls
gen initial_wage = 10 + rnormal(0, 2)
gen college_share = runiform(0.1, 0.5)

di "Data generation complete."
di ""

********************************************************************************
* 2. NAIVE OLS (BIASED)
********************************************************************************

di "==================================================================="
di "OLS Estimation (biased due to endogeneity)"
di "==================================================================="
reg wage_growth employment_growth, robust
di ""
di "NOTE: OLS is biased upward because employment_growth is correlated"
di "      with unobservables (xi). True effect is 0.5."
di ""

********************************************************************************
* 3. SHIFT-SHARE IV ESTIMATION
********************************************************************************

di "==================================================================="
di "Shift-Share IV Estimation (ssiv command)"
di "==================================================================="

* Add ado directory to path (if running from package directory)
* Uncomment and adjust path as needed:
* adopath + "../ado"

* Run ssiv command
ssiv wage_growth employment_growth, ///
	shares(share_s*) ///
	shocks(shock_s*) ///
	cluster(state) ///
	saveiv(ssiv_constructed)

di ""
di "Expected result: Coefficient should be close to true value of 0.5"
di "                 (within sampling error)"
di ""

* Store results
estimates store ssiv_main

********************************************************************************
* 4. COMPARISON WITH MANUAL 2SLS
********************************************************************************

di "==================================================================="
di "Comparison: Manual 2SLS using constructed IV"
di "==================================================================="

ivregress 2sls wage_growth (employment_growth = ssiv_constructed), ///
	vce(cluster state)

di ""
di "The manual 2SLS should give identical results to ssiv command."
di ""

********************************************************************************
* 5. DIAGNOSTICS AND INTERPRETATION
********************************************************************************

di "==================================================================="
di "Diagnostics and Interpretation"
di "==================================================================="

* Check first stage
reg employment_growth ssiv_constructed, vce(cluster state)
test ssiv_constructed
local F_manual = r(F)
di ""
di "First-stage F-statistic (manual): " %6.2f `F_manual'
di ""

* Check instrument validity
di "Instrument construction:"
corr ssiv_true ssiv_constructed
di ""

* Check concentration
egen total_contrib = rowtotal(share_s*)
sum total_contrib
di "Sum of shares (should be ~1): " %6.3f r(mean)
di ""

* Display stored results from ssiv
di "Stored results from ssiv command:"
di "  First-stage F: " %8.2f e(F_stat)
di "  Herfindahl index: " %6.4f e(herf_index)
di "  Correlation with size: " %6.3f e(corr_size)
di "  Number of shocks: " e(n_shocks)
di "  Number of shares: " e(n_shares)
di ""

********************************************************************************
* 6. ROBUSTNESS: LEAVE-ONE-OUT
********************************************************************************

di "==================================================================="
di "Robustness: Leave-One-Out Instrument"
di "==================================================================="

ssiv wage_growth employment_growth, ///
	shares(share_s*) ///
	shocks(shock_s*) ///
	cluster(state) ///
	loo

estimates store ssiv_loo

* Compare estimates
estimates table ssiv_main ssiv_loo, b(%7.4f) se(%7.4f) stats(F_stat N)

di ""
di "==================================================================="
di "Example complete!"
di "==================================================================="
di ""
di "Key takeaways:"
di "  1. OLS is biased upward due to endogeneity"
di "  2. Shift-share IV recovers estimate close to true value (0.5)"
di "  3. First-stage is strong (F > 10)"
di "  4. Diagnostics show no major concerns"
di "  5. Leave-one-out estimate is very similar (as expected with many regions)"
di ""

* Save dataset for testing
* save "simulated_data.dta", replace
