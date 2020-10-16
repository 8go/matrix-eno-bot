#!/bin/bash

echo -n "Server time:  "
date
echo -n "Los Angeles:  "
TZ='America/Los_Angeles' date
echo -n "Paris/Madrid: "
TZ='Europe/Madrid' date
echo -n "Lima:         "
TZ='America/Lima' date
echo -n "Melbourne:    "
TZ='Australia/Melbourne' date

# EOF
