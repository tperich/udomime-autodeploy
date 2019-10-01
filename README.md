<p align="center">
  <img width="300px" src="./logo.png" />
</p>

### How to deploy

Make sure:

- To have [git](https://git-scm.com/), [docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/) installed
- Ports `80 (frontend)`, `8000 (backend)`, and `3306 (database)` are free or change them in the repositories' docker-compose files

Steps:

1. Run `./auto_deploy.sh --deploy`
2. Enter your superuser password if asked
3. Upon completion the app should be running at `localhost:80`

For script's usage run `./auto_deploy.sh -h`
