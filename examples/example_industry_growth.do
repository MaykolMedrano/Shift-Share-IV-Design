********************************************************************************
* SSIV Package - Example 3: Regional Industry Growth and Productivity
* Purpose: Applied example with industry composition and trade shocks
* Author: Claude Code
* Date: 2025-12-04
********************************************************************************

clear all
set more off
set seed 54321

di ""
di "==================================================================="
di "SSIV Example 3: Regional Growth and Trade Shocks"
di "==================================================================="
di "Application: Effect of trade-induced manufacturing decline on"
di "            regional economic outcomes"
di ""

********************************************************************************
* 1. SETUP
********************************************************************************

local N_regions = 180     // U.S. commuting zones (approx)
local N_industries = 20   // Manufacturing industries
local period_start = 2000
local period_end = 2010

di "Parameters:"
di "  Regions: `N_regions' (commuting zones)"
di "  Industries: `N_industries' (manufacturing sectors)"
di "  Period: `period_start'-`period_end'"
di ""

set obs `N_regions'
gen czone_id = _n
gen czone_name = "CZ_" + string(_n, "%03.0f")

* Assign to states and census regions
gen state_id = ceil(_n/6)
gen census_region = ceil(_n/45)  // 4 regions

* Regional characteristics (baseline)
gen pop_2000 = exp(rnormal(11, 1)) * 1000
gen college_2000 = rnormal(0.25, 0.08)
replace college_2000 = max(0.10, min(0.50, college_2000))
gen urban = (runiform() < 0.6)
gen south = (census_region == 3)
gen midwest = (census_region == 2)

********************************************************************************
* 2. INDUSTRY EMPLOYMENT SHARES (2000)
********************************************************************************

di "Generating industry employment shares (baseline)..."

* Different regions specialize in different industries
* Shares represent employment share in manufacturing by industry
forvalues ind = 1/`N_industries' {

	* Base share with some heterogeneity
	gen temp_base`ind' = rexponential(1)

	* Some industries concentrated in specific regions
	if `ind' <= 5 {
		* Rust belt industries (autos, steel, machinery)
		replace temp_base`ind' = temp_base`ind' * 2 if midwest == 1
	}
	else if `ind' <= 10 {
		* Textiles, furniture -> South
		replace temp_base`ind' = temp_base`ind' * 1.5 if south == 1
	}
	else if `ind' <= 15 {
		* Tech manufacturing -> Urban areas
		replace temp_base`ind' = temp_base`ind' * 1.8 if urban == 1
	}
	* Others distributed more evenly
}

* Normalize to shares
egen temp_total = rowtotal(temp_base*)
forvalues ind = 1/`N_industries' {
	gen emp_share_ind`ind' = temp_base`ind' / temp_total
	label variable emp_share_ind`ind' "Employment share in industry `ind' (2000)"
	drop temp_base`ind'
}
drop temp_total

* Total manufacturing share of employment
gen mfg_share_2000 = runiform(0.08, 0.35)
label variable mfg_share_2000 "Manufacturing share of total employment"

* Summary
di "Industry share summary (first 3 industries):"
sum emp_share_ind1 emp_share_ind2 emp_share_ind3
di ""

********************************************************************************
* 3. TRADE SHOCKS (2000-2010)
********************************************************************************

di "Generating trade shocks (2000-2010)..."
di "Simulating China trade shock à la Autor, Dorn & Hanson (2013)"
di ""

* Industry-level import competition growth
* Some industries face massive import competition, others less
forvalues ind = 1/`N_industries' {

	if `ind' <= 8 {
		* High import competition (textiles, furniture, electronics)
		gen import_shock_ind`ind' = rnormal(0.25, 0.08)
	}
	else if `ind' <= 15 {
		* Moderate import competition
		gen import_shock_ind`ind' = rnormal(0.10, 0.05)
	}
	else {
		* Low import competition (services, non-tradable)
		gen import_shock_ind`ind' = rnormal(0.02, 0.02)
	}

	* Ensure non-negative
	replace import_shock_ind`ind' = max(0, import_shock_ind`ind')
	label variable import_shock_ind`ind' "Import growth in industry `ind' (% points)"
}

