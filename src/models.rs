use chrono::prelude::*;

#[derive(Queryable)]
pub struct BlogPost {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime
}

use super::schema::blog_posts;

#[derive(Insertable)]
#[table_name="blog_posts"]
pub struct NewBlogPost<'a> {
    pub title: &'a str,
    pub body: &'a str,
    pub published: bool,
}
