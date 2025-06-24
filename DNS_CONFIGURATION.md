# 🌐 DNS & Domain Configuration for Kirvano

## ✅ Current Status
- **Railway Deployment**: Active at `https://kirvano-web-production.up.railway.app`
- **Custom Domains**: Configured for `kirvano.com` and `app.kirvano.com`
- **SSL**: Automatically managed by Railway
- **Project**: balanced-manifestation (production environment)

## 🎯 Domain Configuration

### Primary Domains
- **Main Domain**: `kirvano.com` → Production application
- **App Subdomain**: `app.kirvano.com` → Alternative access point
- **Railway Default**: `kirvano-web-production.up.railway.app` → Fallback URL

## 📋 DNS Records Required

Add the following DNS records to your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.):

### For kirvano.com (Root Domain)
```
Type: CNAME
Name: @
Value: zvlylqeh.up.railway.app
TTL: 3600 (1 hour)
```

### For app.kirvano.com (Subdomain)
```
Type: CNAME
Name: app
Value: xhf6sswf.up.railway.app
TTL: 3600 (1 hour)
```

### Additional Recommended DNS Records

#### Email Configuration (MX Records)
```
Type: MX
Name: @
Value: mx1.kirvano.com
Priority: 10
TTL: 3600
```

#### Email Security (SPF, DKIM, DMARC)
```
Type: TXT
Name: @
Value: "v=spf1 include:_spf.google.com ~all"
TTL: 3600

Type: TXT
Name: _dmarc
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@kirvano.com"  
TTL: 3600
```

#### Security Headers
```
Type: TXT
Name: @
Value: "v=spf1 include:railway.app ~all"
TTL: 3600
```

## 🔒 SSL Certificate Configuration

### Automatic SSL via Railway
- **Certificate Authority**: Let's Encrypt (managed by Railway)
- **Auto-Renewal**: Yes, handled automatically
- **HTTPS Redirect**: Configured automatically
- **TLS Version**: 1.2+ supported
- **HSTS**: Enabled by default

### SSL Verification
After DNS propagation (24-72 hours), verify SSL:
```bash
# Check SSL certificate
openssl s_client -connect kirvano.com:443 -servername kirvano.com

# Check SSL grade
curl -s "https://api.ssllabs.com/api/v3/analyze?host=kirvano.com"
```

## 🚀 Environment Variables for Production

Update these environment variables in Railway:

```bash
# Domain Configuration
FRONTEND_URL=https://kirvano.com
BACKEND_URL=https://kirvano.com

# Force SSL in production
FORCE_SSL=true

# Asset CDN (optional)
ASSET_CDN_HOST=https://cdn.kirvano.com

# CORS Configuration
ENABLE_API_CORS=true

# Email Configuration
MAILER_SENDER_EMAIL=Kirvano <contato@kirvano.com>
SMTP_DOMAIN=kirvano.com
```

## 🔄 Subdomain Routing Options

### Potential Subdomains
- `api.kirvano.com` → API endpoints only
- `admin.kirvano.com` → Admin panel
- `docs.kirvano.com` → Documentation
- `status.kirvano.com` → Status page
- `cdn.kirvano.com` → Static assets

### Adding Additional Subdomains
```bash
# Add API subdomain
railway domain api.kirvano.com

# Add admin subdomain  
railway domain admin.kirvano.com
```

## 🔍 DNS Propagation Monitoring

### Check DNS Propagation
```bash
# Check global DNS propagation
dig kirvano.com @8.8.8.8
dig kirvano.com @1.1.1.1

# Check specific record types
dig CNAME app.kirvano.com
dig MX kirvano.com
dig TXT kirvano.com
```

### Online Tools
- **DNS Checker**: https://dnschecker.org/
- **What's My DNS**: https://whatsmydns.net/
- **DNS Propagation**: https://dnspropagation.io/

## 🛡️ Security Configuration

### Content Security Policy (CSP)
Update `/config/initializers/content_security_policy.rb`:
```ruby
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data, 'https://fonts.gstatic.com'
  policy.img_src     :self, :https, :data, 'https://cdn.kirvano.com'
  policy.object_src  :none
  policy.script_src  :self, :https, 'https://js.stripe.com'
  policy.style_src   :self, :https, :unsafe_inline, 'https://fonts.googleapis.com'
  policy.connect_src :self, :https, 'wss://kirvano.com'
end
```

### CORS Configuration
Already configured in `/config/initializers/cors.rb` for production use.

### Security Headers
Add to production configuration:
```ruby
# config/environments/production.rb
config.force_ssl = true
config.ssl_options = { hsts: { subdomains: true } }
```

## 📊 Domain Monitoring & Testing

### Uptime Monitoring
- **UptimeRobot**: Monitor `https://kirvano.com`
- **Pingdom**: Performance monitoring
- **StatusCake**: Global monitoring

### Performance Testing
```bash
# Test page load speed
curl -w "@curl-format.txt" -o /dev/null -s "https://kirvano.com"

# Test API endpoints
curl -X GET "https://kirvano.com/api/v1/status" \
  -H "Accept: application/json"
```

## 🚨 Troubleshooting

### Common Issues

#### DNS Not Propagating
- Wait 24-72 hours for full propagation
- Clear local DNS cache: `sudo dscacheutil -flushcache` (macOS)
- Check with multiple DNS servers

#### SSL Certificate Issues
- Ensure DNS is properly configured first
- Railway auto-generates certificates after DNS verification
- Check Railway logs for SSL provisioning errors

#### CORS Errors
- Verify `FRONTEND_URL` environment variable
- Check CORS configuration in `/config/initializers/cors.rb`
- Ensure API endpoints allow cross-origin requests

#### Email Not Working
- Configure MX records properly
- Set up SPF, DKIM, and DMARC records
- Test email delivery with Railway logs

### Railway Commands
```bash
# Check domain status
railway domain

# View logs
railway logs --follow

# Check environment variables
railway variables

# Deploy latest changes
railway deploy
```

## 📋 Post-Configuration Checklist

- [ ] DNS records added to domain registrar
- [ ] SSL certificate provisioned (24-72 hours)
- [ ] Environment variables updated
- [ ] CORS configuration verified
- [ ] Email configuration tested
- [ ] Performance monitoring setup
- [ ] Security headers configured
- [ ] Backup Railway URL documented

## 🎉 Final Verification

Once DNS propagation is complete:

1. **Access Application**: `https://kirvano.com`
2. **Verify SSL**: Check for green lock icon
3. **Test API**: Ensure all endpoints work
4. **Check Email**: Test contact forms
5. **Monitor Performance**: Set up alerts

---

**Note**: DNS changes can take up to 72 hours to propagate worldwide. During this time, the application remains accessible via the Railway default URL: `https://kirvano-web-production.up.railway.app`