# Agora RTM Setup Guide for SilverCart

## Overview
Agora RTM (Real-Time Messaging) is integrated into SilverCart to provide real-time chat functionality for customer support.

## Configuration

### 1. App ID and Token
- **App ID**: `d37efc8cf7624babaf1a8c9f79e5ed04`
- **Token**: `006d37efc8cf7624babaf1a8c9f79e5ed04IAATtLHJhl9aqfElhxfW9RtwiBWBrXSbwasJgNsrHFwxNMJBJDUAAAAAIgBP0r6D8rmnaAQAAQCCdqZoAgCCdqZoAwCCdqZoBACCdqZo`

### 2. Dependencies
```yaml
dependencies:
  agora_rtm: ^2.2.2
  agora_rtc_engine: ^6.5.2
```

### 3. Android Configuration

#### build.gradle.kts
```kotlin
android {
    defaultConfig {
        minSdk = 21 // Agora RTM requires minSdk 19+
        // ... other config
    }
}
```

#### AndroidManifest.xml
```xml
<!-- Agora RTM Permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

## Architecture

### Service Layer
- `AgoraRtmService`: Main service handling RTM operations
- Singleton pattern with dependency injection
- Handles connection, authentication, and messaging

### Event Handling
- Connection state changes
- Message reception
- Member join/leave events
- Token expiration

### Channel Management
- Support channel: `support_general`
- Dynamic channel creation
- Member management

## Usage

### 1. Initialize Service
```dart
final rtmService = getIt<AgoraRtmService>();
final initialized = await rtmService.initialize();
```

### 2. Login User
```dart
final loggedIn = await rtmService.login(userId);
```

### 3. Join Channel
```dart
final joined = await rtmService.joinChannel('support_general');
```

### 4. Send Messages
```dart
final sent = await rtmService.sendChannelMessage('Hello!');
```

### 5. Handle Events
```dart
rtmService.onMessageReceived = (channelName, userId, message) {
  // Handle incoming messages
};

rtmService.onMemberJoined = (channelName, userId) {
  // Handle member joining
};
```

## Testing

### Development Mode
- Uses `simulateSupportAgentJoin()` method
- Simulates support agent joining after 2 seconds
- Sends welcome message after 3 seconds

### Production Mode
- Remove simulation calls
- Real support agents will join through RTM channels
- Implement proper agent management system

## Error Handling

### Connection States
- `connecting`: Initial connection attempt
- `connected`: Successfully connected
- `disconnected`: Connection lost
- `reconnecting`: Attempting to reconnect
- `aborted`: Connection aborted
- `failure`: Connection failed

### Common Issues
1. **Token Expired**: Implement token refresh mechanism
2. **Network Issues**: Handle reconnection automatically
3. **Permission Denied**: Check Android permissions
4. **App ID Invalid**: Verify App ID configuration

## Security Considerations

### Token Management
- Tokens have expiration time
- Implement secure token refresh
- Store tokens securely (not in code for production)

### Channel Security
- Use unique channel names per user/session
- Implement user authentication
- Validate message content

## Performance Optimization

### Connection Management
- Reuse RTM client instances
- Implement connection pooling for multiple users
- Handle connection timeouts gracefully

### Message Handling
- Implement message queuing for offline scenarios
- Use efficient message serialization
- Implement message delivery confirmation

## Monitoring and Logging

### Log Levels
- Connection state changes
- Message send/receive events
- Error conditions
- Performance metrics

### Metrics to Track
- Connection success rate
- Message delivery latency
- Error frequency
- User engagement

## Troubleshooting

### Build Issues
1. Clean project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Check minSdk version
4. Verify Android permissions

### Runtime Issues
1. Check network connectivity
2. Verify App ID and Token
3. Check Android permissions
4. Review connection logs

### Common Errors
- `AgoraRtmClient.createInstance failed`: Check App ID
- `Login failed`: Check Token validity
- `Channel join failed`: Check network and permissions
- `Message send failed`: Check channel connection

## Future Enhancements

### Planned Features
- File sharing support
- Voice messages
- Typing indicators
- Read receipts
- Message encryption
- Offline message storage

### Scalability
- Multiple support channels
- Agent load balancing
- Message persistence
- Analytics integration
