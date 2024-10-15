resource "aws_instance" "wordpress-instance" {
  ami                    = "ami-08d8ac128e0a1b91c"  # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  availability_zone      = "us-west-2a"
  key_name               = "keyss"
  subnet_id              = aws_subnet.private1.id
  security_groups        = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = false
  
  # User data script to install MySQL
   user_data = <<-EOF
                  #!/bin/bash
                  sudo yum update -y
                  sudo yum install php php-mysqlnd php-fpm php-json -y
                  sudo yum install -y httpd
                  sudo systemctl start httpd
                  sudo systemctl enable httpd
                  touch /etc/yum.repos.d/MariaDB.repo
                   echo "[mariadb]" >> /etc/yum.repos.d/MariaDB.repo
                   echo "name=MariaDB" >>  /etc/yum.repos.d/MariaDB.repo
                   echo "baseurl=https://mirror.mariadb.org/yum/11.6/rhel/9Server/x86_64/" >> /etc/yum.repos.d/MariaDB.repo
                   echo "gpgkey=https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB" >>  /etc/yum.repos.d/MariaDB.repo
                   echo "gpgcheck=1" >>  /etc/yum.repos.d/MariaDB.repo
                   yum install -y mariadb-server
                  cd /var/www/html
                  wget https://wordpress.org/latest.tar.gz
                  sudo tar -xzf latest.tar.gz
                  cp -r wordpress/* /var/www/html/
                  cp ./wp-config-sample.php ./wp-config.php 
                  sed -i "s/'database_name_here'/'mydb'/g" wp-config.php 
                  sed -i "s/'username_here'/'admin'/g" wp-config.php 
                  sed -i "s/'password_here'/'admin!123'/g" wp-config.php
                  sed -i 's/localhost/${aws_db_instance.mysql.address}/' /var/www/html/wp-config.php
                  usermod -a -G apache ec2-user 
                  chown -R ec2-user:apache /var/www 
                  chmod 2775 /var/www 
                  find /var/www -type d -exec chmod 2775 {} \; 
                  find /var/www -type f -exec chmod 0664 {} \; 
                  systemctl restart httpd
                  EOF

  tags = {
    Name = "WordPress-Instance"
  }
}