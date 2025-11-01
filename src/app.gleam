import app/router
import app/web.{type Context}
import envoy
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()
  let ctx: Context = web.Context(static_directory: static_directory())
  let assert Ok(secret_key) = envoy.get("SECRET_KEY")
  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp_mist.handler(secret_key)
    |> mist.new
    |> mist.port(3000)
    |> mist.start
  process.sleep_forever()
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/static"
}
