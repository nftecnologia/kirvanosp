up:
	docker-compose up --build

prod:
	docker-compose -f docker-compose.yml -f docker-compose.production.yml up --build

test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up --build

down:
	docker-compose down

build:
	docker-compose build

logs:
	docker-compose logs -f

bash:
	docker-compose exec web bash
