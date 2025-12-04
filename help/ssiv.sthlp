{smcl}
{* *! version 0.1.0  04dec2025}{...}
{viewerjumpto "Syntax" "ssiv##syntax"}{...}
{viewerjumpto "Description" "ssiv##description"}{...}
{viewerjumpto "Options" "ssiv##options"}{...}
{viewerjumpto "Examples" "ssiv##examples"}{...}
{viewerjumpto "Stored results" "ssiv##results"}{...}
{viewerjumpto "References" "ssiv##references"}{...}
{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{cmd:ssiv} {hline 2}}Shift-Share Instrumental Variables Estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:ssiv} {depvar} {it:endogvar} [{it:controls}] {ifin} {weight}{cmd:,}
{cmd:shares(}{varlist}{cmd:)}
{cmd:shocks(}{varlist}{cmd:)}
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt shares(varlist)}}variables containing share weights (w_is){p_end}
{synopt :{opt shocks(varlist)}}variables containing sector shocks (g_s){p_end}

{syntab:Estimation}
{synopt :{opt method(string)}}estimation method: {bf:classic}, {bf:akm}, or {bf:borusyak} (default){p_end}
{synopt :{opt loo}}use leave-one-out instrument construction{p_end}
{synopt :{opt normalize}}normalize shocks to z-scores{p_end}
{synopt :{opt controls(varlist)}}additional control variables{p_end}

{syntab:Inference}
{synopt :{opt vce(vcetype)}}variance-covariance estimation: {bf:robust} (default) or {bf:cluster} {it:clustvar}{p_end}
{synopt :{opt cluster(varname)}}cluster standard errors by {it:varname}{p_end}

{syntab:Robustness}
{synopt :{opt altshares(varlist)}}alternative share specification for robustness check{p_end}

