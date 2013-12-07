#! /usr/bin/env python
# python3

import sqlite3
import os

#### open db, create table

try:
    db = sqlite3.connect('sqlite.db')
    cursor = db.cursor()
    cursor.execute('CREATE TABLE IF NOT EXISTS test(id INTEGER PRIMARY KEY, name TEXT, num INTEGER)')
    db.commit()
except Exception as e:
    db.rollback()
    raise e

os.system('ls -lh sqlite.db')

#### insert data-lines

for (i,c) in enumerate('abcdefghijklmnopqrstuvwxyz') :
    print( "%s:%d %s:%d ," % (c,i,c+c,i*i) ),
    try:
        cursor.execute('INSERT INTO test(name,num) VALUES(?,?)', (c,i) )
        cursor.execute('INSERT INTO test(name,num) VALUES(?,?)', (c+c,i*i) )
        db.commit()
    except Exception as e:
        db.rollback()
        raise e

print("")
os.system('ls -lh sqlite.db')

#### select

cursor.execute('SELECT name,num FROM test')
for row in cursor :
    print( "%s:%d" % row ),

#### close

db.close()

