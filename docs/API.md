# API Documentation

## Overview

The Yuninet Platform backend exposes RESTful APIs to support app functionality including authentication, data retrieval, and real-time updates.

## Base URL

https://api.yuninet.example.com/v1

## Authentication

- Uses JWT tokens.
- Obtain token via /auth/login endpoint.

## Endpoints

| Endpoint           | Method | Description                          |
|--------------------|--------|------------------------------------|
| /auth/login      | POST   | Authenticate user and return token |
| /users/{id}      | GET    | Get user profile information       |
| /posts           | GET    | Retrieve posts feed                 |
| /notifications   | GET    | Get user notifications             |

## Error Handling

- Uses standard HTTP status codes.
- Error responses include JSON with message field.

