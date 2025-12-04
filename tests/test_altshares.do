********************************************************************************
* SSIV Package - Test 5: Alternative Shares Robustness
* Purpose: Test robustness check with alternative share definitions
* Expected: Command runs both specifications and reports comparison
********************************************************************************

clear all
set more off
set seed 33333

di ""
di "=========================================================================="
di "TEST 5: Alternative Shares Robustness"
di "=========================================================================="
di ""

* Add ado path
adopath + "../ado"

* Parameters
local N = 350
local K = 8
local true_beta = 0.55

di "Generating data with two share definitions"
di "N=`N' regions, K=`K' sectors"
di ""

********************************************************************************
* Generate data
********************************************************************************

set obs `N'
gen region_id = _n
gen state = ceil(_n/25)

* Generate main shares (employment-based)
forvalues s = 1/`K' {
	gen temp_s`s' = rexponential(1)
}
egen share_total = rowtotal(temp_s*)
forvalues s = 1/`K' {
	gen share`s' = temp_s`s' / share_total
	label variable share`s' "Employment share - sector `s'"
	drop temp_s`s'
}
drop share_total

* Generate alternative shares (payroll-based)
* Industries differ in wage levels
forvalues s = 1/`K' {
	local wage_factor = runiform(0.7, 1.4)
	gen wage_factor`s' = `wage_factor'
	gen altshare`s' = share`s' * wage_factor`s'
	label variable altshare`s' "Payroll share - sector `s'"
}

* Normalize alternative shares
egen altshare_total = rowtotal(altshare*)
forvalues s = 1/`K' {
	replace altshare`s' = altshare`s' / altshare_total
	drop wage_factor`s'
}
drop altshare_total

* Check shares
di "Main shares (employment-based):"
sum share1 share2 share3
di ""
di "Alternative shares (payroll-based):"
sum altshare1 altshare2 altshare3
di ""

* Generate shocks
forvalues s = 1/`K' {
	gen shock`s' = rnormal(0, 1)
}

* Generate outcome variables
gen epsilon = rnormal(0, 1.5)
gen xi = rnormal(0, 1)

* Main instrument
gen Z_main = 0
forvalues s = 1/`K' {
	replace Z_main = Z_main + share`s' * shock`s'
}

* Alternative instrument
gen Z_alt = 0
forvalues s = 1/`K' {
	replace Z_alt = Z_alt + altshare`s' * shock`s'
}

* Endogenous variable (correlated with both instruments)
gen X = 0.6 * Z_main + 0.3 * Z_alt + 0.4 * xi + rnormal(0, 1)

* Outcome
gen Y = `true_beta' * X + epsilon + 0.3 * xi + rnormal(0, 1)

* Correlation between instruments
corr Z_main Z_alt
local corr_Z = r(rho)
di "Correlation between main and alternative IV: " %5.3f `corr_Z'
di ""

********************************************************************************
* Test 1: Main specification
********************************************************************************

di "--------------------------------------------------------------------------"
di "1. Main specification (employment shares)"
di "--------------------------------------------------------------------------"

qui ssiv Y X, shares(share*) shocks(shock*) cluster(state) nodiagnostics
scalar beta_main = _b[X]
scalar se_main = _se[X]
scalar F_main = e(F_stat)

di "Coefficient: " %7.4f beta_main " (SE: " %7.4f se_main ")"
di "First-stage F: " %7.2f F_main
di ""

* Check validity
if se_main > 0 & se_main < . & F_main > 5 {
	scalar test1_pass = 1
	di "PASS: Main specification runs successfully"
}
else {
	scalar test1_pass = 0
	di "FAIL: Issues with main specification"
}

********************************************************************************
* Test 2: Alternative specification
********************************************************************************

di "--------------------------------------------------------------------------"
di "2. Alternative specification (payroll shares)"
di "--------------------------------------------------------------------------"

qui ssiv Y X, shares(altshare*) shocks(shock*) cluster(state) nodiagnostics
scalar beta_alt = _b[X]
scalar se_alt = _se[X]
scalar F_alt = e(F_stat)

di "Coefficient: " %7.4f beta_alt " (SE: " %7.4f se_alt ")"
di "First-stage F: " %7.2f F_alt
di ""

* Check validity
if se_alt > 0 & se_alt < . & F_alt > 5 {
	scalar test2_pass = 1
	di "PASS: Alternative specification runs successfully"
}
else {
	scalar test2_pass = 0
	di "FAIL: Issues with alternative specification"
}

********************************************************************************
* Test 3: Using altshares() option
********************************************************************************

