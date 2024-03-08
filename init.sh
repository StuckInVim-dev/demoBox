#!/bin/bash
set -e
master_image_name="demobox-master"
master_container_name="demobox-master"

print_usage() {
  cat << END
USAGE:
bash init.sh [OPTION]

Options:
-i	  Launch master container interactively
-p [PORT] Serve SSH on different port then 2002
-r	  Run container with restart=unless_stopped
-d	  Delete running master container
-h	  Print this help message
END
}

# Set the default interectivity to false (Run detached)
interactive="-d"

# Set the default restart policy to no
restart="no"

# Set the default port to 2002
port="2002"



while getopts 'p:irdh' flag; do
  case "${flag}" in
    p) port="${OPTARG}" ;;
    i) interactive="-it" ;;
    r) restart="unless-stopped" ;;
    d) delete_old="true" ;;
    h) print_usage
    exit 0 ;;

    *) print_usage
    exit 1 ;;
  esac
done

echo "@@@Port: $port", "Interactive: $interactive", "Restart: $restart", "Delete: $delete_old"


for dir in $(find "children" -type d); do
    # Skip the root directory
    if [ "$dir" == "children" ]; then
        continue
    fi

    # Change into the child directory
    cd $dir

    # Construct the container name in the format: "childrenchild"
    container_name="demobox-child-$(echo "$dir" | tr -d '/' | sed "s|^children||")"

    # Build the child image
    docker build -t $container_name .

    # LOG
    echo "Built child image $container_name from $dir successfully"

    # Construct the image path
    image_path="child_images/$container_name"

    # Return back to the root of the project
    cd -

    # Save the child image into the archive
    docker save $container_name > "$image_path.tar"

    # LOG
    echo "Saved child image $container_name successfully"
done

# Build the master image
docker build -t $master_image_name .

# LOG
echo "Built master image $master_image_name successfully"


# Presume that the master container does not exist
master_exists=false

# If there is a container with the name of the master container
if [ "$(docker ps -aq -f name=^${master_container_name}$)" ]; then

    # Set the master exists flag to true
    master_exists="true"

    # LOG
    echo "Detected existing master container"
fi



# If the removal of the old master container is requested
if [ "$delete_old" = "true" ]; then

    # If there is a container with the name of the master container
    if [ "$master_exists"="true" ]; then
        
        # Stop the container
        docker stop "$master_container_name"

        # Remove the container
        docker rm "$master_container_name"

        # Set the master exists variable to false
        master_exists="false"

        # LOG
        echo "Container '${master_container_name}' has been removed as requested"

    else
        # LOG
        echo "Container '${master_container_name}' does not exist, ignoring the -d flag"
    fi

else
    echo "Skipping removal of old master container, -d was not set"
fi

# If the master container does not exist
if [ "$master_exists" = "false" ]; then

    # LOG
    echo "Attempting to start master container $master_container_name"

    # Run the master container
    docker run $interactive \
        -p $port:22 \
        --name=$master_container_name \
        --restart=$restart \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(which docker):/usr/bin/dockerc \
        $master_image_name

    # LOG
    echo "Started master container $master_container_name successfully"

else
    echo -e "\n\nCannot run master container, a container with the name '${master_container_name}' already exists"
    echo "Please remove the old container or use the -d flag to remove it automatically"
    exit 1
fi



