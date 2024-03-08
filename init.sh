#!/bin/bash
set -e
master_image_name="master-virtssh"
master_container_name="master-virtssh"

print_usage() {
  cat << END
USAGE:
bash init.sh [OPTION]

Options:
-i	  Launch master container interactively
-p [PORT] Serve SSH on different port then 2002
-r	  Run container with restart=unless_stopped
-d	  Delete running master container
END
}

# Set the default interectivity to false (Run detached)
interactive="-d"

# Set the default restart policy to no
restart="no"

# Set the default port to 2002
port="2002"



while getopts 'p:ird' flag; do
  case "${flag}" in
    p) port="${OPTARG}" ;;
    i) interactive="-it" ;;
    r) restart="unless-stopped" ;;
    d) delete_old="true" ;;

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
    container_name="virtssh-$(echo "$dir" | tr -d '/')"

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




if [ "$delete_old" = "true" ]; then
    docker rm -f $master_container_name
    echo "Removed old master container successfully"
else
    echo "Skipping removal of old master container"
fi

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
