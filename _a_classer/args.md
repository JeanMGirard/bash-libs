# Bash

## Args

-------------------------------------------------------------------------
### arguments

```shell
while [[ $# -gt 0 ]]; do case "$1" in
  --param-value) PARAM="$2"; shift; ;;
  --param) FLAG=1; ;;
  *) echo "invalid argument";
esac; shift; done;
```
