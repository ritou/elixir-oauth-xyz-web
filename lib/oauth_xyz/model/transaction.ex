defmodule OAuthXYZ.Model.Transaction do
  @moduledoc """
  Transaction Handling Module.
  """

  alias OAuthXYZ.Model.{Handle, TransactionRequest}

  @type t :: %__MODULE__{}

  @transaction_status_list [:new, :issued, :authorized, :waiting, :denied]

  defstruct [
    #! :string
    :handle,

    #! :atom
    :status,

    # request and response data
    :display,
    :interact,
    :user,
    :resources,
    :keys,

    #! :integer
    :wait,
    #! %OAuthXYZ.Model.Handle{}
    :access_token
  ]

  @doc """
  init from handle and request
  """
  @spec new(data :: map) :: t
  def new(%{handle: handle = %Handle{}, request: request = %TransactionRequest{}}) do
    %__MODULE__{
      handle: handle,
      status: :new,
      display: request.display,
      interact: request.interact,
      user: request.user,
      resources: request.resources,
      keys: request.keys,
      access_token: nil
    }
  end

  @spec update_status(t, atom) :: t
  def update_status(transaction = %__MODULE__{}, status)
      when status in @transaction_status_list,
      do: %{transaction | status: status}

  @spec rotate_handle(t, Handle.t()) :: t
  def rotate_handle(transaction = %__MODULE__{}, handle = %Handle{}),
    do: %{transaction | handle: handle}
end
