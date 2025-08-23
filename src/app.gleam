import app/router
import app/web.{type Context}
import envoy
import gleam/erlang/process.{type Name}
import gleam/option.{Some}
import gleam/otp/static_supervisor as supervisor
import gleam/otp/supervision.{type ChildSpecification}
import mist
import pog.{type Connection, type Message}
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()
  let ctx: Context =
    web.Context(db: setup_db(), static_directory: static_directory())
  let assert Ok(secret_key) = envoy.get("SECRET_KEY")
  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp_mist.handler(secret_key)
    |> mist.new
    |> mist.port(3000)
    |> mist.start
  process.sleep_forever()
}

fn setup_db() -> Connection {
  let assert Ok(host) = envoy.get("PGHOST")
  let assert Ok(database) = envoy.get("PGDATABASE")
  let assert Ok(user) = envoy.get("PGUSER")
  let assert Ok(password) = envoy.get("PGPASSWORD")

  let db_pool_name: Name(Message) = process.new_name("db_pool")
  let db_pool_child: ChildSpecification(Connection) =
    pog.default_config(db_pool_name)
    |> pog.host(host)
    |> pog.database(database)
    |> pog.user(user)
    |> pog.password(Some(password))
    |> pog.ssl(pog.SslVerified)
    |> pog.pool_size(15)
    |> pog.supervised
  let assert Ok(_) =
    supervisor.new(supervisor.RestForOne)
    |> supervisor.add(db_pool_child)
    |> supervisor.start
  pog.named_connection(db_pool_name)
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/static"
}
