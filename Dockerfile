# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.3
FROM ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /app

# Install base Alpine packages
RUN apk update && apk add make gcc musl-dev tzdata git build-base postgresql-dev yaml-dev jemalloc

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"

# Build stage: install gems and precompile
FROM base AS build

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .
RUN chmod +x bin/docker-entrypoint


# Precompile bootsnap code
RUN bundle exec bootsnap precompile app/ lib/

# Final stage
FROM base

# Copy built app and installed gems
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

# Create non-root user for security
RUN addgroup -g 1000 rails && \
    adduser -D -u 1000 -G rails rails && \
    mkdir -p log tmp && \
    chown -R rails:rails /app


USER rails

# Entrypoint prepares the database
ENTRYPOINT ["bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
