<p align="center"> <img src="https://img.shields.io/badge/Version-3.0-blue" alt="Version"> <img src="https://img.shields.io/badge/License-MIT-green" alt="License"> <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-lightgrey" alt="Platform"> <img src="https://img.shields.io/badge/Purpose-Education%20Only-red" alt="Purpose"> </p>
📖 Overview
LxPhisher is a sophisticated phishing simulation toolkit designed for educational purposes and security awareness training. It provides a comprehensive platform for demonstrating phishing techniques, testing organizational resilience, and educating users about online security threats.

⚠️ ETHICAL WARNING & LEGAL DISCLAIMER
THIS TOOL IS FOR EDUCATIONAL AND SECURITY AWARENESS PURPOSES ONLY

🚫 ILLEGAL WITHOUT PERMISSION: Unauthorized use of this tool is strictly prohibited

✅ LEGAL WITH CONSENT: Only use on systems you own or have explicit written permission to test

🔒 RESPONSIBLE USAGE: Always obtain proper authorization before conducting any tests

📝 DOCUMENT PERMISSION: Maintain records of authorization for all testing activities

🗑️ SECURE DISPOSAL: Responsibly handle and delete any captured data after demonstrations

The author is not responsible for any misuse or damage caused by this program. Users assume full liability.

🎯 Features
30+ Pre-built Templates: Facebook, Instagram, Google, Netflix, PayPal, and more

Multiple Tunneling Options: Ngrok, Cloudflared, LocalXpose, Localhost.run

Real-time Monitoring: Live victim connection tracking

Credential Capture: Form data extraction and storage

Geolocation Tracking: IP-based location information

Cross-Platform: Works on Linux and macOS

User-friendly Interface: Color-coded menu system

📦 Installation
Quick Auto-Installation:
bash
chmod +x install_lxphisher.sh
./install_lxphisher.sh
Manual Installation (if needed):
bash
# Install dependencies
sudo apt-get update
sudo apt-get install php curl wget unzip jq ssh

# Make main script executable
chmod +x lxphisher.sh

# Create required directories
mkdir -p templates servers captured_data auth .tunnels
🚀 Usage
Basic Usage:
bash
./lxphisher.sh
Step-by-Step Guide:
Run the tool:

bash
./lxphisher.sh
Select a template from the menu (Facebook, Instagram, etc.)

Choose port (default: 8080)

Select tunneling method:

1 Localhost (127.0.0.1:8080)

2 Ngrok (Public URL)

3 Cloudflared (Public URL)

4 LocalXpose (Public URL)

5 Localhost.run (Public URL)

Send the generated URL to your target (for authorized testing)

Monitor connections in real-time

View captured data in the captured_data/ directory

Advanced Usage:
bash
# Use custom port
./lxphisher.sh  # then select option 3 to change port

# View captured credentials
ls -la captured_data/
cat captured_data/credentials_facebook_*.log

# Use specific tunnel only
./lxphisher.sh  # then select option 2 for tunnel configuration
📁 Directory Structure
text
lxphisher/
├── lxphisher.sh                 # Main script
├── install_lxphisher.sh         # Auto-installer
├── templates/                   # Phishing templates
│   ├── facebook/               # Facebook template
│   │   ├── index.html          # Login page
│   │   ├── login.php           # Credential handler
│   │   └── assets/             # Images/CSS/JS
│   ├── instagram/              # Instagram template
│   └── ...                     # 30+ other templates
├── servers/                     # Runtime copies (auto-created)
├── captured_data/               # Stored credentials
├── auth/                        # Authentication files
└── .tunnels/                   # Tunnel binaries
│   ├── cloudflared-bin         # Cloudflared executable
│   └── loclx                   # LocalXpose executable
🛠️ Template Management
Adding Custom Templates:
Create a new directory in templates/

Add your index.html and login.php files

The tool will automatically detect it

Available Templates:
Social Media: Facebook, Instagram, Twitter, LinkedIn, TikTok, Discord

Email: Gmail, Microsoft, Yahoo, ProtonMail

Streaming: Netflix, Spotify, Twitch

Finance: PayPal, Adobe, Dropbox

Gaming: Steam, Xbox, PlayStation, Origin

Development: GitHub, GitLab, StackOverflow

And many more...

🔧 Configuration
Setting Ngrok Auth Token (Optional):
bash
ngrok authtoken YOUR_TOKEN_HERE
Customizing Redirect URLs:
Edit the login.php file in any template to change where victims are redirected after form submission.

