# My python still kinda sucks, so be patient with me here

from flask import Flask, request, send_from_directory,redirect, render_template
from flask import jsonify

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

mysql = MySQL(app)

# API Start

@app.route('/api/')
def _():
	"""
	Base API
	"""
	return jsonify({'Message': 'OK'}),200

# TODO add all the needed API functions

if __name__ == '__main__':

	app.run(host='0.0.0.0',debug=True,port=80)
