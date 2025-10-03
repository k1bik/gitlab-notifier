curl -X POST https://e1a971713aaf.ngrok-free.app/api/user_mappings \
  -H "Content-Type: application/json" \
  -d '{"emails": ["user1@example.com", "user2@example.com"]}'

curl -X POST https://885a0dda3db1.ngrok-free.app/api/observable_labels \
  -H "Content-Type: application/json" \
  -d '{"labels": ["Need Improvements", "Need QA"]}'

curl -X DELETE https://885a0dda3db1.ngrok-free.app/api/observable_labels/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Need QA"}'

curl -X POST https://885a0dda3db1.ngrok-free.app/api/messages \
  -H "Content-Type: application/json" \
  -d '{"message": "text", "email": "user@example.com"}'
