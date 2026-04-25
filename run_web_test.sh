#!/bin/bash

# Start ChromeDriver in the background
echo "Starting ChromeDriver..."
chromedriver --port=4444 > /dev/null 2>&1 &
CHROME_DRIVER_PID=$!

# Wait for ChromeDriver to initialize
sleep 2

# Run the integration test
echo "Running Integration Tests..."
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/demo_test.dart \
  -d chrome

# Cleanup: Kill ChromeDriver after tests finish
echo "Cleaning up ChromeDriver (PID: $CHROME_DRIVER_PID)..."
kill $CHROME_DRIVER_PID
