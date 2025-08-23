import cors_builder
import gleam/http
import pog.{type Connection}
import wisp.{type Request, type Response}

pub type Context {
  Context(db: Connection, static_directory: String)
}

pub fn middleware(
  req: Request,
  ctx: Context,
  request_handler: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  request_handler(req)
}

pub fn cors_middleware(
  req: Request,
  handler: fn(Request) -> Response,
) -> Response {
  cors_builder.new()
  |> cors_builder.allow_all_origins()
  |> cors_builder.allow_method(http.Get)
  |> cors_builder.allow_method(http.Post)
  |> cors_builder.allow_method(http.Options)
  |> cors_builder.allow_header("Content-Type")
  |> cors_builder.allow_header("HX-Request")
  |> cors_builder.allow_header("HX-Target")
  |> cors_builder.allow_header("HX-Trigger")
  |> cors_builder.allow_header("HX-Trigger-Name")
  |> cors_builder.wisp_middleware(req, _, handler)
}
