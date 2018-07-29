defmodule CloudSigma do

  @moduledoc """
  Documentation for CloudSigma.
  """

  use Tesla, only: [:get, :post, :put, :delete, :options]

  @api_endpoint_slug_default "https://{loc}.cloudsigma.com/api/2.0"
  @api_endpoint_location_default "zrh"

  if Application.get_env(:cloudsigma_api_wrapper, :enable_tesla_log, false) do
    plug Tesla.Middleware.Logger
  end
  plug Tesla.Middleware.BaseUrl, make_endpoint()
  plug Tesla.Middleware.Headers, make_auth_header()
  plug Tesla.Middleware.JSON
  if Application.get_env(:cloudsigma_api_wrapper, :http_retry_enabled, true) do
    plug Tesla.Middleware.Retry, delay: Application.get_env(:cloudsigma_api_wrapper, :http_retry_delay, 1000), max_retries: Application.get_env(:cloudsigma_api_wrapper, :http_retry_max_retries, 5)
  end
  if Application.get_env(:cloudsigma_api_wrapper, :http_follow_redirects, true) do
    plug Tesla.Middleware.FollowRedirects
  end

  def make_endpoint() do
    api_endpoint_default = String.replace(Application.get_env(:cloudsigma_api_wrapper, :api_endpoint_slug, @api_endpoint_slug_default), ~r/{loc}/, Application.get_env(:cloudsigma_api_wrapper, :api_endpoint_location, @api_endpoint_location_default))
    Application.get_env(:cloudsigma_api_wrapper, :api_endpoint, api_endpoint_default)
  end

  def make_endpoint_client(loc) do
    endpoint_url = String.replace(Application.get_env(:cloudsigma_api_wrapper, :api_endpoint_slug, @api_endpoint_slug_default), ~r/{loc}/, loc)
    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, endpoint_url},
    ]
  end

  def make_auth_header() do
    [{"Authorization", "Basic " <> Base.encode64(Application.fetch_env!(:cloudsigma_api_wrapper, :user_email) <> ":" <> Application.fetch_env!(:cloudsigma_api_wrapper, :password))}]
  end

end
