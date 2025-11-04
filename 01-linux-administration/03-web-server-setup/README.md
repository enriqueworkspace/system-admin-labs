This lab demonstrates the installation and configuration of an Apache web server on Ubuntu Server with HTTPS enabled using a self-signed certificate. It covers:

- Updating the system
- Installing Apache
- Configuring UFW firewall
- Creating a test website
- Setting up Virtual Hosts for HTTP and HTTPS
- Generating a self-signed SSL certificate
- Testing site access

---

## Step 1: Update the system

Update the package list and upgrade installed packages:

```
sudo apt update
sudo apt upgrade -y
```
Step 2: Install Apache

Install Apache web server:
```
sudo apt install apache2 -y
```
Verify Apache is running:
```
sudo systemctl status apache2
```
Step 3: Configure UFW firewall

Allow HTTP and HTTPS traffic:
```
sudo ufw allow 'Apache Full'
sudo ufw enable
sudo ufw status
```
Step 4: Create a test website

Create the website directory and set ownership:
```
sudo mkdir -p /var/www/mywebsite
sudo chown -R $USER:$USER /var/www/mywebsite
```
Create a simple index.html page:
```
echo "<h1>My first website with HTTPS</h1>" > /var/www/mywebsite/index.html
```
Verify content:
```
cat /var/www/mywebsite/index.html
```
Step 5: Configure Virtual Host for HTTP

Create a configuration file:
```
sudo nano /etc/apache2/sites-available/mywebsite.conf
```
Content:
```
<VirtualHost *:80>
    ServerAdmin admin@example.com
    ServerName mywebsite.local
    DocumentRoot /var/www/mywebsite
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Enable the site and reload Apache:
```
sudo a2ensite mywebsite.conf
sudo systemctl reload apache2
```
Add a hosts entry to resolve mywebsite.local (inside the VM):
```
sudo nano /etc/hosts
```
Add:
```
192.168.0.150 mywebsite.local
```
Test access:
```
curl http://mywebsite.local
```
Step 6: Enable HTTPS with self-signed certificate

Install OpenSSL (if not already installed):
```
sudo apt install openssl -y
```
Generate certificate and private key:
```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/mywebsite.key \
-out /etc/ssl/certs/mywebsite.crt
```
When prompted, use:
```
Country Name: VE
State: Miranda
Locality: Caracas
Organization: MyLab
Organizational Unit: IT
Common Name: mywebsite.local
Email Address: admin@example.com
```
Create HTTPS Virtual Host:
```
sudo nano /etc/apache2/sites-available/mywebsite-ssl.conf
```
Content:
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
Enable SSL and the site:
```
sudo a2enmod ssl
sudo a2ensite mywebsite-ssl.conf
sudo systemctl restart apache2
```
Test HTTPS access (ignore self-signed warning):
```
curl -k https://mywebsite.local
```