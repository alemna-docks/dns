#!/bin/bash

# Change the IP addresses in 'home.arpa.conf' to the
# value of environmental variable NSD_IP.
sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/$NSD_IP/g" /etc/unbound/unbound.conf.d/home.arpa.conf

# Adjust the performance tuning
reserved=12582912
availableMemory=$((1024 * $( (grep MemAvailable /proc/meminfo || grep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
memoryLimit=$availableMemory
[ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ] && memoryLimit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes | sed 's/[^0-9]//g')
[[ ! -z $memoryLimit && $memoryLimit -gt 0 && $memoryLimit -lt $availableMemory ]] && availableMemory=$memoryLimit
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
rr_cache_size=$(($availableMemory / 3))
# Use roughly twice as much rrset cache memory as msg cache memory
msg_cache_size=$(($rr_cache_size / 2))
nproc=$(nproc)
export nproc
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc - 1))
    # Calculate base 2 log of the number of processors
    nproc_log=$(perl -e 'printf "%5.5f\n", log($ENV{nproc})/log(2);')

    # Round the logarithm to an integer
    rounded_nproc_log="$(printf '%.*f\n' 0 "$nproc_log")"

    # Set *-slabs to a power of 2 close to the num-threads value.
    # This reduces lock contention.
    slabs=$(( 2 ** rounded_nproc_log ))
else
    threads=1
    slabs=4
fi

sed -i "s/@MSG_CACHE_SIZE@/${msg_cache_size}/" /etc/unbound/unbound.conf.d/performance.conf
sed -i "s/@RR_CACHE_SIZE@/${rr_cache_size}/" /etc/unbound/unbound.conf.d/performance.conf
sed -i "s/@THREADS@/${threads}/" /etc/unbound/unbound.conf.d/performance.conf
sed -i "s/@SLABS@/${slabs}/" /etc/unbound/unbound.conf.d/performance.conf


/usr/sbin/unbound -d
