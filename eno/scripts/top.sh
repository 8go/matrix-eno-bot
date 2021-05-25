#!/bin/bash

echo "Top 5 CPU consumers:"
#ps -eo %cpu,pid,ppid,cmd --sort=-%cpu | head
ps -eo %cpu,cmd:60 --sort=-%cpu --cols 80 | head -n 5
echo ""
echo "Top 5 RAM consumers:"
#ps -eo %mem,pid,ppid,cmd --sort=-%mem | head
ps -eo %mem,cmd:60 --sort=-%mem --cols 80 | head -n 5
echo
echo "Details of CPU and Memory usage:"
echo

declare -A count_array

count_array["%CPU"]=3
count_array["%MEM"]=3
count_array["TIME+"]=1
# count_array+=(["%MEM"]=3 ["TIME+"]=1) # alternative way of setting array

# The arr array now contains the three key value pairs.
if [ "$DEBUG" == "true" ]; then
    for key in "${!count_array[@]}"; do
        echo ${key} ${count_array[${key}]}
    done
fi

top -bn 1 | head -n 5
for key in "${!count_array[@]}"; do
    for ii in $(seq ${count_array[${key}]}); do
        echo "===sorted by $key ($ii)==="
        # -o sort by %CPU %MEM TIME+, -c ... full commnd, -w ... width, -n ... number of times, -b ... batch
        # tr -s ... squeeze spaces
        # sed ... remove leading whitespaces
        # cut
        # 3 times: replace first space with |
        # column: now column 12 "cmd arg1 arg2 file1 file2" is seen as 1 column even though it has spaces
        top -bn 1 -o "$key" -c -w 180 | head -n10 | tail -n4 | tr -s " " | sed -e 's/^[ \t]*//' | cut -d " " -f 9,10,11,12- | sed 's/ /|/1' | sed 's/ /|/1' | sed 's/ /|/1' | column -t -s'|'
    done
done

echo
echo "CPU time used divided by the time the process has been running (cputime/realtime ratio)"
for ss in "%cpu" "%mem" "time"; do
    echo "===sorted by $ss==="
    ps -eo %cpu,%mem,bsdtime,cmd:60,pid --sort=-$ss | head
done # sort by %mem %cpu time, -o ... format/fields, : ... length, -e ... all processes (-A)

# EOF