📊 Monitoring & Results
Real-time Monitoring:
Live connection alerts with IP addresses

Geolocation data display

Credential capture notifications

Viewing Results:
bash
# List all captured data files
ls -la captured_data/

# View specific capture file
cat captured_data/credentials_facebook_20231201_123045.log

# Sample output:
# [2023-12-01 12:30:45]
# IP: 192.168.1.100
# Email: test@example.com
# Password: password123
# User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
# ----------------------------------------
🐛 Troubleshooting
Common Issues:
"PHP not found":

bash
./install_lxphisher.sh  # Re-run installer
Tunnel services not working:

bash
# Test Ngrok
ngrok http 8080

# Test Cloudflared
.tunnels/cloudflared-bin tunnel --url http://127.0.0.1:8080
Port already in use:

bash
# Change port in menu or kill existing process
pkill -f "php -S"
Templates not loading:

bash
# Verify template structure
ls templates/facebook/
# Should show: index.html login.php
📝 Legal & Ethical Guidelines
✅ DO:
Use for authorized security awareness training

Obtain written permission before testing

Document all testing activities

Delete captured data after demonstrations

Educate users about phishing dangers

🚫 DO NOT:
Use without explicit permission

Test on production systems without authorization

Store sensitive data unnecessarily

Use for malicious purposes

Share captured credentials

👥 Author & Credits
Author:
Voltsparx - Developer & Security Researcher

Email: voltsparx@gmail.com

Purpose: Educational cybersecurity tool development

Credits:
Template designs inspired by various open-source security projects

Tunnel services: Ngrok, Cloudflare, LocalXpose

Community contributors for testing and feedback

📜 License
MIT License - For educational purposes only

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software for educational and security awareness purposes only, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

The Software shall not be used for unauthorized or malicious activities.

Users must obtain proper authorization before using the Software.

The author is not liable for any misuse of the Software.

🤝 Contributing
This project is for educational purposes only. While we appreciate interest, we do not accept contributions that enhance the tool's capabilities for unauthorized use.

Educational Contributions:
Documentation improvements

Security awareness content

Ethical usage guidelines

Tutorials for legitimate training purposes

📞 Support
For legitimate educational use and authorized security training questions:

Email: voltsparx@gmail.com

Response Time: 24-48 hours for legitimate inquiries

Note: We do not provide support for unauthorized usage

🔒 Responsible Disclosure
If you find vulnerabilities in this tool:

Do not exploit them maliciously

Email: voltsparx@gmail.com

Allow reasonable time for response

Help improve security education

Remember: Knowledge is power, but ethics give it purpose. Use this tool responsibly.

🎓 Educational Use Cases
Security Awareness Training:
Demonstrate how phishing attacks work

Show employees what to look for in suspicious emails

Train users to identify fake login pages

University Courses:
Cybersecurity education

Ethical hacking classes

Digital forensics training

Penetration Testing Practice:
Lab environment testing

Red team exercises (with proper authorization)

Security certification preparation

🔍 Detection Indicators
Common Phishing Signs:
Urgent language and threats

Suspicious sender addresses

Mismatched URLs (hover before clicking)

Poor grammar and spelling

Requests for sensitive information

How to Protect Yourself:
Enable two-factor authentication (2FA)

Use password managers

Verify unusual requests via alternative channels

Keep software updated

Regular security training

📚 Learning Resources
Recommended Reading:
"Social Engineering: The Science of Human Hacking" by Christopher Hadnagy

"Phishing Dark Waters" by Christopher Hadnagy and Michele Fincher

OWASP Top 10 Web Application Security Risks

NIST Cybersecurity Framework

Online Courses:
Cybrary: Ethical Hacking and Penetration Testing

Coursera: Cybersecurity Specialization

SANS Security Awareness Training

🔄 Version History
v3.0 (Current)
Added 30+ website templates

Multiple tunneling services support

Enhanced monitoring capabilities

Cross-platform compatibility

Improved user interface

v2.0
Basic template system

Local hosting only

Simple credential capture

Linux support only

v1.0
Initial release

Single template support

Basic functionality

🌟 Star History
If you find this tool useful for educational purposes, please consider starring the repository to support continued development of security awareness tools.

⚠️ FINAL REMINDER: This tool must only be used for legitimate educational and authorized security testing purposes. Unauthorized use is illegal and unethical.

🛡️ Stay safe, stay ethical, and help make the internet more secure for everyone.

