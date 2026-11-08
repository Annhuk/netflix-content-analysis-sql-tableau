-- Optional: initialise an EMPTY SQLite database before importing the CSV.
-- After running this file, import data/raw/netflix_titles.csv with header skipped.
CREATE TABLE IF NOT EXISTS netflix_titles (
    show_id TEXT,
    type TEXT,
    title TEXT,
    director TEXT,
    "cast" TEXT,
    country TEXT,
    date_added TEXT,
    release_year INTEGER,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT
);
