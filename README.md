# COCONUT 🥥

COCONUT is a fully automated blockchain benchmarking system.

## Currently supported systems

Currently supported distributed ledger systems / blockchains:
1. [Corda OS](https://github.com/corda)
2. [Corda Enterprise](https://github.com/corda)
3. [BitShares](https://github.com/bitshares), which is based on [Graphene](https://github.com/cryptonomex/graphene)
4. [Hyperledger Fabric](https://github.com/hyperledger/fabric)
5. [Quorum](https://github.com/jpmorganchase/quorum), which is based on [Ethereum](https://github.com/ethereum/go-ethereum)
6. [Hyperedger Sawtooth](https://github.com/hyperledger/sawtooth-core)
7. [Diem/Libra](https://github.com/diem/diem)
8. [Ethereum](https://github.com/ethereum/go-ethereum)
## Benchmark Execution

To start a COCONUT (*an automatiC blOckChain perfOrmaNce evalUation sysTem*) benchmark each component can be run individually or the process can be fully automated.

To start an automated benchmark, we provide numerous examples in the **execution-scripts/** folder.

The regular process is to run: 
```bash
bash start-*.sh [parameters]
```

The *parameters* are to be set as used in the script itself.

For a manual benchmark, the distributed ledger systems and the clients can be provisioned manually running:
```bash
ansible-playbook runlocal.yaml
```
in their respective folders
(this will also provision the interface execution layers (in case not specified otherwise in the given configuration files).

Both approaches require a modification of the supplied configuration files.
The paths and variables in the wrapper scripts called **start-*.sh** in the **execution-scripts/** folder should be adjusted.

For the coconut-client these can be found in the **configs/** folder and affect the configurations of the clients.

For the provisioning folder the automated provisioning of the client and the distributed ledger systems can be configured in the **vars/** folder, the file **ansible.cfg** and the associated **hosts** file.

The COCONUT wrapper script replaces single configuration values as it can be traced in the folder **example-configs/**.

To run a benchmark manually, just provision the distributed ledger system (including its interface execution layer, if required) and afterwards provision the clients. which will consequently trigger the benchmark.

### Directory Description

The **example-configs/** folder contains the configuration files to obtain the results as presented in the paper and should enable a reproduction of the conducted experiments.

For netem and the latency emulation scenarios, we use the command: *sudo tc qdisc del add **device** root netem delay 12ms 2ms distribution normal* across all six servers.

The folder **all-plots/** contains further visualizations and statistics as addition to the paper itself.

The folder **r-scripts/** contains various R-scripts to create the plots as shown in the paper.

The folder **data/** contains the raw data which is used by the R-scripts.

The folder **iel/** contains the interface execution layer implementations for Corda, BitShares, Fabric and Sawtooth.
Further information can be found in section [Interface Execution Layers](#Interface-Execution-Layers)

## Requirements

We are using Ansible version *2.9.27* with *Mitogen* (https://mitogen.networkgenomics.com/ansible_detailed.html) to run the provisioning process of COCONUT.

The data can be stored in a database. Currently only PostgreSQL is supported. The database settings are to be adjusted as needed in the configuration files described.

## Interface Execution Layers

 The folder **iel/custom-flows/** contains the interface execution layers for Corda.

 The folder **iel/custom-operations/** contains the interface execution layers for BitShares.

 The folder **fabric/chaincode** within the coconut-client contains the interface execution layers for Fabric.

 The folder **quorum/contracts** within the coconut-client contains the interface execution layers for Quorum.

 The folder **iel/transactions_processors_source/** contains the interface execution layers for Sawtooth.

 The folder **diem/modules** within the coconut-client contains the interface execution layers for Diem.

 Within the folder **additions/** of the coconut-client, the two files *corda.sh* and *sawtooth.sh* can be used to create the binaries / JAR files of the interface execution layers for Corda and Sawtooth.

 For Corda, we use the following template in our IDE to ease the building process of the JAR files:
 https://github.com/corda/cordapp-template-java
 Version: 52aaff7fcfa387ac74b54cf284550928850cb891

 For Sawtooth, we use the following template in our IDE to ease the building process of the binaries:
 https://github.com/hyperledger/sawtooth-sdk-go
 Version 727bba445a90dbcc5eb730fb20bf85084874d090

## Support

For support, email info@coconut.sh.
Support includes the request of additional artifacts, like the raw datasets.
