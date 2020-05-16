# Upgrade Jenkins and plugins

If you need to upgrade Jenkins server which has no internet connection it could be quite challange.
To do it you can follow these steps:

## Steps

1. Get latest Jenkins version from http://updates.jenkins-ci.org/download/war/
1. Backup and replace `/usr/lib/jenkins/jenkins.war`
1. Get all plugins you need to upgrade and copy them to Jenkins server. You can use script `dwl_jenkins_plugin.sh` which will help you collect all dependencies
1. Backup Jenkins profile directory and put all plugins into `plugins` directory. To do it you can use script `cp_jenkins_plugin.sh`
1. Postinstallation tasks
   * verify and enable master security subsystem
   * upgrade data store format

## Download jenkins plugins

Use script `dwl_jenkins_plugin.sh` which will download plugins **and also all mandatory dependencies**. Dependencies with `resolution:=optional` are **skipped**. If you need some of these put them into list explicitly.  

Usage:
```
dwl_jenkins_plugin.sh plugin-list-file destination-directory
```

Plugin list file format:

```
envinject|1.90
parameterized-trigger|2.25
etc
```

This script is derived from https://gist.github.com/chuxau/6bc42f0f271704cd4e91

## Reference

* https://www.thegeekstuff.com/2016/06/upgrade-jenkins-and-plugins/
* https://gist.github.com/chuxau/6bc42f0f271704cd4e91
