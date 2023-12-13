defmodule Birdfed.Fed do
  alias Fedex.Activitystreams
  alias Fedex.Activitypub
  alias Fedex.Webfinger
  alias Fedex.Webfinger.Entity

  @in_reply_to "https://mastodon.social/@lawiktesting/111575603672007918"

  # @host "fedex.fly.dev"
  # @base_url "https://fedex.fly.dev"
  @host "sliver.tailb203e.ts.net"
  @base_url "https://sliver.tailb203e.ts.net"
  @target_host "mastodon.social"

  def setup do
    keypair = Fedex.Crypto.generate_keypair()

    actor =
      Activitystreams.actor(
        @base_url,
        "lawik",
        "Person",
        "lawik",
        "inbox",
        "main-key",
        keypair.public.public_key
      )

    entity =
      Webfinger.ent("lawik@#{@host}", [
        Webfinger.link("self", "application/activity+json", "#{@base_url}/lawik")
      ])

    json_doc = entity |> Entity.as_map() |> Jason.encode!()
    Fedex.Doc.set(:birdfed_fingers, entity.subject, json_doc)

    Fedex.Doc.set(:birdfed_actors, "/lawik", Jason.encode!(actor))

    obj_id = "note-1"

    note_object =
      Activitystreams.new_note_object(
        @base_url,
        obj_id,
        actor.id,
        DateTime.utc_now(),
        @in_reply_to,
        "Some great content from an automation.",
        Activitystreams.to_public()
      )

    Fedex.Doc.set(:birdfed_actors, "/#{obj_id}", Jason.encode!(note_object))
  end

  def try_post do
    keypair = Fedex.Crypto.generate_keypair()

    actor =
      Activitystreams.actor(
        @base_url,
        "lawik",
        "Person",
        "lawik",
        "inbox",
        "main-key",
        keypair.public.public_key
      )

    entity =
      Webfinger.ent("lawik@sliver.tailb203e.ts.net", [
        Webfinger.link("self", "application/activity+json", "#{@base_url}/lawik")
      ])

    json_doc = entity |> Entity.as_map() |> Jason.encode!()
    Fedex.Doc.set(:birdfed_fingers, entity.subject, json_doc)

    Fedex.Doc.set(:birdfed_actors, "/lawik", Jason.encode!(actor))

    obj_id = System.unique_integer([:positive, :monotonic])

    note_object =
      Activitystreams.new_note_object(
        @base_url,
        "note-#{obj_id}",
        actor.id,
        DateTime.utc_now(),
        @in_reply_to,
        "Some great content from an automation.",
        Activitystreams.to_public()
      )

    create = Activitystreams.new(@base_url, "create-#{obj_id}", "Create", actor.id, note_object)

    Activitypub.request_by_actor(actor, keypair, :post, @target_host, "/inbox", create)
    |> Activitypub.request()
    |> IO.inspect(label: "result")
  end

  def fetch_fingers(key) do
    Fedex.Doc.get(:birdfed_fingers, key)
  end

  def fetch_actors(key) do
    Fedex.Doc.get(:birdfed_actors, key)
  end
end
