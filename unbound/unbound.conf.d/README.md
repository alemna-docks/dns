# `unbound/unbound.conf.d/`

This is `unbound.conf.d`, Unbound's extra configuration directory.
Any files in this directory ending in `.conf` will be automatically 
included in `Unbound`'s configuration (as long as there is a 
`include: /etc/unbound/unbound.conf.d/*.conf` statement in 
`unbound.conf`).
