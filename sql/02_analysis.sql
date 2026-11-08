-- 02_analysis.sql
-- SQLite | Exploration, descriptive summaries, window functions and joins.
-- Run 01_prepare_data.sql first if the derived tables are not present.

-- Data-quality checks on the original imported catalog.
SELECT
    SUM(CASE WHEN country IS NULL OR TRIM(country) = '' THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN director IS NULL OR TRIM(director) = '' THEN 1 ELSE 0 END) AS missing_director,
    SUM(CASE WHEN rating IS NULL OR TRIM(rating) = '' THEN 1 ELSE 0 END) AS missing_rating
FROM netflix_titles;

-- Duplicate title names (not necessarily duplicate records).
SELECT title, COUNT(*) AS occurrences
FROM netflix_titles
GROUP BY title
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, title;

-- Content type breakdown.
SELECT
    type,
    COUNT(*) AS titles,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_catalog
FROM netflix_clean
GROUP BY type
ORDER BY titles DESC;

-- Content rating distribution.
SELECT rating, COUNT(*) AS titles
FROM netflix_clean
GROUP BY rating
ORDER BY titles DESC;

-- Year added to Netflix: counts, shares and running total.
WITH yearly AS (
    SELECT year_added, COUNT(*) AS titles_added
    FROM netflix_clean
    WHERE year_added IS NOT NULL
    GROUP BY year_added
)
SELECT
    year_added,
    titles_added,
    ROUND(100.0 * titles_added / SUM(titles_added) OVER (), 1) AS pct_of_dated_titles,
    SUM(titles_added) OVER (ORDER BY year_added) AS cumulative_titles
FROM yearly
ORDER BY year_added;

-- Original release year by content type (2000 onwards).
SELECT release_year, type, COUNT(*) AS titles
FROM netflix_clean
WHERE release_year >= 2000
GROUP BY release_year, type
ORDER BY release_year, type;

-- Top genre labels: titles may be counted in several categories.
SELECT genre, COUNT(*) AS titles
FROM genres
GROUP BY genre
ORDER BY titles DESC
LIMIT 10;

-- Top production countries: co-produced titles count for multiple countries.
SELECT country, COUNT(*) AS titles
FROM countries
WHERE country <> 'Unknown'
GROUP BY country
ORDER BY titles DESC
LIMIT 10;

-- Genre trends from release year 2010 onwards.
SELECT n.release_year, g.genre, COUNT(*) AS titles
FROM netflix_clean AS n
JOIN genres AS g ON n.show_id = g.show_id
WHERE n.release_year >= 2010
GROUP BY n.release_year, g.genre
ORDER BY n.release_year, titles DESC;

-- Genre preferences in selected production countries.
SELECT c.country, g.genre, COUNT(*) AS titles
FROM countries AS c
JOIN genres AS g ON c.show_id = g.show_id
WHERE c.country IN (
    'United States', 'India', 'United Kingdom', 'Japan', 'South Korea'
)
GROUP BY c.country, g.genre
ORDER BY c.country, titles DESC;
