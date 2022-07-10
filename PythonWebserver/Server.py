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


@app.route('/api/leaderboard/<Map>', defaults={'Limit': 100})
@app.route('/api/leaderboard/<Map>/<Limit>')
def leaderboard(Map, Limit):
	Map = Map.lower()

	if request.method == 'GET':
		Cursor = mysql.connection.cursor()

		Cursor.execute(f"SELECT * FROM {Map} ORDER BY score  LIMIT {Limit}; ")
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

@app.route('/api/profile/<UserId>')
def profile(UserId):
	Cursor = mysql.connection.cursor()

	if request.method == 'GET':
		Cursor.execute(f"SELECT * from accountdata WHERE ID = {UserId}")

		AccountData = cursor.fetchall()

		mysql.connection.commit()

		return jsonify(AccountData)

if __name__ == '__main__':

	app.run(host='0.0.0.0', debug=True, port=5000)
