#!/bin/sh -ex
# Original: https://github.com/docker-library/postgres/blob/master/9.3/docker-entrypoint.sh

[ -d ${PGDATA} ] || mkdir -p ${PGDATA}

chown -R postgres "$PGDATA"
	
#chmod g+s /run/postgresql
#chown -R postgres:postgres /run/postgresql
	
if [ -z "$(ls -A "$PGDATA")" ]; then
  gosu postgres initdb
		
	sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
		
	: ${POSTGRES_USER:=postgres}
	: ${POSTGRES_DB:=$POSTGRES_USER}
		
# check password first so we can ouptut the warning before postgres
# messes it up
  if [ "$POSTGRES_PASSWORD" ]; then
	  pass="PASSWORD '$POSTGRES_PASSWORD'"
		authMethod=md5
	else
	# The - option suppresses leading tabs but *not* spaces. :)
	cat >&2 <<-'EOWARN'
		****************************************************
		WARNING: No password has been set for the database.
		         This will allow anyone with access to the
		         Postgres port to access your database. In
		         Docker's default configuration, this is
		         effectively any other container on the same
		         system.
		         
		         Use "-e POSTGRES_PASSWORD=password" to set
		         it in "docker run".
		****************************************************
	EOWARN
			
	pass=
	authMethod=trust
	fi

	if [ "$POSTGRES_DB" != 'postgres' ]; then
	  gosu postgres postgres --single -jE <<-EOSQL
		  CREATE DATABASE "$POSTGRES_DB" ;
		EOSQL
	  echo
	fi
		
	if [ "$POSTGRES_USER" = 'postgres' ]; then
	  op='ALTER'
	else
		op='CREATE'
	fi

	gosu postgres postgres --single -jE <<-EOSQL
	  $op USER "$POSTGRES_USER" WITH SUPERUSER $pass ;
	EOSQL
	echo
		
	{ echo; echo "host all all 0.0.0.0/0 $authMethod"; } >> "$PGDATA"/pg_hba.conf
		
	exec gosu postgres "$@"
fi

exec gosu postgres "$@"
