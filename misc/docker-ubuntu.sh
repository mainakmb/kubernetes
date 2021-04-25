#Erase old versions
echo "**[Task 1]** Erasing old Docker version"
apt-get remove -qq docker docker-engine docker.io containerd runc >/dev/null 2>&1

#Add repository
echo "**[Task 2]** Adding repository"
apt-get update -qq
apt-get install -qq \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release >/dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >/dev/null 2>&1
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
#Install Docker Engine
echo "**[Task 3]** Installing Docker Engine"
apt-get update -qq >/dev/null 2>&1
apt-get install -qq docker-ce docker-ce-cli containerd.io >/dev/null 2>&1