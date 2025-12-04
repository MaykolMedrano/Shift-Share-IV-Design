********************************************************************************
* SSIV Package - Test 1: Basic Simulation Test
* Purpose: Verify basic functionality and coefficient recovery
* Expected: F-stat > 10, coefficient within 0.1 of true value (0.5)
********************************************************************************

clear all
set more off
set seed 12345

di ""
di "=========================================================================="
di "TEST 1: Basic Simulation and Coefficient Recovery"
di "=========================================================================="
di ""

* Add ado path
adopath + "../ado"

* Parameters
local N = 1000
local K = 10
local true_beta = 0.5

di "Generating data: N=`N' regions, K=`K' sectors"
di "True beta = `true_beta'"
di ""

********************************************************************************
* Generate data
********************************************************************************

set obs `N'
gen region_id = _n
gen state = ceil(_n/50)

* Generate shares (Dirichlet-like)
forvalues s = 1/`K' {
	gen temp_s`s' = rexponential(1)
}
egen share_total = rowtotal(temp_s*)
forvalues s = 1/`K' {
	gen share`s' = temp_s`s' / share_total
	drop temp_s`s'
}
drop share_total

* Generate shocks
forvalues s = 1/`K' {
	gen shock`s' = rnormal(0, 1)
}

* Generate unobservables
gen epsilon = rnormal(0, 2)
gen xi = rnormal(0, 1.5)

* Construct IV
gen Z = 0
forvalues s = 1/`K' {
	replace Z = Z + share`s' * shock`s'
}

* Generate endogenous X
gen X = 0.8 * Z + 0.5 * xi + rnormal(0, 1)

* Generate outcome with TRUE effect = 0.5
gen Y = `true_beta' * X + epsilon + 0.3 * xi + rnormal(0, 1)

********************************************************************************
* Run ssiv
********************************************************************************

di "Running ssiv command..."
ssiv Y X, shares(share*) shocks(shock*) cluster(state)

********************************************************************************
* Tests and assertions
********************************************************************************

di ""
di "--------------------------------------------------------------------------"
di "TEST ASSERTIONS:"
di "--------------------------------------------------------------------------"

* Test 1: First-stage F > 10
scalar F_test = e(F_stat)
di "1. First-stage F-statistic: " %8.2f F_test
if F_test > 10 {
	di "   PASS: F > 10 (strong instrument)"
	scalar test1_pass = 1
}
else {
	di "   FAIL: F <= 10 (weak instrument)"
	scalar test1_pass = 0
}

* Test 2: Coefficient within 0.15 of true value
scalar beta_hat = _b[X]
scalar beta_diff = abs(beta_hat - `true_beta')
di ""
di "2. Estimated coefficient: " %6.3f beta_hat " (true: " %6.3f `true_beta' ")"
di "   Absolute difference: " %6.3f beta_diff
if beta_diff < 0.15 {
	di "   PASS: Coefficient within 0.15 of true value"
	scalar test2_pass = 1
}
else {
	di "   FAIL: Coefficient differs by more than 0.15"
	scalar test2_pass = 0
}

* Test 3: Coefficient statistically significant
test X
scalar p_val = r(p)
di ""
di "3. Significance test p-value: " %6.4f p_val
if p_val < 0.05 {
	di "   PASS: Coefficient significant at 5% level"
	scalar test3_pass = 1
}
else {
	di "   FAIL: Coefficient not significant"
	scalar test3_pass = 0
}

* Test 4: Herfindahl index not too high
scalar herf = e(herf_index)
di ""
di "4. Herfindahl concentration index: " %6.4f herf
if herf < 0.30 {
	di "   PASS: Concentration acceptable (H < 0.30)"
	scalar test4_pass = 1
}
else {
	di "   FAIL: High concentration (H >= 0.30)"
	scalar test4_pass = 0
}

* Summary
di ""
di "=========================================================================="
di "TEST SUMMARY:"
di "=========================================================================="
scalar total_pass = test1_pass + test2_pass + test3_pass + test4_pass
di "Tests passed: " total_pass " / 4"

if total_pass == 4 {
	di "RESULT: ALL TESTS PASSED"
	scalar exit_code = 0
}
else {
	di "RESULT: SOME TESTS FAILED"
	scalar exit_code = 1
}

di "=========================================================================="
di ""

* Return exit code
exit `=exit_code'
