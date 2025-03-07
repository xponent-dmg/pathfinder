# Pathfinder 馃敟馃搫  
A full-stack app built using **Flutter** and **Node.js** with **MongoDB Atlas** as the database.

Pathfinder is a feature-rich application that showcases **Project Harishankar: The Legend Arc 馃敟馃搫**, blending modern technologies to build scalable and secure apps.

## Tech Stack 馃洜锔�  
### Frontend  
- Flutter (Dart)  
- HTTP Package  
- Secure Storage  
- Provider (State Management)  

### Backend  
- Node.js  
- Express.js  
- MongoDB Atlas  
- Railway (Deployment)  

### Features  
- User Authentication (JWT-based)  
- Image Upload and Storage  
- Secure Data Storage  
- Full CRUD Operations  
- Async API Calls  
- MongoDB Integration  

## Folder Structure  
```bash
鈹溾攢鈹€ backend           # Node.js Express API  
鈹�   鈹溾攢鈹€ models       # MongoDB Models  
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

## Environment Setup 馃寪  
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
node index.js  
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
| Method | Endpoint        | Description        | Auth Required |  
|--------|---------------|------------------|--------------|  
| POST   | /auth/signup  | Register user    | 鉂�           |  
| POST   | /auth/login   | Login user      | 鉂�           |  
| GET    | /user/profile | Get user profile | 鉁�           |  
| POST   | /image/upload | Upload Image    | 鉁�           |  

## How Images are Stored 馃柤锔�  
Images are **Base64-encoded** and stored as strings in MongoDB for now. Upcoming updates will integrate **GridFS** for efficient binary storage.  

## Future Features 馃敟  
- Dark Mode  
- File Upload (GridFS)  
- Role-Based Authentication  
- Google Sign-In  

---

### How to Contribute  
Fork the repo, create a branch, and submit a PR!  

---

### Author  
Harishankar R  
**Project Harishankar: The Legend Arc 馃敟馃搫**  

---

This journey is just getting started 馃殌  