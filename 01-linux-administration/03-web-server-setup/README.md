# Apache Web Server Installation and Configuration with HTTPS

This lab details the setup of Apache on Ubuntu Server, including system updates, firewall adjustments, virtual host configuration for HTTP and HTTPS, and generation of a self-signed SSL certificate for secure access.

## 1. Update the System
Refresh the package index and upgrade existing packages to ensure compatibility:
```
sudo apt update
sudo apt upgrade -y
```

## 2. Install Apache
Install the Apache web server package:
```
sudo apt install apache2 -y
```

Confirm the service is active:
```
sudo systemctl status apache2
```
Expected: "active (running)" status.

## 3. Configure UFW Firewall
Permit HTTP (port 80) and HTTPS (port 443) traffic:
```
sudo ufw allow 'Apache Full'
sudo ufw enable
sudo ufw status
```
Expected: "Apache Full" listed as ALLOW.

## 4. Create a Test Website
Establish the site directory and assign ownership to the current user:
```
sudo mkdir -p /var/www/mywebsite
sudo chown -R $USER:$USER /var/www/mywebsite
```

Generate a basic index page:
```
echo "<h1>My first website with HTTPS</h1>" > /var/www/mywebsite/index.html
```

Inspect the file:
```
cat /var/www/mywebsite/index.html
```
Expected: The HTML heading displayed.

## 5. Configure Virtual Host for HTTP
Define the virtual host configuration:
```
sudo nano /etc/apache2/sites-available/mywebsite.conf
```

Insert the following content:
```
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName mywebsite.local
    DocumentRoot /var/www/mywebsite
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Activate the site and reload Apache:
```
sudo a2ensite mywebsite.conf
sudo systemctl reload apache2
```

Map the domain locally by editing the hosts file:
```
sudo nano /etc/hosts
```

Append this entry (using the server's IP):
```
192.168.0.150 mywebsite.local
```

Validate HTTP access:
```
curl http://mywebsite.local
```
Expected: The HTML heading returned.

## 6. Enable HTTPS with Self-Signed Certificate
Install OpenSSL for certificate generation:
```
sudo apt install openssl -y
```

Produce the certificate and key (valid for 365 days):
```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/mywebsite.key \
-out /etc/ssl/certs/mywebsite.crt
```

Provide these details during prompts:
- Country Name: VE
- State: Miranda
- Locality: Caracas
- Organization: MyLab
- Organizational Unit: IT
- Common Name: mywebsite.local
- Email Address: admin@example.com

Configure the HTTPS virtual host:
```
sudo nano /etc/apache2/sites-available/mywebsite-ssl.conf
```

Insert the following content:
```
<VirtualHost *:443>
    ServerAdmin admin@example.com
    ServerName mywebsite.local
    DocumentRoot /var/www/mywebsite
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/mywebsite.crt
    SSLCertificateKeyFile /etc/ssl/private/mywebsite.key
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Enable the SSL module and site, then restart Apache:
```
sudo a2enmod ssl
sudo a2ensite mywebsite-ssl.conf
sudo systemctl restart apache2
```

Test HTTPS access (bypassing self-signed certificate validation):
```
curl -k https://mywebsite.local
```
Expected: The HTML heading returned, confirming secure access.

## Summary
- System updated and Apache installed with firewall rules applied.
- HTTP virtual host configured and tested.
- Self-signed SSL certificate generated and HTTPS virtual host enabled.
- Local access verified for both protocols.

This setup provides a functional web server with basic security. For production, replace the self-signed certificate with a CA-issued one.
