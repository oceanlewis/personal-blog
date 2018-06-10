extern crate actix;
extern crate actix_web;
extern crate env_logger;
extern crate futures;

#[macro_use]
extern crate diesel;
extern crate chrono;
extern crate r2d2;
extern crate r2d2_diesel;

extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;

use actix::prelude::*;
use actix_web::middleware::{cors::Cors, Logger};
use actix_web::{fs::StaticFiles, http, server, App};

use diesel::prelude::*;

mod db;
use db::actors::DbExecutor;

mod routes;
use routes::{api::{create_blog_post, list_blog_posts, ApiState},
             app};

const BLOG_SYSTEM_NAME: &str = "personal-blog";
const SERVER_ADDRESS: &str = "127.0.0.1:8080";
const POSTGRES_ADDRESS: &str = "postgres://127.0.0.1/personal-blog";
const ELM_BUILD_STATIC_PATH: &str = "elm/build/static/";

fn main() {
    ::std::env::set_var("RUST_LOG", "actix_web=debug");
    ::std::env::set_var("RUST_BACKTRACE", "1");
    env_logger::init();

    let sys = actix::System::new(BLOG_SYSTEM_NAME);

    let manager = r2d2_diesel::ConnectionManager::<PgConnection>::new(POSTGRES_ADDRESS);

    let pool = r2d2::Pool::new(manager).expect("Failed to create pool.");

    let addr = SyncArbiter::start(3, move || DbExecutor(pool.clone()));

    server::new(move || {
        vec![
            App::with_state(ApiState { db: addr.clone() })
                .prefix("/api")
                .configure(|app| {
                    Cors::for_app(app)
                        .resource("/blogs", |r| {
                            r.put().with(create_blog_post);
                            r.get().with(list_blog_posts);
                        })
                        .register()
                })
                .boxed(),
            App::new()
                .prefix("/")
                .middleware(Logger::default())
                .resource("/", |r| r.method(http::Method::GET).f(app::index))
                .resource("/service-worker.js", |r| {
                    r.method(http::Method::GET).f(app::service_worker)
                })
                .handler("/static", StaticFiles::new(ELM_BUILD_STATIC_PATH))
                .boxed(),
        ]
    }).bind(SERVER_ADDRESS)
        .unwrap()
        .start();

    let _ = sys.run();
}
