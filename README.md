# Employee-Experience-Modeling
Modeling employee advocacy and happiness using advanced quantitative methods: MICE, PLS-SEM, IPMA, and HLM. This project demonstrates moving from raw survey response to aggregated constructs, pooled structural results, multilevel models, and actionable insights.

## Overview

This repository contains a complete end‑to‑end People Analytics modeling pipeline for identifying the strongest drivers of employee advocacy (eNPS score) and employee happiness. The workflow integrates SQL data preparation, multiple imputation, higher‑order PLS‑SEM, Importance–Performance Map Analysis, and Hierarchical Linear Modeling.

## Project Goals

- Clean and prepare a real-world employee engagement dataset.
- Investigate relationships between organizational factors and engagement outcomes.
- Apply advanced statistical modeling techniques to evaluate direct and hierarchical effects.
- Produce a clear, reproducible analytical report.

## Methods
### Data Preparation

* Imported and explored the raw Kaggle dataset.  
* Cleaned and transformed the data using SQL.  
* Standardized variables and prepared the dataset for statistical modeling.

### Statistical Analysis

Two outcome variables were modeled throughout the analysis:

- **Employee Advocacy (eNPS-style)**  
- **Employee Happiness**

These outcomes were selected to evaluate the **unique contributions** of each organizational domain to both advocacy and wellbeing.

The cleaned dataset was analyzed in **R** using three complementary approaches:

* **Partial Least Squares Structural Equation Modeling (PLS-SEM)**  
  * Modeled latent constructs and relationships between organizational variables.  
  * Evaluated measurement and structural models.  
  * Estimated path coefficients and model quality metrics for both eNPS and Happiness.

* **Importance–Performance Map Analysis (IPMA)**  
  * Combined construct performance (mean scores) with structural importance (total effects).  
  * Identified high-impact domains where improvements may yield the strongest gains in eNPS and Happiness.  
  * Highlighted differences in what drives advocacy versus happiness.

* **Hierarchical Linear Modeling (HLM)**  
  * Examined multilevel relationships within the engagement data.  
  * Accounted for nested observations where appropriate.  
  * Compared multilevel effects for eNPS and Happiness to provide additional insight beyond the SEM results.

### Reporting

The complete analysis was documented using **R Markdown**, allowing the project to be reproduced from raw data through final results.

## Technologies

* SQL  
* R  
* R Markdown  
* Multiple Imputation (MICE)  
* PLS-SEM  
* Importance–Performance Map Analysis (IPMA)  
* Hierarchical Linear Modeling (HLM)

## Repository Structure

```text
.
├── sql/                  # SQL scripts for data cleaning
├── R/                    # R scripts for analysis
├── report/               # R Markdown report and generated output
├── figures/              # Charts and visualizations
└── README.md
```

## Skills Demonstrated

* Data cleaning and preprocessing  
* SQL querying and transformation  
* Statistical modeling in R  
* Structural Equation Modeling (PLS-SEM)  
* Importance–Performance Map Analysis (IPMA)  
* Hierarchical Linear Modeling  
* Reproducible research using R Markdown  
* End-to-end workflow documentation

## Key Takeaways

This project demonstrates a complete analytics workflow—from raw data extraction and cleaning, through advanced statistical modeling, to a fully reproducible analytical report. It highlights the ability to work across SQL and R while applying graduate-level statistical techniques to answer practical organizational research questions.

## Dataset

The dataset used in this project is publicly available through Kaggle:

**Employee Stress & Experience**  
[https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data](https://www.kaggle.com/datasets/harriken/myhappyforce-survey-employee-stress/data)

### License & Attribution  
This dataset is released under the **EU Open Data Portal (EU ODP) Legal Notice**, which permits reuse, modification, and redistribution with attribution.

> This project uses publicly available, de‑identified data released under the EU ODP Legal Notice. The dataset is sourced from Kaggle and included solely for educational and portfolio purposes.

Please refer to the original dataset license before reusing the data.

## Future Improvements

* Expand the analysis with additional predictive models.  
* Develop an interactive dashboard to explore engagement metrics.  
* Perform model validation using alternative estimation techniques.  
* Automate the data preparation workflow.

