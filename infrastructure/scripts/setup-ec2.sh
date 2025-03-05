#!/bin/bash

# Update system
echo "Updating system..."
sudo yum update -y

# Install Java 17
echo "Installing Java 17..."
sudo yum install -y java-17-amazon-corretto-devel

# Install Tomcat
echo "Installing Tomcat..."
sudo yum install -y tomcat

# Configure Tomcat
echo "Configuring Tomcat..."
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Configure firewall
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /usr/share/tomcat/webapps
sudo chown -R tomcat:tomcat /usr/share/tomcat/webapps

# Install monitoring tools
echo "Installing monitoring tools..."
sudo yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
echo "Configuring CloudWatch agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

# Start CloudWatch agent
echo "Starting CloudWatch agent..."
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

echo "Setup completed successfully!" 