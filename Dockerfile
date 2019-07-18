FROM kong

RUN mkdir -p /usr/local/kong/declarative/
RUN kong config -c kong.conf init

RUN cp kong.yml /usr/local/kong/declarative/kong.yml
