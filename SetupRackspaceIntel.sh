#!/bin/bash


ReleaseVar="$(lsb_release -a | awk '/Release:/{print $NF}')"
yumRepoDir=/etc/yum.repos.d/rackspace-cloud-monitoring.repo
ubuntuSourceList=/etc/apt/sources.list.d/rackspace-monitoring-agent.list

ubuntu1404SourcePackagesAndSignKey() 
{

    sudo sh -c 'echo "deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-14.10-x86_64 cloudmonitoring main" > /etc/apt/sources.list.d/rackspace-monitoring-agent.list'
    if [ ! -f $ubuntuSourceList ]; then
        echo "No such file: $ubuntuSourceList, did not configure sources list for ubuntu"
    else
        curl https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
        sudo apt-get install update
        sudo apt-get install rackspace-monitoring-agent
    fi
}

ubuntu1604SourcePackagesAndSignKey() 
{
    sudo sh -c 'echo "deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-16.04-x86_64 cloudmonitoring main" > /etc/apt/sources.list.d/rackspace-monitoring-agent.list'
    if [ ! -f $ubuntuSourceList ]; then
        echo "No such file: $ubuntuSourceList, did not configure sources list for ubuntu"
    else
        curl https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
        sudo apt-get install update
        sudo apt-get install rackspace-monitoring-agent
    fi
}

AWSLinuxSourcePackagesAndSignKey() 
{
    curl https://monitoring.api.rackspacecloud.com/pki/agent/redhat-5.asc > /tmp/signing-key.asc
    sudo rpm --import /tmp/signing-key.asc
    configureRepoAndInstall()
    {
        cat >$yumRepoDir <<EOF
                [rackspace]
                name=Rackspace Monitoring
                baseurl=http://stable.packages.cloudmonitoring.rackspace.com/redhat-5-x86_64
                enabled=1
EOF
                sudo yum install rackspace-monitoring-agent
    }

    if [ ! -f $yumRepoDir ]; then
        sudo touch $yumRepoDir
            if [ -f $yumRepoDir ]; then
                echo "file found, configuring rackspace monitoring package repository and installing agent"
                configureRepoAndInstall
                else
                    echo "something went wrong, could not find file"
                    echo "Won't install rackspace monitoring agent"
            fi
        else
            echo "Could not make $yumRepoDir"
    fi
}


if [ "$ReleaseVar" == 14.04 ]; then
    ubuntu1404SourcePackagesAndSignKey
    echo "Release version is 14.04"
else

    if [ "$ReleaseVar" == 16.04 ]; then

        ubuntu1604SourcePackagesAndSignKey
        echo "Release version is 16.04"
    else

        AWSLinuxSourcePackagesAndSignKey
        echo "Release is some AWS Linux Version based on RHEL 5.x"
    
    fi
fi