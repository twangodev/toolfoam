# Logging Guidelines

Dart's `logging` package defines several logging levels. Below are the guidelines and examples for each level.

### FINEST
**Guideline:** Can use on any continuous user interaction, hovering, every paint cycle, etc.

**Example:**
```dart
logger.finest('User hovered over button with ID: $buttonId');
```

### FINER
**Guideline:** ONLY USER EVENTS excluding ones that are continuously called (i.e., no hovering, but clicks are ok).

**Example:**
```dart
logger.finer('User clicked on button with ID: $buttonId');
```

### FINE
**Guideline:** More high-level user events.

**Example:**
```dart
logger.fine('User completed the signup process.');
```

### CONFIG
**Guideline:** Log configuration details.

**Example:**
```dart
logger.config('Application configuration loaded: $configSettings');
```

### INFO
**Guideline:** General informational messages.

**Example:**
```dart
logger.info('User successfully logged in.');
```

### WARNING
**Guideline:** Potentially harmful situations.

**Example:**
```dart
logger.warning('API call failed, retrying...');
```

### SEVERE
**Guideline:** Serious errors that require immediate attention.

**Example:**
```dart
logger.severe('Database connection failed: $error');
```

### SHOUT
**Guideline:** Extremely severe issues that may cause the application to abort.

**Example:**
```dart
logger.shout('Out of memory error: system shutting down!');
```