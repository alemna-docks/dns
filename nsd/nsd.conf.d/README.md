# `nsd/nsd.conf.d/`

This is `nsd.conf.d`, NSD's extra configuration directory. Any files 
in this directory ending in `.conf` will be automatically included 
in `NSD`'s configuration (as long as there is a 
`include: /etc/nsd/nsd.conf.d/*.conf` statement in `nsd.conf`).
