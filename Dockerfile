FROM debian:latest

# Set the environment variable for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive


# Copy the docker shell and setup script binary to the container and make them executable
COPY dosh /bin/dosh
COPY setup /bin/setup
RUN chmod +x /bin/dosh 
RUN chmod +x /bin/setup

# Install openssh-server and sudo
RUN apt update 
RUN apt install sudo openssh-server -y

# Create directory for ssh (probably not necessary)
RUN mkdir /var/run/sshd

# Remove password requirement for sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Customize the MOTD
COPY motd.txt /etc/motd

# Hide last login line when connecting via ssh
RUN echo PrintLastLog no >> /etc/ssh/sshd_config

# Change the environment variable for interactive installations
ENV DEBIAN_FRONTEND= 

# Expose ssh port
EXPOSE 22

# Create a directory for the dockerfile source directories
RUN mkdir /mnt/source

# Change to the source directory
WORKDIR /mnt/

# Run the setup script
CMD ["/bin/setup"]
