#!/usr/bin/env python3
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import subprocess
import sys


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def issue_background_command(cmd, stdout_path, stderr_path, env=None):
    stdout = open(stdout_path, 'w', encoding='utf-8')
    stderr = open(stderr_path, 'w', encoding='utf-8')
    proc = subprocess.Popen(
        cmd,
        shell=False,
        env=env,
        stdout=stdout,
        stderr=stderr,
        close_fds=True
    )
    return proc

def kill_process(proc):
    proc.terminate()
