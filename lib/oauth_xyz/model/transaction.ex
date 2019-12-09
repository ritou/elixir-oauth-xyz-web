defmodule OAuthXYZ.Model.Transaction do
  @moduledoc """
  Transaction Handling Module.
  """

  alias OAuthXYZ.Model.{TransactionRequest}

  @type t :: %__MODULE__{}

  @transaction_status_list [:new, :issued, :authorized, :waiting, :denied]

  # TODO: additional params
  # * handles
  # * access_token 
  defstruct [
    #! :string
    :handle,
    #! %OAuthXYZ.Model.TransactionRequest{}
    :request,
    #! %OAuthXYZ.Enum.TransactionStatus
    :status
  ]

  @doc """
  Parse string or map and return structure
  """
  @spec new(data :: map) :: t
  def new(%{request: request = %TransactionRequest{}}) do
    handle = Ulid.generate()

    %__MODULE__{
      handle: handle,
      request: request,
      status: :new
    }
  end
end
