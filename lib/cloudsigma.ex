defmodule CloudSigma do

  @moduledoc """
  Documentation for CloudSigma.
  """

  @api_endpoint_slug_default "https://{loc}.cloudsigma.com/api/2.0"
  @api_endpoint_location_default "zrh"

  use Tesla, only: [:get, :post, :put, :delete, :options]

  @user_email Application.fetch_env!(:cloudsigma, :user_email)
  @password Application.fetch_env!(:cloudsigma, :password)

  plug Tesla.Middleware.Tuples, rescue_errors: :all
  plug Tesla.Middleware.BaseUrl, make_endpoint()
  plug Tesla.Middleware.Headers, make_auth_header()
  plug Tesla.Middleware.JSON
  if Application.get_env(:cloudsigma, :debug_http) do
    plug Tesla.Middleware.DebugLogger
  end

  def make_endpoint() do
    slug = Application.get_env(:cloudsigma, :api_endpoint_slug, @api_endpoint_slug_default)
    loc = Application.get_env(:cloudsigma, :api_endpoint_location, @api_endpoint_location_default)
    api_endpoint_default = String.replace(slug, ~r/{loc}/, loc)
    Application.get_env(:cloudsigma, :api_endpoint, api_endpoint_default)
  end

  def make_endpoint_client(loc) do
    slug = Application.get_env(:cloudsigma, :api_endpoint_slug, @api_endpoint_slug_default)
    endpoint_url = String.replace(slug, ~r/{loc}/, loc)
    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, endpoint_url},
    ]
  end

  def make_auth_header() do
    %{"Authorization" => "Basic " <> Base.encode64(@user_email <> ":" <> @password)}
  end

end
