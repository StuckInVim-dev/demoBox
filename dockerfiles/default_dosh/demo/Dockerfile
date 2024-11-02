FROM debian:latest

# Add limited user
RUN useradd -m demouser

# Chnage the working directory to the user's home directory
WORKDIR /home/demouser

# Update repositories
RUN apt update

# Install sudo
RUN apt install -y sudo

# Remove password requirement for sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set the password for the limited user
RUN echo "demouser:demouser" | chpasswd

# Add the limited user to the sudo group
RUN adduser demouser sudo

# Switch to the limited "demouser" user
USER demouser

# Enter the container as the limited user in a bash shell
CMD ["/bin/bash"]
