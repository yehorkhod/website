import app/web.{type Context}
import gleam/dynamic/decode.{type Decoder}
import gleam/http.{Get}
import gleam/int
import gleam/list
import nakai
import nakai/attr
import nakai/html
import pog
import wisp.{type Request, type Response}

pub fn respond(req: Request, ctx: Context, endpoint: List(String)) -> Response {
  use req <- web.cors_middleware(req)
  case endpoint {
    ["blog"] -> blog(req, ctx)
    ["blog", id] -> single_blog(req, ctx, id)
    ["products"] -> todo
    ["products", _id] -> todo
    _ -> wisp.not_found()
  }
}

fn blog(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  let query: String = "SELECT id, title FROM posts"
  let decoder: Decoder(#(Int, String)) = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    decode.success(#(id, title))
  }
  let assert Ok(data) =
    pog.query(query)
    |> pog.returning(decoder)
    |> pog.execute(ctx.db)

  data.rows
  |> list.map(fn(row) {
    html.a([attr.href("/blog/" <> int.to_string(row.0))], [html.Text(row.1)])
  })
  |> html.div([attr.id("blog")], _)
  |> nakai.to_inline_string_tree
  |> wisp.html_response(200)
}

fn single_blog(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Get)
  let assert Ok(id) = int.parse(id)
  let query: String = "SELECT title, content FROM posts WHERE id = $1"
  let decoder: Decoder(#(String, String)) = {
    use title <- decode.field(0, decode.string)
    use content <- decode.field(1, decode.string)
    decode.success(#(title, content))
  }
  let assert Ok(data) =
    pog.query(query)
    |> pog.parameter(pog.int(id))
    |> pog.returning(decoder)
    |> pog.execute(ctx.db)

  case data.rows {
    [#(title, content)] -> {
      html.div([], [
        html.h1_text([], title),
        html.UnsafeInlineHtml(content),
      ])
      |> nakai.to_inline_string_tree
      |> wisp.html_response(200)
    }
    _ -> panic
  }
}
