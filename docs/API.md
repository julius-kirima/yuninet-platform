API

Overview

The backend API provides endpoints for authentication, data retrieval, and updates. It is built using Node.js/Express or Firebase Functions, depending on deployment preferences.

Endpoints

POST /auth/login — Authenticate users

POST /auth/register — Register new users

GET /posts — Retrieve posts feed

POST /posts — Create new post

GET /users/{id} — Retrieve user profile information

Authentication

Uses JWT tokens for session management. All protected endpoints require a valid token in the Authorization header.

Error Handling

Standard HTTP status codes are used to indicate success or failure. Error responses include descriptive messages.

