#!/usr/bin/python
#
#External auth script for ejabberd that enable auth against MySQL db with
#use of custom fields and table. It works with hashed passwords.
#Inspired by Lukas Kolbe script.
#Released under GNU GPLv3
#Author: iltl. Contact: iltl@free.fr
#Version: 27 July 2009

########################################################################
#DB Settings
#Just put your settings here.
########################################################################
db_name="platform"
db_user="root"
db_pass="TV.xian"
db_host="192.168.1.6"
db_table="oauth_access_token"
db_username_field="user_id"
db_password_field="token_id"
domain_suffix="@localhost" #JID= user+domain_suffix
########################################################################
#Setup
########################################################################
import sys, logging, struct, hashlib, MySQLdb
from struct import *


class EjabberdInputError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

logging.basicConfig(level=logging.INFO,format='%(asctime)s %(levelname)s %(message)s',filename='/opt/server/broker/ejabberd/var/log/ejabberd/auth.log',filemode='a')

logging.debug('extauth script started, waiting for ejabberd requests')

database=MySQLdb.connect(db_host, db_user, db_pass, db_name)
cursor=database.cursor()

########################################################################
#Declarations
########################################################################
def ejabberd_in():
		logging.debug("trying to read 2 bytes from ejabberd:")
		try:
			input_length = sys.stdin.read(2)
		except IOError:
			logging.debug("ioerror")
		
		if len(input_length) is not 2:
			logging.debug("ejabberd sent us wrong things!")
			raise EjabberdInputError('Wrong input from ejabberd!')
		else:
			logging.debug('got 2 bytes via stdin: %s'%input_length)
			(size,) = unpack('>h', input_length)
			return sys.stdin.read(size).split(':')

def ejabberd_out(bool):
		logging.debug("Ejabberd gets: %s" % bool)
		token = genanswer(bool)
		logging.debug("sent bytes: %#x %#x %#x %#x" % (ord(token[0]), ord(token[1]), ord(token[2]), ord(token[3])))
		sys.stdout.write(token)
		sys.stdout.flush()

def genanswer(bool):
		answer = 0
		if bool:
			answer = 1
		return pack('>hh', 2, answer)

def db_entry(in_user):
	ls=[None, None]
	cursor.execute("SELECT %s,%s FROM %s WHERE %s ='%s'"%(db_username_field,db_password_field , db_table, db_username_field, in_user))
	return cursor.fetchone()
	
def isuser(in_user, in_host):
	data=db_entry(in_user)
	out=False #defaut to O preventing mistake
	if data==None:
		out=False
		logging.debug("Wrong username: %s"%(in_user))
	if in_user+"@"+in_host==data[0]+domain_suffix:
		out=True
	return out
	
def auth(in_user, in_host, in_password):
	data=db_entry(in_user)
	out=False #defaut to O preventing mistake
	if data==None:
		out=False
		logging.debug("Wrong username: %s"%(in_user))
	if in_user+"@"+in_host==data[0]+domain_suffix:
		if in_password==data[1]:
			logging.debug("Success password for user: %s"%(in_user))
			out=True
		else:
			logging.debug("Wrong password for user: %s"%(in_user))
			out=False
	else:
		out=False
	return out

########################################################################
#Main Loop
########################################################################
while True:
	logging.debug("start of infinite loop")
	try: 
		ejab_request = ejabberd_in()
	except EjabberdInputError, inst:
		logging.debug("Exception occured: %s", inst)
		break
	logging.debug('operation: %s'%(ejab_request[0]))
	op_result = False
	if ejab_request[0] == "auth":
		op_result = auth(ejab_request[1], ejab_request[2], ejab_request[3])
		ejabberd_out(op_result)
	elif ejab_request[0] == "isuser":
		op_result = isuser(ejab_request[1], ejab_request[2])
		ejabberd_out(op_result)
	elif ejab_request[0] == "setpass":
		op_result=False
		ejabberd_out(op_result)

logging.debug("end of infinite loop")
logging.debug('extauth script terminating')
database.close()
