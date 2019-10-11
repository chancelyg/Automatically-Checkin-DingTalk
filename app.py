from flask import Flask
import os

app = Flask(__name__)

@app.route('/',methods=["GET"])
def index():
     process = os.popen('./check-in.sh.sh')
     output = process.read()
     process.close()
     return output

app.run(host='0.0.0.0',port=30000)