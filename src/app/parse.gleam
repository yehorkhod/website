import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import nakai/attr.{class}
import nakai/html.{type Node, code_text, h1_text, h2_text, h3_text, p_text, pre}

type State {
  Code(lang: Option(String))
  Paragraph
}

pub fn md_to_html(contents: String) -> List(Node) {
  contents
  |> string.split("\n")
  |> parse("", None, [])
}

fn parse(
  lines: List(String),
  temp: String,
  state: Option(State),
  acc: List(Node),
) -> List(Node) {
  case lines {
    [line, ..rest] -> {
      case line, state {
        // TODO: ---
        // Headers
        "###" <> _, None -> parse(rest, "", None, [h3_text([], line), ..acc])
        "##" <> _, None -> parse(rest, "", None, [h2_text([], line), ..acc])
        "#" <> _, None -> parse(rest, "", None, [h1_text([], line), ..acc])
        // Code
        "```" <> language, None ->
          case language {
            "" -> parse(rest, "", Some(Code(None)), acc)
            lang -> parse(rest, "", Some(Code(Some(lang))), acc)
          }
        "```", Some(Code(language)) ->
          case language {
            Some(lang) ->
              parse(rest, "", None, [
                pre([], [code_text([class("language-" <> lang)], temp)]),
                ..acc
              ])
            None ->
              parse(rest, "", None, [pre([], [code_text([], temp)]), ..acc])
          }
        "", Some(Code(_)) -> parse(rest, temp <> "\n", state, acc)
        _, Some(Code(_)) -> parse(rest, temp <> "\n" <> line, state, acc)
        // Paragraphs
        _, None -> parse(rest, temp <> "\n" <> line, Some(Paragraph), acc)
        "", Some(Paragraph) -> parse(rest, "", None, [p_text([], temp), ..acc])
        _, Some(Paragraph) -> parse(rest, temp <> " " <> line, state, acc)
      }
    }
    [] -> list.reverse(acc)
  }
}
