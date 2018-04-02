-- Your SQL goes here
CREATE TABLE blog_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    body TEXT NOT NULL,
    published BOOLEAN NOT NULL DEFAULT 'f',
    created_at timestamp NOT NULL,
    updated_at timestamp NOT NULL
);

CREATE OR REPLACE FUNCTION set_timestamps() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    NEW.created_at = now();
  END IF;

  NEW.updated_at = now();
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_timestamps
  BEFORE INSERT OR UPDATE on blog_posts
  FOR EACH ROW
  EXECUTE PROCEDURE set_timestamps();
