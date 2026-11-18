# Install NGINX
apt-get update
apt-get install -y nginx

# Configure default website
echo "NGINX running on $(hostname)" > /var/www/html/index.html

# Enable and start NGINX
systemctl enable --now nginx