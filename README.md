# packer-centos-vagrant
Simple configuration files &amp; scripts for downloading a verified CentOS ISO image with Packer and converting it into a Vagrant box

## What &amp; how

I've been playing around with automating VM image downloads in a secure, replicable way. For this I'm using the following software:

[CentOS](https://centos.org/) as my choice of Linux distribution  
[Packer](https://packer.io/) for downloading the ISO images of the distribution and turning them into Vagrant images  
[VirtualBox](https://virtualbox.org/) for running the Vagrant images with

TODO next: explore using Docker to create more lightweight images to run inside each VM (for more granular control).

## Detailed HOWTO

### Pick a suitable image

For example, to use CentOS, go to https://centos.org/ -> more choices -> mirrors, pick a suitable mirror, then pick whichever ISO file you need. I used [http://ftp.heanet.ie/pub/centos/7/isos/x86_64/](http://ftp.heanet.ie/pub/centos/7/isos/x86_64/). Be sure to verify the checksums (SHA256 and PGP).

Here are the relevant snippets from the [Packer config file](centos7_virtualbox.json):

```
  "builders": [
    {
      "type": "virtualbox-iso",
      "iso_url": "http://ftp.heanet.ie/pub/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso",
      "iso_checksum": "7cf1ac8da13f54d6be41e3ccf228dc5bb35792f515642755ff4780d5714d4278",
      "iso_checksum_type": "sha256",
      "guest_additions_path": "VBoxGuestAdditions_{{.Version}}.iso",
      "guest_additions_sha256": "974063ca9c7bde796dd77ba55d35583dc5d8bc27d53a6bfd81ae206978b133e2",
      "guest_os_type": "RedHat_64",
      "vm_name": "centos7_1503_x86-64"
    }
```

Notice that if you're using VirtualBox, you will also want to specify the guest additions ISO and its checksum.

Packer will cache the ISO image it downloads. You probably want to add the Packer cache directory into `.gitignore` (see [dot_gitignore](dot_gitignore)).

### Configure Packer to boot &amp; install your image automatically

With CentOS automatic installations are done with a Kickstart script. See [http/ks.cfg](http/ks.cfg) for an example and https://wiki.centos.org/TipsAndTricks/KickStart for a reference.

Once you're happy with your autoboot file, configure Packer to use it like so:

```
      "boot_command": [
        "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
      ],
```

With this, Packer will automatically start up an HTTP server to serve your config file to the image as it boots.

### Set up shell scripts to do whatever post-install tasks are required

Relevant config:

```
  "provisioners": [
    {
      "type": "shell",
      "execute_command": "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'",
      "scripts": [
        "script/yum-update.sh",
        "script/vbox-guest-additions.sh"
      ]
    }
  ],
```

For the scripts, see [script/](script/). Note that these are very rudimentary and not ready for actual production, but they're good enough for my personal use.

### Set up your provider, run Packer and see what happens

I'm using VirtualBox as the Vagrant provider, which is straightforward enough.

One very useful setting for debugging is

```
      "headless": "false",
```

which will start VirtualBox in a window, so you can see what is happening. After you're confident everything works you can set this back to `true`.

Once you're happy with your Packer JSON config, your autoinstall config and your scripts, you can run Packer:

```
packer build centos7_virtualbox.json
```

This should eventually result in a file called `CentOS-7-1503-x86_64-virtualbox.box` in the current directory. You can then import that into Vagrant:

```
vagrant box add --name centos7 CentOS-7-1503-x86_64-virtualbox.box
```

And then to boot it up with Vagrant, you can use the rudimentary Vagrant file in [vagrant/](vagrant/):

```
cd vagrant
vagrant up
vagrant ssh
```

### Next steps

Congratulations, you now have a consistent, easily replicable Vagrant VM image that you can install on all your machines.

I hope this has helped you to get started. To proceed further, there are many other projects around with more information and detailed templates; see e.g. [https://github.com/boxcutter/centos](https://github.com/boxcutter/centos).
