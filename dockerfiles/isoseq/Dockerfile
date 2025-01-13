#######################################################################
#     Basic image
#######################################################################
FROM public.ecr.aws/smaht-dac/base-ubuntu2204-py38:0.0.1

LABEL maintainers="Michele Berselli (berselli.michele@gmail.com), Dominika Maziec (dominika_maziec@hms.harvard.edu)"

#######################################################################
#     General updates & installing necessary Linux components
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix=1.13+ds-2build1 \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#######################################################################
#     Setting env
#######################################################################
## Set working directory
WORKDIR /usr/local/bin

## Supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

#######################################################################
#     Software
#######################################################################
## Conda install
RUN conda install -c bioconda -y isoseq==4.2.0 && \
    conda clean -a -y -f

#######################################################################
#     Scripts
#######################################################################
## isoseq_cluster2
COPY isoseq_cluster2.sh .
RUN chmod +x isoseq_cluster2.sh

## isoseq_collapse
COPY isoseq_collapse.sh .
RUN chmod +x isoseq_collapse.sh

CMD ["bash"]
