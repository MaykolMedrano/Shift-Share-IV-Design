********************************************************************************
* SSIV Package - Test 3: Dominant Sector Detection
* Purpose: Verify that command detects and warns about dominant sectors
* Expected: High Herfindahl index when one sector dominates
********************************************************************************

clear all
set more off
set seed 77777

di ""
di "=========================================================================="
di "TEST 3: Dominant Sector Detection"
di "=========================================================================="
di ""

* Add ado path
adopath + "../ado"

* Parameters
local N = 300
local K = 5

di "Generating data with one dominant sector"
di "N=`N' regions, K=`K' sectors"
di ""

********************************************************************************
* Generate data with dominant sector
********************************************************************************

set obs `N'
gen region_id = _n
gen state = ceil(_n/20)

* Generate shares where sector 1 is dominant (80% of employment in most regions)
gen share1 = runiform(0.75, 0.85)  // Dominant sector

* Distribute remaining share among other sectors
gen remaining = 1 - share1
forvalues s = 2/`K' {
	gen temp_s`s' = rexponential(1)
}
egen temp_total = rowtotal(temp_s*)
forvalues s = 2/`K' {
	gen share`s' = (temp_s`s' / temp_total) * remaining
	drop temp_s`s'
}
drop temp_total remaining

* Verify shares sum to 1
egen check_sum = rowtotal(share*)
sum check_sum
assert abs(check_sum - 1) < 0.001
drop check_sum

* Generate shocks
forvalues s = 1/`K' {
	gen shock`s' = rnormal(0, 1)
}

* Show share distribution
di "Share distribution:"
sum share1 share2 share3
di ""
di "Sector 1 is clearly dominant (mean ~0.80)"
di ""

* Generate outcome variables
gen epsilon = rnormal(0, 1.5)
gen xi = rnormal(0, 1)

gen Z = 0
forvalues s = 1/`K' {
	replace Z = Z + share`s' * shock`s'
}

gen X = 0.7 * Z + 0.4 * xi + rnormal(0, 1)
gen Y = 0.5 * X + epsilon + 0.3 * xi + rnormal(0, 1)

********************************************************************************
* Run ssiv
********************************************************************************

di "Running ssiv with dominant sector..."
ssiv Y X, shares(share*) shocks(shock*) cluster(state)

********************************************************************************
* Tests and assertions
********************************************************************************

di ""
di "--------------------------------------------------------------------------"
di "TEST ASSERTIONS:"
di "--------------------------------------------------------------------------"

* Test 1: Herfindahl index should be high (> 0.25)
scalar herf = e(herf_index)
di "1. Herfindahl concentration index: " %6.4f herf
if herf > 0.25 {
	di "   PASS: High concentration detected (H > 0.25)"
	scalar test1_pass = 1
}
else {
	di "   FAIL: Concentration not detected (H <= 0.25)"
	scalar test1_pass = 0
}

* Test 2: First-stage should still work (F > 5 at least)
scalar F_test = e(F_stat)
di ""
di "2. First-stage F-statistic: " %8.2f F_test
if F_test > 5 {
	di "   PASS: First stage has some strength (F > 5)"
	scalar test2_pass = 1
}
else {
	di "   FAIL: Very weak first stage (F <= 5)"
	scalar test2_pass = 0
}

* Test 3: Standard errors should exist and be finite
scalar se_X = _se[X]
di ""
di "3. Standard error: " %7.4f se_X
if se_X > 0 & se_X < . {
	di "   PASS: Valid standard error"
	scalar test3_pass = 1
}
else {
	di "   FAIL: Invalid standard error"
	scalar test3_pass = 0
}

* Test 4: Command should complete without error
di ""
di "4. Command completion: PASS (command ran successfully)"
scalar test4_pass = 1

* Additional diagnostic: Compare to case without dominant sector
di ""
di "--------------------------------------------------------------------------"
di "COMPARISON: Generating data WITHOUT dominant sector"
di "--------------------------------------------------------------------------"

preserve

clear
set obs `N'
gen region_id = _n
gen state = ceil(_n/20)

* Generate more balanced shares
forvalues s = 1/`K' {
	gen temp_s`s' = rexponential(1)
}
egen share_total = rowtotal(temp_s*)
forvalues s = 1/`K' {
	gen share`s' = temp_s`s' / share_total
	drop temp_s`s'
}
drop share_total

* Same shocks
forvalues s = 1/`K' {
	gen shock`s' = rnormal(0, 1)
}

* Same DGP
gen epsilon = rnormal(0, 1.5)
gen xi = rnormal(0, 1)
gen Z = 0
forvalues s = 1/`K' {
	replace Z = Z + share`s' * shock`s'
}
gen X = 0.7 * Z + 0.4 * xi + rnormal(0, 1)
gen Y = 0.5 * X + epsilon + 0.3 * xi + rnormal(0, 1)

qui ssiv Y X, shares(share*) shocks(shock*) cluster(state) nodiagnostics
scalar herf_balanced = e(herf_index)

restore

di "Herfindahl with dominant sector:  " %6.4f herf
di "Herfindahl with balanced shares:  " %6.4f herf_balanced
di "Ratio (dominant/balanced):        " %6.2f herf/herf_balanced
di ""
di "The dominant sector case should have much higher Herfindahl."

* Summary
di ""
di "=========================================================================="
di "TEST SUMMARY:"
di "=========================================================================="
scalar total_pass = test1_pass + test2_pass + test3_pass + test4_pass
di "Tests passed: " total_pass " / 4"

if total_pass == 4 {
	di "RESULT: ALL TESTS PASSED"
	di "Command correctly detects dominant sector concentration"
	scalar exit_code = 0
}
else {
	di "RESULT: SOME TESTS FAILED"
	scalar exit_code = 1
}

di "=========================================================================="
di ""

exit `=exit_code'
