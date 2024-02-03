import cv2
import os
from flask import Flask,request,render_template
from datetime import date
import numpy as np
from sklearn.neighbors import KNeighborsClassifier
import pandas as pd
import joblib
import mysql.connector

#### Defining Flask App
app = Flask(__name__)

cnx = mysql.connector.connect(user='global', password='rahul@1234',
                              host='localhost',
                              database='geoat'
                              )

cursor = cnx.cursor()

#### Saving Date today in 2 different formats
datetoday = date.today().strftime("%m_%d_%y")
datetoday2 = date.today().strftime("%d-%B-%Y")


#### Initializing VideoCapture object to access WebCam
face_detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')





#### get a number of total registered users
def totalreg():
    return len(os.listdir('static/faces'))


#### extract the face from an image
def extract_faces(img):
    try:
        if img.shape!=(0,0,0):
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            face_points = face_detector.detectMultiScale(gray, 1.3, 5)
            return face_points
        else:
            return []
    except:
        return []


#### A function which trains the model on all the faces available in faces folder
def train_model():
    faces = []
    labels = []
    userlist = os.listdir('static/faces')
    for user in userlist:
        for imgname in os.listdir(f'static/faces/{user}'):
            img = cv2.imread(f'static/faces/{user}/{imgname}')
            resized_face = cv2.resize(img, (50, 50))
            faces.append(resized_face.ravel())
            labels.append(user)
    faces = np.array(faces)
    knn = KNeighborsClassifier(n_neighbors=5)
    knn.fit(faces,labels)
    joblib.dump(knn,'static/face_recognition_model.pkl')



################## ROUTING FUNCTIONS #########################

#### Our main page
@app.route('/admin')
def home():
    return render_template('home.html',totalreg=totalreg(),datetoday2=datetoday2)  


#### This function will run when we add a new user
@app.route('/add',methods=['GET','POST'])
def add():
    newusername = request.form['newusername']
    newuserid = request.form['newuserid']
    userimagefolder = 'static/faces/'+newusername+'_'+str(newuserid)
    if not os.path.isdir(userimagefolder):
        os.makedirs(userimagefolder)
    i,j = 0,0
    cap = cv2.VideoCapture(0)
    while 1:
        _,frame = cap.read()
        faces = extract_faces(frame)
        for (x,y,w,h) in faces:
            cv2.rectangle(frame,(x, y), (x+w, y+h), (255, 0, 20), 2)
            cv2.putText(frame,f'Images Captured: {i}/50',(30,30),cv2.FONT_HERSHEY_SIMPLEX,1,(255, 0, 20),2,cv2.LINE_AA)
            if j%10==0:
                name = newusername+'_'+str(i)+'.jpg'
                cv2.imwrite(userimagefolder+'/'+name,frame[y:y+h,x:x+w])
                i+=1
            j+=1
        if j==500:
            break
        cv2.imshow('Adding new User',frame)
        if cv2.waitKey(1)==27:
            break
    cap.release()
    cv2.destroyAllWindows()
    print('Training Model')
    train_model()
    return render_template('home.html',totalreg=totalreg(),datetoday2=datetoday2) 


#### Our main function which runs the Flask App
if __name__ == '__main__':
    app.run()
