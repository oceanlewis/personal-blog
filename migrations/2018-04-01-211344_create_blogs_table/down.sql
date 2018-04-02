-- This file should undo anything in `up.sql`
DROP TRIGGER trigger_set_timestamps ON blog_posts;
DROP FUNCTION set_timestamps;
DROP TABLE blog_posts;
