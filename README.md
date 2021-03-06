# aws-elk-billing [![Build Status](https://travis-ci.org/PriceBoardIn/aws-elk-billing.svg?branch=master)](https://travis-ci.org/PriceBoardIn/aws-elk-billing)

![Alt text](https://github.com/prasenforu/aws-elk-billing/blob/master/screenshots/kibana-dashboard.png "Overview") 

## Overview
 
aws-elk-billing is a combination of configuration snippets and tools to assist with indexing AWS programatic billing access files(CSV's) and visualizing the data using Kibana.

Currently it supports `AWS Cost and Usage Report` type, although it might work for other [AWS Billing Report Types](http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/detailed-billing-reports.html#other-reports) which contains some extra columns along with all the columns from `AWS Cost and Usage Report`.

![Alt text](https://github.com/prasenforu/aws-elk-billing/blob/master/screenshots/aws-report-usage-cost.png)

You can create `AWS Cost and Usage Report` at https://console.aws.amazon.com/billing/home#/reports
Make sure that it contains the following dimensions only **(Don't include Resource IDs)**
* Account Identifiers
* Invoice and Bill Information
* Usage Amount and Unit
* Rates and Costs
* Product Attributes
* Pricing Attributes
* Cost Allocation Tags

Follow instructions at http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/detailed-billing-reports.html#turnonreports


### Architecture
There are Four Docker containers. 

1. [Elasticsearch 2.3.3](https://hub.docker.com/r/priceboard/elasticsearch) (https://github.com/PriceBoardIn/elasticsearch/tree/2.3.3)
2. [Kibana](https://hub.docker.com/r/priceboard/kibana) (https://github.com/PriceBoardIn/kibana)
3. [Logstash](https://hub.docker.com/r/priceboard/logstash) (https://github.com/PriceBoardIn/logstash)
4. aws-elk-billing (Refer: Dockerfile of this repository)

Integration among the 4 containers is done with `docker-compose.yml`


### Primary Components
Task | Files
------------ | -------------
Logstash configuration | `logstash.conf`
Kibana configuration | `kibana.yml`
Elasticsearch index mapping | `aws-billing-es-template.json`
Indexing Kibana dashboard| `kibana/orchestrate_dashboard.sh`
Indexing Kibana visualisation| `kibana/orchestrate_visualisation.sh`
Indexing Kibana default index (This file is just for reference purpose, we will automate this part eventually)| `kibana/orchestrate_kibana.sh`
Parsing the aws-billing CSV's and sending to logstash | `main.go`
Connecting the dots: `Wait` for ELK Stack to start listening on their respective ports, `downloads`, `extracts` the latest compressed billing report from S3, `XDELETE` previous index of the current month, `Index mapping`, `Index kibana_dashboard`, `Index kibana_visualization` and finally executes `main.go` | `orchestrate.py`
Integrating all 4 containers | `Dockerfile`, `docker-compose.yml`

## Getting Started
Clone the Repository and make sure that no process is listening to the ports used by all these dockers.

Ports | Process
------------ | -------------
9200, 9300 | Elasticsearch
5160 | Kibana
5140 | Logstash

**Installation**

### Run Docker
The entire process is automated through scripts and docker and docker-compose. All the components would be downloaded automatically inside your docker. If you are not ok with docker-compose follow link for docker-compose (https://docs.docker.com/compose/install/)

Option #1

Copy "aws-elk-billing-installlation-script.sh" file in your linux host. Just edit few lines in # Important ## section in that file as per your input (like below screen shot) and relax, script will do everything for you.

1. View `Kibana` at http://localhost:5601

    1.1 Use the **index pattern** as `aws-billing-*` and select the **time field** as `lineItem/UsageStartDate`
    
    1.2 `Kibana AWS Billing Dashboard` http://localhost:5601/app/kibana#/dashboard/AWS-Billing-DashBoard

Option #2

1. Clone this repository.

2. ### Set S3 credentials and AWS Billing bucket and directory name
Rename [prod.sample.env](https://github.com/PriceBoardIn/aws-elk-billing/blob/master/prod.sample.env) to `prod.env` and provide values for the following keys `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`, `S3_REPORT_PATH`

##### `S3_BUCKET_NAME` = S3 bucket name (Refer the image above)
##### `S3_REPORT_PATH` = Report path (Refer the image above)
##### `S3_REPORT_NAME` = Report name (Refer the image above)

![Alt text](https://github.com/prasenforu/aws-elk-billing/blob/master/screenshots/aws-report-usage-cost-prodenv.png)

`prod.env` is added in `.gitignore` so that you don't push your credentials upstream accidentally.

3. run ```sudo docker-compose up -d```
4. View `Kibana` at http://localhost:5601

    4.1 Use the **index pattern** as `aws-billing-*` and select the **time field** as `lineItem/UsageStartDate`
    
    4.2 `Kibana AWS Billing Dashboard` http://localhost:5601/app/kibana#/dashboard/AWS-Billing-DashBoard
    
    4.3 For MAC replace localhost with the ip of docker-machine
    To find IP of docker-machine `docker-machine ip default`

5. `sudo docker-compose stop` to shutdown all the docker containers.

6. `sudo docker-compose down` to shutdown and remove all the files from docker. 

**Note #1** Next time you do a `docker-compose up` every thing will start from scratch. Use this if you see some problems in your data or ES is timing out.

**Note #2** Normally AWS send "Cost and Usage Report" daily to S3 bucket. These docker container does not fetch report automatically from S3. So you need to restart your all container `docker-compose restrt` manually otherwise put in host's crontab (Try to find when you are getting report file in your S3 based on that you can set cron time). 

## Gotchas

* `aws-elk-billing` container will take time while running the following two process `[Filename: orchestrate.py]`.
    1. Downloading and extracting AWS Billing report from AWS S3.
    2. Depending on the size of AWS Billing CSV report `main.go` will take time to index all the data to Elasticsearch via Logstash.
* You can view the dashboard in kibana, even while `main.go` is still indexing the data.
* In order to index new data, you'll have to run `docker-compose up -d` again.

## Feedback
We'll love to hear feedback and ideas on how we can make it more useful. Just create an issue.

Thanks
