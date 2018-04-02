table! {
    blog_posts (id) {
        id -> Int4,
        title -> Varchar,
        body -> Text,
        published -> Bool,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}
