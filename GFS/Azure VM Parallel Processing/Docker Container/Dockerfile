# Pull the Redhat 8 UBI image
FROM redhat/ubi8

# Install necessary packages (sudo, wget)
RUN yum -y update && \
    yum -y install sudo wget bzip2 && \
    yum clean all

# Create a new user with sudo privileges
RUN useradd -m fewx-user && \
    echo "fewx-user:fewx" | chpasswd && \
    usermod -aG wheel fewx-user && \
    echo 'fewx-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the new user
USER fewx-user
WORKDIR /home/fewx-user

# Download and install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /home/fewx-user/miniconda && \
    rm ~/miniconda.sh

# Add conda to the PATH
ENV PATH="/home/fewx-user/miniconda/bin:$PATH"

# Set up a volume for data persistence
VOLUME ["/home"]

# Default shell
CMD ["/bin/bash"]

