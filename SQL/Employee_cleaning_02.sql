/*===============================================================
    Employee Engagement Modeling Script
    Author: Joseph R. Vilches, PhD
    Purpose: Create cleaned score tables, factor scores, indicator
             scores, engagement profiles, and final modeling dataset.
    Notes:   Assumes SQLite syntax. Raw data not included.
===============================================================*/


/*===============================================================
    Summary of happiness responses
===============================================================*/
CREATE TABLE hiVotes_summary AS
SELECT 
    DISTINCT employee_id,
    companyId,
    departmentId,
    AVG(hiVote) AS avg_happiness,
    MIN(hiVote) AS min_happiness,
    MAX(hiVote) AS max_happiness,
    COUNT(*) AS happiness_responses,
    MIN(date) AS first_response,
    MAX(date) AS latest_response
FROM hiVotes
GROUP BY employee_id;


/*===============================================================
    Investigating the engagement survey structure
===============================================================*/
--how many factors exist and how many questions are there. 
CREATE TABLE factor_question_summary AS
SELECT
    factorId,
    COUNT(*) AS responses,
    COUNT(DISTINCT questionId) AS questions
FROM scoreVotes
GROUP BY factorId
ORDER BY responses DESC;


/*===============================================================
    Connecting scores to metadata (long format)
===============================================================*/
CREATE TABLE scoreVotes_clean_long AS
SELECT
    s.employee_id,
    s.companyId,
    s.departmentId,
    s.date,
    s.scoreVote,
    s.scoreId,
    m.name AS survey_category,
    s.factorId,
    m.factor,
    s.questionId,
    m.question
FROM scoreVotes s
LEFT JOIN scoreMetadata m
    ON s.scoreId = m.scoreId
    AND s.factorId = m.factorId
    AND s.questionId = m.questionId;


/*===============================================================
    Creating employee factor scores
===============================================================*/
CREATE TABLE employee_factor_scores AS
SELECT
    employee_id,
    factorId,
    factor,
    AVG(scoreVote) AS factor_score,
    COUNT(*) AS item_responses,
    COUNT(DISTINCT questionId) AS questions_per_factor,
    MIN(date) AS first_response_date,
    MAX(date) AS last_response_date
FROM scoreVotes_clean_long
GROUP BY
    employee_id,
    factorId,
    factor;


/*===============================================================
    Creating employee indicator scores
===============================================================*/
CREATE TABLE employee_indicator_scores AS
SELECT
    e.employee_id,
    m.name AS survey_category,
    AVG(e.factor_score) AS indicator_score,
    COUNT(DISTINCT e.factorId) AS factors_answered
FROM employee_factor_scores e
LEFT JOIN (
    SELECT DISTINCT factorId, name
    FROM scoreMetadata
) m
    ON e.factorId = m.factorId
GROUP BY
    e.employee_id,
    m.name;


/*===============================================================
    Creating an employee engagement profile
===============================================================*/
CREATE TABLE employee_engagement_profile AS 
SELECT
    employee_id,
    AVG(CASE WHEN survey_category = 'Relationships'
        THEN indicator_score END) AS relationships_score,

    AVG(CASE WHEN survey_category = 'Intrinsic Motivation'
        THEN indicator_score END) AS intrinsic_motivation_score,

    AVG(CASE WHEN survey_category = 'Feedback'
        THEN indicator_score END) AS feedback_score,

    AVG(CASE WHEN survey_category = 'Wellbeing'
        THEN indicator_score END) AS wellbeing_score,

    AVG(CASE WHEN survey_category = 'Reward & Recognition'
        THEN indicator_score END) AS recognition_score,

    AVG(CASE WHEN survey_category = 'Alignment'
        THEN indicator_score END) AS alignment_score,

    AVG(CASE WHEN survey_category LIKE '%eNPS%'
        THEN indicator_score END) AS enps_score
FROM employee_indicator_scores
GROUP BY employee_id;


/*===============================================================
    Creating employee item scores
===============================================================*/
CREATE TABLE employee_item_scores AS
SELECT
    employee_id,
    questionId,
    question,
    factorId,
    factor,
    AVG(scoreVote) AS item_score,
    COUNT(*) AS responses,
    MIN(date) AS first_response_date,
    MAX(date) AS last_response_date
