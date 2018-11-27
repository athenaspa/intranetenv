docker build -t athenagroup/php-fpm:latest --compress --force-rm -f Dockerfile .  && \
[[ $1 == '--push' ]] && docker push athenagroup/php-fpm:latest