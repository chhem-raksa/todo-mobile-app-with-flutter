**Simple Summary — Local API (json-server)**

## **1. Start Local Server**

* Open terminal in VS Code.
* Go to data folder:

  ```
  cd lib/data
  ```
* Start server:

  ```
  json-server --watch db.json
  ```
* Server runs at:

  * `localhost:3000/todos` → tasks
  * `localhost:3000/users` → users

---

## **2. Local Authentication (Login & Register)**

### **Register (Create User)**

* Send **POST request** with:

```json
{
  "email": "your@email.com",
  "password": "123456",
  "name": "Test User"
}
```

* User is saved in `db.json` → `"users"` list.

---

### **Login (Check User)**

* Send **GET request**:

```
/users?email=YOUR_EMAIL&password=123456
```

* Result:

  * User found → login success 
  * Empty list → login failed 

---

## **3. Manage Todos (Tasks)**

* **GET** `/todos` → see all tasks
* **POST** `/todos` → add task
* **PUT** `/todos/1` → update task
* **DELETE** `/todos/1` → delete task

---

## **4. How Your App Works (Hybrid System)**

Your app uses **two systems together**:

### **Local Storage (Main System)**

* Keeps login session.
* Works even if server is off.
* User won’t notice network problems.

### **Local API (json-server)**

* Saves backup data to `db.json`.
* Syncs users and todos when server is running.

👉 If server is OFF → app still works.
👉 If server is ON → data syncs.



Manual Testing Guide

1. Start Local Server
Open terminal in VS Code and run:

cd lib/data
json-server --watch db.json
2. Register New User
Send POST request to http://localhost:3000/users with:

{
  "email": "[EMAIL_ADDRESS]",
  "password": "123456",
  "name": "Test User"
}
3. Login
Send GET request to http://localhost:3000/users?email=[EMAIL_ADDRESS]&password=123456
4. Add Task
Send POST request to http://localhost:3000/todos with:

{
  "title": "Test Task",
  "description": "Test Description",
  "dateTime": "2024-12-31T23:59:59",
  "isCompleted": false,
  "taskPriority": "high"
}
5. Update Task
Send PUT request to http://localhost:3000/todos/1 with:

{
  "title": "Updated Task",
  "isCompleted": true
}
6. Delete Task
Send DELETE request to http://localhost:3000/todos/1



On postman guide build manual

---

## 🛠 Manual Postman Setup (Step-by-Step)

### 1. Create a New Collection

1. Open Postman and click **New** or the **+** icon in the sidebar.
2. Select **Collection** and name it `Flutter Todo API`.

### 2. Configure the Registration (POST)

* **Method:** Change `GET` to `POST`.
* **URL:** `http://localhost:3000/users`
* **Headers:**
* Key: `Content-Type` | Value: `application/json`


* **Body:**
1. Click the **Body** tab.
2. Select **raw**.
3. Change "Text" to **JSON** in the dropdown.
4. Paste this:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Raksa"
}

```





---

### 3. Configure Login (GET with Query Params)

* **Method:** `GET`
* **URL:** `http://localhost:3000/users`
* **Params:**
1. In the **Params** tab, add the following:
* Key: `email` | Value: `user@example.com`
* Key: `password` | Value: `password123`



---

### 4. Create Todo Operations (CRUD)

| Action | Method | URL | Notes |
| --- | --- | --- | --- |
| **Get All** | `GET` | `http://localhost:3000/todos` | No body needed. |
| **Add New** | `POST` | `http://localhost:3000/todos` | Same Body setup as "Register". |
| **Update** | `PUT` | `http://localhost:3000/todos/1` | Change `1` to the ID of your task. |
| **Delete** | `DELETE` | `http://localhost:3000/todos/1` | No body needed. |