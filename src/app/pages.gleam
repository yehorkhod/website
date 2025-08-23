import nakai
import nakai/attr
import nakai/html.{type Node}
import wisp.{type Response}

pub fn home() -> Response {
  let main: Node =
    html.main([attr.id("home")], [
      html.h1_text([], "Sweet home"),
    ])
  let header: Node = header("/")
  template(main, header)
}

pub fn blog() -> Response {
  let main: Node =
    html.main([], [
      html.div(
        [
          attr.id("loadding"),
          attr.Attr("hx-get", "/api/blog"),
          attr.Attr("hx-trigger", "load"),
          attr.Attr("hx-target", "this"),
          attr.Attr("hx-swap", "outerHTML"),
        ],
        [],
      ),
    ])
  let header: Node = header("/blog")
  template(main, header)
}

pub fn single_post(id: String) -> Response {
  let main: Node =
    html.main([], [
      html.div(
        [
          attr.id("loadding"),
          attr.Attr("hx-get", "/api/blog/" <> id),
          attr.Attr("hx-trigger", "load"),
          attr.Attr("hx-target", "this"),
          attr.Attr("hx-swap", "outerHTML"),
        ],
        [],
      ),
    ])
  let header: Node = header("")
  template(main, header)
}

fn template(main: Node, header: Node) -> Response {
  html.Html([], [
    html.Doctype("html"),
    html.Head([
      html.title("Yehor Khodysko - Blog - Shop"),
      html.link([attr.rel("stylesheet"), attr.href("/static/style.css")]),
      html.Script(
        [
          attr.src(
            "https://cdn.jsdelivr.net/npm/htmx.org@2.0.6/dist/htmx.min.js",
          ),
          attr.integrity(
            "sha384-Akqfrbj/HpNVo8k11SXBb6TlBWmXXlYQrCSqEWmyKJe+hDm3Z/B2WVG4smwBkRVm",
          ),
          attr.crossorigin("anonymous"),
        ],
        "",
      ),
    ]),
    html.Body([], [
      header,
      main,
    ]),
  ])
  |> nakai.to_inline_string_tree
  |> wisp.html_response(200)
}

fn header(page: String) -> Node {
  let nav: Node =
    html.nav([], case page {
      "/" -> [
        html.a_text([attr.class("active"), attr.href("/")], "[0] ~"),
        html.a_text([attr.href("/blog")], "[1] ~/blog"),
        html.a_text([attr.href("/shop")], "[2] ~/shop"),
      ]
      "/blog" -> [
        html.a_text([attr.href("/")], "[0] ~"),
        html.a_text([attr.class("active"), attr.href("/blog")], "[1] ~/blog"),
        html.a_text([attr.href("/shop")], "[2] ~/shop"),
      ]
      "/shop" -> [
        html.a_text([attr.href("/")], "[0] ~"),
        html.a_text([attr.href("/blog")], "[1] ~/blog"),
        html.a_text([attr.class("active"), attr.href("/shop")], "[2] ~/shop"),
      ]
      _ -> [
        html.a_text([attr.href("/")], "[0] ~"),
        html.a_text([attr.href("/blog")], "[1] ~/blog"),
        html.a_text([attr.href("/shop")], "[2] ~/shop"),
      ]
    })
  html.header([attr.id("status-bar")], [
    html.div([attr.id("status-left")], [nav]),
    html.div([attr.id("status-right")], [
      html.span([attr.id("status-indicator")], []),
      html.Text("online"),
    ]),
  ])
}
