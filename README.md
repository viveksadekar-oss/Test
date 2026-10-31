# Week 1: AWS Ubuntu EC2 DevOps CI/CD + Git Practical

This is a **training-only** Jenkins pipeline + static HTML site with Python stdlib tests. Designed for Ubuntu Server 22.04 / 24.04 LTS running on AWS EC2 (Ubuntu 24.04 reference).

## Files

- `site/index.html` — minimal demo application
- `tests/test_site.py` — two automated Python tests
- `Jenkinsfile` — checkout → test → build → archive → deploy → verify
- `setup_ubuntu_ec2.sh` — optional instructor EC2 setup script

## Preflight

Use a *dedicated training EC2 instance* with at least 4 GB RAM (e.g. t3.medium), adequate storage, internet egress, an appropriate IAM/security setup and inbound ports 22, 80, 8080 restricted to your approved public IP. A public IPv4 address incurs AWS costs. For SSH, the Ubuntu AMI's default username is `ubuntu`.

### Install software on Ubuntu manually (or use setup script)

```bash
sudo apt update
sudo apt install -y git python3 zip unzip curl wget ca-certificates fontconfig nginx openjdk-21-jre
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo 'deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' \
 | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl enable --now nginx
sudo install -d -o jenkins -g jenkins -m 755 /var/www/html/devops-demo
```

The instructor should complete Jenkins' first-run wizard at `http://EC2_PUBLIC_IP:8080`, install suggested plugins (including Pipeline and Git), and ensure an executor is available. In this single-VM training lab you can enable **one executor on Built-In Node** if there are no dedicated agents; **do not use this pattern in production**. Retrieve initial unlock token:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Session 1: Git and tests (on the Ubuntu VM)

Upload this ZIP to the VM using SCP (from your laptop) and unzip under your Ubuntu user home. Then:

```bash
cd ~/devops-fasttrack-aws
git config --global user.name 'Training User'
git config --global user.email 'you@example.com'
git init -b main
git add .
git commit -m 'Initial demo app'
python3 -m unittest discover -s tests -v
```

Create an **empty, public demo** GitHub repository `devops-fasttrack-aws` (no README), then:

```bash
git remote add origin https://github.com/YOUR_USERNAME/devops-fasttrack-aws.git
git push -u origin main
git switch -c feature/update-homepage
sed -i 's/Version 1/Version 2/' site/index.html
git add site/index.html
git commit -m 'Update homepage to v2'
git push -u origin feature/update-homepage
```

Use GitHub's website to create a pull request and merge the feature branch into `main` (only for the demo). Then:

```bash
git switch main
git pull origin main
python3 -m unittest discover -s tests -v
```

GitHub HTTPS push authentication requires a suitable access token rather than your GitHub account password. Do not embed tokens in code or commands.

## Session 2: Jenkins pipeline (on same Ubuntu VM)

Create **New Item > Pipeline**. In Pipeline select **Pipeline script from SCM**, SCM **Git**, URL `https://github.com/YOUR_USERNAME/devops-fasttrack-aws.git`, Branch `*/main`, Script path `Jenkinsfile`, save and click **Build Now**.

Expected stages: `Checkout > Test > Build > Archive Artifact > Deploy > Verify`.

After success, inspect build artifacts `dist/webapp.zip` and open:

`http://EC2_PUBLIC_IP/devops-demo/`

**Ubuntu detail:** Nginx normally serves `/var/www/html`, therefore the target is `/var/www/html/devops-demo`. Creating the directory with `jenkins` ownership avoids dangerous broad filesystem permissions or granting `sudo` to Jenkins.

## Troubleshooting

```bash
java -version
sudo systemctl status jenkins --no-pager
sudo journalctl -u jenkins -n 50 --no-pager
sudo systemctl status nginx --no-pager
sudo nginx -t
sudo ss -lntp | grep -E ':(80|8080)'
ls -ld /var/www/html/devops-demo
curl -I http://127.0.0.1/devops-demo/
```

If a job is queued forever, check available executors/agents. If `unzip` returns `Permission denied`, check ownership with `ls -ld /var/www/html/devops-demo`. If Jenkins can't be reached but localhost works, review the EC2 security group and firewall.

## Cleanup and safety

This simple HTTP-only Jenkins/controller build lab is **not production architecture**. Keep demo repository free of secrets and real workloads. Restrict access; run builds on separate agents and use TLS in production. Stop/terminate the EC2 instance and clean up billable volumes/public IPv4 allocations after training.
