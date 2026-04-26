# Use a Devuan base image
FROM devuan/devuan:daedalus

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        perl \
        libcpan-meta-yaml-perl 

# Set default module name and get module name from build argument
ARG MODULE_NAME=Unicode::NoFancyPants
ARG module_name=$MODULE_NAME

CMD ["cpan", $module_name]
