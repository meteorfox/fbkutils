#!/usr/bin/env python3
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

from .cpu_limit import CpuLimit
from .file import FileHook
from .shell import ShellHook
from .toplev import Toplev


def register_hooks(factory):
    factory.register('cpu-limit', CpuLimit)
    factory.register('file', FileHook)
    factory.register('shell', ShellHook)
    factory.register('toplev', Toplev)
