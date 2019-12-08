# Define variables needed for script
read -p 'Server IP' SERVER_IP
read -p 'Server username' USERNAME
# install requirements
sudo apt update && sudo apt install xfce4 xfce4-goodies && sudo apt install tightvncserver
# backup & modify xstartup
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
# define DE for Xresources
echo -e "#!/bin/bash \nxrdb $HOME/.Xresources \nstartxfce4 &" >> ~/.vnc/xstartup
sudo chmod +x ~/.vnc/xstartup # change to chmod 755
vncserver
ssh -L 5901:127.0.0.1:5901 -C -N -l $USERNAME $SERVER_IP
echo -e "[Unit] \nDescription=Start TightVNC server at startup \nAfter=syslog.target network.target \n \n[Service] \nType=forking" >> /etc/systemd/system/vncserver@.service
# setup vncserver Username, Group, Working directory, and home directory
read -p 'User:' VNC_USER && echo -e 'User=$VNC_USER' >> /etc/systemd/system/vncserver@.service
read -p 'Group:' VNC_GROUP && echo -e "Group=$VNC_GROUP" >> /etc/systemd/system/vncserver@.service
read -p 'Working directory:' VNC_WORK && echo -e 'WorkingDirectory="/home/$VNC_WORK\n' >> /etc/systemd/system/vncserver@.service
read -p 'Home directory:' VNC_HOME && echo -e ' \n \nPIDFile=/home/$VNC_HOME/.vnc/%H:%i.pid' >> /etc/systemd/system/vncserver@.service
# setup vncserver as a service
echo -e "ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1 \nExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i \nExecStop=/usr/bin/vncserver -kill :%i \n \n[Install] \nWantedBy=multi-user.target" >> /etc/systemd/system/vncserver@.service
# begin the newly created service, killing our original vncserver instance
sudo systemctl daemon-reload && sudo systemctl enable vncserver@1.service && vncserver -kill :1 && sudo systemctl start vncserver@1 && sudo systemctl status vncserver@1
echo 'Ready to connect via VNC'
