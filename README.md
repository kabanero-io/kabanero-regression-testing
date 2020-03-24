# kabanero-regression-testing
Work items and scripts for builds and test framework

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

- In that directory place either test.sh or test.yaml. You can have both there, but only the .sh will run

```
gedit kabanero-regression-testing/tests/mynewtest/test.sh
```

- Any other required files should be placed in that directory
- maintest.sh will iterate through all the test directories and run each test

