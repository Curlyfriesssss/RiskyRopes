# My python still kinda sucks, so be patient with me here

from flask import Flask, request, send_from_directory, redirect, render_template
from flask import jsonify
from flask_mysqldb import MySQL

import requests
import json
import datetime
import os
import re
import base64
import math

import mysql.connector
import logging

# init

logs = logging.getLogger('werkzeug')
logs.setLevel(logging.ERROR)

app = Flask(__name__)

# config the mysql stuff
with open("ServerInfo.json") as file:
	js = json.load(file)
	for k in js:
		app.config[k] = js[k]

app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

# API Start


@app.route('/api/')
def _():
	"""
	Base API
	"""
	return jsonify({'Message': 'OK'}), 200


@app.route("/api/leaderboard/<Map>", methods=['GET'], defaults={'Limit': 100})
@app.route("/api/leaderboard/<Map>/<Limit>", methods=['GET'])
def leaderboard(Map, Limit):
	"""
	Risky Ropes API Call
	Returns the JSON data for a leaderboard
	"""
	Page = request.args.get('page')

	if not Page:
		Page = 0

	Page = int(Page)

	Map = Map.lower()

	Limit = int(Limit)
	if request.method == 'GET':
		cursor = mysql.connection.cursor()

		cursor.execute(
			f"SELECT * FROM {Map} ORDER BY score  LIMIT {(Page * Limit)}, {Limit}; ")
		result = list(cursor.fetchall())
		i = 1
		for pos in result:
			result[i-1]['pos'] = i
			i += 1
		mysql.connection.commit()
		cursor.execute(f"SELECT COUNT(*) AS TotalRanks FROM {Map};")
		result2 = cursor.fetchall()[0]['TotalRanks']
		result.append({
			'Count': result2
		})

		mysql.connection.commit()

		return jsonify(result), 200
	elif request.method == 'POST':
		cursor = mysql.connection.cursor()
		cursor.execute(f""" 
		CREATE TABLE `riskyropes`.`{Map}` (
		`userid` INT NOT NULL,
		`score` INT NOT NULL DEFAULT 0,
		PRIMARY KEY (`userid`),
		UNIQUE INDEX `userid_UNIQUE` (`userid` ASC) VISIBLE);
		""")
		mysql.connection.commit()
		return {"Success": True}, 200


@app.route('/api/profile/<UserId>', methods=['GET','POST'])
def profile(UserId):
	Cursor = mysql.connection.cursor()

	if request.method == 'GET':
		Cursor.execute(f"SELECT * from accountdata WHERE ID = {UserId}")

		AccountData = Cursor.fetchall()
		if len(AccountData) == 0:
			return jsonify("Profile does not exist"),404
		mysql.connection.commit()

		return jsonify(AccountData[0])
	elif request.method == 'POST':
		Cursor.execute(f"""INSERT INTO accountdata
(`ID`,
`Balance`,
`XP`,
`Wins`,
`Inventory`,
`Ropes`,
`Networth`,
`Playtime`)
VALUES({UserId},0,0,0,'[]',0,0,0);""")

		mysql.connection.commit()
		return 'Success',200


if __name__ == '__main__':

	app.run(host='0.0.0.0', debug=True, port=5000)
