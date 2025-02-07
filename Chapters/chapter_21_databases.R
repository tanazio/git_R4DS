library(DBI)
library(dbplyr)
library(tidyverse)

# There are three high level differences between data frames and database 
# tables:
  
# Database tables are stored on disk and can be arbitrarily large. Data 
# frames are stored in memory, and are fundamentally limited (although that
# limit is still plenty large for many problems).

# Database tables almost always have indexes. Much like the index of a book, 
# a database index makes it possible to quickly find rows of interest without
# having to look at every single row. Data frames and tibbles don’t have indexes,
# but data.tables do, which is one of the reasons that they’re so fast.

# Most classical databases are optimized for rapidly collecting data, not 
# analyzing existing data. These databases are called row-oriented because 
# the data is stored row-by-row, rather than column-by-column like R. More 
# recently, there’s been much development of column-oriented databases that
# make analyzing the existing data much faster.





# To connect to the database from R, you’ll use a pair of packages:

# You’ll always use DBI (database interface) because it provides a set of 
# generic functions that connect to the database, upload data, run SQL 
# queries, etc.

# You’ll also use a package tailored for the DBMS you’re connecting to. 
# This package translates the generic DBI commands into the specifics needed
# for a given DBMS. There’s usually one package for each DBMS, e.g. RPostgres
# for PostgreSQL and RMariaDB for MySQL.

# Concretely, you create a database connection using DBI::dbConnect(). 
# The first argument selects the DBMS2, then the second and subsequent 
# arguments describe how to connect to it (i.e. where it lives and the 
# credentials that you need to access it). The following code shows a 
# couple of typical examples:

con <- DBI::dbConnect(
  RMariaDB::MariaDB(),
  username = "foo"
)

con <- DBI::dbConnect(
  RPostgres::Postgres(),
  hostname = "databse.mycompany.com",
  port = 1234
)

# The precise details of the connection vary a lot from DBMS to DBMS so 
# unfortunately we can’t cover all the details here. This means you’ll 
# need to do a little research on your own. Typically you can ask the 
# other data scientists in your team or talk to your DBA (database 
# administrator). The initial setup will often take a little fiddling 
# (and maybe some googling) to get it right, but you’ll generally only 
# need to do it once.


# Connecting to DuckDB ----------------------------------------------------

# Connecting to duckdb is particularly simple because the defaults create
# a temporary database that is deleted when you quit R. That’s great for 
# learning because it guarantees that you’ll start from a clean slate every
# time you restart R:


con <- DBI::dbConnect(duckdb::duckdb())

# If you want to use duckdb for a real data analysis project, you’ll also 
# need to supply the dbdir argument to make a persistent database and tell
# duckdb where to save it. Assuming you’re using a project (Chapter 6), 
# it’s reasonable to store it in the duckdb directory of the current 
# project:

con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "duckdb")


# Loading data ------------------------------------------------------------

# Since this is a new database, we need to start by adding some data. Here
# we’ll add mpg and diamonds datasets from ggplot2 using DBI::dbWriteTable().
# The simplest usage of dbWriteTable() needs three arguments: a database 
# connection, the name of the table to create in the database, and a data 
# frame of data.

dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

# If you’re using duckdb in a real project, we highly recommend learning 
# about duckdb_read_csv() and duckdb_register_arrow(). These give you 
# powerful and performant ways to quickly load data directly into duckdb,
# without having to first load it into R. 

dbListTables(con)

con |> 
  dbReadTable("diamonds") |> 
  as_tibble()

# If you already know SQL, you can use dbGetQuery() to get the results of 
# running a query on the database:

sql <- "
SELECT carat, cut, clarity, color, price
FROM diamonds
WHERE price > 15000
"

as_tibble(dbGetQuery(con, sql))



# DBPLYR basics -----------------------------------------------------------

# Now that we’ve connected to a database and loaded up some data, we can 
# start to learn about dbplyr. dbplyr is a dplyr backend, which means 
# that you keep writing dplyr code but the backend executes it differently. 
# In this, dbplyr translates to SQL; other backends include dtplyr which 
# translates to data.table, and MULTIDPLYR which executes your code on 
# multiple cores.

#####################################################
# EXPLORE MORE THIS TOOL FOR THE MASTER THESIS !!!
library(multidplyr)
parallel::detectCores() # reads how many cores are the system have

cluster <- new_cluster(10) # sets how many cores will be used 
# (always leave 1~2 cores free to do other tasks)
#####################################################

# To use dbplyr, you must first use tbl() to create an object that represents
# a database table:
diamonds_db <- tbl(con, "diamonds")
diamonds_db

# This object is lazy; when you use dplyr verbs on it, dplyr doesn’t do 
# any work: it just records the sequence of operations that you want to 
# perform and only performs them when needed. For example, take the 
# following pipeline:

big_diamonds_db <- diamonds_db |> 
  filter(price > 1500) |> 
  select(carat:clarity, price)

big_diamonds_db

# shows the SQL code generated by dplyr function
diamonds_db |> 
  show_query()

big_diamonds_db |> 
  show_query()

# To get all the data back into R, you call collect(). Behind the scenes, 
# this generates the SQL, calls dbGetQuery() to get the data, then turns 
# the result into a tibble:

big_diamonds <- big_diamonds_db |> 
  collect()

big_diamonds


# Typically, you’ll use dbplyr to select the data you want from the 
# database, performing basic filtering and aggregation using the translations
# described below. Then, once you’re ready to analyse the data with functions
# that are unique to R, you’ll collect() the data to get an in-memory 
# tibble, and continue your work with pure R code.

dbplyr::copy_nycflights13(con)

flights <- tbl(con, "flights")
planes <- tbl(con, "planes")


# The top-level components of SQL are called statements. Common statements 
# include CREATE for defining new tables, INSERT for adding data, and SELECT
# for retrieving data. We will focus on SELECT statements, also called queries, 
# because they are almost exclusively what you’ll use as a data scientist.

# A query is made up of clauses. There are five important clauses: 
# SELECT, FROM, WHERE, ORDER BY, and GROUP BY. 
# Every query must have the SELECT4 and FROM5 clauses and the simplest 
# query is SELECT * FROM table, which selects all columns from the specified 
# table . This is what dbplyr generates for an unadulterated table :

flights |> show_query()

planes |> show_query()

# WHERE and ORDER BY control which rows are included and how they are ordered:

flights |> 
  filter(dest == "IAH") |> 
  arrange(dep_delay) |> 
  show_query()

# GROUP BY converts the query to a summary, causing aggregation to happen:

flights |> 
  group_by(dest) |> 
  summarize(dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  show_query()


# There are two important differences between dplyr verbs and SELECT clauses:
  
# 1 - In SQL, case doesn’t matter: you can write select, SELECT, or even SeLeCt.
# In this book we’ll stick with the common convention of writing SQL keywords 
# in uppercase to distinguish them from table or variables names.

# 2 - In SQL, order matters: you must always write the clauses in the order 
# SELECT, FROM, WHERE, GROUP BY, ORDER BY. Confusingly, this order doesn’t 
# match how the clauses are actually evaluated which is first FROM, then 
# WHERE, GROUP BY, SELECT, and ORDER BY.

