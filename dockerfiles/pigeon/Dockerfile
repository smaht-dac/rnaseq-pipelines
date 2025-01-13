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
RUN conda install -c bioconda -y pbpigeon==1.3.0 && \
    conda clean -a -y -f

#######################################################################
#     Scripts
#######################################################################
## pigeon_prepare
COPY pigeon_prepare.sh .
RUN chmod +x pigeon_prepare.sh

## pigeon_classify
COPY pigeon_classify.sh .
RUN chmod +x pigeon_classify.sh

## pigeon_filter
COPY pigeon_filter.sh .
RUN chmod +x pigeon_filter.sh

## pigeon_report
COPY pigeon_report.sh .
RUN chmod +x pigeon_report.sh

CMD ["bash"]
