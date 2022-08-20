import gleam/io
import examples/toml.{
  Node, Table, VArray, VBoolean, VDatetime, VInteger, toml_doc_parser,
}
import parser_gleam/string as s
import gleam/json.{Json}
import gleam/list
import gleam/bool
import gleam/int

fn parse_toml(it: String) {
  try r =
    toml_doc_parser()
    |> s.run(it)
  Ok(r.value)
}

fn with_type_info(type_: String, value: String) {
  [
    #(
      "type",
      type_
      |> json.string(),
    ),
    #(
      "value",
      value
      |> json.string(),
    ),
  ]
  |> json.object()
}

fn to_json_obj(tbl: Table) -> Json {
  tbl
  |> list.map(fn(it) {
    let #(key, node) = it
    #(key, node_to_json(node))
  })
  |> json.object()
}

fn node_to_json(node: Node) -> Json {
  case node {
    toml.VTable(it) -> to_json_obj(it)
    toml.VTArray(it) -> json.array(it, to_json_obj)
    toml.VString(it) -> with_type_info("string", it)
    toml.VInteger(it) ->
      with_type_info(
        "integer",
        it
        |> int.to_string(),
      )
    toml.VFloat(it) -> todo
    toml.VBoolean(it) ->
      with_type_info(
        "bool",
        it
        |> json.bool()
        |> json.to_string(),
      )
    toml.VDatetime(it) -> todo
    toml.VArray(it) -> todo
  }
}

fn serialize_toml(toml: Table) -> String {
  to_json_obj(toml)
  |> json.to_string()
}

pub fn toml_to_json(it: String) {
  try ast = parse_toml(it)
  Ok(serialize_toml(ast))
}
