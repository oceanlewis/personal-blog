use actix_web::*;
use std::io;

const INDEX_HTML: &str = "elm/build/index.html";
const SERVICE_WORKER_JS: &str = "elm/build/service-worker.js";

pub fn index(_request: HttpRequest) -> io::Result<fs::NamedFile> {
    Ok(fs::NamedFile::open(INDEX_HTML)?)
}

pub fn service_worker(_request: HttpRequest) -> io::Result<fs::NamedFile> {
    Ok(fs::NamedFile::open(SERVICE_WORKER_JS)?)
}