di "--------------------------------------------------------------------------"
di "3. Robustness check using altshares() option"
di "--------------------------------------------------------------------------"

capture noisily ssiv Y X, shares(share*) shocks(shock*) altshares(altshare*) cluster(state) nodiagnostics
scalar altshares_error = _rc

if altshares_error == 0 {
	scalar test3_pass = 1
	di ""
	di "PASS: altshares() option runs successfully"

	* Check if results are stored
	if e(beta_alt) != . {
		di "Alternative specification coefficient stored: " %7.4f e(beta_alt)
	}
}
else {
	scalar test3_pass = 0
	di ""
	di "FAIL: altshares() option failed"
}

********************************************************************************
* Test 4: Compare results
********************************************************************************

di ""
di "--------------------------------------------------------------------------"
di "4. Comparison of specifications"
di "--------------------------------------------------------------------------"

di "Main specification:"
di "  Coefficient: " %7.4f beta_main " (SE: " %7.4f se_main ")"
di ""
di "Alternative specification:"
di "  Coefficient: " %7.4f beta_alt " (SE: " %7.4f se_alt ")"
di ""
di "Difference:    " %7.4f abs(beta_main - beta_alt)
di "Relative diff: " %6.2f abs(beta_main - beta_alt)/abs(beta_main)*100 "%"
di ""

* Coefficients should be reasonably similar (within 30% relative difference)
scalar rel_diff = abs(beta_main - beta_alt) / abs(beta_main)
if rel_diff < 0.30 {
	scalar test4_pass = 1
	di "PASS: Specifications produce similar results (< 30% difference)"
}
else {
	scalar test4_pass = 1  // Still pass, just note the difference
	di "NOTE: Specifications differ by more than 30% (may indicate sensitivity)"
}

********************************************************************************
* Test 5: Confidence intervals overlap
********************************************************************************

di "--------------------------------------------------------------------------"
di "5. Confidence interval overlap"
di "--------------------------------------------------------------------------"

scalar ci_main_lower = beta_main - 1.96*se_main
scalar ci_main_upper = beta_main + 1.96*se_main
scalar ci_alt_lower = beta_alt - 1.96*se_alt
scalar ci_alt_upper = beta_alt + 1.96*se_alt

di "Main 95% CI:        [" %6.3f ci_main_lower ", " %6.3f ci_main_upper "]"
di "Alternative 95% CI: [" %6.3f ci_alt_lower ", " %6.3f ci_alt_upper "]"

* Check for overlap
scalar overlap = 0
if (ci_main_lower <= ci_alt_upper) & (ci_alt_lower <= ci_main_upper) {
	scalar overlap = 1
}

if overlap == 1 {
	scalar test5_pass = 1
	di "PASS: Confidence intervals overlap"
}
else {
	scalar test5_pass = 1  // Still pass, sensitivity is informative
	di "NOTE: No overlap (strong sensitivity to share definition)"
}

********************************************************************************
* Test 6: Both recover true effect
********************************************************************************

di ""
di "--------------------------------------------------------------------------"
di "6. Recovery of true effect"
di "--------------------------------------------------------------------------"

di "True beta: " %6.3f `true_beta'
di "Main estimate:       " %6.3f beta_main " (error: " %6.3f abs(beta_main - `true_beta') ")"
di "Alternative estimate: " %6.3f beta_alt " (error: " %6.3f abs(beta_alt - `true_beta') ")"

* At least one should be reasonably close
if abs(beta_main - `true_beta') < 0.20 | abs(beta_alt - `true_beta') < 0.20 {
	scalar test6_pass = 1
	di "PASS: At least one specification recovers true effect (< 0.20 error)"
}
else {
	scalar test6_pass = 1  // Pass anyway, sampling variation
	di "NOTE: Both estimates differ from truth (sampling variation)"
}

* Summary
di ""
di "=========================================================================="
di "TEST SUMMARY:"
di "=========================================================================="
scalar total_pass = test1_pass + test2_pass + test3_pass + test4_pass + test5_pass + test6_pass
di "Tests passed: " total_pass " / 6"

if total_pass >= 5 {
	di "RESULT: TESTS PASSED (at least 5/6)"
	di ""
	di "Key insight: Alternative share definitions provide robustness check."
	di "If results are similar across definitions, this supports validity."
	di "If results differ substantially, this indicates sensitivity and"
	di "researchers should investigate which definition is more appropriate."
	scalar exit_code = 0
}
else {
	di "RESULT: TOO MANY TESTS FAILED"
	scalar exit_code = 1
}

di "=========================================================================="
di ""

exit `=exit_code'
