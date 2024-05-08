-- This table is *read only* for the most of the function of the application.
-- Used just to store a snapshot of the current repositories state of the user,
-- it's important to update this table frequently once the train data was
-- setted up correctly.
--
-- NOTE: Use the "YYYYMMDD" format for the date types.

CREATE TABLE IF NOT EXISTS mirror (
	name TEXT UNIQUE,
	url TEXT,
	fetch_date TEXT,
	last_push_date TEXT,
	last_opened_issues TEXT,
	stars INTEGER,
	commits INTEGER,
	forks INTEGER,
	open_issues INTEGER,
	watchers INTEGER,
	licence TEXT, -- json: Array<string>
	languages TEXT -- json: Array<string>
);
