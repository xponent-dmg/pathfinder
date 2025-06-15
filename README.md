# Pathfinder 
A full-stack event management mobile app built with Flutter, Node.js, and MongoDB. It enables users to discover, create, and register for college events with features like role-based access (User, Club Leader, Admin), interactive map-based navigation, event filtering, and real-time updates.

## Tech Stack
### Frontend  
- Flutter (Dart)  
- HTTP Package  
- Secure Storage 

### Backend  
- Node.js  
- Express.js  
- MongoDB Atlas  
- Railway (Deployment)  

### Features  
- User Authentication (JWT-based)    
- Secure Data Storage  
- Full CRUD Operations  
- Async API Calls  
- MongoDB Integration  

## Folder Structure  
```bash
鈹�   鈹溾攢鈹backend           # Node.js Express API  
鈹�   鈹溾攢鈹€models       # MongoDB Models  
鈹�   鈹溾攢鈹€ routes       # API Routes  
鈹�   鈹斺攢鈹€ controllers  # Business Logic  
鈹�  
鈹斺攢鈹€ frontend         # Flutter App  
    鈹溾攢鈹€ lib  
    鈹�   鈹溾攢鈹€ models   # Data Models  
    鈹�   鈹溾攢鈹€ services # API Services  
    鈹�   鈹溾攢鈹€ screens  # UI Screens  
    鈹�   鈹斺攢鈹€ widgets  # Reusable Components  
    鈹斺攢鈹€ assets       # Images & Icons  
```  

## Environment Setup
### Backend  
1. Install Node.js  
2. Clone the repo  
3. Install dependencies  
```bash
cd backend  
npm install  
```  
4. Set environment variables  
```bash
MONGO_URI=your_mongodb_url  
JWT_SECRET=your_jwt_secret  
```  
5. Start the server  
```bash
npm start
```  

### Frontend  
1. Install Flutter  
2. Clone the repo  
3. Install dependencies  
```bash
cd frontend  
flutter pub get  
```  
4. Run the app  
```bash
flutter run  
```  

## API Endpoints  
| Method | Endpoint        | Description        | 
|--------|---------------|------------------|
| POST   | /auth/signup  | Register user    |         |  
| POST   | /auth/login   | Login user      |         |  
| GET    | /user/profile | Get user profile |         |  
| POST   | /image/upload | Upload Image    |         |  

## How Images are Stored 
Images are **Base64-encoded** and stored as strings in MongoDB for now. Upcoming updates will integrate **GridFS** for efficient binary storage.  

## Future Features
- Dark Mode  
- Image Upload and storage
- File Upload (GridFS) 
- Role-Based Authentication  
- Forget password

---

### How to Contribute  
Fork the repo, create a branch, and submit a PR!  

---

### Authors 
- Harishankar R  
- Dhruv John Samuel
- Antony Prajin
- Vyshnav M
---

This journey is just getting started
