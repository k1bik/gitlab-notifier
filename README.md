# GitLab Notifier

A Rails application that integrates GitLab webhooks with Slack notifications to keep teams informed about merge requests and deployment events.

## Features

- 🔔 **Merge Request Notifications**: Get notified when merge requests are labeled
- 🚀 **Deployment Events**: Track deployment status updates
- 👥 **User Mapping**: Map GitLab users to Slack users via email
- 🏷️ **Label Filtering**: Configure which labels trigger notifications
- 💬 **Interactive Messages**: Handle Slack interactive message responses

## API Endpoints

### User Mappings

Map GitLab users to Slack users by email addresses.

```bash
curl -X POST https://your-domain.com/api/user_mappings \
  -H "Content-Type: application/json" \
  -d '{
    "emails": ["user1@example.com", "user2@example.com"]
  }'
```

### Observable Labels

Configure which GitLab labels should trigger notifications.

```bash
curl -X POST https://your-domain.com/api/observable_labels \
  -H "Content-Type: application/json" \
  -d '{
    "labels": ["Need Improvements", "Need QA"]
  }'
```

### Send Messages

Send direct messages to users via Slack.

```bash
curl -X POST https://your-domain.com/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Your merge request needs attention!",
    "email": "user@example.com"
  }'
```

## Webhook Endpoints

- `POST /deployment_events_gitlab_webhook` - GitLab deployment events
- `POST /merge_request_labels_gitlab_webhook` - GitLab merge request label changes
- `POST /interactive_messages_slack_webhook` - Slack interactive message responses
