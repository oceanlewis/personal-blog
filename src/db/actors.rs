use actix::prelude::*;
use actix_web::*;

use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;

use db::messages::{CreateBlogPost, ListBlogPosts};
use db::models::{BlogPost, NewBlogPost};
use db::schema::blog_posts::dsl::*;

pub struct DbExecutor(pub Pool<ConnectionManager<PgConnection>>);

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}

impl Handler<CreateBlogPost> for DbExecutor {
    type Result = Result<BlogPost, Error>;

    fn handle(&mut self, msg: CreateBlogPost, _: &mut Self::Context) -> Self::Result {

        let new_blog_post = NewBlogPost {
            title: &msg.title,
            body: &msg.body,
            published: msg.published,
        };

        let conn: &PgConnection = &self.0.get().expect("Connection was fucked");

        let inserted_blog_post = diesel::insert_into(blog_posts)
            .values(&new_blog_post)
            .get_results(conn);

        let mut inserted_blog_post = inserted_blog_post.expect("Error creating new blog post");
        let result = inserted_blog_post.pop();

        Ok(result.expect("Insertion was fucked"))
    }
}

impl Handler<ListBlogPosts> for DbExecutor {
    type Result = Result<Vec<BlogPost>, Error>;

    fn handle(&mut self, _msg: ListBlogPosts, _: &mut Self::Context) -> Self::Result {
        let conn: &PgConnection = &self.0.get().expect("Connection was fucked");

        let results = blog_posts
            .filter(published.eq(true))
            .load::<BlogPost>(conn)
            .expect("Error loading posts");

        Ok(results)
    }
}
