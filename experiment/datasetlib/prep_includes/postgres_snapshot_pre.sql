\echo [INFO] Prepare DB files for postgres (Start)
\timing on
DROP DATABASE IF EXISTS :v0;
CREATE DATABASE :v0;
\c :v0;
\echo [INFO] Prepare DB files for postgres (End)
\echo [INFO] Create tables and indexes (Start)
CREATE TABLE IF NOT EXISTS N_schema (_0 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS E_schema (_0 VARCHAR(1024), _1 VARCHAR(1024), _2 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS EGD (_0 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS CATALOG_VIEW (_0 VARCHAR(1024), _1 VARCHAR(1024), _2 VARCHAR(1024), _3 VARCHAR(1024), _4 INT DEFAULT 0);
CREATE TABLE IF NOT EXISTS CATALOG_INDEX (_0 VARCHAR(1024), _1 VARCHAR(1024), _2 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS CATALOG_SINDEX (_0 VARCHAR(1024), _1 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS N_g (
    _0 INT DEFAULT 0, 
    _1 VARCHAR(1024),
    PRIMARY KEY(_0)
);
CREATE TABLE IF NOT EXISTS E_g (
    _0 INT DEFAULT 0, 
    _1 INT DEFAULT 0, 
    _2 INT DEFAULT 0, 
    _3 VARCHAR(1024),
    PRIMARY KEY(_0)
    --, 
    -- CONSTRAINT fk_e_g_1 FOREIGN KEY(_1) REFERENCES N_g(_0),
    -- CONSTRAINT fk_e_g_2 FOREIGN KEY(_2) REFERENCES N_g(_0)
);
CREATE TABLE IF NOT EXISTS NP_g (_0 INT DEFAULT 0, _1 VARCHAR(1024), _2 VARCHAR(1024));
CREATE TABLE IF NOT EXISTS EP_g (_0 INT DEFAULT 0, _1 VARCHAR(1024), _2 VARCHAR(1024));
\echo [INFO] Create tables (End)
--\echo [INFO] v1: :'v1'
--\COPY n_g (_0, _1) FROM /home/ubuntu/src/graph-trans/experiment/dataset/targets/SYN-10000-1000/node.csv WITH DELIMITER ',' CSV HEADER;
--\COPY n_g (_0, _1) FROM :'v1' WITH DELIMITER ',' CSV HEADER;
--COPY n_g (_0, _1) FROM :'v1' DELIMITER ',' CSV HEADER;
--COPY e_g (_0, _1, _2, _3) FROM :'v2' DELIMITER ',' CSV HEADER;



