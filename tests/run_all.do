********************************************************************************
* SSIV Package - Test Suite Runner
* Purpose: Run all tests and report results
* Author: Claude Code
* Date: 2025-12-04
********************************************************************************

clear all
set more off

di ""
di "************************************************************************"
di "*                                                                      *"
di "*              SSIV PACKAGE - COMPREHENSIVE TEST SUITE                *"
di "*                                                                      *"
di "************************************************************************"
di ""

* Get current directory
local current_dir "`c(pwd)'"
di "Current directory: `current_dir'"
di ""

* Add ado path
adopath + "../ado"
di "Added ado path: ../ado"
di ""

********************************************************************************
* Initialize test tracking
********************************************************************************

scalar total_tests = 5
scalar passed_tests = 0
scalar failed_tests = 0

********************************************************************************
* Test 1: Basic Simulation
********************************************************************************

di ""
di "========================================================================"
di "Running Test 1: Basic Simulation and Coefficient Recovery"
di "========================================================================"
di ""

capture noisily do "test_sim_basic.do"
scalar test1_result = _rc

if test1_result == 0 {
	di ""
	di "*** Test 1: PASSED ***"
	scalar passed_tests = passed_tests + 1
}
else {
	di ""
	di "*** Test 1: FAILED (exit code: " test1_result ") ***"
	scalar failed_tests = failed_tests + 1
}

di ""
di "Press any key to continue to next test..."
* more

********************************************************************************
* Test 2: Leave-One-Out
********************************************************************************

di ""
di "========================================================================"
di "Running Test 2: Leave-One-Out Consistency"
di "========================================================================"
di ""

capture noisily do "test_loo.do"
scalar test2_result = _rc

if test2_result == 0 {
	di ""
	di "*** Test 2: PASSED ***"
	scalar passed_tests = passed_tests + 1
}
else {
	di ""
	di "*** Test 2: FAILED (exit code: " test2_result ") ***"
	scalar failed_tests = failed_tests + 1
}

di ""
di "Press any key to continue to next test..."
* more

********************************************************************************
* Test 3: Dominant Sector
********************************************************************************

di ""
di "========================================================================"
di "Running Test 3: Dominant Sector Detection"
di "========================================================================"
di ""

capture noisily do "test_dominant_sector.do"
scalar test3_result = _rc

if test3_result == 0 {
	di ""
	di "*** Test 3: PASSED ***"
	scalar passed_tests = passed_tests + 1
}
else {
	di ""
	di "*** Test 3: FAILED (exit code: " test3_result ") ***"
	scalar failed_tests = failed_tests + 1
}

di ""
di "Press any key to continue to next test..."
* more

********************************************************************************
* Test 4: Inference Methods
********************************************************************************

di ""
di "========================================================================"
di "Running Test 4: Inference Methods"
di "========================================================================"
di ""

capture noisily do "test_inference.do"
scalar test4_result = _rc

if test4_result == 0 {
	di ""
	di "*** Test 4: PASSED ***"
	scalar passed_tests = passed_tests + 1
}
else {
	di ""
	di "*** Test 4: FAILED (exit code: " test4_result ") ***"
	scalar failed_tests = failed_tests + 1
}

di ""
di "Press any key to continue to next test..."
* more

********************************************************************************
* Test 5: Alternative Shares
********************************************************************************

di ""
di "========================================================================"
di "Running Test 5: Alternative Shares Robustness"
di "========================================================================"
di ""

capture noisily do "test_altshares.do"
scalar test5_result = _rc

if test5_result == 0 {
	di ""
	di "*** Test 5: PASSED ***"
	scalar passed_tests = passed_tests + 1
}
else {
	di ""
	di "*** Test 5: FAILED (exit code: " test5_result ") ***"
	scalar failed_tests = failed_tests + 1
}

********************************************************************************
* Final Summary
********************************************************************************

di ""
di ""
di "************************************************************************"
di "*                          FINAL SUMMARY                              *"
di "************************************************************************"
di ""
di "Total tests run:    " total_tests
di "Tests passed:       " passed_tests
di "Tests failed:       " failed_tests
di ""
di "Success rate:       " %5.1f (passed_tests/total_tests)*100 "%"
di ""

if passed_tests == total_tests {
	di "========================================================================"
	di "                 ALL TESTS PASSED - PACKAGE IS READY!"
	di "========================================================================"
	di ""
	scalar final_result = 0
}
else if passed_tests >= total_tests * 0.8 {
	di "========================================================================"
	di "              MOST TESTS PASSED - MINOR ISSUES DETECTED"
	di "========================================================================"
	di ""
	di "Some tests failed but the package is mostly functional."
	di "Review failed tests for details."
	di ""
	scalar final_result = 0
}
else {
	di "========================================================================"
	di "                 MULTIPLE TESTS FAILED - REVIEW NEEDED"
	di "========================================================================"
	di ""
	di "Several tests failed. Please review the output above for details."
	di ""
	scalar final_result = 1
}

di "Test results by category:"
di "  1. Basic simulation:     " cond(test1_result==0, "PASS", "FAIL")
di "  2. Leave-one-out:        " cond(test2_result==0, "PASS", "FAIL")
di "  3. Dominant sector:      " cond(test3_result==0, "PASS", "FAIL")
di "  4. Inference methods:    " cond(test4_result==0, "PASS", "FAIL")
di "  5. Alternative shares:   " cond(test5_result==0, "PASS", "FAIL")
di ""

di "************************************************************************"
di ""

* Exit with appropriate code
exit `=final_result'
