ENV ?= apatris-ref.local
BRANCH ?= master

start:
	docker-compose -f config/${ENV}/docker-compose.yml up -d \
		--force-recreate \
		--remove-orphans

stop:
	docker-compose -f config/${ENV}/docker-compose.yml stop

ps:
	docker-compose -f config/${ENV}/docker-compose.yml ps

logs:
	docker-compose -f config/${ENV}/docker-compose.yml logs --tail 100 -f -t

migrate:
	docker exec backend.${ENV} bundle exec rake db:migrate

seed:
ifneq ($(ENV),apatris-ref.test)
	docker exec backend.${ENV} bundle exec rake db:seed
endif

wait-db:
	OK="0"; \
	CHECK="ActiveRecord::Base.connection.execute('SELECT datname FROM pg_database WHERE datistemplate = false;')"; \
	for i in {0..25} ; do \
		if docker exec backend.${ENV} rails runner "$$CHECK" 2> /dev/null ; then \
			OK="1"; \
			break; \
		fi; \
 	\
		echo -n . ; \
	done; \
	\
	if [ "$$OK" = "0" ] ; then \
		docker exec backend.${ENV} rails runner "$$CHECK" ; \
	fi

up:
	make -C backend build
	make start
	make wait-db
	make migrate
	make seed


fetch:
	git fetch

rollout:
ifeq (yes,$(shell test "`git --no-pager diff "${BRANCH}" "origin/${BRANCH}"`" != "" && echo "yes"))
		git reset --hard origin/${BRANCH}
		git submodule init
		git submodule update

		make stop
		make up

		curl -X POST -H 'Content-type: application/json' \
			--data '{"text":"${ENV} deployed successfully"}' \
			https://hooks.slack.com/services/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
else
		# up-to-date!
endif

deploy:
	make fetch
	make rollout

set-git-hooks:
	git config core.hooksPath git-hooks

lint:
	docker exec -t backend.${ENV} bundle exec rubocop --display-cop-name app spec -a

test:
	docker exec -t backend.${ENV} bundle exec rspec

update-doc:
	docker exec -t backend.${ENV} bundle exec rake docs:generate