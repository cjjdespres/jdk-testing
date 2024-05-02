# Building and testing benchmarks with custom JDKs

This repository collects various container build/benchmarking utilities.
Currently only Acmeair EE8 can be built.

## Installation

Current requirements:

1. A linux kernel that supports `setcap cap_checkpoint_restore` (should be version `5.9` or later)
2. A prebuilt `tomcat.tar.gz` and `criu.tar.gz`

Installation:

``` shell
(Not the nicest setup, yet).

# Clone the repo

git clone --recurse-submodules https://github.com/cjjdespres/jdk-testing
cd jdk-testing

# Copy over prebuilt tomcat and CRIU
mkdir liberty-container/extras/
cp <PATH>/tomcat.tar.gz liberty-container/extras/
cp <PATH>/CRIU.tar.gz liberty-container/extras/
```

## Usage

The `buildVersionedAcmeair.sh` script will build a full Acmeair EE8 container
with embedded SCC using a specified local JDK image. It takes the following
required parameters:

1. `--version=<VERSION_STRING>` - the version to use in the image names for the various
   built containers
2. `--jdk-dir=<PATH>` - the path to the local JDK image directory

This will build three containers:

1. `semeruesque:<VERSION_STRING>` - a JDK image built in a similar manner to the Semeru docker images
2. `liberty:<VERSION_STRING>` - a Liberty server image based on the the JDK image in (1)
3. `acmeair-full:<VERSION_STRING>` - an Acmeair EE8 server image based on the Liberty image in (2)


The `buildAcmeairSupport.sh` script will build the JMeter and mongodb containers required to run the acmeair image. See `./acmeair-container/README.md` for more details.
