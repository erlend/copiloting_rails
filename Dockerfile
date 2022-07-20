ARG RUBY_VERSION=3.1.2
FROM ruby:$RUBY_VERSION AS dev

# Install system dependencies here. This stage is used for precompiling assets
# and running the server locally in development mode.

# Uncomment the following to install NodeJS
# RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
#     apt-get install --yes nodejs && \
#     rm -rf /var/lib/apt/lists/* && \
#     corepack enable

FROM dev AS build
WORKDIR /src

# Install application
COPY Gemfile Gemfile.lock ./
RUN bundle config without "development test" && \
    bundle config frozen true && \
    bundle install --jobs="$(nproc)"

# Uncomment the following if node modules are required for precompiling assets.
# COPY package.json yarn.lock
# RUN yarn install --frozen-lockfile

# Copy remaining files into image
COPY . .

# Precompile assets
ARG RAILS_ENV=production
ARG SECRET_KEY_BASE=x
RUN bundle exec rails assets:precompile

# Generate bootsnap cache (makes the application boot faster)
RUN bundle exec bootsnap precompile --gemfile app/ lib/

FROM ruby:$RUBY_VERSION-slim
WORKDIR /src

# Install runtime dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends --yes libpq5 && \
    rm -rf /var/lib/apt/lists/*

# Create and login as app user
RUN useradd --create-home app && \
    mkdir -p log tmp/cache && \
    chown -R app:app .
USER app

COPY . .
COPY --from=build /src/public ./public
COPY --from=build /src/tmp/cache/bootsnap ./tmp/cache/bootsnap
COPY --from=build /usr/local/bundle /usr/local/bundle

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1

EXPOSE 3000
CMD bundle exec rails server --binding="0.0.0.0" --port="${PORT:-3000}"
