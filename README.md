# GitLab Notifier

A Rails application that integrates GitLab webhooks with Slack notifications to keep teams informed about merge requests and deployment events.

## Features

- 🔔 **Merge Request Notifications**: Get notified when merge requests are labeled
- 🚀 **Deployment Events**: Track deployment status updates
- 👥 **User Mapping**: Map GitLab users to Slack users via email
- 🏷️ **Label Filtering**: Configure which labels trigger notifications
- 🥷 **Estimation items**: What the team members need to evaluate
- 💬 **Interactive Messages**: Handle Slack interactive message responses
- ✉️ **Temporary Deployment Notification Targets**: Define temporary destinations for deployment notifications — messages can be redirected to a specific Slack channel or user for a limited time

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

### Estimation Items

Create estimation items for collecting user estimates on specific references

```bash
curl -X POST https://your-domain.com/api/estimation_items \
  -H "Content-Type: application/json" \
  -d '{
    "reference_url": "https://some-task",
    "emails": ["user1@example.com", "user2@example.com"]
  }'
```

Send results to users

```bash
curl -X GET https://your-domain.com/api/estimation_items/:id/send_results \
  -H "Content-Type: application/json"
```

### Temporary Deployment Notification Targets

Create Temporary Deployment Notification Targets (user_email or slack_channel_id)

```bash
curl -X POST https://your-domain.com/api/temporary_deployment_notification_targets \
  -H "Content-Type: application/json" \
  -d '{
    "environment": "dev",
    "user_email": "user1@example.com",
    "slack_channel_id: "XYZ123"
  }'
```

## Webhook Endpoints

- `POST /deployment_events_gitlab_webhook` - GitLab deployment events
- `POST /merge_request_events_gitlab_webhook` - GitLab merge request changes
- `POST /interactive_messages_slack_webhook` - Slack interactive message responses
