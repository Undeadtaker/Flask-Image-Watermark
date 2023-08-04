import os
from flask import Flask, render_template, request
from werkzeug.utils import secure_filename

ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'}

app = Flask(__name__)
app.debug = True


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/', methods=("POST", "GET"))
def upload_file():
    if request.method == 'POST':
        uploaded_img = request.files
        for key, value in uploaded_img.items():
            print(f"Key: {key}, Value: {value}")
            img_filename = secure_filename(key)
            print(img_filename)

        return render_template('index.html')


if __name__ == '__main__':
    app.run()