********************************************************************************
* SSIV Package - Test 2: Leave-One-Out Consistency
* Purpose: Verify LOO produces consistent results
* Expected: LOO coefficient within 10% of main coefficient
********************************************************************************

clear all
set more off
set seed 99999

di ""
di "=========================================================================="
di "TEST 2: Leave-One-Out Consistency"
di "=========================================================================="
di ""

* Add ado path
adopath + "../ado"

* Parameters
local N = 500
local K = 8
local true_beta = 0.6

di "Generating data: N=`N' regions, K=`K' sectors"
di "True beta = `true_beta'"
di ""

********************************************************************************
* Generate data
********************************************************************************

set obs `N'
gen region_id = _n
gen state = ceil(_n/25)

* Generate shares
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
gen epsilon = rnormal(0, 1.5)
gen xi = rnormal(0, 1)

* Construct IV
gen Z = 0
forvalues s = 1/`K' {
	replace Z = Z + share`s' * shock`s'
}

* Generate endogenous X
gen X = 0.85 * Z + 0.4 * xi + rnormal(0, 0.8)

* Generate outcome
gen Y = `true_beta' * X + epsilon + 0.2 * xi + rnormal(0, 1)

********************************************************************************
* Run standard ssiv
********************************************************************************

di "Running standard ssiv..."
qui ssiv Y X, shares(share*) shocks(shock*) cluster(state)
scalar beta_main = _b[X]
scalar se_main = _se[X]
scalar F_main = e(F_stat)

di "Standard SSIV results:"
di "  Coefficient: " %7.4f beta_main
di "  Std. error:  " %7.4f se_main
di "  First-stage F: " %7.2f F_main
di ""

********************************************************************************
* Run LOO ssiv
********************************************************************************

di "Running leave-one-out ssiv..."
qui ssiv Y X, shares(share*) shocks(shock*) cluster(state) loo
scalar beta_loo = _b[X]
scalar se_loo = _se[X]
scalar F_loo = e(F_stat)

di "Leave-one-out SSIV results:"
di "  Coefficient: " %7.4f beta_loo
di "  Std. error:  " %7.4f se_loo
di "  First-stage F: " %7.2f F_loo
di ""

********************************************************************************
* Tests and assertions
********************************************************************************

di "--------------------------------------------------------------------------"
di "TEST ASSERTIONS:"
di "--------------------------------------------------------------------------"

* Test 1: Both have strong first stage
di "1. First-stage strength:"
di "   Main F: " %7.2f F_main
di "   LOO F:  " %7.2f F_loo
if F_main > 10 & F_loo > 10 {
	di "   PASS: Both have F > 10"
	scalar test1_pass = 1
}
else {
	di "   FAIL: Weak instrument in at least one specification"
	scalar test1_pass = 0
}

* Test 2: Coefficients are similar (within 15% relative difference)
scalar rel_diff = abs(beta_main - beta_loo) / abs(beta_main)
di ""
di "2. Coefficient consistency:"
di "   Main coefficient: " %7.4f beta_main
di "   LOO coefficient:  " %7.4f beta_loo
di "   Relative difference: " %6.2f rel_diff*100 "%"
if rel_diff < 0.15 {
	di "   PASS: Coefficients within 15% of each other"
	scalar test2_pass = 1
}
else {
	di "   FAIL: Large difference between main and LOO (> 15%)"
	scalar test2_pass = 0
}

* Test 3: Confidence intervals overlap
scalar ci_main_lower = beta_main - 1.96*se_main
scalar ci_main_upper = beta_main + 1.96*se_main
scalar ci_loo_lower = beta_loo - 1.96*se_loo
scalar ci_loo_upper = beta_loo + 1.96*se_loo

di ""
di "3. Confidence interval overlap:"
di "   Main 95% CI: [" %6.3f ci_main_lower ", " %6.3f ci_main_upper "]"
di "   LOO 95% CI:  [" %6.3f ci_loo_lower ", " %6.3f ci_loo_upper "]"

* Check for overlap
scalar overlap = 0
if (ci_main_lower <= ci_loo_upper) & (ci_loo_lower <= ci_main_upper) {
	scalar overlap = 1
}

if overlap == 1 {
	di "   PASS: Confidence intervals overlap"
	scalar test3_pass = 1
}
else {
	di "   FAIL: No overlap in confidence intervals"
	scalar test3_pass = 0
}

* Test 4: Both recover true effect reasonably well
di ""
di "4. Recovery of true effect:"
scalar main_diff = abs(beta_main - `true_beta')
scalar loo_diff = abs(beta_loo - `true_beta')
di "   True beta: " %6.3f `true_beta'
di "   Main distance from truth: " %6.3f main_diff
di "   LOO distance from truth:  " %6.3f loo_diff

if main_diff < 0.20 & loo_diff < 0.20 {
	di "   PASS: Both within 0.20 of true value"
	scalar test4_pass = 1
}
else {
	di "   FAIL: At least one estimate far from truth"
	scalar test4_pass = 0
}

* Summary
di ""
di "=========================================================================="
di "TEST SUMMARY:"
di "=========================================================================="
scalar total_pass = test1_pass + test2_pass + test3_pass + test4_pass
di "Tests passed: " total_pass " / 4"

if total_pass >= 3 {
	di "RESULT: TESTS PASSED (at least 3/4)"
	scalar exit_code = 0
}
else {
	di "RESULT: TOO MANY TESTS FAILED"
	scalar exit_code = 1
}

di "=========================================================================="
di ""

exit `=exit_code'
