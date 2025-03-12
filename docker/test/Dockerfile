# CONTAINER_NAME: stat440
# AS quarto-builder
FROM debian:bookworm-slim
# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
# Set Quarto version for easier updates
ENV QUARTO_VERSION=1.6.40
# Set processor architecture
ENV PROCESSOR=arm64

LABEL maintainer="Noah J. Blair"
LABEL version="0.1.0"
LABEL description="""\
Quarto publishing system base image with TeX support. \
Built on Debian Bookworm-slim with essential TeX packages \
and dependencies for document generation. \
Version ${QUARTO_VERSION} for ${PROCESSOR} architecture.\
\
Add the following to the new Dockerfile to add quarto:\
\
COPY --from=quarto-base /usr/local/bin/quarto /usr/local/bin/quarto \
COPY --from=quarto-base /usr/local/share/quarto /usr/local/share/quarto\
"""
LABEL quarto.paths="""\
Required paths for downstream images:\
/usr/local/bin/quarto: Quarto executable\
/usr/local/share/quarto: Quarto support files\
"""

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    pandoc \
    texlive-latex-extra \
    make \
    wget && \
    # Clean apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp.d/ && \
    cd /tmp.d/ && \
    wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${PROCESSOR}.deb -O quarto.deb && \
    dpkg -i quarto.deb && \
    quarto check
    # touch test.qmd && \
    # echo "# Test" >> test.qmd && \
    # echo "This is a test file" >> test.qmd && \
    # echo "\$\$" >> test.qmd && \
    # echo "\\sin" >> test.qmd && \
    # echo "\$\$" >> test.qmd && \
    # echo "" >> test.qmd
    # quarto render test.qmd && \
    # cd / && \
    # rm -rf /tmp.d/

# Verify Quarto installation
RUN quarto check



# # Use official R base image with specific version
# FROM r-base:4.4.0

# # Set environment variables for non-interactive installation
# ENV DEBIAN_FRONTEND=noninteractive

# # Create a non-root user with a home directory
# RUN useradd -m -s /bin/bash ruser \
#     && mkdir -p /workspace \
#     && chown -R ruser:ruser /workspace

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     # Development tools
#     build-essential \
#     libcurl4-openssl-dev \
#     libssl-dev \
#     libxml2-dev \
#     # TeX for document rendering
#     texlive-xetex \
#     texlive-fonts-recommended \
#     texlive-latex-extra \
#     texlive-fonts-extra \
#     file \
#     # Utilities
#     git \
#     curl \
#     wget \
#     pandoc \
#     # Add dependencies for package installation
#     ca-certificates \
#     gnupg \
#     software-properties-common \
#     # Python dependencies
#     python3 \
#     python3-pip \
#     python3-venv

# # Set working directory
# WORKDIR /workspace

# # RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-arm64.sh -O quarto-install.sh \
# #     && chmod +x quarto-install.sh \
# #     && cat quarto-install.sh \
# #     && ./quarto-install.sh \
# #     && rm quarto-install.sh

# # Python and pip for radian
# RUN apt-get install -y \
#     python3 \
#     python3-pip \
#     python3.13-venv

#     # Switch to non-root user

# # RUN python3 -m venv .venv \
# #     && .venv/bin/python -m ensurepip \
# #     && .venv/bin/python -m pip install radian \
# #     && source .venv/bin/activate

# RUN R -e " \
#     options(repos = c(CRAN='https://cloud.r-project.org/')); \
#     install.packages(c('quarto')); \
#     install.packages(c('devtools', 'tidyverse', 'remotes', 'tidymodels', 'pracma', 'modelr', 'lintr')); \
#     install.packages(c('bayesplot', 'bayesrules', 'janitor', 'rstanarm', 'tidybayes', 'broom.mixed', 'e1071', 'forcats')) \
#     "

# USER ruser

# CMD [ "bash" ]



# # # Install R packages directly (without renv for coursework simplicity)
# # RUN R - e ""
# # RUN R -e "install.packages(c('devtools', 'tidyverse', 'remotes', 'tidymodels', 'pracma', 'modelr', 'lintr'))"
# # # Specific for this project
# # RUN R -e "
