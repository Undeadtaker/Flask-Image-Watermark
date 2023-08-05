import base64
import uuid
import boto3

from io import BytesIO
from PIL import Image

def lambda_handler(event, context):
    image_data = base64.b64decode(event)
    opened_image = Image.open(BytesIO(image_data))

    watermark = Image.open("watermark.png")

    # Get the size of the original image
    image_width, image_height = opened_image.size

    # Get the size of the watermark image
    watermark_width, watermark_height = watermark.size

    # Calculate the position to place the watermark at the bottom right corner
    x_position = image_width - watermark_width
    y_position = image_height - watermark_height

    # Paste the watermark on the original image
    opened_image.paste(watermark, (x_position, y_position), watermark)

    watermarked_image_io = BytesIO()
    opened_image.save(watermarked_image_io, format='PNG')
    watermarked_image_io.seek(0)

    s3 = boto3.client('s3')
    bucket_name = "s3-flask-bucket"
    key = f"{str(uuid.uuid4())}.png"

    s3.upload_fileobj(watermarked_image_io, bucket_name, key)

    return {
        'statusCode': 200,
        'body': 'Image processed successfully'
    }