/// This is db executor actor. We are going to run 3 of them in parallel.
use actix::prelude::*;
use actix_web::*;

use diesel;
use diesel::prelude::*;
use diesel::pg::PgConnection;
use r2d2_diesel::ConnectionManager;
use r2d2::Pool;

use models;
use schema;

pub struct DbExecutor(pub Pool<ConnectionManager<PgConnection>>);

/// This is only message that this actor can handle, but it is easy to extend number of
/// messages.
pub struct CreateBlogPost {
    pub title: String,
    pub body: String,
    pub published: bool,
}

impl Message for CreateBlogPost {
    type Result = Result<models::BlogPost, Error>;
}

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}

impl Handler<CreateBlogPost> for DbExecutor {
    type Result = Result<models::BlogPost, Error>;

    fn handle(&mut self, msg: CreateBlogPost, _: &mut Self::Context) -> Self::Result {
        use self::schema::blog_posts::dsl::*;

        let new_blog_post = models::NewBlogPost {
            title: &msg.title,
            body: &msg.body,
            published: msg.published,
        };

        let conn: &PgConnection = &self.0.get().unwrap();

        let mut inserted_blog_post = diesel::insert_into(blog_posts)
            .values(&new_blog_post)
            .get_results(conn).expect("Error creating new blog post");

        Ok(inserted_blog_post.pop().unwrap())
    }
}
