locals_without_parens = [
  # Ecto.Migration
  add: 3,
  add: 2,
  create: 1,
  index: 2,
  drop_if_exists: 1,

  # Params
  defparams: 1,

  # ecto_enum
  defenum: 2
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,priv}/**/*.{ex,exs}"],
  import_deps: [:plug, :ecto, :phoenix],
  locals_without_parens: locals_without_parens
]
