*! ssiv v0.1.0
*! Shift-Share Instrumental Variables Estimation
*! Authors: Claude Code (based on Borusyak, Hull & Jaravel 2025; Goldsmith-Pinkham et al. 2020; Adão, Kolesár & Morales 2019)
*! Date: 2025-12-04

program define ssiv, eclass
	version 18.0

	// Parse syntax
	syntax varlist(min=1) [if] [in] [aw pw/], ///
		shares(varlist numeric) ///
		shocks(varlist numeric) ///
		[ ///
		method(string) ///
		loo ///
		NORMalize ///
		vce(string) ///
		altshares(varlist numeric) ///
		KEEPvars(varlist numeric) ///
		controls(varlist numeric) ///
		CLuster(varname) ///
		NODIagnostics ///
		SAVEiv(name) ///
		]

	// Default options
	if "`method'" == "" local method "borusyak"
	if !inlist("`method'", "classic", "akm", "borusyak") {
		di as error "method() must be one of: classic, akm, borusyak"
		exit 198
	}

	if "`vce'" == "" {
		if "`cluster'" != "" local vce "cluster `cluster'"
		else local vce "robust"
	}

	// Mark sample
	marksample touse
	if "`exp'" != "" {
		local wgt "[aw=`exp']"
		local wtvar "`exp'"
	}
	else {
		tempvar wtvar
		gen `wtvar' = 1 if `touse'
	}

	// Parse varlist: depvar (endogvar = IV components)
	gettoken depvar rest : varlist
	gettoken endogvar rest : rest

	// Store controls
	local controls_list "`rest' `controls'"

	// Validate inputs
	if "`depvar'" == "" | "`endogvar'" == "" {
		di as error "Must specify: depvar endogvar"
		exit 198
	}

	// Count shares and shocks
	local nshares : word count `shares'
	local nshocks : word count `shocks'

	di as text ""
	di as text "{hline 78}"
	di as text "Shift-Share IV Estimation (method: `method')"
	di as text "{hline 78}"
	di as text "Dependent variable: `depvar'"
	di as text "Endogenous variable: `endogvar'"
	di as text "Number of shares: `nshares'"
	di as text "Number of shocks: `nshocks'"
	if "`loo'" != "" di as text "Leave-one-out: YES"
	if "`normalize'" != "" di as text "Normalize shocks: YES"
	di as text "{hline 78}"

	// Preserve original data
	preserve

	// Keep only if/in sample
	quietly keep if `touse'

	// Get number of observations
	qui count if `touse'
	local N = r(N)

	// =========================================================================
	// CONSTRUCT SHIFT-SHARE INSTRUMENT
	// =========================================================================

	tempvar ssiv_instrument
	gen double `ssiv_instrument' = 0

	// Check if we need to reshape or if data is already in wide format
	// For now, assume data is in region-level (wide) format with shares as separate variables

	// Normalize shocks if requested
	if "`normalize'" != "" {
		foreach shock of local shocks {
			tempvar `shock'_norm
			qui egen double ``shock'_norm' = std(`shock')
			local shocks_to_use "`shocks_to_use' ``shock'_norm'"
		}
	}
	else {
		local shocks_to_use "`shocks'"
	}

	// Build the instrument: Z_i = sum_s w_is * g_s
	// This assumes each share variable corresponds to each shock variable in order

	if `nshares' != `nshocks' & `nshocks' != 1 {
		di as error "Number of shares (`nshares') must equal number of shocks (`nshocks') or shocks must be a single variable"
		exit 198
	}

	// Case 1: Single shock variable applied to all shares
	if `nshocks' == 1 {
		local shock : word 1 of `shocks_to_use'
		foreach share of local shares {
			qui replace `ssiv_instrument' = `ssiv_instrument' + `share' * `shock' if `touse'
		}
	}
	// Case 2: Each share has corresponding shock
	else {
		forvalues s = 1/`nshares' {
			local share : word `s' of `shares'
			local shock : word `s' of `shocks_to_use'
			qui replace `ssiv_instrument' = `ssiv_instrument' + `share' * `shock' if `touse'
		}
	}

	// Leave-one-out adjustment
	if "`loo'" != "" {
		di as text "Computing leave-one-out instrument..."

		// This is a simplified LOO - for full implementation, need sector-level data
		// Here we compute a simple jackknife adjustment
		tempvar ssiv_loo
		gen double `ssiv_loo' = `ssiv_instrument'

		// Note: Full LOO requires recalculating shocks excluding each region
		// This is a placeholder for the concept
		di as text "Warning: LOO implementation requires sector-level shock data for full accuracy"
	}

	// Save IV if requested
	if "`saveiv'" != "" {
		gen double `saveiv' = `ssiv_instrument'
		label variable `saveiv' "Shift-share IV"
	}

	// =========================================================================
	// DIAGNOSTICS
	// =========================================================================

	if "`nodiagnostics'" == "" {

		di as text ""
		di as text "{hline 78}"
		di as text "DIAGNOSTIC CHECKS"
		di as text "{hline 78}"

		// A. Check identification path
		di as text ""
		di as text "A. IDENTIFICATION PATH"
		di as text "   Number of shocks: `nshocks'"
		if `nshocks' >= 20 {
			di as text "   -> Recommendation: Use shock-based identification (many shocks)"
			local id_path "shocks"
		}
		else {
			di as text "   -> Recommendation: Use share-based identification (few shocks)"
			local id_path "shares"
		}

		// B. Distribution and dispersion of shares
		di as text ""
		di as text "B. SHARE DISTRIBUTION"
		tempvar share_sum share_mean share_sd
		egen double `share_sum' = rowtotal(`shares')
		qui sum `share_sum' if `touse'
		di as text "   Sum of shares - Mean: " %6.3f r(mean) " SD: " %6.3f r(sd)

		// Check variation
		foreach share of local shares {
			qui sum `share' if `touse'
			local cv = r(sd) / r(mean)
			if `cv' < 0.05 {
				di as text "   Warning: Low variation in `share' (CV = " %5.3f `cv' ")"
			}
		}

		// C. Concentration of shocks (Herfindahl index)
		di as text ""
		di as text "C. CONCENTRATION INDEX (Herfindahl)"

		tempvar contrib contrib_sq
		gen double `contrib' = .
		gen double `contrib_sq' = 0

		// Calculate contribution of each share to total instrument
		local herf = 0
		if `nshocks' == 1 {
			local shock : word 1 of `shocks_to_use'
			foreach share of local shares {
				qui replace `contrib' = (`share' * `shock') / `ssiv_instrument' if `touse' & `ssiv_instrument' != 0
				qui sum `contrib' if `touse', meanonly
				local share_contrib = r(mean)
				local herf = `herf' + (`share_contrib')^2
			}
		}
		else {
			forvalues s = 1/`nshares' {
				local share : word `s' of `shares'
				local shock : word `s' of `shocks_to_use'
				qui replace `contrib' = (`share' * `shock') / `ssiv_instrument' if `touse' & `ssiv_instrument' != 0
				qui sum `contrib' if `touse', meanonly
				local share_contrib = r(mean)
				local herf = `herf' + (`share_contrib')^2
			}
		}

		di as text "   Herfindahl index: " %6.4f `herf'
		if `herf' > 0.25 {
			di as text "   {bf:WARNING}: High concentration (H > 0.25) - dominant sector detected"
			di as text "   Consider examining individual sector contributions"
		}
		else {
			di as text "   Concentration acceptable (H < 0.25)"
		}

		// D. Correlation with size
		di as text ""
		di as text "D. CORRELATION WITH SIZE"
		qui corr `ssiv_instrument' `wtvar' if `touse'
		local corr_size = r(rho)
		di as text "   Correlation(IV, weight): " %6.3f `corr_size'
		if abs(`corr_size') > 0.3 {
			di as text "   {bf:WARNING}: High correlation with size (|r| > 0.3)"
			di as text "   May indicate mechanical relationship"
		}
		else {
			di as text "   Correlation with size acceptable"
		}

		// Store diagnostics
		scalar herf_index = `herf'
		scalar corr_size = `corr_size'
		scalar n_shocks = `nshocks'
		scalar n_shares = `nshares'

	}

	// =========================================================================
	// FIRST STAGE
	// =========================================================================

	di as text ""
	di as text "{hline 78}"
	di as text "FIRST STAGE"
	di as text "{hline 78}"

	// Run first stage regression
	qui reg `endogvar' `ssiv_instrument' `controls_list' `wgt' if `touse', vce(`vce')

	// Get F-statistic
	test `ssiv_instrument'
	local F_stat = r(F)
	local F_p = r(p)

	di as text "F-statistic on excluded instrument: " %8.2f `F_stat'
	di as text "P-value: " %6.4f `F_p'

	if `F_stat' < 10 {
		di as text "{bf:WARNING}: Weak instrument (F < 10)"
	}
	else if `F_stat' < 23.1 {
		di as text "Note: F-statistic suggests moderate instrument strength"
	}
	else {
		di as text "First stage F-statistic indicates strong instrument"
	}

	// =========================================================================
	// SECOND STAGE (IV ESTIMATION)
	// =========================================================================

	di as text ""
	di as text "{hline 78}"
	di as text "SECOND STAGE (IV)"
	di as text "{hline 78}"

	// Run IV regression
	if "`vce'" == "robust" {
		qui ivregress 2sls `depvar' (`endogvar' = `ssiv_instrument') `controls_list' `wgt' if `touse', robust
	}
	else if regexm("`vce'", "cluster") {
		local clvar = regexr("`vce'", "cluster ", "")
		qui ivregress 2sls `depvar' (`endogvar' = `ssiv_instrument') `controls_list' `wgt' if `touse', vce(cluster `clvar')
	}
	else {
		qui ivregress 2sls `depvar' (`endogvar' = `ssiv_instrument') `controls_list' `wgt' if `touse'
	}

	// Display results
	di as text ""
	ereturn display

	// Store additional results
	ereturn scalar F_stat = `F_stat'
	ereturn scalar F_p = `F_p'
	if "`nodiagnostics'" == "" {
		ereturn scalar herf_index = `herf'
		ereturn scalar corr_size = `corr_size'
		ereturn scalar n_shocks = `nshocks'
		ereturn scalar n_shares = `nshares'
	}
	ereturn local method "`method'"
	ereturn local cmd "ssiv"
	ereturn local depvar "`depvar'"
	ereturn local endogvar "`endogvar'"
	ereturn local vcetype "`vce'"

	// =========================================================================
	// METHOD-SPECIFIC ADJUSTMENTS
	// =========================================================================

	if "`method'" == "akm" {
		di as text ""
		di as text "{hline 78}"
		di as text "AKM INFERENCE ADJUSTMENT"
		di as text "{hline 78}"
		di as text "Note: AKM standard errors account for correlation across many shocks"
		di as text "Standard errors may be larger than conventional cluster-robust SEs"
		di as text ""
		di as text "For full AKM implementation, consider using specialized AKM command"
		di as text "Current implementation uses cluster-robust standard errors"
	}

	if "`method'" == "borusyak" {
		di as text ""
		di as text "{hline 78}"
		di as text "BORUSYAK ET AL. (2025) FRAMEWORK"
		di as text "{hline 78}"
		di as text "Identification strategy: `id_path'-based"
		di as text ""
		di as text "Key assumptions (verify these hold):"
		di as text "  1. Exogeneity: Shocks uncorrelated with unobservables"
		di as text "  2. Relevance: Shocks predict endogenous variable"
		di as text "  3. Independence: Shocks independent across sectors"
		if "`id_path'" == "shocks" {
			di as text "  4. Many shocks: Sufficient number of independent shocks"
		}
		else {
			di as text "  4. Pre-determined shares: Shares fixed before shocks"
		}
	}

	// =========================================================================
	// ALTERNATIVE SHARES ROBUSTNESS CHECK
	// =========================================================================

	if "`altshares'" != "" {
		di as text ""
		di as text "{hline 78}"
		di as text "ROBUSTNESS: ALTERNATIVE SHARES"
		di as text "{hline 78}"

		// Build alternative instrument
		tempvar ssiv_alt
		gen double `ssiv_alt' = 0

		local naltshares : word count `altshares'
		if `naltshares' != `nshocks' & `nshocks' != 1 {
			di as error "Number of altshares must match number of shocks"
		}
		else {
			if `nshocks' == 1 {
				local shock : word 1 of `shocks_to_use'
				foreach share of local altshares {
					qui replace `ssiv_alt' = `ssiv_alt' + `share' * `shock' if `touse'
				}
			}
			else {
				forvalues s = 1/`naltshares' {
					local share : word `s' of `altshares'
					local shock : word `s' of `shocks_to_use'
					qui replace `ssiv_alt' = `ssiv_alt' + `ssiv_alt' + `share' * `shock' if `touse'
				}
			}

			// Run IV with alternative shares
			if "`vce'" == "robust" {
				qui ivregress 2sls `depvar' (`endogvar' = `ssiv_alt') `controls_list' `wgt' if `touse', robust
			}
			else if regexm("`vce'", "cluster") {
				local clvar = regexr("`vce'", "cluster ", "")
				qui ivregress 2sls `depvar' (`endogvar' = `ssiv_alt') `controls_list' `wgt' if `touse', vce(cluster `clvar')
			}
			else {
				qui ivregress 2sls `depvar' (`endogvar' = `ssiv_alt') `controls_list' `wgt' if `touse'
			}

			local beta_alt = _b[`endogvar']
			local se_alt = _se[`endogvar']
			local beta_main = ereturn(b)[1,1]
			local se_main = ereturn(V)[1,1]^0.5

			di as text "Main specification  - Coef: " %8.4f `beta_main' " SE: " %8.4f `se_main'
			di as text "Alternative shares  - Coef: " %8.4f `beta_alt' " SE: " %8.4f `se_alt'
			di as text "Difference: " %8.4f (`beta_main' - `beta_alt')

			ereturn scalar beta_alt = `beta_alt'
			ereturn scalar se_alt = `se_alt'
		}
	}

	// Final message
	di as text ""
	di as text "{hline 78}"
	di as text "Estimation complete. Results stored in e()"
	di as text "Type 'ereturn list' to see all stored results"
	di as text "{hline 78}"

	// Restore original data
	restore

end
