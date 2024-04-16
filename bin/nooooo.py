#!/usr/bin/env python

import sys
import random

stdin_fd = sys.stdin
ret = ''
for line in stdin_fd:
    for char in line:
        if bool(random.getrandbits(1)):
            ret += char.upper()
        else:
            ret += char.lower()

print(ret.rstrip() + ('!' * random.randint(3,7)))
