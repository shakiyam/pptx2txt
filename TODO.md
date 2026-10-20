# TODO

1. Rename `Dockerfile.dev` to `dev.Dockerfile`, following the `<something>.Dockerfile` convention in [Docker's documentation](https://docs.docker.com/build/concepts/dockerfile/#filename), which also lets a `dev.Dockerfile.dockerignore` apply to that build only. Update every reference to the old name (`grep -rn 'Dockerfile.dev' --exclude-dir=.git .`), including the `build_dev`, `dockerfmt` and `hadolint` targets in `Makefile` and `AGENTS.md`, then verify with `make all`. Sibling repos make the same rename.
