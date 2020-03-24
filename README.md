# kabanero-regression-testing
Work items and scripts for builds and test framework

## How to Run Tests
- Clone this repository

```
git clone https://github.ibm.com/IBMCloudPak4Apps/icpa-build-and-test
cd icpa-build-and-test
```

- Log in to OCP

```
oc login -u kubeadmin -p somepassword
or
oc login --token=5O95y9gdhG9V9z6PTopL3Eb_iBrcUewsuLmd_5rO8fI --server=https://api.prorate.os.fyre.ibm.com:6443
```

- Run maintest.sh

```
./maintest.sh
```

## How to add a test to this repository
- Add a directory to icpa-build-and-test/tests

```
mkdir icpa-build-and-test/tests/mynewtest
```

- In that directory place either test.sh or test.yaml. You can have both there, but only the .sh will run

```
gedit icpa-build-and-test/tests/mynewtest/test.sh
```

- Any other required files should be placed in that directory
- maintest.sh will iterate through all the test directories and run each test

