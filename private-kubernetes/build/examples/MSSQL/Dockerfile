# Base OS layer: Latest Ubuntu LTS.
FROM ubuntu:16.04

# Default SQL Server TCP/Port.
EXPOSE 1433

COPY ./bin /

RUN /install.sh

# Run SQL Server process.
CMD /startup.sh
