# Original Copyright (c) 2021 Niko Virtala. Licensed under the MIT License.
# Modifications Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT

FROM public.ecr.aws/amazonlinux/amazonlinux:2

RUN yum -y update \
    && yum -y install systemd \
    && yum clean all

RUN cd /lib/systemd/system/sysinit.target.wants/; \
    for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i; done

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/*

RUN amazon-linux-extras install epel docker && \
    systemctl enable docker

CMD ["/usr/sbin/init"]
