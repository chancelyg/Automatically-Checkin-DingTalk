from flask import Flask, send_file
import time
import os
import sys


app = Flask(__name__)


@app.route('/', methods=["GET"])
def index():
    script_path = sys.path[0] + "/check-in.sh"
    process = os.popen(script_path)
    output = process.read()
    output = output.replace("\\n", "</br>")
    process.close()
    file_name = sys.path[0] + "/" + str(int(time.time())) + ".png"
    os.popen("adb shell screencap -p | sed 's/\r$//' > " + file_name)
    time.sleep(2)
    if os.path.exists(file_name) is True:
        return send_file(file_name, mimetype='image/gif')
    if os.path.exists(file_name) is False:
        return output


app.run(host='0.0.0.0', port=30000)
