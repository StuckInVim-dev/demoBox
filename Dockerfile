FROM debian:latest

# Set the environment variable for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive



# Install openssh-server
RUN apt update 
RUN apt install openssh-server -y

# Copy the docker shell and setup script binary to the container and make them executable
COPY dosh /bin/dosh
COPY setup /bin/setup
RUN chmod +x /bin/dosh 
RUN chmod +x /bin/setup

# Create directory for ssh
RUN mkdir /var/run/sshd

# Customize the MOTD
COPY motd.txt /etc/custom_motd

# Hide last login line when connecting via ssh
RUN echo PrintLastLog no >> /etc/ssh/sshd_config

# Change the environment variable for interactive installations
ENV DEBIAN_FRONTEND= 

# Expose ssh port
EXPOSE 22

RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Change to the source directory
WORKDIR /mnt/

# Run the setup script
CMD ["/bin/setup"]
