# Pingit Clone Vagrant

This is the repo to hold the config files to a successful `vagrant up` to deploy/locally run my [pingit clone project](https://github.com/HardyHardy08/pingit_clone.git). Using this as an excuse to learn Vagrant. In addition I will probably also try to dockerize this exact process in the future as well. In the long term, I would probably like to extend this to automate any 'run local' or 'deploy' tasks of any project.

## Getting Started

### Prerequisites

All you need is Vagrant.. Which requires VirtualBox. Look here to [download Vagrant](http://www.vagrantup.com/downloads.html) and here to [download VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Installing

To get started, simply clone the project to your machine.

```
developer@machine:~/$ git clone https://github.com/HardyHardy08/pingit_clone_vagrant_setup.git <destination>
```

or

```
developer@machine:~/$ git clone git@github.com:HardyHardy08/pingit_clone_vagrant_setup.git <destination>
```

then start vagrant

```
developer@machine:~/pingit_clone_vagrant_setup$ vagrant up 
```

you should be good to go! `vagrant ssh` into the VM. Checkout [Vagrant's docs]() to see what you can do. 

## Contributing

Everyone is welcome to contribute by making pull requests :) 

## Authors

* **Achmad Hardiansyah**
