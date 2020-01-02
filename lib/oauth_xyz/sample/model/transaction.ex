defmodule OAuthXYZ.Sample.Model.Transaction do
  use OAuthXYZ.Sample.Model

  @type t :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}

  schema "sample_transactions" do
    # TODO: use EctoEnum
    field :status, :string

    field :display, :string
    field :interact, :string
    field :user, :string
    field :resources, :string
    field :keys, :string

    timestamps()
  end

  @required_fields ~w(id status)a
  @optional_fields ~w(display interact user resources keys inserted_at updated_at)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:id, name: :PRIMARY)
  end
end
