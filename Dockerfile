FROM debian:bookworm

RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections

RUN apt-get update && apt-get dist-upgrade -qy && apt-get install -qy \
    --no-install-recommends systemd systemd-sysv corosync-qnetd  openssh-server && \
    apt-get clean

RUN rm -rf /var/lib/apt/lists/* /var/log/alternatives.log /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN chown -R coroqnetd:coroqnetd /etc/corosync/
RUN systemctl mask -- dev-hugepages.mount sys-fs-fuse-connections.mount
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id

FROM debian:bookworm
COPY --from=0 / /
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]
CMD [ "/usr/bin/sleep", "infinity" ]
