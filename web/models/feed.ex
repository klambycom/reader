defmodule Reader.Feed do
  use Reader.Web, :model

  alias Reader.Xml
  alias Reader.Feed.Parser.RSS2

  @http_client Application.get_env(:reader, :http_client)

  schema "feeds" do
    field :name, :string
    field :homepage, :string
    field :description, :string
    field :rss_feed, :string
    field :subscriber_count, :integer, virtual: true

    many_to_many :users, Reader.User, join_through: Reader.Subscription

    timestamps
  end

  @required_fields ~w(name homepage description rss_feed)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  Download and parse feed from url.
  """
  def download(url) do
    {:ok, response} = @http_client.get(url)

    feed =
      response.body
      |> Xml.from_string
      |> RSS2.parse

    %{feed | rss_feed: url}
  end

  @doc """
  Get summary of the feed, with number of subscribers.
  """
  def summary do
    from f in __MODULE__,
      left_join: u in assoc(f, :users),
      select: %{f | subscriber_count: count(u.id)},
      group_by: f.id
  end
end
