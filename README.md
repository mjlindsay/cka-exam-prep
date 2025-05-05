# cka-exam-prep

This repository contains all of the files necessary for preparing/configuring
my Kubernetes homelab as I prepare for my CKA. The work here follows a few core ideas/tenants:
- Usable by myself or others in the future, either for hobbyist projects or as a starting point for production systems.
- Makes the development/configuration process easy to understand, learn from, and repeat.
- Adheres to a reasonable standard of security. Even though this is a homelab, security is still important. Where feasible, secure practices have been selected. Documentation includes notes on any additional concerns. The repository may be updated in the future to include additional features or notes on improving the security posture.

## Components / Table of Contents
1. [dns-dhcp](./dns-dhcp/README.md): Containers and scripts for performing fully automatic installations of Debian on baremetal nodes.