# Overview

Dead simple [Elixir](http://elixir-lang.github.io) wrapper for the
[CloudSigma API](https://cloudsigma-docs.readthedocs.io/en/latest).

## Installation (for now)


```elixir
def deps do
  [
    {:cloudsigma, git: "https://github.com/stirlab/elixir-cloudsigma.git"},
  ]
end
```

```sh
cp config/config.sample.exs config/config.exs
```

Edit to taste. Pay particular attention to the ```api_endpoint_location:```
setting -- this should be set to the three letter abbreviation for the API
endpoint you want to connect with. Defaults to "zrh"

## Usage

The library leverages the [Tesla](https://github.com/teamon/tesla) HTTP
library, and for now it simply wraps the Tesla GET/POST/etc methods
directly.

The path and JSON data parameters can be figured out via CloudSigma's
[API](https://cloudsigma-docs.readthedocs.io/en/latest).

Note that many of the endpoint paths include a trailing slash -- you'll need
to include that to hit the right path on the endpoint.

### Examples

```elixir
# Get location info.
response = CloudSigma.get("/locations/")
IO.puts response.status
IO.inspect response.headers
IO.inspect response.body
# First location.
location = Enum.at(response.body["objects"], 0)
location_id = location["id"]
# Get only the first three locations.
response = CloudSigma.get("/locations/", query: [offset: 0, limit: 3])

#Get servers.
response = CloudSigma.get("/servers/")
# First server.
server = Enum.at(response.body["objects"], 0)
server_id = server["uuid"]

# Get server.
response = CloudSigma.get("/servers/#{server_id}/")
Apex.ap(response.body)
ip = Enum.at(response.body["nics"], 0)["ip_v4_conf"]["ip"]["uuid"]
status = response.body["status"]

# Update server.
data = %{
  name: "new-server-name",
  cpu: 2000,
  mem: 4294967296,
  vnc_password: "updated_password",
}
response = CloudSigma.put("/servers/#{server_id}/", data)
name = response.body["name"]

# Get drives.
response = CloudSigma.get("/drives/")
Enum.each response.body["objects"], fn drive ->
  IO.inspect drive
end
# First drive
drive = Enum.at(response.body["objects"], 0)
drive_id = drive["uuid"]
response = CloudSigma.get("/drives/#{drive_id}/")
name = response.body["name"]

# Clone server.
data = %{
  name: "example-server-clone",
  random_vnc_password: true,
}
response = CloudSigma.post("/servers/#{server_id}/action/", data, query: [do: "clone"])
clone_name = response.body["name"]
server_clone_id = response.body["uuid"]
clone_status = response.body["status"]

# Start the cloned server.
response = CloudSigma.post("/servers/#{server_clone_id}/action/", %{}, query: [do: "start"])
start_result = response.body["result"]

# Stop the cloned server.
response = CloudSigma.post("/servers/#{server_clone_id}/action/", %{}, query: [do: "stop"])
start_result = response.body["result"]

# Delete cloned server and all attached drives.
response = CloudSigma.delete("/servers/#{server_clone_id}/", query: [recurse: "all_drives"])
# 204 is successful delete.
204 == response.status

```
