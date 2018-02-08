#!/bin/bash

if [ ! -z "$MSSQL_BASE_DIR" ]; then
    if [ ! -e "$MSSQL_BASE_DIR" ]; then
        mkdir -p $MSSQL_BASE_DIR
    fi
    if [ -e "/var/opt/mssql" ]; then
        cp -rp /var/opt/mssql/* $MSSQL_BASE_DIR/
	rm -rf /var/opt/mssql
    fi
    ln -s $MSSQL_BASE_DIR /var/opt/mssql
fi

/opt/mssql/bin/sqlservr
