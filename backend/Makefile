ENV ?= apatris-ref.local

build-gemfile:
	docker run --rm -v "`pwd`:/app" -w /app ruby:2.7.3 bash -c " \
		bundle config set path 'vendor/bundle'; \
		bundle install --jobs 128 \
	"


build-image:
	docker build --rm -t backend.$(ENV) .

build-assets:
	docker run --rm -v "`pwd`:/app" --env-file ../config/$(ENV)/config.env -w /app backend.$(ENV) \
		bash -c " \
			bundle exec rake tmp:cache:clear; \
			bundle exec rake assets:clobber; \
			bundle exec rake assets:precompile; \
		"

build:
	make build-gemfile
	make build-image
	make build-assets
