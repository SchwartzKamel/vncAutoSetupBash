# Define variables needed for script
read -p 'Server IP:' SERVER_IP
read -p 'Server username:' USERNAME
# install requirements
sudo apt update && sudo apt install xfce4 xfce4-goodies && sudo apt install tightvncserver
# backup & modify xstartup
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
# define DE for Xresources
sudo echo -e "#!/bin/bash \nxrdb $HOME/.Xresources \nstartxfce4 &" >> ~/.vnc/xstartup
sudo chmod +x ~/.vnc/xstartup # change to chmod 755
vncserver
# create the vncservice, append data to it
sudo touch /etc/systemd/system/vncserver@.service
sudo echo -e "[Unit] \nDescription=Start TightVNC server at startup \nAfter=syslog.target network.target \n \n[Service] \nType=forking" >> /etc/systemd/system/vncserver@.service
# setup vncserver Username, Group, Working directory, and home directory
sudo echo -e 'User=$USERNAME' >> /etc/systemd/system/vncserver@.service
sudo echo -e 'Group=$USERNAME' >> /etc/systemd/system/vncserver@.service
sudo echo -e 'WorkingDirectory="/home/$USERNAME' >> /etc/systemd/system/vncserver@.service
sudo echo -e '\nPIDFile=/home/$USERNAME/.vnc/%H:%i.pid' >> /etc/systemd/system/vncserver@.service
# setup vncserver as a service
sudo echo -e "ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1 \nExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i \nExecStop=/usr/bin/vncserver -kill :%i \n \n[Install] \nWantedBy=multi-user.target" >> /etc/systemd/system/vncserver@.service
# begin the newly created service, killing our original vncserver instance
sudo systemctl daemon-reload && sudo systemctl enable vncserver@1.service && vncserver -kill :1 && sudo systemctl start vncserver@1 && sudo systemctl status vncserver@1
echo 'Ready to connect via VNC'
