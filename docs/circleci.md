# Upgrading Docker image

1. Make changes to `Dockerfile`.
2. `export tag=2.6.3-(n+1)`
3. `docker build -t mast/perf-check:$tag .`
4. Update `.circleci/config.yml` to use `image: mast/perf-check:$tag`.
5. circleci local execute --job build
5. `docker push mast/perf-check:$tag`
6. Commit changes and push
