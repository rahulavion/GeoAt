import cv2
import os
import math
import base64
import numpy as np
from sklearn.neighbors import KNeighborsClassifier
import joblib
from io import BytesIO
from PIL import Image
from flask import Flask,request,render_template
from datetime import date


#### Defining Flask App
app = Flask(__name__)
rollNumber=0

#### Initializing VideoCapture object to access WebCam
face_detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

#### Saving Date today in 2 different formats
datetoday = date.today().strftime("%m_%d_%y")
datetoday2 = date.today().strftime("%d-%B-%Y")

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



def calculate_distance(lat1, lon1):

    # Convert degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(10.931620)
    lon2_rad = math.radians(76.984920)

    # Earth's radius in meters
    earth_radius = 6371000

    # Calculate the central angle
    delta_lat = lat2_rad - lat1_rad
    delta_lon = lon2_rad - lon1_rad

    a = math.sin(delta_lat / 2) ** 2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2
    c = 2 * math.asin(math.sqrt(a))

    # Calculate the distance
    distance = earth_radius * c
    return round(distance)


#### Identify face using ML model
def identify_face(facearray):
    model = joblib.load('static/face_recognition_model.pkl')
    return model.predict(facearray)

#to identify the person present in the image
def identify_image(img):
    image = cv2.imread(img)
    (x,y,w,h) = extract_faces(image)[0]

    cv2.rectangle(image,(x, y), (x+w, y+h), (255, 0, 20), 2)
    face = cv2.resize(image[y:y+h,x:x+w], (50, 50))
    identified_person = identify_face(face.reshape(1,-1))[0]
    result=identified_person.split('_')
    return result

#to decode the image
def decode_base64_image(encoded_image):
  decoded_data = base64.b64decode(encoded_image)
  image_data = BytesIO(decoded_data)
  image = Image.open(image_data)
  return image


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
def index():
    return render_template('home.html',totalreg=totalreg(),datetoday2=datetoday2)  


#### This function will run when we add a new user
@app.route('/add',methods=['GET','POST'])
def add_newUser():
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


@app.route("/geoat",methods = ['GET','POST'])
def find_name_from_image_request():
    encoded_image=request.form['face']
    #rollNumber=request.form['rollNumber']
    img=decode_base64_image(encoded_image)
    img.save("decoded_image.jpg")
    img_path="decoded_image.jpg"
    ans=identify_image(img_path)
    data = {
        "identified_name": ans[0],
        "roll_number": ans[1],
    }
    if(rollNumber==ans[1]):
        return data
    return "Not a valid user"

@app.route('/locate',methods = ['GET','POST'])
def locate():
    global rollNumber
    encoded_roll=request.form['roll']
    lat=request.form['lat']
    lng=request.form['lng']
    decoded_data = base64.b64decode(encoded_roll).decode('utf-8')
    key, value = decoded_data.split(':')
    rollNumber = value
    distance = calculate_distance(float(lat), float(lng))
    return {'distance':str(distance)}
    

#### Our main function which runs the Flask App
if __name__ == '__main__':
    app.run()