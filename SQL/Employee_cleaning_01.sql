/*===============================================================
    Employee Cleaning Script
    Author: Joseph R. Vilches, PhD
    Purpose: Create globally unique employee identifiers, merge
             survey metadata, construct tenure and age variables,
             and produce a cleaned employee dataset.
    Notes:   Raw data is not included in the repository.
===============================================================*/


/*===========================
First step would be to create a unique identifier for each employee
as the id numbers are only unique to the company in question.
===========================*/
ALTER TABLE employees
ADD employee_id VARCHAR(50);

UPDATE employees
SET employee_id = CONCAT(companyId, '_', employeeId);


/*===========================
Adding unique employee_id to hiVotes
===========================*/
ALTER TABLE hiVotes
ADD employee_id VARCHAR(50);

UPDATE hiVotes
SET employee_id = CONCAT(companyId, '_', employeeId);


/*===========================
Adding unique employee_id to scoreVotes
===========================*/
ALTER TABLE scoreVotes
ADD employee_id VARCHAR(50);

UPDATE scoreVotes
SET employee_id = CONCAT(companyId, '_', employeeId);



/*===============================================================
    Constructing cleaned employee dataset
===============================================================*/

WITH survey_dates AS (
    /*===========================
    Finding earliest and latest survey date for each employee
    ===========================*/
    SELECT
        employee_id,
        MIN(date) AS earliest_survey_date,
        MAX(date) AS latest_survey_date
    FROM hiVotes
    GROUP BY employee_id
),

employee_base AS (
    /*===========================
    Merging employee table with survey metadata and constructing end_date
    ===========================*/
    SELECT
        e.employee_id,
        e.companyId,
        e.gender,
        e.birthDate,
        e.hiringDate,
        e.deletionDate,
        e.deleted,

        s.earliest_survey_date,
        s.latest_survey_date,

        CASE
            WHEN e.deleted = 1 THEN e.deletionDate
            WHEN s.latest_survey_date IS NOT NULL THEN s.latest_survey_date
            ELSE NULL
        END AS end_date

    FROM employees e
    LEFT JOIN survey_dates s
        ON e.employee_id = s.employee_id
),

employee_dates AS (
    /*===========================
    Creating tenure days, observed tenure, survey adoption, and age variables
    ===========================*/
    SELECT
        *,
        
        /* tenure_days: days between hiring and end_date */
        CASE
            WHEN hiringDate < '1900-01-01'
                 OR hiringDate > DATE('now')
                THEN NULL

            WHEN end_date IS NULL
                THEN NULL

            WHEN julianday(end_date) < julianday(hiringDate)
                THEN NULL

            WHEN julianday(end_date) - julianday(hiringDate) > 36525
                THEN NULL

            ELSE julianday(end_date) - julianday(hiringDate)
        END AS tenure_days,


        /* observed_tenure_days: days between earliest survey and end_date */
        CASE
            WHEN earliest_survey_date IS NULL
                THEN NULL

            WHEN end_date IS NULL
                THEN NULL

            WHEN julianday(end_date) < julianday(earliest_survey_date)
                THEN NULL

            ELSE julianday(end_date) - julianday(earliest_survey_date)
        END AS observed_tenure_days,


        /* survey_adoption_days: days between hiring and earliest survey */
        CASE
            WHEN earliest_survey_date IS NULL
                THEN NULL

            WHEN hiringDate < '1900-01-01'
                 OR hiringDate > DATE('now')
                THEN NULL

            WHEN julianday(earliest_survey_date) < julianday(hiringDate)
                THEN NULL

            ELSE julianday(earliest_survey_date) - julianday(hiringDate)
        END AS survey_adoption_days,


        /* age_days: days between birthDate and end_date */
        CASE
            WHEN birthDate < '1900-01-01'
                 OR birthDate > DATE('now')
                THEN NULL

            WHEN end_date IS NULL
                THEN NULL

            WHEN julianday(end_date) < julianday(birthDate)
                THEN NULL

            WHEN julianday(end_date) - julianday(birthDate) < 5110
                THEN NULL

            WHEN julianday(end_date) - julianday(birthDate) > 36525
                THEN NULL

            ELSE julianday(end_date) - julianday(birthDate)
        END AS age_days

    FROM employee_base
),

employee_final AS (
    /*===========================
    Creating tenure buckets
    ===========================*/
    SELECT
        *,
        CASE
            WHEN tenure_days IS NULL
                THEN NULL

            WHEN tenure_days <= 365.25
                THEN 'New Hire'

            WHEN tenure_days <= 1095.75
                THEN 'Early Tenure'

            WHEN tenure_days <= 1826.25
                THEN 'Established'

            WHEN tenure_days <= 3652.5
                THEN 'Experienced'

            ELSE 'Long Tenure'
        END AS tenure_bucket
    FROM employee_dates
)


/*===============================================================
    Final cleaned employee table
===============================================================*/
CREATE TABLE employees_clean AS
SELECT *
FROM employee_final;
