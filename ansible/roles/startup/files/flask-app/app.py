import boto3
import base64
import json
from flask import Flask, render_template, request

ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'}
LAMBDA_NAME = 'lambda_flask'

app = Flask(__name__)
app.debug = True


@app.route('/', methods=("POST", "GET"))
def upload_file():
    if request.method == 'POST':
        uploaded_img = request.files
        for key, value in uploaded_img.items():
            print(f"Key: {key}, Value: {value}")
            image_data = value.read()

            lambda_client = boto3.client('lambda', region_name='eu-central-1')
            image_data_base64 = base64.b64encode(image_data).decode('utf-8')

            response = lambda_client.invoke(
                FunctionName=LAMBDA_NAME,
                Payload=json.dumps(image_data_base64)
            )

            response_payload = response['Payload'].read()
            json_data_response = json.loads(response_payload)
            print(json_data_response)

        return render_template('index.html')

    if request.method == 'GET':
        return render_template('index.html')


@app.route('/list_images', methods=["GET"])
def get_images():
    s3_client = boto3.client("s3")
    bucket_name = "s3-flask-bucket"
    response = s3_client.list_objects_v2(Bucket=bucket_name)
    files = response.get("Contents")
    if files:
        for file in files:
            print(f"file_name: {file['Key']}, size: {file['Size']}")

    return render_template('files.html', files=files)

if __name__ == '__main__':
    app.run()