{syntab:Output}
{synopt :{opt saveiv(newvar)}}save constructed instrument as {it:newvar}{p_end}
{synopt :{opt nodiagnostics}}suppress diagnostic checks{p_end}
{synopt :{opt keepvars(varlist)}}variables to keep in output{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s and {cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:ssiv} implements shift-share (Bartik) instrumental variables estimation with modern inference methods
and diagnostic checks. The command constructs a shift-share instrument of the form:

{pmore}
Z_i = sum_s w_is * g_s

{pstd}
where w_is are pre-determined shares (e.g., employment shares) and g_s are exogenous shocks (e.g., national
industry growth rates). The command then uses Z_i as an instrument for an endogenous variable in a two-stage
least squares framework.

{pstd}
The command implements three methodological approaches:

{pmore}
{bf:classic}: Traditional Bartik IV with standard inference (Bartik 1991)

{pmore}
{bf:akm}: Inference adjustments for correlation across many shocks (Adão, Kolesár & Morales 2019)

{pmore}
{bf:borusyak}: Recommended framework distinguishing shock-based vs. share-based identification (Borusyak, Hull & Jaravel 2025)

{pstd}
The command automatically performs diagnostic checks including:

{phang}• Identification path determination (shock-based vs. share-based){p_end}
{phang}• Share distribution and variation analysis{p_end}
{phang}• Concentration measures (Herfindahl index){p_end}
{phang}• Correlation with region size{p_end}
{phang}• First-stage strength tests{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt shares(varlist)} specifies the share variables (w_is). These should be pre-determined weights that sum
to approximately 1 for each region. For example, employment shares by industry in a base period.

{phang}
{opt shocks(varlist)} specifies the shock variables (g_s). These should be exogenous sector-level shocks.
Can be a single variable applied to all shares, or a list matching the number of shares.

{dlgtab:Estimation}

{phang}
{opt method(string)} specifies the estimation method. {bf:borusyak} (default) is recommended and implements
the framework of Borusyak, Hull & Jaravel (2025), which provides guidance on identification strategy.
{bf:akm} implements inference adjustments for settings with many shocks (Adão, Kolesár & Morales 2019).
{bf:classic} implements traditional Bartik IV.

{phang}
{opt loo} constructs leave-one-out instruments by excluding each region from the shock calculation.
This addresses concerns about mechanical correlation between instrument and error term.

{phang}
{opt normalize} standardizes shocks to z-scores (mean 0, standard deviation 1) before constructing
the instrument.

{phang}
{opt controls(varlist)} includes additional control variables in both first and second stage regressions.

{dlgtab:Inference}

{phang}
{opt vce(vcetype)} specifies the variance-covariance estimator. Default is {bf:robust}.
Specify {bf:cluster} {it:clustvar} to cluster standard errors.

{phang}
{opt cluster(varname)} is a shorthand for {cmd:vce(cluster} {it:varname}{cmd:)}.

{dlgtab:Robustness}

{phang}
{opt altshares(varlist)} specifies alternative share definitions for robustness checks.
The command will estimate the model using both the main and alternative shares and report
the comparison.

{dlgtab:Output}

{phang}
{opt saveiv(newvar)} saves the constructed shift-share instrument as a new variable.

{phang}
{opt nodiagnostics} suppresses the automatic diagnostic checks.

{phang}
{opt keepvars(varlist)} specifies variables to keep in the output dataset.


{marker examples}{...}
{title:Examples}

{pstd}Setup: Load simulated data{p_end}
{phang2}{cmd:. use example_data, clear}{p_end}

{pstd}Basic shift-share IV estimation{p_end}
{phang2}{cmd:. ssiv wage_growth (employment_growth = .), shares(share_ind1 share_ind2 share_ind3) shocks(shock1 shock2 shock3)}{p_end}

{pstd}With clustered standard errors{p_end}
{phang2}{cmd:. ssiv wage_growth employment_growth, shares(share_ind*) shocks(shock*) cluster(state)}{p_end}

{pstd}Using leave-one-out instrument{p_end}
{phang2}{cmd:. ssiv wage_growth employment_growth, shares(share_ind*) shocks(shock*) loo cluster(state)}{p_end}

{pstd}With AKM inference for many shocks{p_end}
{phang2}{cmd:. ssiv wage_growth employment_growth, shares(share_ind*) shocks(shock*) method(akm) cluster(state)}{p_end}

{pstd}Robustness check with alternative shares{p_end}
{phang2}{cmd:. ssiv wage_growth employment_growth, shares(emp_share*) shocks(shock*) altshares(wage_share*) cluster(state)}{p_end}

{pstd}Save the constructed instrument{p_end}
{phang2}{cmd:. ssiv wage_growth employment_growth, shares(share*) shocks(shock*) saveiv(bartik_iv)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ssiv} stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(F_stat)}}first-stage F-statistic on excluded instrument{p_end}
{synopt:{cmd:e(F_p)}}p-value for first-stage F-statistic{p_end}
{synopt:{cmd:e(herf_index)}}Herfindahl concentration index{p_end}
{synopt:{cmd:e(corr_size)}}correlation between instrument and weights{p_end}
{synopt:{cmd:e(n_shocks)}}number of shocks{p_end}
{synopt:{cmd:e(n_shares)}}number of shares{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ssiv}{p_end}
{synopt:{cmd:e(method)}}estimation method used{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(endogvar)}}endogenous variable{p_end}
{synopt:{cmd:e(vcetype)}}variance-covariance type{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix{p_end}


{marker references}{...}
{title:References}

{phang}
Bartik, T. J. (1991). {it:Who Benefits from State and Local Economic Development Policies?}
W.E. Upjohn Institute for Employment Research.

{phang}
Borusyak, K., Hull, P., & Jaravel, X. (2025).
A Practical Guide to Shift-Share Instruments.
{it:Journal of Economic Perspectives}, 39(1), 181-204.

{phang}
Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020).
Bartik Instruments: What, When, Why, and How.
{it:American Economic Review}, 110(8), 2586-2624.

{phang}
Adão, R., Kolesár, M., & Morales, E. (2019).
Shift-Share Designs: Theory and Inference.
{it:The Quarterly Journal of Economics}, 134(4), 1949-2010.


{title:Author}

{pstd}
Claude Code{break}
Based on methodology by Borusyak, Hull, Jaravel; Goldsmith-Pinkham, Sorkin, Swift; Adão, Kolesár, Morales

{pstd}
For bug reports and feature requests, please visit:{break}
https://github.com/MaykolMedrano/Shift-Share-IV-Design


{title:Also see}

{psee}
Online: {helpb ivregress}, {helpb ivreg2}, {helpb reghdfe}
{p_end}
