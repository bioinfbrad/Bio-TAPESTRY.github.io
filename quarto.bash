# update + essential tools
sudo apt-get update
sudo apt-get install -y wget curl jq gdebi-core build-essential pandoc libcurl4-openssl-dev libxml2-dev libssl-dev libfontconfig1

# Install R (base)
sudo apt-get install -y r-base




# fetch latest .deb URL from GitHub releases and install it
LATEST_URL=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest \
  | jq -r '.assets[] | select(.name|test("linux.*amd64.*\\.deb")) | .browser_download_url')

curl -L -o /tmp/quarto.deb "$LATEST_URL"
sudo gdebi -n /tmp/quarto.deb || (sudo dpkg -i /tmp/quarto.deb && sudo apt-get -f install -y)
rm /tmp/quarto.deb

# check
quarto --version


# 1) Make a user R library and make it persistent for this session
export R_LIBS_USER="$HOME/R/library"
mkdir -p "$R_LIBS_USER"

# 2) (Optional) Make the setting persistent across new shells
echo "R_LIBS_USER=${HOME}/R/library" >> ~/.Renviron

# 3) Verify R will see that user library first
Rscript -e '.libPaths(); cat("R_LIBS_USER=", Sys.getenv("R_LIBS_USER"), "\n")'

# 4) Install the packages into your user library
Rscript -e 'install.packages(c("rmarkdown","bookdown","tinytex","remotes"), lib=Sys.getenv("R_LIBS_USER"), repos="https://cran.rstudio.com")'



Rscript render-deploy.R


quarto preview --port 8080 --no-browser
