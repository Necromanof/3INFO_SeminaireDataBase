CREATE VIEW eff_working.V_Technician_Interventions AS
SELECT
    i.intervention_type,
    i.scheduled_date,
    i.status::TEXT,
    c.company_name,
    c.contact_name,
    c.phone,
    s.address,
    s.city,
    s.access_codes
FROM eff_working.F_Intervention i
         JOIN eff_customer.LU_Customer c ON i.client_id = c.client_id
         JOIN eff_customer.LU_Site_Address s ON i.site_id = s.site_id;

-- Monthly Interventions KPI
CREATE VIEW eff_working.V_Stats_Monthly_Interventions AS
SELECT
    TO_CHAR(created_at, 'YYYY-MM') AS month_year,
    COUNT(*) AS total_interventions
FROM eff_working.F_Intervention
GROUP BY month_year
ORDER BY month_year;

-- Weekly Interventions KPI
CREATE VIEW eff_working.V_Stats_Weekly_Interventions AS
SELECT
    TO_CHAR(created_at, 'IYYY-IW') AS week_year,
    COUNT(*) AS total_interventions
FROM eff_working.F_Intervention
GROUP BY week_year
ORDER BY week_year;

-- Weekly Interventions per Technician
CREATE VIEW eff_working.V_Stats_Weekly_Per_Tech AS
SELECT
    p.user_id AS technician_id,
    p.name,
    p.surname,
    TO_CHAR(i.created_at, 'IYYY-IW') AS week_year,
    COUNT(*) AS total_interventions
FROM eff_working.F_Intervention i
         JOIN eff_dataintern.LU_Personnel p ON i.technician_id = p.user_id
GROUP BY p.user_id, p.name, p.surname, week_year
ORDER BY week_year, p.user_id;

-- Average Score per Technician
CREATE VIEW eff_working.V_Stats_Avg_Score_Per_Tech AS
SELECT
    p.user_id AS technician_id,
    p.name,
    p.surname,
    AVG(n.score)::FLOAT AS average_score,
    COUNT(n.rating_id) AS number_of_ratings
FROM eff_customer.F_Notation n
         LEFT JOIN eff_working.F_Intervention i ON n.intervention_id = i.intervention_id
         LEFT JOIN eff_dataintern.LU_Personnel p ON i.technician_id = p.user_id
GROUP BY p.user_id, p.name, p.surname;

-- Global Quality KPI
CREATE VIEW eff_working.V_Stats_Global_Score AS
SELECT
    AVG(score)::FLOAT AS global_average_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score,
    COUNT(rating_id) AS total_ratings
FROM eff_customer.F_Notation;