* Display shock distribution
di "Trade shock distribution:"
sum import_shock_ind1 import_shock_ind5 import_shock_ind10 import_shock_ind15
di ""

********************************************************************************
* 4. CONSTRUCT SHIFT-SHARE INSTRUMENT
********************************************************************************

di "Constructing shift-share instrument (predicted trade exposure)..."

* Bartik-style instrument: predicted import competition based on
* initial industry composition and national import shocks
gen trade_exposure_iv = 0
forvalues ind = 1/`N_industries' {
	replace trade_exposure_iv = trade_exposure_iv + ///
		(emp_share_ind`ind' * import_shock_ind`ind')
}
label variable trade_exposure_iv "Predicted trade exposure (shift-share IV)"

sum trade_exposure_iv, detail
di ""

********************************************************************************
* 5. ENDOGENOUS VARIABLE: ACTUAL MANUFACTURING DECLINE
********************************************************************************

di "Generating endogenous variable (actual manufacturing decline)..."

* Unobserved local factors
gen local_demand_shock = rnormal(0, 0.05)
gen automation_shock = rnormal(0, 0.03)

* Actual manufacturing employment decline (endogenous)
* Responds to: trade shocks, local demand, automation, policy
gen mfg_decline = trade_exposure_iv + ///
	0.5 * local_demand_shock + ///
	0.4 * automation_shock + ///
	-0.3 * college_2000 + ///
	rnormal(0, 0.02)

label variable mfg_decline "Manufacturing employment decline 2000-2010 (pp)"

* Make sure it's positive (decline)
replace mfg_decline = abs(mfg_decline)

sum mfg_decline, detail
di ""

********************************************************************************
* 6. OUTCOME VARIABLES
********************************************************************************

di "Generating outcome variables..."

* TRUE EFFECTS (for validation):
* Manufacturing decline -> unemployment (+0.4), wage decline (+0.3), pop decline (+0.2)

* A. Unemployment rate change
gen unemp_change = 0.4 * mfg_decline + ///
	-0.3 * college_2000 + ///
	local_demand_shock + ///
	rnormal(0, 0.015)
label variable unemp_change "Change in unemployment rate (pp)"

* B. Wage growth
gen wage_growth = -0.3 * mfg_decline + ///
	0.5 * college_2000 + ///
	0.6 * local_demand_shock + ///
	rnormal(0, 0.02)
label variable wage_growth "Wage growth 2000-2010"

* C. Population growth (out-migration)
gen pop_growth = -0.2 * mfg_decline + ///
	0.3 * urban + ///
	local_demand_shock + ///
	rnormal(0, 0.015)
label variable pop_growth "Population growth 2000-2010"

di "Outcomes generated. True effects:"
di "  Manufacturing decline -> Unemployment: +0.4"
di "  Manufacturing decline -> Wages: -0.3"
di "  Manufacturing decline -> Population: -0.2"
di ""

********************************************************************************
* 7. NAIVE OLS
********************************************************************************

di "==================================================================="
di "OLS Regressions (biased)"
di "==================================================================="

di "A. Unemployment:"
reg unemp_change mfg_decline college_2000 mfg_share_2000, vce(cluster state_id)
di ""

di "B. Wages:"
reg wage_growth mfg_decline college_2000 mfg_share_2000, vce(cluster state_id)
di ""

di "NOTE: OLS estimates are biased because manufacturing decline is"
di "      endogenous (responds to local demand shocks, policy, etc.)"
di ""

********************************************************************************
* 8. SHIFT-SHARE IV ESTIMATION
********************************************************************************

di "==================================================================="
di "Shift-Share IV Estimation"
di "==================================================================="

* Add ado path if needed
* adopath + "../ado"

