/// This is db executor actor. We are going to run 3 of them in parallel.
use actix::prelude::*;
use actix_web::*;

use diesel;
use diesel::pg::PgConnection;
use diesel::prelude::*;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;

use models;
use schema;

pub struct DbExecutor(pub Pool<ConnectionManager<PgConnection>>);

/// This is only message that this actor can handle, but it is easy to extend number of
/// messages.
#[derive(Debug, Deserialize)]
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

        let conn: &PgConnection = &self.0.get().expect("Connection was fucked");

        let inserted_blog_post = diesel::insert_into(blog_posts)
            .values(&new_blog_post)
            .get_results(conn);

        let mut inserted_blog_post = inserted_blog_post.expect("Error creating new blog post");
        let result = inserted_blog_post.pop();

        Ok(result.expect("Insertion was fucked"))
    }
}
