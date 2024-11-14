opts='rw,nosuid,nodev,noexec,relatime'
cgroups='blkio cpu cpuacct devices freezer memory pids'

# fix iptables so you can run with bridged network driver
ip route add default via 192.168.1.1 dev wlan0
ip rule add from all lookup main pref 30000

# unmount all cgroup
umount /sys/fs/cgroup/*
umount /sys/fs/cgroup

# try to mount cgroup root dir and exit in case of failure
if ! mountpoint -q /sys/fs/cgroup 2>/dev/null; then
  mkdir -p /sys/fs/cgroup
  mount -t tmpfs -o "${opts}" cgroup_root /sys/fs/cgroup || exit
fi

# try to mount differents cgroups
for cg in ${cgroups}; do
  if ! mountpoint -q "/sys/fs/cgroup/${cg}" 2>/dev/null; then
    mkdir -p "/sys/fs/cgroup/${cg}"
    mount -t cgroup -o "${opts},${cg}" "${cg}" "/sys/fs/cgroup/${cg}" \
    || rmdir "/sys/fs/cgroup/${cg}"
  fi
done
# start the docker daemon
dockerd