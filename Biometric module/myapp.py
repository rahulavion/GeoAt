#to recognize/identify person from images

import base64
from io import BytesIO
import os
from PIL import Image
from flask import Flask, render_template, request,jsonify
import cv2
import joblib
import pandas as pd
import datetime
import app

app = Flask(__name__)

#### Initializing VideoCapture object to access WebCam
face_detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
#### extract the face from an image
#### Saving Date today in 2 different formats
datetoday = datetime.date.today().strftime("%m_%d_%y")
datetoday2 = datetime.date.today().strftime("%d-%B-%Y")

#### If these directories don't exist, create them
if not os.path.isdir('Attendance'):
    os.makedirs('Attendance')
if not os.path.isdir('static'):
    os.makedirs('static')
if not os.path.isdir('static/faces'):
    os.makedirs('static/faces')
if f'Attendance-{datetoday}.csv' not in os.listdir('Attendance'):
    with open(f'Attendance/Attendance-{datetoday}.csv','w') as f:
        f.write('Name,Roll,Time')

        
def extract_faces(img):
    try:
        if img.shape!=(0,0,0):
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            face_points = face_detector.detectMultiScale(gray, 1.1, 5)
            return face_points
        else:
            print("ila")
            return []
    except:
        return []


#### Identify face using ML model
def identify_face(facearray):
    model = joblib.load('static/face_recognition_model.pkl')
    return model.predict(facearray)


# def add_attendance(name):
#     username = name.split('_')[0]
#     userid = name.split('_')[1]
#     current_time = datetime.now().strftime("%H:%M:%S")
    
#     df = pd.read_csv(f'Attendance/Attendance-{datetoday}.csv')
#     if int(userid) not in list(df['Roll']):
#         with open(f'Attendance/Attendance-{datetoday}.csv','a') as f:
#             f.write(f'\n{username},{userid},{current_time}')


def process_image(img):
    image = cv2.imread(img)
    (x,y,w,h) = extract_faces(image)[0]

    cv2.rectangle(image,(x, y), (x+w, y+h), (255, 0, 20), 2)
    face = cv2.resize(image[y:y+h,x:x+w], (50, 50))
    identified_person = identify_face(face.reshape(1,-1))[0]
    #add_attendance(identified_person)
    return identified_person


def decode_base64_image(encoded_image):
  decoded_data = base64.b64decode(encoded_image)
  image_data = BytesIO(decoded_data)
  image = Image.open(image_data)
  return image


@app.route("/geoat",methods = ['GET','POST'])
def process_img():
    encoded_image=request.form['name']
    img=decode_base64_image(encoded_image)
    img.save("decoded_image.jpg")
    img_path="/home/rently/Downloads/attempt-1/decoded_image.jpg"
    ans=process_image(img_path)
    data = {
        "result": ans,
        "number": 42,
    }

    return { 'statusCode': 200,
     'headers': {
  "Access-Control-Allow-Origin": "*", 
  "Access-Control-Allow-Credentials": 'true', 
  "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
},
    'body': data
};


if __name__ == "__main__":
    app.run(debug=True)

