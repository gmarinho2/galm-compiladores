

## list directories

import os
import shutil

def list_files(s):
    return [d for d in os.listdir(s) if os.path.isfile(os.path.join(s, d))]

# run command make test to all files in the examples directory

print("-= GALM Compiler -=- Testing =-")
print("Compiling the project")

test_files = list_files("./examples")
test_len = len(test_files)
success = 0

RED_COLOR = "\033[1;31m"
RED_COLOR_UNDERLINED = "\033[4;31m"
GREEN_COLOR = "\033[1;32m"
GREEN_COLOR_UNDERLINED = "\033[4;32m"
DEFAULT_COLOR = "\033[0m"

test_path = "__test__/tests"

if not os.path.exists(test_path):
    os.makedirs(test_path)
else:
    shutil.rmtree(test_path)
    os.makedirs(test_path)

if (os.system(f"make compile >/dev/null") != 0):
    print("\nThe project could not be compiled")
    exit(1)

print("The project has been compiled successfully\nStarting the tests:\n")

for file in test_files:

    print(f"Creating intermediate code (c++) {file}...")
    result = os.system(f"./output/compiler.exe < examples/{file} > {test_path}/{file}.cpp")

    if (result != 0):
        os.rename(f"{test_path}/{file}.cpp", f"{test_path}/{file}.err")
        print(f"{RED_COLOR_UNDERLINED}Error while we are creating intermediate code for {file}{DEFAULT_COLOR}\n")
        continue

    print(f"Compiling {file} using g++...")

    result = os.system(f"g++ {test_path}/{file}.cpp -o {test_path}/{file}.exe > {test_path}/{file}.cpp.err")

    if (result != 0):
        print(f"{RED_COLOR_UNDERLINED}Error while compiling {file}{DEFAULT_COLOR}\n")
        continue

    print(f"Testing {file}...")

    result = os.system(f"./{test_path}/{file}.exe") 
    # delete the executable file
    os.remove(f"{test_path}/{file}.exe")

    if (result != 0):
        print(f"{RED_COLOR_UNDERLINED}Error while compiling {file}{DEFAULT_COLOR}\n")
        continue

    if result == 0:
        success += 1
        print(f"{GREEN_COLOR}{file} has been successfully tested{DEFAULT_COLOR}\n")
    else:
        print(f"{RED_COLOR}{file} has failed{DEFAULT_COLOR}\n")
    
if (success == test_len):
    print(f"{GREEN_COLOR_UNDERLINED}All tests have been successfully completed, congratulations!")
else:
    print(f"{success}/{test_len} tests passed")
    COLOR = GREEN_COLOR if success / test_len > 0.75 else RED_COLOR
    print(f"{COLOR}Success rate: {((success/test_len) * 100):.2f}%")
    exit(1)