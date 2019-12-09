# Define variables needed for script
read -p 'Server username:' USERNAME
# install requirements
sudo apt update && sudo apt install xfce4 xfce4-goodies && sudo apt install tightvncserver
vncserver && vncserver -kill :1
# backup & modify xstartup
sudo mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
# define DE for Xresources
sudo echo -e "#!/bin/bash \nxrdb $HOME/.Xresources \nstartxfce4 &" >> ~/.vnc/xstartup
sudo chmod +x ~/.vnc/xstartup # change to chmod 755
vncserver
# create the vncservice, append data to it
sudo touch /etc/systemd/system/vncserver@.service
sudo echo -e "[Unit] \nDescription=Start TightVNC server at startup \nAfter=syslog.target network.target \n \n[Service] \nType=forking" >> /tmp/vncserver.txt
# setup vncserver Username, Group, Working directory, and home directory
sudo echo -e 'User=${USERNAME}' >> /tmp/vncserver.txt
sudo echo -e 'Group=${USERNAME}' >> /tmp/vncserver.txt
sudo echo -e 'WorkingDirectory="/home/${USERNAME}' >> /tmp/vncserver.txt
sudo echo -e 'PIDFile=/home/${USERNAME}/.vnc/%H:%i.pid\n' >> /tmp/vncserver.txt
# setup vncserver as a service
sudo echo -e "ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1 \nExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i \nExecStop=/usr/bin/vncserver -kill :%i \n \n[Install] \nWantedBy=multi-user.target" >> /tmp/vncserver.txt
sudo cat /tmp/vncserver.txt >> /etc/systemd/system/vncserver@.service
# begin the newly created service, killing our original vncserver instance
sudo systemctl daemon-reload && sudo systemctl enable vncserver@1.service && vncserver -kill :1 && sudo systemctl start vncserver@1 && sudo systemctl status vncserver@1
echo 'Ready to connect via VNC'
