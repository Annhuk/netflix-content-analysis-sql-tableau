-- 01_prepare_data.sql
-- SQLite | Repeatable preparation of the Netflix catalog for analysis and Tableau.
-- Source: netflix_titles (8,807 rows in the supplied dataset).
-- WARNING: This script rebuilds the three derived tables below.

DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS netflix_clean;

-- Standardise blank countries, rating anomalies and the year a title was added.
-- Keep the original release_year and the source comma-separated genre labels.
CREATE TABLE netflix_clean AS
SELECT
    show_id,
    type,
    title,
    COALESCE(NULLIF(TRIM(country), ''), 'Unknown') AS country,
    CASE
        WHEN date_added IS NULL OR TRIM(date_added) = '' THEN NULL
        ELSE CAST(SUBSTR(TRIM(date_added), -4) AS INTEGER)
    END AS year_added,
    release_year,
    CASE
        WHEN rating IS NULL OR TRIM(rating) = '' THEN 'Unknown'
        WHEN rating LIKE '%min%' THEN 'Unknown'
        ELSE TRIM(rating)
    END AS rating,
    duration,
    listed_in
FROM netflix_titles;

-- Each title can have multiple genre labels, so split into separate rows.
CREATE TABLE genres AS
WITH RECURSIVE split (show_id, genre, rest) AS (
    SELECT show_id, '', COALESCE(listed_in, '') || ','
    FROM netflix_clean
    UNION ALL
    SELECT
        show_id,
        TRIM(SUBSTR(rest, 1, INSTR(rest, ',') - 1)),
        SUBSTR(rest, INSTR(rest, ',') + 1)
    FROM split
    WHERE rest <> ''
)
SELECT show_id, genre
FROM split
WHERE genre <> '';

-- Split production-country lists to analyse each country individually.
CREATE TABLE countries AS
WITH RECURSIVE split (show_id, country, rest) AS (
    SELECT show_id, '', COALESCE(country, '') || ','
    FROM netflix_clean
    UNION ALL
    SELECT
        show_id,
        TRIM(SUBSTR(rest, 1, INSTR(rest, ',') - 1)),
        SUBSTR(rest, INSTR(rest, ',') + 1)
    FROM split
    WHERE rest <> ''
)
SELECT show_id, country
FROM split
WHERE country <> '';

-- Sanity checks: 8,807 titles, 19,323 title-genre links, 10,843 country links.
SELECT 'netflix_clean' AS table_name, COUNT(*) AS row_count FROM netflix_clean
UNION ALL
SELECT 'genres', COUNT(*) FROM genres
UNION ALL
SELECT 'countries', COUNT(*) FROM countries;
