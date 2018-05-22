extern crate actix;
extern crate actix_web;
extern crate env_logger;

#[macro_use]
extern crate diesel;
extern crate r2d2;
extern crate r2d2_diesel;

extern crate chrono;
extern crate futures;

extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;


use actix::prelude::*;
use actix_web::{
    http, middleware, server, App, AsyncResponder, Error, HttpRequest, HttpResponse, Json, State as ActixState
};
use diesel::prelude::*;
use futures::prelude::*;

mod db;
use db::messages::CreateBlogPost;
use db::actors::DbExecutor;

struct State {
    db: Addr<Syn, DbExecutor>,
}

fn index(_request: HttpRequest<State>) -> &'static str {
    "Hello!"
}

fn create_blog_post(data: (ActixState<State>, Json<CreateBlogPost>)) -> Box<Future<Item = HttpResponse, Error = Error>> {

    let (state, blog) = data;

    state.db
        .send(CreateBlogPost{
            title: blog.title.to_owned(),
            body: blog.body.to_owned(),
            published: blog.published
        })
        .from_err()
            .and_then(|res| match res {
                Ok(blog_post) => Ok(HttpResponse::Ok().json(blog_post)),
                Err(_) => Ok(HttpResponse::InternalServerError().into()),
            })
        .responder()
}

fn main() {
    ::std::env::set_var("RUST_LOG", "actix_web=debug");
    env_logger::init();

    let sys = actix::System::new("personal-blog");

    let manager =
        r2d2_diesel::ConnectionManager::<PgConnection>::new("postgres://localhost/personal-blog");

    let pool = r2d2::Pool::new(manager)
        .expect("Failed to create pool.");

    let addr = SyncArbiter::start(3, move || DbExecutor(pool.clone()));

    server::new(move || {
        App::with_state(State{db: addr.clone()})
            .middleware(middleware::Logger::default())
            .resource("/", |r| r.method(http::Method::GET).f(index))
            .resource("/blogs", |r| r.method(http::Method::POST).with(create_blog_post))
    }).bind("127.0.0.1:8080")
        .unwrap()
        .start();

    let _ = sys.run();
}
