# Agora Chat Setup Guide for SilverCart

## Overview
Agora Chat SDK được tích hợp vào SilverCart để cung cấp tính năng **channel chat với consultant**, thay thế cho Agora RTM SDK. 

**Đặc điểm chính:**
- ✅ Chat dạng **channel/group** (không phải 1-1)
- ✅ Users chat với consultants trong support channel
- ✅ Nhiều users có thể chat cùng lúc trong 1 channel
- ✅ Consultants có thể monitor và respond cho nhiều users

## Configuration

### 1. App Key và Channel Name
- **App Key**: `d37efc8cf7624babaf1a8c9f79e5ed04#silvercart`
- **Support Channel**: `support_general`

### 2. Dependencies
```yaml
dependencies:
  agora_chat_sdk: ^1.3.1  # Agora Chat SDK for real-time messaging
  agora_rtc_engine: ^6.5.2
```

### 3. Android Configuration
Tương tự như RTM SDK, cần cấu hình permissions và minSdk.

## Architecture

### Service Layer
- `AgoraChatService`: Service chính xử lý các thao tác Chat
- Singleton pattern với dependency injection
- Xử lý kết nối, xác thực, và messaging

### Event Handling
- Connection state changes
- Message reception
- Member join/leave events
- Token expiration

### Group Management
- Support group: `support_general`
- Dynamic group creation
- Member management

## Usage

### 1. Initialize Service
```dart
final chatService = getIt<AgoraChatService>();
final initialized = await chatService.initialize();
```

### 2. Login User
```dart
final token = chatService.generateDevToken(userId);
final loggedIn = await chatService.loginWithToken(userId, token);
```

### 3. Join Support Channel
```dart
final joined = await chatService.joinSupportChannel();
```

### 4. Send Messages to Consultant
```dart
final sent = await chatService.sendMessageToSupport('Tôi cần hỗ trợ về sản phẩm!');
```

### 5. Handle Events
```dart
chatService.onMessageReceived = (fromUserId, messageText) {
  // Handle incoming messages từ consultant
};

chatService.onConsultantJoined = (userId) {
  // Handle consultant joining support channel
};

chatService.onConsultantLeft = (userId) {
  // Handle consultant leaving support channel
};
```

## Key Features

### Simplified API
- Đơn giản hóa so với RTM SDK
- Callback rõ ràng và dễ sử dụng
- Xử lý lỗi tốt hơn

### Development Mode
- Sử dụng `simulateSupportAgentJoin()` method
- Tự động tạo token development
- Logging chi tiết

### Production Ready
- Token authentication từ server
- Group management tự động
- Error handling toàn diện

## Error Handling

### Connection States
- `onConnected`: Kết nối thành công
- `onDisconnected`: Mất kết nối
- `onTokenWillExpire`: Token sắp hết hạn
- `onTokenDidExpire`: Token đã hết hạn

### Common Issues
1. **Token Expired**: Implement token refresh mechanism
2. **Network Issues**: Handle reconnection automatically
3. **Permission Denied**: Check Android permissions
4. **App Key Invalid**: Verify App Key configuration

## Security Considerations

### Token Management
- Tokens có thời gian hết hạn
- Implement secure token refresh
- Store tokens securely (không trong code cho production)

### Group Security
- Sử dụng unique group names per session
- Implement user authentication
- Validate message content

## Performance Optimization

### Connection Management
- Reuse Chat client instances
- Handle connection timeouts gracefully
- Efficient event handling

### Message Handling
- Simplified message structure
- Efficient callback system
- Real-time message delivery

## Migration from RTM

### Key Changes
1. **Service Name**: `AgoraRtmService` → `AgoraChatService`
2. **Dependencies**: `agora_rtm` → `agora_chat_sdk`
3. **API**: RTM channels → Chat groups
4. **Events**: Simplified callback structure

### Callback Changes
```dart
// OLD (RTM)
onMessageReceived = (channelName, userId, message) { ... };

// NEW (Chat)
onMessageReceived = (fromUserId, messageText) { ... };
```

### Method Changes
```dart
// OLD (RTM)
await rtmService.joinChannel('support_general');
await rtmService.sendChannelMessage('Hello');

// NEW (Chat)
await chatService.joinGroup('support_general');
await chatService.sendGroupMessage('support_general', 'Hello');
```

## Testing

### Development Mode
- Sử dụng `simulateSupportAgentJoin()` method
- Tự động simulate agent join sau 2 giây
- Gửi welcome message sau 3 giây

### Production Mode
- Remove simulation calls
- Real support agents sẽ join qua Chat groups
- Implement proper agent management system

## Troubleshooting

### Build Issues
1. Clean project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Rebuild injection config: `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Runtime Issues
1. Check network connectivity
2. Verify App Key và Token
3. Check Android permissions
4. Review connection logs

## Future Enhancements

### Planned Features
- File sharing support
- Voice messages
- Typing indicators
- Read receipts
- Message encryption
- Offline message storage

### Scalability
- Multiple support groups
- Agent load balancing
- Message persistence
- Analytics integration
