# Neos Dockerized

A Docker image for the ingenious Neos CMS.

![License](https://img.shields.io/github/license/MCStreetguy/neos-dockerized)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/mcstreetguy/neos-dockerized)
![Docker Build Status](https://img.shields.io/docker/build/mcstreetguy/neos-dockerized)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/mcstreetguy/neos-dockerized)
![Docker Pulls](https://img.shields.io/docker/pulls/mcstreetguy/neos-dockerized)
![Docker Stars](https://img.shields.io/docker/stars/mcstreetguy/neos-dockerized)
![GitHub issues](https://img.shields.io/github/issues/MCStreetguy/neos-dockerized)
![GitHub pull requests](https://img.shields.io/github/issues-pr/MCStreetguy/neos-dockerized)
![GitHub language count](https://img.shields.io/github/languages/count/MCStreetguy/neos-dockerized)
![GitHub top language](https://img.shields.io/github/languages/top/MCStreetguy/neos-dockerized)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/MCStreetguy/neos-dockerized)
![GitHub last commit](https://img.shields.io/github/last-commit/MCStreetguy/neos-dockerized)

- [Neos Dockerized](#neos-dockerized)
  - [Usage instructions](#usage-instructions)
    - [Setup database connection](#setup-database-connection)
    - [Installing my own Neos project](#installing-my-own-neos-project)
    - [Custom configuration files](#custom-configuration-files)

## Usage instructions

Use this image as a base for your own custom Neos image by specifying it in a FROM instruction:

```Dockerfile
FROM mcstreetguy/neos-dockerized:4.3
```

### Setup database connection

As Neos requires a database to be present, you need to provide the neccessary credentials for the image to work.
Using the ONBUILD instructions, this image already sets up the required build arguments in your child image.
These include:

| Argument | Description | Default Value |
|:--------:|:------------|:-------------:|
| `DB_HOST` | The hostname or ip address of the database server. | _none_ |
| `DB_PORT` | The port on the database server to connect to. | `3306` |
| `DB_NAME` | The database name to use. | `db_neos` |
| `DB_USER` | The username for the database conncetion | `usr_neos` |
| `DB_PASS` | The password for the database connection | _none_ |

All values with a default value of `none` are mandatory and may not be omitted!
Otherwise the container might complain during startup and fail with an error message.

### Installing my own Neos project

As the demo installation is not what we want to install in most cases, there is of course an option to install your own Neos project inside this container.
The initial setup will check if a `composer.json` file is present in the `/var/www/neos` directory and otherwise run the `compose create-project` command to initialize the project.
This means in turn that you simply can copy the `composer.json` file of your project to the named directory to make the container install your own project.

```Dockerfile
COPY /path/to/my/composer.json /var/www/neos/
```

### Custom configuration files

**Please note at this point, that you may not override the `Configuration/Settings.yaml` file, as it is required for the container to work properly!**  
You may provide your custom configuration inside the context subdirectories of the `Configuration` folder.
It is strongly recommended to provide the same configuration inside `Configuration/Development` and `Configuration/Production` as the Flow CLI runs in the latter context, whereas the Apache webserver is set to `Production` by default. This ensures consistency between all contexts.

```Dockerfile
COPY /path/to/my/Settings.yaml /var/www/neos/Configuration/Development/
COPY /path/to/my/Settings.yaml /var/www/neos/Configuration/Production/
```
