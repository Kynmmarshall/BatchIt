# BatchIt VPS + Jenkins Setup Guide

This guide is for Ubuntu 22.04/24.04 on your VPS.

## 1. Install base packages

~~~bash
sudo apt update
sudo apt install -y openjdk-17-jdk git curl unzip zip rsync nginx jq
~~~

## 2. Install Jenkins

~~~bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins --no-pager
~~~

Get initial admin password:

~~~bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
~~~

## 3. Install Flutter SDK

~~~bash
sudo git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
sudo chown -R jenkins:jenkins /opt/flutter
sudo -u jenkins /opt/flutter/bin/flutter --version
~~~

## 4. Install Android command line SDK tools

~~~bash
sudo mkdir -p /usr/lib/android-sdk/cmdline-tools
cd /tmp
curl -LO https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
sudo unzip -q commandlinetools-linux-11076708_latest.zip -d /usr/lib/android-sdk/cmdline-tools
sudo mv /usr/lib/android-sdk/cmdline-tools/cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest
sudo chown -R jenkins:jenkins /usr/lib/android-sdk
~~~

Install required Android packages and accept licenses:

~~~bash
sudo -u jenkins bash -lc '
export ANDROID_HOME=/usr/lib/android-sdk
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;35.0.0"
'
~~~

## 5. Prepare deployment directory

~~~bash
sudo mkdir -p /var/www/batchit
sudo chown -R jenkins:www-data /var/www/batchit
sudo chmod -R 775 /var/www/batchit
sudo find /var/www/batchit -type d -exec chmod g+s {} \;
~~~

## 6. Configure Nginx site

Copy the included config:

~~~bash
sudo cp devops/nginx-batchit.conf /etc/nginx/sites-available/batchit
sudo ln -sf /etc/nginx/sites-available/batchit /etc/nginx/sites-enabled/batchit
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
~~~

If UFW is enabled:

~~~bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
~~~

## 7. Create Jenkins pipeline job

1. In Jenkins: New Item -> Pipeline -> name it batchit-cicd.
2. In Pipeline section set:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: your GitHub repository
   - Branch: */main
   - Script Path: Jenkinsfile
3. Save and click Build Now once.

## 8. Add webhook in GitHub

1. Repository -> Settings -> Webhooks -> Add webhook.
2. Payload URL: http://YOUR_VPS_IP:8080/github-webhook/
3. Content type: application/json
4. Select Just the push event.
5. Save.

## 9. Jenkins plugins you should install

- Pipeline
- Git
- GitHub Integration
- Warnings Next Generation (optional)
- JUnit (optional)

## 10. Optional domain + HTTPS

After DNS points to VPS:

~~~bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
~~~

## Important notes

- Your Jenkinsfile assumes Flutter is at /opt/flutter and deployment target is /var/www/batchit.
- Keep Android signing keys in Jenkins Credentials, not in the repository.
- If your repository is private, add a GitHub token credential in Jenkins and attach it to the pipeline SCM config.
