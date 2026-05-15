# Session 2: Using R on HPC Clusters

In the second part of this two-part workshop we're going to learn how to use R on high-performance computing systems! Now that you're comfortable with the basics of R and RStudio, we'll move onto using the Digital Research Alliance of Canada's HPC systems to level up your analyses. 

Over the course of this workshop, we will log into a cluster, load R and download some packages, and then use RStudio to do some model testing and visualization. Afterwards, we will submit our full script as a batch job to the cluster.

This session is suitable for those with some R experience, who feel comfortable with writing and running R scripts. Some knowledge of working in the shell, or of basic Linux, is an asset. No prior knowledge of high-performance computing is required. While the examples and data used will be aimed at the Humanities and Social Sciences community, the session is open to anyone and everyone interested in learning about R.

## Learning objectives

1. Learn to use access the Digital Research Alliance of Canada's HPC clusters
2. Learn to navigate the cluster in your terminal
3. Learn to load R in the terminal, and to access RStudio through JupyterHub
4. Learn to submit a job to the cluster

## Before we start

!!!note "Using the Alliance clusters."
    To use the Digital Research Alliance of Canada's clusters, you will need to first sign up for an account. To sign up for an account with the Alliance, follow [the instructions here](https://www.alliancecan.ca/en/our-services/advanced-research-computing/account-management/apply-account). 

For the first half of today's session, we'll be using the same subset of the World Values Survey wave 7 data on Canada. You can download it [here](./content/data/wvs_subset_modified.csv). When we go to write and submit a job on the training cluster, we'll use a larger version of the dataset, which you can download [here](./content/data/full_wvs_canada_data_modified.csv). You can view the codebook for our data subset [here](./content/codebook.xlsxnWV7.jsp) or visit the [WVS wave 7 website](https://www.worldvaluessurvey.org/WVSDocumentationWV7.jsp) to access the full survey documentation.

I'd encourage you to follow along in R and RStudio, but if you get stuck or want to check something, you can download my [RStudio script](./content/rstudio_script.R), my [R script for the shell](./content/shell_script.R), and my [job script](./content/shell_job.sh). 

???note "Further resources."
    - [High-performance research computing in R](https://mint.westdri.ca/r/wb_hpc_slides.html#/title-slide)
    - [R for Graduate Students](https://bookdown.org/yih_huynh/Guide-to-R-Book/)
    - [Getting Started (on HPC)](https://training.westdri.ca/getting-started/)
    - [How to run your R script with Compute Canada](https://medium.com/the-nature-of-food/how-to-run-your-r-script-with-compute-canada-c325c0ab2973)
    - [Alliance's documentation on R](https://docs.alliancecan.ca/wiki/R)
    - [Managing R on HPC systems](https://hackmd.io/@bbolker/r_hpc#Getting-started)
    - [Simple Linear Regression](https://www.sfu.ca/~mjbrydon/tutorials/BAinR/regression.html)