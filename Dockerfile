FROM elixir:1.12.2

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force
