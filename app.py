from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    # 試著從環境變數讀取名字，如果沒有就用預設值
    name = os.environ.get('NAME', 'World')
    return f'Hello, {name}!'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)