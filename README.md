# kabanero-regression-testing
Work items and scripts for builds and test framework

## Prerequisuites
- If running any yaml test scripts, install ansible 
## How to Run Tests
- Clone this repository

```
git clone https://github.ibm.com/kabanero-op/kabanero-regression-testing
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

- Any other required / support files should be placed in that directory
- maintest.sh will iterate through all the test directories and run each test

