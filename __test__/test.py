

## list directories

import os
import time
import shutil

def list_files(s):
    return [d for d in os.listdir(s) if os.path.isfile(os.path.join(s, d))]

# run command make test to all files in the examples directory

print("-= GALM Compiler -=- Testing =-")
print("Compiling the project")

test_files = list_files("./examples")
test_len = len(test_files)
success = 0

test_path = "__test__/tests"

if not os.path.exists(test_path):
    os.makedirs(test_path)
else:
    shutil.rmtree(test_path)
    os.makedirs(test_path)

time.sleep(0.5)

if (os.system(f"make compile >/dev/null 2> {test_path}/compile.err") != 0):
    print("\nThe project could not be compiled")
    exit(0)

time.sleep(0.5)
print("The project has been compiled successfully\nStarting the tests:\n")
time.sleep(0.7)

for file in test_files:

    print(f"Creating intermediate code (c++) {file}...")
    result = os.system(f"./output/compiler.exe < examples/{file} > {test_path}/{file}.cpp")

    if (result != 0):
        os.rename(f"{test_path}/{file}.cpp", f"{test_path}/{file}.err")
        print(f"Error while we are creating intermediate code for {file}\n")
        continue

    print(f"Compiling {file} using g++...")

    result = os.system(f"g++ {test_path}/{file}.cpp -o {test_path}/{file}.exe > {test_path}/{file}.cpp.err")

    if (result != 0):
        print(f"Error while compiling {file}\n")
        continue

    print(f"Testing {file}...")

    if result == 0:
        success += 1
        print(f"{file} has been successfully tested\n")
    else:
        print(f"{file} has failed\n")
    
    time.sleep(0.1)

if (success == test_len):
    print("All tests have been successfully completed, congratulations!")
else:
    print(f"{success}/{test_len} tests passed")
    print(f"Success rate: {((success/test_len) * 100):.2f}%")