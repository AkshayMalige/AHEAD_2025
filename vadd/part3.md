<table class="sphinxhide" width="100%">
  <tr>
    <td align="center">
      <img src="./images/copy.png" width="30%"/><h1>Review the Kernel Code and Host Application</h1>
    </td>
  </tr>
  <tr>
    <td></td>
  </tr>
</table>

 The example used in this tutorial is a trivial vector-add application. The simplicity of this example allows focusing on the key concepts of FPGA acceleration without being distracted by complicated algorithmic consideration.

### The Source Code for the Vector-Add Kernel

In this tutorial, the hardware accelerator (also referred to as kernel) is modeled in C++. The Vitis flow also supports kernels coded in Verilog or VHDL. An example using a Verilog RTL version of the vector-add kernel can be found [here](https://github.com/Xilinx/Vitis_Accel_Examples/tree/2021.2/rtl_kernels/rtl_vadd).

Using C++, the description of the hardware accelerator fits in less than 20 lines of code and can be easily and efficiently implemented in FPGA using the Vitis compiler.


```cpp
extern "C" {
  void krnl_vadd(
    const unsigned int *in1, // Read-Only Vector 1
    const unsigned int *in2, // Read-Only Vector 2
    unsigned int *out,       // Output Result
    int size                 // Size in integer
  )
  {

#pragma HLS INTERFACE m_axi port=in1 bundle=aximm1
#pragma HLS INTERFACE m_axi port=in2 bundle=aximm2
#pragma HLS INTERFACE m_axi port=out bundle=aximm1

    for(int i = 0; i < size; ++i)
    {
      out[i] = in1[i] + in2[i];
    }
  }
}
```

This simple example highlights two important aspects of C++ kernels:

1. Vitis requires C++ kernels to be declared as `extern “C”` to avoid name mangling issues
2. The results of the Vitis compilation process are controlled by the usage of pragmas in the source code.

Other than this, the functionality of the vector-add kernel is very easily recognizable. The krnl_vadd function reads in two inputs vectors (`in1` and `in2`) and adds them into the `out` vector using a simple for loop. The `size` parameter indicates the number of elements in the input and output vector.

The pragmas are used to map function parameters to distinct kernel ports. By mapping the two inputs parameters to different input ports, the kernel will be able to read both inputs in parallel. As a general rule, and without going into further details in this introductory tutorial, it is important to think about interface requirements of hardware accelerators and they will have a determining impact on maximum achievable performance. Here is a version of the same vector add exmaple kernel optimized for performance by splitting the process in to functions (like read, compute and store result) that can run in parallel using the dataflow pragma. 

```cpp

static void load_input(uint32_t* in, hls::stream<uint32_t>& inStream, int size) {
mem_rd:
    for (int i = 0; i < size; i++) {
#pragma HLS LOOP_TRIPCOUNT min = c_size max = c_size
        inStream << in[i];
    }
}

static void compute_add(hls::stream<uint32_t>& in1_stream,
                        hls::stream<uint32_t>& in2_stream,
                        hls::stream<uint32_t>& out_stream,
                        int size) {
// The kernel is operating with vector of NUM_WORDS integers. The + operator performs
// an element-wise add, resulting in NUM_WORDS parallel additions.
execute:
    for (int i = 0; i < size; i++) {
#pragma HLS LOOP_TRIPCOUNT min = c_size max = c_size
        out_stream << (in1_stream.read() + in2_stream.read());
    }
}

 void store_result(uint32_t* out, hls::stream<uint32_t>& out_stream, int size) {
mem_wr:
    for (int i = 0; i < size; i++) {
#pragma HLS LOOP_TRIPCOUNT min = c_size max = c_size
        out[i] = out_stream.read();
    }
}

extern "C" {

void krnl_vadd(uint32_t* in1, uint32_t* in2, uint32_t* out, int size) {
#pragma HLS INTERFACE m_axi port = in1 bundle = gmem0 depth=DATA_SIZE
#pragma HLS INTERFACE m_axi port = in2 bundle = gmem1 depth=DATA_SIZE
#pragma HLS INTERFACE m_axi port = out bundle = gmem0 depth=DATA_SIZE

    static hls::stream<uint32_t> in1_stream("input_stream_1");
    static hls::stream<uint32_t> in2_stream("input_stream_2");
    static hls::stream<uint32_t> out_stream("output_stream");

#pragma HLS dataflow
    // dataflow pragma instruct compiler to run following three APIs in parallel
    load_input(in1, in1_stream, size);
    load_input(in2, in2_stream, size);
    compute_add(in1_stream, in2_stream, out_stream, size);
    store_result(out, out_stream, size);
}
}
```


The Vitis online documentation provides comprehensive information on [HLS Pragmas](https://docs.amd.com/r/en-US/ug1399-vitis-hls/HLS-Pragmas) reference guide.

### The Source Code for the Host Program

The source code for the host program is written in C/C++ and uses the native XRT APIs to interact with the hardware-accelerated vector-add kernel.

* Open the [`vadd.cpp`](https://github.com/AkshayMalige/AHEAD_2025/blob/main/vadd/src/vadd.cpp) file located in the `src` directory of this tutorial

There are four main steps in the source code for this simple example.

* **Step 1:** The runtime environment is initialized. In this section, the host detects the attached AMD device, loads the FPGA binary (.xclbin file) from file and programs it into the first AMD device it found. Then the kernel object is created. All Vitis applications will have code very similar to the one in this section.

* **Step 2:** The application creates the three buffers needed to share data with the kernel: one for each input and one for the output. On data-center platforms.

```cpp
    // These commands will allocate memory on the Device. The cl::Buffer objects can
    // be used to reference the memory locations on the device.
    OCL_CHECK(err, cl::Buffer buffer_a(context, CL_MEM_READ_ONLY, size_in_bytes, NULL, &err));
    OCL_CHECK(err, cl::Buffer buffer_b(context, CL_MEM_READ_ONLY, size_in_bytes, NULL, &err));
    OCL_CHECK(err, cl::Buffer buffer_result(context, CL_MEM_WRITE_ONLY, size_in_bytes, NULL, &err));

    // We then need to map our OpenCL buffers to get the pointers
    int* ptr_a;
    int* ptr_b;
    int* ptr_result;
    OCL_CHECK(err, ptr_a = (int*)q.enqueueMapBuffer(buffer_a, CL_TRUE, CL_MAP_WRITE, 0, size_in_bytes, NULL, NULL, &err));
    OCL_CHECK(err, ptr_b = (int*)q.enqueueMapBuffer(buffer_b, CL_TRUE, CL_MAP_WRITE, 0, size_in_bytes, NULL, NULL, &err));
    OCL_CHECK(err, ptr_result = (int*)q.enqueueMapBuffer(buffer_result, CL_TRUE, CL_MAP_READ, 0, size_in_bytes, NULL, NULL, &err));
```

>**NOTE:** A common alternative is for the application to explicitly allocate host memory, and reuse the corresponding pointers when creating the buffers. The approach used in this example was chosen because it is the most portable and efficient.

* **Step 3:** The host program sets the arguments of the kernel, then schedules three operations: the transfers of the two input vectors to device memory, the execution of the kernel, and lastly the transfer of the results back to host memory. 

  ```cpp

      OCL_CHECK(err, err = krnl_vector_add.setArg(narg++, buffer_a));
      OCL_CHECK(err, err = krnl_vector_add.setArg(narg++, buffer_b));
      OCL_CHECK(err, err = krnl_vector_add.setArg(narg++, buffer_result));
      OCL_CHECK(err, err = krnl_vector_add.setArg(narg++, DATA_SIZE));

      // Data will be migrated to kernel space
      OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_a, buffer_b}, 0 /* 0 means from host*/));
  
      // Launch the Kernel
      OCL_CHECK(err, err = q.enqueueTask(krnl_vector_add));
  
      // The result of the previous kernel execution will need to be retrieved in
      // order to view the results. This call will transfer the data from FPGA to
      // source_results vector
      OCL_CHECK(err, q.enqueueMigrateMemObjects({buffer_result}, CL_MIGRATE_MEM_OBJECT_HOST));
  
  ```

* **Step 4:** The output buffer containing the results of the kernel are migrated back to host memory and can safely be used by the software application. Here the results are simply checked against expected values before the program finishes.

This example shows the simplest way of using XRT API to interact with the hardware accelerator.

## Next Step

  **Click here to [Build and Run with the new Vitis unified IDE](./part4.md)**

