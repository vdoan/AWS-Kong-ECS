FROM kong
RUN ls -l /usr/local/kong
RUN mkdir -p /usr/local/kong/declarative/
RUN kong config -c kong.conf init
RUN ls -l
RUN cp kong.yml /usr/local/kong/declarative/kong.yml
RUN ls -l /usr/local/kong/declarative