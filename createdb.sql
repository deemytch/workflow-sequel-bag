CREATE DATABASE sequelbagz;
\c sequelbagz;
CREATE TABLE sequelbags (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, 
  client_id BIGINT,
  token VARCHAR(256),
  jobstatus VARCHAR(32)
);
ALTER TABLE sequelbags OWNER TO datapultem;
CREATE INDEX IF NOT EXISTS jobstatus_idx ON sequelbags ( jobstatus );
