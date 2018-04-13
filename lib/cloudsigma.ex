defmodule CloudSigma do

  @moduledoc """
  Documentation for CloudSigma.
  """

  use Tesla, only: [:get, :post, :put, :delete, :options]

  @api_endpoint_slug_default "https://{loc}.cloudsigma.com/api/2.0"
  @api_endpoint_location_default "zrh"

  @api_endpoint_slug Application.get_env(:cloudsigma_api_wrapper, :api_endpoint_slug, @api_endpoint_slug_default)
  @api_endpoint_location Application.get_env(:cloudsigma_api_wrapper, :api_endpoint_location, @api_endpoint_location_default)

  @user_email Application.fetch_env!(:cloudsigma_api_wrapper, :user_email)
  @password Application.fetch_env!(:cloudsigma_api_wrapper, :password)

  @http_follow_redirects Application.get_env(:cloudsigma_api_wrapper, :http_follow_redirects, true)
  @http_retry_enabled Application.get_env(:cloudsigma_api_wrapper, :http_retry_enabled, true)
  @http_retry_delay Application.get_env(:cloudsigma_api_wrapper, :http_retry_delay, 1000)
  @http_retry_max_retries Application.get_env(:cloudsigma_api_wrapper, :http_retry_max_retries, 5)
  @debug_http Application.get_env(:cloudsigma_api_wrapper, :debug_http, false)

  plug Tesla.Middleware.Tuples, rescue_errors: :all
  plug Tesla.Middleware.BaseUrl, make_endpoint()
  plug Tesla.Middleware.Headers, make_auth_header()
  plug Tesla.Middleware.JSON
  if @http_retry_enabled do
    plug Tesla.Middleware.Retry, delay: @http_retry_delay, max_retries: @http_retry_max_retries
  end
  if @http_follow_redirects do
    plug Tesla.Middleware.FollowRedirects
  end
  if @debug_http do
    plug Tesla.Middleware.DebugLogger
  end

  def make_endpoint() do
    api_endpoint_default = String.replace(@api_endpoint_slug, ~r/{loc}/, @api_endpoint_location)
    Application.get_env(:cloudsigma_api_wrapper, :api_endpoint, api_endpoint_default)
  end

  def make_endpoint_client(loc) do
    endpoint_url = String.replace(@api_endpoint_slug, ~r/{loc}/, loc)
    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, endpoint_url},
    ]
  end

  def make_auth_header() do
    %{"Authorization" => "Basic " <> Base.encode64(@user_email <> ":" <> @password)}
  end

end
