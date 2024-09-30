# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

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