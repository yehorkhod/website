import app/api
import app/pages
import app/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)
  case wisp.path_segments(req) {
    [] -> pages.home()
    ["blog"] -> pages.blog()
    ["blog", id] -> pages.single_post(id)
    ["shop"] -> todo
    ["shop", _id] -> todo
    ["api", ..rest] -> api.respond(req, ctx, rest)
    _ -> wisp.not_found()
  }
}
