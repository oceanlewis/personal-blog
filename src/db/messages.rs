use actix::prelude::*;
use actix_web::*;

use db::models::BlogPost;

#[derive(Debug, Deserialize)]
pub struct CreateBlogPost {
    pub title: String,
    pub body: String,
    pub published: bool,
}

impl Message for CreateBlogPost {
    type Result = Result<BlogPost, Error>;
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ListBlogPosts;

impl Message for ListBlogPosts {
    type Result = Result<Vec<BlogPost>, Error>;
}
