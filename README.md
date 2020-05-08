# kabanero-regression-testing
Work items and scripts for builds and test framework

## Prerequisuites
- If running any yaml test scripts, install ansible 

## How to Run Tests
- Clone this repository

```
git clone https://github.com/kabanero-io/kabanero-regression-testing.git
cd kabanero-regression-testing
```

- Log in to OCP

```
oc login -u kubeadmin -p somepassword
or
oc login --token=tometoken --server=https://api.mauler.os.fyre.ibm.com:6443
```

- Run maintest.sh

```
./maintest.sh
```

## How to add a test to this repository
- Add a directory to icpa-build-and-test/tests

```
mkdir kabanero-regression-testing/tests/mynewtest
```

- In that directory create your new XXXX-mynewtest.sh and / or XXXX-mynewtest.yaml
  - where XXXX is some numeric which orders the test sequence based on alphanumeric sort

- Any other required / support files should be placed in that directory, do not prefix with XXXX
- maintest.sh will iterate through all the test directories and run each test

## Test Framework Project Structure
```
.
├── maintest.sh
├── README.md
├── scripts
│   ├── crc_install.shcrc_install.sh
│   └── kabanero-mustgather.sh
├── build                                 # .gitignore
│   ├── kabanero-operator                 # Testsuite directory
│   │   └── 00-credentials                # Testcase directory
│   │       ├── PASSED.TXT|FAILED.TXT     # File name result
│   │       ├── output                    # OCP/misc logs
│   │       └── results                   # Testcase standard out/err logs
│   │           ├── junit.html            # Junit logs
│   │           ├── 00-credentials.sh.stderr.txt
│   │           └── 00-credentials.sh.stdeout.txt
...
│   └── testsuite-example                 # Testsuite directory
│       └── XX-example                    # Testcase directory
│           ├── PASSED.TXT|FAILED.TXT     # File name result
│           ├── output                    # OCP/misc logs
│           └── results                   # Testcase standard out/err logs
│               ├── junit.html            # Junit logs
│               ├── XX-example.stderr.txt
│               └── XX-example.stdeout.txt
└── tests
    ├── default.yaml
    ├── kabanero-operator
    │   ├── 00-credentials.sh
    │   ├── 10-java-microprofile.sh
    │   ├── 11-java-spring-boot2.sh
    │   ├── 12-nodejs.sh
    │   ├── 13-nodejs-express.sh
    │   ├── 14-java-openliberty.sh
    │   ├── 20-delete-pipeline.sh
    │   ├── 21-delete-stack.sh
    │   ├── 22-update-index.sh
    │   ├── 23-deactivate-stack.sh
    │   ├── pipelinerun.sh
    │   ├── rstr.sh
    │   ├── support-22-merge.yaml
    │   └── support-23-merge.yaml
    ├── pipeline
    │   ├── java-microprofile.sh
    │   ├── java-spring-boot2.sh
    │   ├── java-websphere-traditional.sh
    │   ├── nodejs-express.sh
    │   ├── nodejs-loopback.sh
    │   ├── nodejs.sh
    │   └── pipelinerun.sh
    └── serving.yaml
```
