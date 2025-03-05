#!/bin/bash

# Configuration
APP_NAME="yourmedia-app"
VERSION="0.0.1-SNAPSHOT"
EC2_HOST="ec2-user@${EC2_PUBLIC_IP}"  # Will be replaced with actual IP
REMOTE_DIR="/usr/share/tomcat/webapps"
LOCAL_BUILD_DIR="target"
WAR_FILE="${APP_NAME}-${VERSION}.war"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 Starting deployment process..."

# Clean and build the application
echo "📦 Building application..."
if mvn clean package -DskipTests; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
if mvn test; then
    echo -e "${GREEN}✅ Tests passed${NC}"
else
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
fi

# Check if WAR file exists
if [ ! -f "${LOCAL_BUILD_DIR}/${WAR_FILE}" ]; then
    echo -e "${RED}❌ WAR file not found${NC}"
    exit 1
fi

# Deploy to EC2
echo "🚀 Deploying to EC2..."
if scp -i ~/.ssh/your-key.pem "${LOCAL_BUILD_DIR}/${WAR_FILE}" "${EC2_HOST}:${REMOTE_DIR}/${APP_NAME}.war"; then
    echo -e "${GREEN}✅ Deployment successful${NC}"
    
    # Restart Tomcat
    echo "🔄 Restarting Tomcat..."
    ssh -i ~/.ssh/your-key.pem "${EC2_HOST}" "sudo systemctl restart tomcat"
    
    # Wait for Tomcat to start
    echo "⏳ Waiting for application to start..."
    sleep 10
    
    # Check application health
    if curl -s "http://${EC2_PUBLIC_IP}:8080/${APP_NAME}/health" | grep -q "healthy"; then
        echo -e "${GREEN}✅ Application is healthy${NC}"
    else
        echo -e "${RED}❌ Application health check failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}" 