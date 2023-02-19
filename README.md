# Personal IaC Repo

Infrastructure-as-Code repository for my personal work. My aim is to start
extremely simply, then build up from there.

## Overview

Ideally, I want a simple way to deploy containers to a server that I then can
put on the web. I already use Docker for a lot, but don't want any sort of k8s
or autoscalaing stuff (for now). I think I'd rather just use a compose file to
spin up nginx in front of whatever other services I'd like to run. This should
be 'good enough' for now, and I can easily put Fastly in front of it as well.

## Implementation

* AWS Terraform modules to create EC2 instance and supporting resources
  * VPC
  * Security Group
  *