FROM scoreVotes_clean_long
GROUP BY
    employee_id,
    questionId,
    question,
    factorId,
    factor;


/*===============================================================
    Item coverage summary
===============================================================*/
CREATE TABLE item_coverage_summary AS   
SELECT
    questionId,
    question,
    factor,
    COUNT(DISTINCT employee_id) AS employees,
    COUNT(*) AS responses,
    AVG(scoreVote) AS avg_score
FROM scoreVotes_clean_long
GROUP BY
    questionId,
    question,
    factor;


/*===============================================================
    Employee eNPS summary
===============================================================*/
CREATE TABLE employee_enps_summary AS
SELECT
    employee_id,
    AVG(factor_score) AS enps_score
FROM employee_factor_scores
WHERE factor = 'eNPS'
GROUP BY employee_id;


/*===============================================================
    Employee factor model (18 factors → 6 domains)
===============================================================*/
CREATE TABLE employee_factor_model AS
SELECT
    e.employee_id,
    e.companyId,
    e.gender,
    e.age_days,
    e.tenure_days,
    e.deleted,
    h.avg_happiness,
    n.enps_score,

    MAX(CASE WHEN f.factor = 'Managers' THEN f.factor_score END) AS managers_score,
    MAX(CASE WHEN f.factor = 'Peers' THEN f.factor_score END) AS peers_score,
    MAX(CASE WHEN f.factor = 'Confidence' THEN f.factor_score END) AS confidence_score,
    MAX(CASE WHEN f.factor = 'Freedom of Opinion' THEN f.factor_score END) AS freedom_opinion_score,
    MAX(CASE WHEN f.factor = 'Quality & Frequency' THEN f.factor_score END) AS quality_frequency_score,
    MAX(CASE WHEN f.factor = 'Active Listening' THEN f.factor_score END) AS active_listening_score,
    MAX(CASE WHEN f.factor = 'Autonomy' THEN f.factor_score END) AS autonomy_score,
    MAX(CASE WHEN f.factor = 'Mastery' THEN f.factor_score END) AS mastery_score,
    MAX(CASE WHEN f.factor = 'Purpose' THEN f.factor_score END) AS purpose_score,
    MAX(CASE WHEN f.factor = 'Recognition' THEN f.factor_score END) AS recognition_score,
    MAX(CASE WHEN f.factor = 'Benefits' THEN f.factor_score END) AS benefits_score,
    MAX(CASE WHEN f.factor = 'Compensation' THEN f.factor_score END) AS compensation_score,
    MAX(CASE WHEN f.factor = 'Goals & Role' THEN f.factor_score END) AS goals_role_score,
    MAX(CASE WHEN f.factor = 'Trust & Vision' THEN f.factor_score END) AS trust_vision_score,
    MAX(CASE WHEN f.factor = 'Values & Ethics' THEN f.factor_score END) AS values_ethics_score,
    MAX(CASE WHEN f.factor = 'Diversity & Equality' THEN f.factor_score END) AS diversity_equality_score,
    MAX(CASE WHEN f.factor = 'Environment' THEN f.factor_score END) AS environment_score,
    MAX(CASE WHEN f.factor = 'Stress & Health' THEN f.factor_score END) AS stress_health_score

FROM employees_clean e
LEFT JOIN hiVotes_summary h
    ON e.employee_id = h.employee_id
LEFT JOIN employee_enps_summary n
    ON e.employee_id = n.employee_id
LEFT JOIN employee_factor_scores f
    ON e.employee_id = f.employee_id
GROUP BY
    e.employee_id,
    e.companyId,
    e.gender,
    e.age_days,
    e.tenure_days,
    e.deleted,
    h.avg_happiness,
    n.enps_score;


/*===============================================================
    Adding company metadata
===============================================================*/
CREATE TABLE employee_factor_model_v2 AS    
SELECT
    efm.*,
    c.Continent,
    c.City,
    c.industry
FROM employee_factor_model efm
LEFT JOIN companyMetadata_cleaned c
    ON efm.companyId = c.companyId;
