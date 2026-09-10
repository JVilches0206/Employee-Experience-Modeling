# People Analytics: Employee Experience Analytics

## Overview
Employee experience surveys contain valuable information about how employees perceive their workplace. This project uses psychometric and statistical modeling to identify which workplace experiences are most strongly associated with employee advocacy (eNPS) and employee happiness.

The analysis combines SQL, R, PLS-SEM, IPMA, and Multilevel Modeling to move from employee survey data to actionable People Analytics insights.

## Key Findings
### Employee Advocacy (eNPS)
Alignment, Rewards, and Wellbeing consistently emerged as the strongest positive correlates of employee advocacy across both PLS-SEM and multilevel modeling. The eNPS model explained substantial variance

- Marginal $R^2$ = 0.62
- Conditional $R^2$ = 0.64

### Employee Happiness
Wellbeing, Intrinsic Motivation, and Alignment were the strongest correlates of employee happiness:

- Marginal $R^2$ = 0.44
- Conditional $R^2$ = 0.48

### Where should organizations focus?
Importance-Performance Map Analysis identified:

|Outcome|	Highest-priority areas |
|--------|-----------------------|
| eNPS |	Alignment, Rewards |
| Happiness |	Wellbeing, Intrinsic Motivation, Alignment |

These dimensions combine relatively strong relationships with the outcomes and meaningful opportunities for improvement. 

### Team context matters
Because employees are nested within team, the analysis used multilevel modeling to account for this natural clustering. This is important because Marginal $R^2$ represents the variance explained by the employee-level predictors, while conditional $R^2$ represents the variance explained by both the employee-level predictors and team-level effects. The difference between these measures indicates that team context provides additional explanatory information, particularly for employee happiness.

#### An important model finding
Feedback showed a negative coefficient in the models. However, this pattern is consistent with statistical suppression, not evidence that feedback is harmful. Its unique coefficient changes direction after accounting for overlapping employee experience dimensions. This finding highlights the importance of interpreting individual predictors within the context of the broader model.

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
- **MICE**: Multiple Imputation by Chained Equations for handling missing data
- **PLS-SEM**: Partial Least Squares Structural Equation Modeling to estimate relationships among latent constructs and outcomes
- **IPMA**: Importance–Performance Map Analysis to identify high-importance areas with opportunities for improvement
- **MLM**: Multilevel Modeling to account for employee clustering within teams
- **R/R Markdown**: Statistical analysis and reproducible reporting

## Why Psychometrics Matter
Employee experience variables such as wellbeing, alignment, intrinsic motivation, and recognition are latent constructs. They are measured through survey items rather than direct observation. A psychometric perspective provides a framework for evaluating the quality of these measures while modeling their relationships with workforce outcomes.

## People Analytics Implications
The results suggest several areas for further organizational investigation:

- Alignment: Are employees clear about organizational and team priorities?
- Rewards: Do employees perceive recognition and rewards as fair?
- Wellbeing: Where are workload and wellbeing risks concentrated?
- Intrinsic Motivation: Do employees experience meaning, autonomy, and purpose in their work?
- Team context: Do employee experiences vary systematically across teams or managers?

These findings can help organizations prioritize areas for further investigation and intervention, while recognizing that the observational design does not establish causal effects.

## Limitations
This analysis is observational and therefore identifies associations rather than causal effects. 
Additional limitations include:

- Self-reported survey data
- Potential response and common-method bias
- Limited generalizability beyond the study population
- Cross-sectional data, which limits conclusions about changes over time

## Detailed Report
For the complete statistical analysis, model results, tables, visualizations, and recommendations, see the full analysis report.

## Dataset
The dataset used in this project is publicly available through Kaggle:

**Employee Stress & Experience**  
[https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data](https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data)

### License & Attribution  
This dataset is released under the **EU Open Data Portal (EU ODP) Legal Notice**, which permits reuse, modification, and redistribution with attribution.

> This project uses publicly available, de‑identified data released under the EU ODP Legal Notice. The dataset is sourced from Kaggle and included solely for educational and portfolio purposes.

Please refer to the original dataset license before reusing the data.

