# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [0.0.8] - 2024-10-12
### Changed

- Parameterized ingress and egress security group rules for the aws instance security group

### Added

- Added a Cat Fact as a tag on the aws_instance resource in the aws_instance module

## [0.0.7] - 2024-10-12
### Added

- Added capability to serve the wordpress site over SSL automatically using letsencrypt certificates

## [0.0.6] - 2024-10-10
### Added

- Created modules for the instance, database, dns, and certificate

## [0.0.5] - 2024-09-30
### Added

- Added DNS registration
- Added LetsEncrypt Certification generation

### Changed

- Modified User Data to pull certificates onto server

## [0.0.4] - 2024-09-30
### Changed

- Modified EC2 Instance to use a launch template
- Modiifed EC2 Instance to be recreated if user data changes
- Created IAM Policy instead of inline policy for IAM Role


## [0.0.3] - 2024-09-29
### Changed

- Updated providers
- Modified user data to launch the containers using docker compose instead of a straight docker command
- Pruned more SSH stuff
- Removed creating local SSH keys as that's not necessary with SSM
- Added an SSM command output so I can use `` `tofu output --raw instance_ssm_command` `` to automatically connect to the instance


## [0.0.2] - 2024-09-29
### Changed

- Added SSM capability
- Disabled SSH capability
- Moved AMI ID to a variable
- Set default AMI ID to latest Amazon Linux 2023 AMI


## [0.0.1] - 2024-09-28

- initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html