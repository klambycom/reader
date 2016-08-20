defmodule Reader.FeedView do
  use Reader.Web, :view

  alias Reader.{UserView, ItemView}

  def render("index.json", %{feeds: feeds, conn: conn}),
    do: %{
      data: render_many(feeds, __MODULE__, "feed.json", conn: conn),
      links: %{
        self: feed_url(conn, :index)
      },
      meta: %{
        count: length(feeds)
      }
    }

  def render("show.json", %{feed: feed, users: users, conn: conn}),
    do: %{
      data: render_one(feed, __MODULE__, "feed.json", users: users, conn: conn),
      links: %{
        self: feed_url(conn, :show, feed)
      }
    }

  def render("feed.json", %{feed: feed, conn: conn} = data),
    do: %{
          title: feed.title,
          subtitle: feed.subtitle,
          summary: feed.summary,
          description: feed.description,
          author: feed.author,
          link: feed.link,
          copyright: feed.copyright,
          block: feed.block,
          explicit: feed.explicit,
          feed_url: feed.feed_url,
          users: Map.get(data, :users, []) |> render_many(UserView, "user.json", conn: conn),
          items: render_assoc(feed.items, ItemView, "item.json", conn: conn),
          nr_of_subscribers: feed.subscriber_count,
          images: %{
            "50": feed_image_url(conn, :show, feed, size: 50),
            "100": feed_image_url(conn, :show, feed, size: 100),
            "600": feed_image_url(conn, :show, feed, size: 600)
          },
          meta: %{
            inserted_at: feed.inserted_at,
            updated_at: feed.updated_at,
            subscribed_at: feed.subscribed_at,
            users_count: Map.get(data, :users, []) |> length_assoc,
            items_count: length_assoc(feed.items)
          },
          links: %{
            self: feed_url(conn, :show, feed),
            delete: feed_url(conn, :delete, feed),
            subscribe: feed_subscription_url(conn, :create, feed),
            unsubscribe: feed_subscription_url(conn, :delete, feed)
          }
        }
end
