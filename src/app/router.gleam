import app/pages
import app/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)
  case wisp.path_segments(req) {
    [] -> pages.home()
    ["blog"] -> pages.blog()
    ["blog", id] -> pages.blog_id(id)
    _ -> wisp.not_found()
  }
}
