FROM ghcr.io/void-linux/void-glibc-full:latest

RUN xbps-install -Syu xbps && xbps-install -Syu
RUN xbps-install -Sy bash
