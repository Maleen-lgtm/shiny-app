FROM rocker/shiny:latest

# System-Abhängigkeiten für terra
RUN apt-get update && apt-get install -y \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# Installiere R-Pakete (auch terra)
RUN R -e "install.packages(c('shiny', 'terra'), repos='https://cloud.r-project.org')"

# App kopieren
COPY . /srv/shiny-server/

# Besitzer ändern (für shiny)
RUN chown -R shiny:shiny /srv/shiny-server

# Port öffnen
EXPOSE 3838

# Container starten mit shiny
CMD ["/usr/bin/shiny-server"]
