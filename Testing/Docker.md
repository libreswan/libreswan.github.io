# Please Note: Testing Using Docker Is Experimental

[KVM](/Testing/KVM) or [Namespaces](/Testing/Namespaces) are
recommended for normal test runs.

##Libreswan testing suite docker adventures.

**Everything below runs as root on Fedora 22**

    #swantest depend on python 3.3 or later

    yum install python3-setproctitle python3-pexpect

    # install docker

    yum -y install docker

    systemctl start docker.service
    systemctl enable docker.service

    wget -O /usr/local/bin/pipework  https://github.com/jpetazzo/pipework/raw/master/pipework
    chmod a+x /usr/local/bin/pipework

    cd /home/build/
    # clone an up to date libreswan tree from somewhere to  /home/build/

    cd /home/build/libreswan/testing/docker/
    # check authorized_keys file edit or add your your keys in there

    docker build -t swanbase .
    # coffee break. It will download Fedora 20 + about 200 packages
    # my experience on swantest real 19m31.907s, on parallels vm from Toronto real 7m1.228s

    # make sure the host has netkey stack loaded
    ipsec _stackmanager start --netkey
    ipsec version |grep klips && echo you need netkey

    cd /home/build/libreswan/
    make programs
    cd /home/build/libreswan/testing/pluto/ikev2-37-docker-rw
    ../../utils/swantest --docker

    iptables  -F ; the iptable rules on host and docker may interfere with IKE or ESP

## Docker related diagnostics commands

    # show running docker containers
    docker ps -a

    # check if you have a proper docker installation?
    docker images

    # stop ALL containers
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)

    # if your tests it create a bunch of bridge devices too. Not all of them are cleaned up.

    brctl show

### Check if you got correct image

    cd /home/build/libreswan/testing/docker

    docker build -t swanbase .

    root@jes:/home/build/libreswan/testing/docker# docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    swanbase            latest              e8e73564a0ae        55 minutes ago      2.84 GB
    fedora              20                  7d3f07f8de5f        6 weeks ago         374.1 MB

### Prerequisites

The swantest need Python 3.3 or later. It is necessary for subprocess to
deal with 100s of threads/processes. Also pexpect is works better in
3.3.

=== Attempt to run as user build

1.  run docker as user build

<!-- -->

    sudo groupadd docker
    usermod -a -G docker build

### Notes

1.  currently support install rpms (on both initiator and responder).
    May be separate options so can have different version on both sides.
2.  Add strongswan package or just install runtime? or keep different
    image?
3.  delete brige interfaces after the test is done
4.  option to clean up all bridges?
5.  make install for docker. support "ipsec start" in Docker