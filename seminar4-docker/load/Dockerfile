FROM gcc:13
WORKDIR /src
COPY cpuload.c memload.c ./
RUN gcc -O2 -o cpuload cpuload.c && gcc -O2 -o memload memload.c
