#!/usr/bin/env bash

# Install Weave CNI
curl -L git.io/weave -o /usr/local/bin/weave
chmod a+x /usr/local/bin/weave
weave setup


