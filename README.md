# San Camillo Shiny Apps

This repository stores the shiny apps developed at [IRCCS San Camillo Hospital](https://hsancamillo.it).

## Structure of the repository

The shiny server is using `R 4.4.3`.

All the shiny apps are stored inside the `apps` folder and can be organized in subfolders.

The file `index.html` is the home page and uses styles in `css` folder.

The template for the apps is an R file inside `template` folder, which define two functions to add header and footer.

## How to contribute

The branch `main` of the repository is protected because it is synced with the website, which is automatically updated every time the branch main receive a new commit.

In order to contribute work on a separate branch and send a pull request to merge the new app in `main`.

The new apps should include the template of the website (see next paragraph).

## Add template to shiny apps

The template of the website is in `template/template_ui.R`.
Apps can inherit the template by just adding these lines:
```r
# .... Here your code with libraries, source, etc

# Add source to the template
source("/srv/shiny-server/template/template_ui.R")

# Then add header and footer and wrap the app in a div
# For example if the original code is
# ui <- fluidPage(
#   your beautiful app
# )
ui <- tagList(
  header(),
  div(id = "content",
        fluidPage(
            # your beautiful app
        )
  ),
  footer()
)
```

Now the app will include the header and footer of the website!

## How to run it locally

You can run the server locally to test new apps (or for any other reason).

The easiest way to deploy the shiny server is by using docker.

You should have installed in your system both `docker` and `docker compose`.

If you are using linux you can use [docker engine](https://docs.docker.com/engine/install/), otherwise the easiest way is by using [docker desktop](https://docs.docker.com/desktop/).

Create a folder for the project, e.g. `shiny`, and inside the folder create a file `docker-compose.yml` with the shiny service:
```yaml
services:
  shiny:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: rocker/shiny
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    restart: unless-stopped
    volumes:
      - ./log:/var/log
      - ./shiny-server:/srv/shiny-server 
    ports:
      - "3838:3838"
```
Create a folder named `log` inside the project folder. All the logs of the server will be saved here.

Now clone this repository inside the project folder
```bash
cd shiny # or your project folder
git clone https://github.com/SanCamillo-NeurophysiologyLab/shiny-server.git
```

Now the structure of your project should be
```
shiny
|- docker-compose.yml
|- log
|- shiny-server
    |- all the files of this repository
```

To run the server just go to the project folder and give the up command
```bash
docker compose up
# docker compose up -d to run it in background
```

The server is accessible at http://localhost:3838

To interrupt the server:
```bash
# ctrl-c if the server is running in the same shell
docker compose down
```

#