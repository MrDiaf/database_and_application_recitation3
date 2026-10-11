PGUSER=postgres PGHOST=localhost
db="recitation_3"
dropdb "$db"
createdb "$db"

psql -d "$db" -f sky_schema.sql
psql -d "$db" -f sky_data.sql

