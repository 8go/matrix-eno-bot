#!/bin/bash

echo "Top 5 CPU consumers:"
#ps -eo %cpu,pid,ppid,cmd --sort=-%cpu | head
ps -eo %cpu,cmd --sort=-%cpu --cols 40 | head -n 5
echo ""
echo "Top 5 RAM consumers:"
#ps -eo %mem,pid,ppid,cmd --sort=-%mem | head
ps -eo %mem,cmd --sort=-%mem --cols 40 | head -n 5

# EOF
