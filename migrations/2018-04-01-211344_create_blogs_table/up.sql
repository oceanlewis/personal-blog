-- Your SQL goes here
CREATE TABLE blog_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR,
    body TEXT,
    published BOOLEAN DEFAULT 'f',
    created_at timestamp,
    updated_at timestamp
);

CREATE OR REPLACE FUNCTION set_timestamps() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    NEW.created_at = now();
  END IF;

  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_timestamps
  BEFORE INSERT OR UPDATE on blog_posts
  FOR EACH ROW
  EXECUTE PROCEDURE set_timestamps();
