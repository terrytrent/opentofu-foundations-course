# OpenTofu Foundations

## Description
This repository tracks my progress in the OpenTofu Foundations training provided by [MassDriver](https://www.massdriver.cloud/) during their 10-week course, which began on September 25, 2024. It will include code generated in accordance with the course objectives, as well as additional code based on my experimentation and exploration beyond the assigned tasks.

### Notes
* I will store any todo items I have not completed from the course, challenges, or additional enhancements using GitLab issues at [https://github.com/terrytrent/opentofu-foundations-course/issues](https://github.com/terrytrent/opentofu-foundations-course/issues).  I cannot guarantee I will tackle all items I specify, but will do my best so that I am able to better explore Terraform/Tofu and how to interact with AWS specifically.
* I am currently using the AWS free tier for deployment, but may look into using the KodeKloud sandbox as I encounter specific free tier limits.

## [Week 1](https://github.com/massdriver-cloud/opentofu-foundations/tree/main/week-1) // September 25,2024

>Introduction to OpenTofu, its purpose, and basic installation. Learn to set up a project and understand the foundational concepts of Infrastructure as Code. Write your first OpenTofu configuration and define basic infrastructure resources like compute instances and networking components.

I implemented the code as the presenter worked through it, then started focusing on the challeneges.  I expanded on the code and challenges in the following ways:
* Creating a role to allow the EC2 instance to access AWS resources, specifically SSM Parameter store
* Updated the user data to pull the database username and password from the parameter store instead of hard coding it in the User Data, enhancing its security
* Added the capability to SSH into the EC2 instance
* Limited the ingress for SSH and HTTP to only allow communication directly from the public IP address I am working from when I `tofu apply` the plan
* Added an RSA key to SSH into the EC2 instance, storing it in parameter store and creating local RSA public and private keys automatically
* Created a username and password for the Wordpress admin account and storing in parameter store
* Enabled SSM registration, disabled SSH access since I can now connect to the instance via SSM

## [Week 2](https://github.com/massdriver-cloud/opentofu-foundations/tree/main/week-2) // October 2,2024

>Organize your code with reusable modules. Learn how to import modules into configurations and apply best practices for modular infrastructure design.

This week they showed how to modularize pieces of your OpenTofu plan.  I followed along and applied the modularization to the modified code from my challenges.


## [Week 3](https://github.com/massdriver-cloud/opentofu-foundations/tree/main/week-3) // October 2,2024

>Learn to enhance your infrastructure configurations using OpenTofu’s built-in and custom functions, and control structures. This session will cover how to use functions and control structures like conditionals and loops to create dynamic and adaptable configurations. We'll also dive into creating custom functions using opentofu/terraform-provider-go to extend the functionality of your setups.

This week they discussed fuctions and control structures; I followd along, mainly learning how to use the console to test the plan and learn how to use varying functions.

I completed some of my week 1 challengeds I had for myself, specifically enabling HTTPS via NGINX and LetsEncrypt SSL certificates and automatic Dynu DNS registration using the http data source.  I also learned how I can nest files and templates inside other templates by storing values of files/templates in local variables, then passing those local variables to other templates.