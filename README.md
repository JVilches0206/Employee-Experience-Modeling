# People Analytics: Employee Experience Analytics

## Overview

Employee surveys can tell organizations how employees are experiencing work, but collecting responses is only the beginning. The harder People Analytics question is:

> When employees report hundreds of different experiences, which ones should an organization investigate first—and how confident can we be that those relationships are meaningful?

### How do workplace experiences relate to employee advocacy and happiness?

This project examines that question using employee survey data and a measurement-first analytical approach. Rather than treating individual survey questions as isolated predictors, the analysis organizes employee experience into broader latent constructs and evaluates how those constructs relate to **employee advocacy (eNPS)** and **employee happiness**.

The analysis combines **SQL, psychometrics, multiple imputation, PLS-SEM, Importance-Performance Map Analysis (IPMA), and multilevel modeling** to move from survey data to evidence that can support further organizational investigation.

> **Important:** This is an observational, cross-sectional analysis. Results describe associations and potential areas for investigation; they do not establish causal effects.

---

## Key Findings
### Employee Advocacy (eNPS)

**Alignment, Rewards, and Wellbeing** emerged as the strongest positive correlates of employee advocacy.

- Marginal $R^2$ = 0.62
- Conditional $R^2$ = 0.64

### Employee Happiness
**Wellbeing, Intrinsic Motivation, and Alignment** emerged as the strongest correlates of employee happiness.

- Marginal $R^2$ = 0.44
- Conditional $R^2$ = 0.48

### Where should organizations focus?
Importance-Performance Map Analysis adds a practical dimension to the statistical results by identifying areas that combine relatively strong relationships with the outcomes and greater opportunity for improvement.

|Outcome|	Highest-priority areas |
|--------|-----------------------|
| eNPS |	Alignment, Rewards |
| Happiness |	Wellbeing, Intrinsic Motivation, Alignment |

### Employee Advocacy

![Importance-Performance Map for Employee Advocacy](Outputs/IPMA/ipma_enps.png)
*Importance-Performance Map for employee advocacy (eNPS).*

### Employee Happiness

![Importance-Performance Map for Employee Happiness](Outputs/IPMA/ipma_happy.png)

*Importance-Performance Map for employee happiness.*

---

## Team Context Matters

Employees are nested within teams, so employee-level observations are not independent. Assuming that clustered observations are independent can lead to overly optimistic uncertainty estimates and misleading statistical inferences. Multilevel modeling was therefore used to account for the hierarchical structure of the data.

The difference between marginal and conditional $R^2$ indicates that **team-level context provides additional explanatory information**, particularly for employee happiness.

This suggests that employee experience may not be solely an individual-level phenomenon and raises an important organizational question:

> **What is happening at the team or manager level that contributes to differences in employee experience?**

---

## An Important Model Finding

Feedback provides an important example of why employee-experience analytics cannot rely on individual relationships alone.

Feedback showed a negative $\beta$ coefficient in the multivariate models despite having a positive correlation with the outcomes.

This is **not evidence that feedback is harmful**. Rather, this pattern is consistent with **statistical suppression**. When correlated employee-experience dimensions are modeled simultaneously, coefficients represent each predictor's unique association after accounting for the others. When correlated employee-experience dimensions are modeled simultaneously, each coefficient represents the predictor's estimated unique association after accounting for the other predictors.

When predictors share substantial information, it becomes more difficult to distinguish which predictor is contributing information that is unique to that predictor. In this case, shared information among the employee-experience dimensions appears to affect the estimated Feedback $\beta$ coefficient, resulting in a negative coefficient in the multivariate model despite its positive correlation.

The important point is not that the presence of suppression invalidates the analysis. Instead, it demonstrates why **individual coefficients should be interpreted within the broader model rather than in isolation**.

The broader pattern of results remains informative: multiple analytical approaches identify consistent relationships among several employee-experience dimensions and the outcomes, while the suppression finding highlights an important limitation in assigning those relationships to completely independent predictors.

---

## Analytical Approach

