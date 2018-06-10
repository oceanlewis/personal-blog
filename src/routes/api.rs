use actix::prelude::*;
use actix_web::*;
use futures::future::Future;

use db::actors::DbExecutor;
use db::messages::{CreateBlogPost, ListBlogPosts};

pub struct ApiState {
    pub db: Addr<Syn, DbExecutor>,
}

pub fn create_blog_post(
    data: (State<ApiState>, Json<CreateBlogPost>),
) -> Box<Future<Item = HttpResponse, Error = Error>> {
    let (state, blog) = data;

    state
        .db
        .send(CreateBlogPost {
            title: blog.title.to_owned(),
            body: blog.body.to_owned(),
            published: blog.published,
        })
        .from_err()
        .and_then(|res| match res {
            Ok(blog_post) => Ok(HttpResponse::Ok().json(blog_post)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

pub fn list_blog_posts(
    request: HttpRequest<ApiState>,
) -> Box<Future<Item = HttpResponse, Error = Error>> {
    request
        .state()
        .db
        .send(ListBlogPosts)
        .from_err()
        .and_then(|res| match res {
            Ok(blog_posts) => {
                let json = HttpResponse::Ok().json(blog_posts);
                println!("{:?}", json);
                Ok(json)
            }
            Err(error) => {
                println!("{:?}", error);
                Ok(HttpResponse::InternalServerError().into())
            }
        })
        .responder()
}
