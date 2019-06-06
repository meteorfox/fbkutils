from cpuinfo import get_cpu_info
import dmidecode
import os
import subprocess
import json
import pprint

def get_cpu_topology():
    cpu_info = get_cpu_info()
    return cpu_info

def get_os_kernel():
    sys_name, node_name, kernel_release, version, machine = os.uname()
    return {
        'sys_name' : sys_name,
        'node_name' : node_name,
        'kernel_release' : kernel_release,
        'version' : version,
        'machine' : machine
    }

def get_dmidecode_bios():
    dmidecode_data = dmidecode.parse_dmi(dmidecode._get_output())
    dmidecode_dict = {}
    for data in dmidecode_data:
        dmidecode_dict[data[0]] = data[1]
    return dmidecode_dict['bios']

def get_sysctl_data():
    p = subprocess.Popen(['sysctl', '-a'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (kernel_params, err) = p.communicate() # No timeout needed

    kernel_params = kernel_params.decode('utf-8').split('\n')[:-1] # Clean up output
    kernel_params_dict = {}
    for kernel_param in kernel_params:
        key, val = [param.strip() for param in kernel_param.split('=')]
        kernel_params_dict[key] = val
    return kernel_params_dict

pprint.pprint(get_sysctl_data())
