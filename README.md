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
├── tests                                     # Top level directory
│   └── testsuite-example                     # Testsuite directory
│       ├── 00-example.sh                     # Testcase file .sh/yaml (Numbered in execution order)
│       ├── ...                               # Testcase file .sh/yaml
│       └── 99-example.sh                     # Testcase file .sh/yaml
└── build                                     # Top level output directory (git ignored)
    └── testsuite-example                     # Testsuite directory
        └── XX-example                        # Testcase directory (Same name as testcase, no file extension)
            ├── PASSED.TXT/FAILED.TXT         # File name result
            ├── output                        # OCP/Kabanero/misc testcase log directory
            └── results                       # Testcase output directory
                ├── junit.html                # Junit results
                ├── XX-example.stderr.txt     # Testcase standard error log
                └── XX-example.stdeout.txt    # Testcase standard out log
```