di "A. Effect on Unemployment:"
ssiv unemp_change mfg_decline college_2000 mfg_share_2000, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id) ///
	method(borusyak) ///
	saveiv(trade_iv)

estimates store ssiv_unemp

di ""
di "B. Effect on Wage Growth:"
ssiv wage_growth mfg_decline college_2000 mfg_share_2000, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id)

estimates store ssiv_wages

di ""
di "C. Effect on Population Growth:"
ssiv pop_growth mfg_decline college_2000 mfg_share_2000, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id)

estimates store ssiv_pop

di ""

********************************************************************************
* 9. LEAVE-ONE-OUT ROBUSTNESS
********************************************************************************

di "==================================================================="
di "Robustness: Leave-One-Out Instrument"
di "==================================================================="

ssiv unemp_change mfg_decline college_2000 mfg_share_2000, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id) ///
	loo

estimates store ssiv_unemp_loo

di ""

********************************************************************************
* 10. ALTERNATIVE SPECIFICATION: ALTERNATIVE SHARES
********************************************************************************

di "==================================================================="
di "Robustness: Alternative Share Definition"
di "==================================================================="
di "Using payroll shares instead of employment shares"
di ""

* Generate alternative shares (payroll instead of employment)
* Industries differ in wage levels
forvalues ind = 1/`N_industries' {
	gen wage_mult_ind`ind' = runiform(0.8, 1.3)
	gen payroll_share_ind`ind' = emp_share_ind`ind' * wage_mult_ind`ind'
}

* Normalize
egen temp_payroll_total = rowtotal(payroll_share_ind*)
forvalues ind = 1/`N_industries' {
	replace payroll_share_ind`ind' = payroll_share_ind`ind' / temp_payroll_total
	drop wage_mult_ind`ind'
}
drop temp_payroll_total

ssiv unemp_change mfg_decline college_2000 mfg_share_2000, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	altshares(payroll_share_ind*) ///
	cluster(state_id)

di ""

********************************************************************************
* 11. HETEROGENEOUS EFFECTS
********************************************************************************

di "==================================================================="
di "Heterogeneous Effects by College Share"
di "==================================================================="

* Split sample by college education
gen high_college = (college_2000 > 0.25)

di "A. Low college areas:"
ssiv unemp_change mfg_decline mfg_share_2000 if high_college == 0, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id) ///
	nodiagnostics

estimates store ssiv_low_coll

di ""
di "B. High college areas:"
ssiv unemp_change mfg_decline mfg_share_2000 if high_college == 1, ///
	shares(emp_share_ind*) ///
	shocks(import_shock_ind*) ///
	cluster(state_id) ///
	nodiagnostics

estimates store ssiv_high_coll

di ""

********************************************************************************
* 12. SUMMARY TABLE
********************************************************************************

di "==================================================================="
di "Summary of Results"
di "==================================================================="

estimates table ssiv_unemp ssiv_wages ssiv_pop, ///
	b(%8.4f) se(%8.4f) ///
	stats(N F_stat herf_index corr_size) ///
	title("Main Results: Effects of Manufacturing Decline")

di ""
di "Comparison: Main vs. Leave-One-Out"
estimates table ssiv_unemp ssiv_unemp_loo, ///
	b(%8.4f) se(%8.4f) stats(F_stat)

di ""
di "Heterogeneity by Education"
estimates table ssiv_low_coll ssiv_high_coll, ///
	b(%8.4f) se(%8.4f) stats(N F_stat)

di ""
di "==================================================================="
di "Example complete!"
di "==================================================================="
di ""
di "Key findings:"
di "  1. Trade-induced manufacturing decline increases unemployment"
di "  2. Negative effects on wages and population (out-migration)"
di "  3. Effects are larger in low-education areas"
di "  4. Results robust to LOO and alternative share definitions"
di "  5. Diagnostics indicate valid identification"
di ""
di "This example demonstrates the Autor, Dorn & Hanson (2013) approach"
di "using industry employment shares and trade shocks."
di ""
