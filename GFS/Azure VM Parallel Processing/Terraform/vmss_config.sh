#! /usr/bin/bash

# set time zone to EST 
sudo timedatectl set-timezone America/New_York

# create folder /home/temp
sudo mkdir /home/temp

# handle disk mount to specific directory
if [ ! -e "/dev/sda1" ]
then
  sudo parted /dev/sda --script mklabel gpt mkpart xfspart xfs 0% 100%
  sudo mkfs.xfs /dev/sda1
  sudo partprobe /dev/sda1
  sudo mount /dev/sda1 /home/azureadmin
  sudo chmod 777 /etc/fstab
  sda1_UUID=$(sudo blkid -s UUID -o value /dev/sda1)
  echo "UUID=$sda1_UUID   /home/azureadmin   xfs   defaults,nofail   1   2" >>  /etc/fstab
  sdb1=$(lsblk -b --output SIZE -n -d /dev/sdb1)
  sdc1=$(lsblk -b --output SIZE -n -d /dev/sdc1)
  if [[ $sdb1 -gt $sdc1 ]]
  then
    sudo mount /dev/sdb1 /home/temp
  else
    sudo mount /dev/sdc1 /home/temp
  fi
elif [ ! -e "/dev/sdb1" ]
then
  sudo parted /dev/sdb --script mklabel gpt mkpart xfspart xfs 0% 100%
  sudo mkfs.xfs /dev/sdb1
  sudo partprobe /dev/sdb1
  sudo mount /dev/sdb1 /home/azureadmin
  sudo chmod 777 /etc/fstab
  sdb1_UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
  echo "UUID=$sdb1_UUID   /home/azureadmin   xfs   defaults,nofail   1   2" >>  /etc/fstab
  sda1=$(lsblk -b --output SIZE -n -d /dev/sda1)
  sdc1=$(lsblk -b --output SIZE -n -d /dev/sdc1)
  if [[ $sda1 -gt $sdc1 ]]
  then
    sudo mount /dev/sda1 /home/temp
  else
    sudo mount /dev/sdc1 /home/temp
  fi
else
  sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
  sudo mkfs.xfs /dev/sdc1
  sudo partprobe /dev/sdc1
  sudo mount /dev/sdc1 /home/azureadmin
  sudo chmod 777 /etc/fstab
  sdc1_UUID=$(sudo blkid -s UUID -o value /dev/sdc1)
  echo "UUID=$sdc1_UUID   /home/azureadmin   xfs   defaults,nofail   1   2" >>  /etc/fstab
  sda1=$(lsblk -b --output SIZE -n -d /dev/sda1)
  sdb1=$(lsblk -b --output SIZE -n -d /dev/sdb1)
  if [[ $sda1 -gt $sdb1 ]]
  then
    sudo mount /dev/sda1 /home/temp
  else
    sudo mount /dev/sdb1 /home/temp
  fi
fi

# change ownership
sudo chown -R azureadmin /home/azureadmin
sudo chown -R azureadmin /home/temp

# install and configure Anaconda3
cd /home/azureadmin
sudo curl -O https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
sudo bash Anaconda3-2024.06-1-Linux-x86_64.sh -b -p /home/azureadmin/anaconda3
cd anaconda3/bin
./conda init bash
source ~/.bashrc

# create python environment using conda
conda create -n fewxenv python=3.10.8 -y
conda activate fewxenv

# install needed packages
sudo yum install cmake -y
sudo yum install gcc-gfortran -y
sudo yum install csh -y

# install python libraries
pip install xarray[complete]
pip install xarray==2022.12.0
pip install numpy==1.24.1
pip install eccodes==2.38.1
pip install ecmwflibs
pip install cfgrib==0.9.10.3
pip install pygrib
pip install cartopy
pip install azure-storage-blob

# install and compile wgrib2
cd /home/azureadmin
wget https://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz
tar -xzvf wgrib2.tgz
cd grib2
export CC=gcc
export FC=gfortran
export COMP_SYS=gnu_linux
make
make lib

# add path to bashrc
echo 'PATH=$PATH:/home/azureadmin/grib2/wgrib2:/home/azureadmin/fewxops/software' >> ~/.bashrc 
echo 'export GRIB2TABLE=/home/azureadmin/fewxops/software/wgrb2_alias.tbl' >> ~/.bashrc 
echo 'export PATH' >> ~/.bashrc 
source ~/.bashrc

# move files; extract files; and make files executable
sudo mv /tmp/fewxops.tar.gz /home/azureadmin
cd /home/azureadmin
tar -xzvf /home/azureadmin/fewxops.tar.gz
chmod +x /home/azureadmin/fewxops/software/*
chmod +x /home/azureadmin/fewxops/software/pycommon/*

# fix bad interpreter issues 
sed -i -e 's/\r$//' /home/azureadmin/fewxops/software/makegribcube.forgusts
sed -i -e 's/\r$//' /home/azureadmin/fewxops/software/get_gfs_grid.py
sed -i -e 's/\r$//' /home/azureadmin/fewxops/software/speed_test.py 
sed -i -e 's/\r$//' /home/azureadmin/fewxops/software/pycommon/gust_window.py
sed -i -e 's/\r$//' /home/azureadmin/fewxops/software/pycommon/visualization.py 

# link python env to /usr/bin/FEWXPYTHON
sudo ln -s /home/azureadmin/anaconda3/envs/fewxenv/bin/python /usr/bin/FEWXPYTHON