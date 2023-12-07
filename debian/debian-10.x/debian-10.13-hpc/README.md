# Debian HPC Image

The Debian HPC Image includes optimizations and recommended configurations to deliver optimal performance,
consistency, and reliability. This image consists of the following HPC tools and libraries:

- Mellanox OFED
- Pre-configured IPoIB (IP-over-InfiniBand)
- Popular InfiniBand based MPI Libraries
  - HPC-X
  - IntelMPI
  - MVAPICH2
- Communication Runtimes
  - Libfabric
  - OpenUCX
- Optimized librares
  - Intel MKL
- GPU Drivers
  - Nvidia GPU Driver
- SHARP Daemon (sharpd)
- NCCL
  - NCCL RDMA Sharp Plugin
  - NCCL Benchmarks
  - Topology file for NDv4
- NV Peer Memory (GPU Direct RDMA)
- GDR Copy
- Data Center GPU Manager
- Azure HPC Diagnostics Tool
- Moby
- NVIDIA-Docker
- Moneo (Distributed HPC/AI system monitor)

## Updating the kernel

This kernel version is for Debian 10 4.19.  In order to use a more recent kernel the backports can be used to upgrade to 5.10.  This upgrade must be run followed by a VM reboot before the `install.sh` script here.  To upgrade, run the following:

    apt install -t buster-backports linux-image-amd64

## Building the image

Check out the `azhpc-images` repo with the `debian-10.13`:

    sudo install git gpg
    # switch to root
    sudo -i
    git clone -b debian-10.13 https://github.com/edwardsp/azhpc-images.git

Now run the debian install script:

    cd azhpc-images/debian/debian-10.x/debian-10.13-hpc/
    ./install.sh 2>&1 | tee install-$(date '+%Y%m%d-%H%M%S').log


## Running the tests

Run the test script as follows:

    cd azhpc-images/tests
    ./run-tests.sh --mofed-lts false 2>&1 | tee run-tests-$(date '+%Y%m%d-%H%M%S').log

## Capture the image

Log in as root on the VM and run the following:

    waagent -deprovision+user -force

Use the AzureCLI to run:

    az vm deallocate --resource-group <resource-group> --name <vm-name>
    az vm generalize --resource-group <resource-group> --name <vm-name>
    az image create --resource-group <resource-group> --name <image-name> --source <vm-name>

Software packages (MPI / HPC libraries) are configured as environment modules. Users can select preferred MPI or software packages as follows:

`module load <package-name>`

Running Single Node NCCL Test (example):

```sh
mpirun -np 8 \
    --bind-to numa \
    --map-by ppr:8:node \
    -x LD_LIBRARY_PATH=/usr/local/nccl-rdma-sharp-plugins/lib:$LD_LIBRARY_PATH \
    -mca coll_hcoll_enable 0 \
    -x UCX_TLS=tcp \
    -x UCX_NET_DEVICES=eth0 \
    -x CUDA_DEVICE_ORDER=PCI_BUS_ID \
    -x NCCL_SOCKET_IFNAME=eth0 \
    -x NCCL_DEBUG=WARN \
    /opt/nccl-tests/build/all_reduce_perf -b1K -f2 -g1 -e 4G
```
