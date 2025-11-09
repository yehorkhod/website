import gleam/list
import gleam/regexp
import gleam/string
import nakai
import nakai/attr.{href, rel, src}
import nakai/html.{
  type Node, Body, Doctype, Head, Html, Script, a_text, h1_text, header, link,
  main, nav, span_text, title,
}
import simplifile
import wisp

import app/parse.{md_to_html}

pub fn home() {
  [h1_text([], "welcome")]
  |> response
}

pub fn blog() {
  let assert Ok(blogs) = simplifile.read_directory("blog")
  blogs
  |> list.sort(string.compare)
  |> list.reverse
  |> list.map(string.drop_start(_, 3))
  |> list.map(fn(x) { a_text([href("/blog/" <> x)], x) })
  |> nav([], _)
  |> list.wrap
  |> response
}

pub fn blog_id(id) {
  let assert Ok(contents) = simplifile.read("blog/" <> id)
  contents |> md_to_html |> response
}

fn response(contents: List(Node)) {
  Html([], [
    Doctype("html"),
    Head([
      title("Yehor Khodysko - Blog"),
      link([rel("stylesheet"), href("/static/style.css")]),
      // Prism.js
      link([
        rel("stylesheet"),
        href(
          "https://cdn.jsdelivr.net/gh/rose-pine/prism/dist/prism-rose-pine-moon.css",
        ),
      ]),
      Script([src("https://cdn.jsdelivr.net/npm/prismjs@1.29.0/prism.js")], ""),
      Script(
        [
          src(
            "https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-bash.min.js",
          ),
        ],
        "",
      ),
      Script(
        [
          src(
            "https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-nix.min.js",
          ),
        ],
        "",
      ),
      Script([src("https://unpkg.com/prismjs-gleam@1/gleam.js")], ""),
    ]),
    Body([], [
      header([], [
        span_text([], "~/yehorkhod"),
        nav([], [
          a_text([attr.href("/")], "[0] home"),
          a_text([attr.href("/blog")], "[1] blog"),
        ]),
      ]),
      main([], contents),
    ]),
  ])
  |> nakai.to_inline_string
  |> minify
  |> wisp.html_response(200)
}

fn minify(html: String) -> String {
  let assert Ok(re_trailing) = regexp.from_string(">\\s+")
  let assert Ok(re_leading) = regexp.from_string("\\s+<")

  html
  |> regexp.replace(each: re_trailing, with: ">")
  |> regexp.replace(each: re_leading, with: "<")
}
