#include <iostream>
#include <cstring>
#include <filesystem>
#include "xrt/xrt_bo.h"
#include <experimental/xrt_xclbin.h>
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"

#define DATA_SIZE 4096

// Automatically find the correct .xclbin based on host executable path
std::string find_xclbin_from_exec(const std::string& exec_path) {
    std::filesystem::path exe = std::filesystem::canonical(exec_path);
    std::filesystem::path build_dir = exe.parent_path().filename();  // Emulation-SW, Emulation-HW, Hardware

    // Go up from: <project>/vadd/<Emulation-SW>/host.exe
    auto project_root = exe.parent_path().parent_path().parent_path();

    // Construct xclbin path
    std::filesystem::path xclbin_path =
        project_root / "vadd_system_hw_link" / build_dir / "binary_container_1.xclbin";

    if (!std::filesystem::exists(xclbin_path)) {
        throw std::runtime_error("ERROR: xclbin not found at " + xclbin_path.string());
    }

    return xclbin_path.string();
}

int main(int argc, char** argv) {
    std::cout << "argc = " << argc << std::endl;
    for (int i = 0; i < argc; i++) {
        std::cout << "argv[" << i << "] = " << argv[i] << std::endl;
    }

    // Get xclbin path based on current directory
    std::string binaryFile = find_xclbin_from_exec(argv[0]);
    std::cout << "Using xclbin: " << binaryFile << std::endl;

    int device_index = 0;
    std::cout << "Opening device " << device_index << std::endl;
    auto device = xrt::device(device_index);

    std::cout << "Loading xclbin..." << std::endl;
    auto uuid = device.load_xclbin(binaryFile);

    auto krnl = xrt::kernel(device, uuid, "krnl_vadd", xrt::kernel::cu_access_mode::exclusive);

    size_t vector_size_bytes = sizeof(int) * DATA_SIZE;

    std::cout << "Allocating buffers..." << std::endl;
    auto boIn1 = xrt::bo(device, vector_size_bytes, krnl.group_id(0));
    auto boIn2 = xrt::bo(device, vector_size_bytes, krnl.group_id(1));
    auto boOut = xrt::bo(device, vector_size_bytes, krnl.group_id(2));

    auto bo0_map = boIn1.map<int*>();
    auto bo1_map = boIn2.map<int*>();
    auto bo2_map = boOut.map<int*>();
    std::fill(bo0_map, bo0_map + DATA_SIZE, 0);
    std::fill(bo1_map, bo1_map + DATA_SIZE, 0);
    std::fill(bo2_map, bo2_map + DATA_SIZE, 0);

    int bufReference[DATA_SIZE];
    for (int i = 0; i < DATA_SIZE; ++i) {
        bo0_map[i] = i;
        bo1_map[i] = i;
        bufReference[i] = i + i;
    }

    std::cout << "Synchronizing input buffers to device..." << std::endl;
    boIn1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    boIn2.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    std::cout << "Running kernel..." << std::endl;
    auto run = krnl(boIn1, boIn2, boOut, DATA_SIZE);
    run.wait();

    std::cout << "Fetching results from device..." << std::endl;
    boOut.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    if (std::memcmp(bo2_map, bufReference, vector_size_bytes))
        throw std::runtime_error("Value read back does not match reference");

    std::cout << "TEST PASSED\n";
    return 0;
}