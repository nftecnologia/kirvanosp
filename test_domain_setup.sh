#!/bin/bash

# 🌐 Domain Testing Script for Kirvano
# This script tests the domain configuration and SSL setup

echo "🌐 Testing Kirvano Domain Configuration"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Domain configuration
MAIN_DOMAIN="kirvano.com"
APP_DOMAIN="app.kirvano.com"
RAILWAY_DOMAIN="kirvano-web-production.up.railway.app"

echo -e "${BLUE}Testing DNS Resolution...${NC}"
echo "----------------------------------------"

# Test DNS resolution
echo -n "Testing $MAIN_DOMAIN: "
if nslookup $MAIN_DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}✓ DNS Resolved${NC}"
else
    echo -e "${RED}✗ DNS Not Resolved${NC}"
fi

echo -n "Testing $APP_DOMAIN: "
if nslookup $APP_DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}✓ DNS Resolved${NC}"
else
    echo -e "${RED}✗ DNS Not Resolved${NC}"
fi

echo -n "Testing $RAILWAY_DOMAIN: "
if nslookup $RAILWAY_DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}✓ DNS Resolved${NC}"
else
    echo -e "${RED}✗ DNS Not Resolved${NC}"
fi

echo
echo -e "${BLUE}Testing HTTP/HTTPS Connectivity...${NC}"
echo "----------------------------------------"

# Test HTTPS connectivity
test_https() {
    local domain=$1
    echo -n "Testing HTTPS on $domain: "
    
    if curl -s --max-time 10 -I "https://$domain" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HTTPS Working${NC}"
        
        # Test SSL certificate
        echo -n "  SSL Certificate: "
        if echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Valid Certificate${NC}"
        else
            echo -e "${YELLOW}⚠ Certificate Issue${NC}"
        fi
        
        # Test security headers
        echo -n "  Security Headers: "
        headers=$(curl -s --max-time 10 -I "https://$domain" 2>/dev/null)
        if echo "$headers" | grep -i "strict-transport-security" > /dev/null; then
            echo -e "${GREEN}✓ HSTS Enabled${NC}"
        else
            echo -e "${YELLOW}⚠ HSTS Missing${NC}"
        fi
        
    else
        echo -e "${RED}✗ HTTPS Failed${NC}"
    fi
}

# Test each domain
test_https $MAIN_DOMAIN
test_https $APP_DOMAIN
test_https $RAILWAY_DOMAIN

echo
echo -e "${BLUE}Testing API Endpoints...${NC}"
echo "----------------------------------------"

# Test API endpoints
test_api() {
    local domain=$1
    echo -n "Testing API on $domain: "
    
    if curl -s --max-time 10 "https://$domain/api/v1/status" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API Accessible${NC}"
    else
        echo -e "${YELLOW}⚠ API Test Failed (may be normal if endpoint doesn't exist)${NC}"
    fi
}

test_api $MAIN_DOMAIN
test_api $APP_DOMAIN
test_api $RAILWAY_DOMAIN

echo
echo -e "${BLUE}DNS Propagation Check...${NC}"
echo "----------------------------------------"

# Check DNS propagation with multiple servers
check_dns_propagation() {
    local domain=$1
    echo "Checking $domain propagation:"
    
    dns_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9")
    
    for server in "${dns_servers[@]}"; do
        echo -n "  $server: "
        if dig @$server +short $domain > /dev/null 2>&1; then
            result=$(dig @$server +short $domain | head -n1)
            if [ -n "$result" ]; then
                echo -e "${GREEN}✓ $result${NC}"
            else
                echo -e "${RED}✗ No result${NC}"
            fi
        else
            echo -e "${RED}✗ Query failed${NC}"
        fi
    done
}

check_dns_propagation $MAIN_DOMAIN
echo
check_dns_propagation $APP_DOMAIN

echo
echo -e "${BLUE}Railway Service Status...${NC}"
echo "----------------------------------------"

# Check Railway status
echo "Railway Domain Configuration:"
railway domain 2>/dev/null || echo "Railway CLI not available or not logged in"

echo
echo -e "${BLUE}Summary${NC}"
echo "----------------------------------------"
echo "Main Domain: https://$MAIN_DOMAIN"
echo "App Domain: https://$APP_DOMAIN"
echo "Railway Domain: https://$RAILWAY_DOMAIN"
echo
echo "Next Steps:"
echo "1. If DNS is not resolved, add CNAME records to your domain registrar"
echo "2. Wait 24-72 hours for DNS propagation"
echo "3. SSL certificates will be automatically provisioned by Railway"
echo "4. Monitor application logs for any issues"
echo
echo "DNS Records to Add:"
echo "Type: CNAME, Name: @, Value: zvlylqeh.up.railway.app"
echo "Type: CNAME, Name: app, Value: xhf6sswf.up.railway.app"