```Employee Survey Data
        ↓
    SQL Cleaning
        ↓
 Multiple Imputation
        ↓
Psychometric Modeling
        ↓
     PLS-SEM
      ↙    ↘
    IPMA    MLM
      ↘    ↙
People Analytics Insights
```

## Methods

- **SQL**: Data preparation and cleaning
- **MICE**: Multiple Imputation by Chained Equations for missing data
- **Psychometric Modeling**: Evaluation of latent employee level constructs
- **PLS-SEM**: Partial Least Squares Structural Equation Modeling to estimate relationships among latent constructs and outcomes
- **IPMA**: Importance–Performance Map Analysis to identify areas of relatively high importance and opportunities for improvement
- **MLM**: Multilevel Modeling to account for employee clustering within teams
- **R/R Markdown**: Statistical analysis and reproducible reporting

## Why Psychometrics Matter
Employee experience variables such as Wellbeing, Alignment, Intrinsic Motivation, Rewards, and Feedback are latent constructs measured through survey items rather than directly observed. Before interpreting relationships between employee experience and outcomes, the analysis evaluates the quality of those measures through:

- Internal consistency and reliability
- Indicator loadings
- Discriminant validity
- Multicollinearity
- Construct correlations
- Intraclass correlations

This reflects a core principle of People Analytics:

> **Good decisions depend on good measurement.**

The underlying measurement outputs are available in the [`Outputs/Diagnostics/`](Outputs/Diagnostics/) and [`Outputs/PLS_SEM/`](Outputs/PLS_SEM/) directories.

## Analysis Pipeline

The analysis is organized as a reproducible sequence:

| Step | Script | Purpose |
|---|---|---|
| 1 | [`01_item_preprocessing.R`](R/01_item_preprocessing.R) | Prepare survey items |
| 2 | [`02_imputation.R`](R/02_imputation.R) | Handle missing data |
| 3 | [`03_pls_sem.R`](R/03_pls_sem.R) | Estimate PLS-SEM models |
| 4 | [`04_pls_sem_exports.R`](R/04_pls_sem_exports.R) | Export model results |
| 5 | [`05_ipma.R`](R/05_ipma.R) | Conduct IPMA |
| 6 | [`06_hlm.R`](R/06_hlm.R) | Estimate multilevel models |

SQL preprocessing is contained in:

- [`Employee_cleaning_01.sql`](SQL/Employee_cleaning_01.sql)
- [`Employee_cleaning_02.sql`](SQL/Employee_cleaning_02.sql)

## People Analytics Implications

The findings point to several areas for organizational investigation:

- Alignment: Are employees clear about organizational and team priorities?
- Rewards: Do employees perceive recognition and rewards as fair and meaningful?
- Wellbeing: Where are workload and wellbeing risks concentrated?
- Intrinsic Motivation: Do employees experience meaning, autonomy, and purpose in their work?
- Team context: Do employee experiences vary systematically across teams or managers?

The analysis is intended to help identify **where organizations might look next**, rather than prescribe specific interventions. A strong association between wellbeing and happiness, for example, does not establish that increasing wellbeing will cause happiness to increase. Establishing that relationship would require longitudinal, experimental, or quasi-experimental evidence.

## Limitations
This analysis is observational and therefore identifies associations rather than causal effects. 
Additional limitations include:

- Self-reported survey data
- Potential response and common-method bias
- Limited generalizability beyond the study population
- Cross-sectional data, which limits conclusions about changes over time

## Detailed Report
The complete analysis, including model diagnostics, statistical results, tables, visualizations, and recommendations, is available in the technical [report](Report/Report.Rmd). The reproducible analysis is provided through the R and SQL scripts in the repository.

## Dataset
The dataset used in this project is publicly available through Kaggle:

**Employee Stress & Experience**  
[https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data](https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data)

### License & Attribution  
This dataset is released under the **EU Open Data Portal (EU ODP) Legal Notice**, which permits reuse, modification, and redistribution with attribution.

> This project uses publicly available, de‑identified data released under the EU ODP Legal Notice. The dataset is sourced from Kaggle and included solely for educational and portfolio purposes.

Please refer to the original dataset license before reusing the data.

