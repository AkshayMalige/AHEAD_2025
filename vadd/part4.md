<table class="sphinxhide" width="100%">
  <tr>
    <td align="center">
      <img src="./images/copy.png" width="30%"/><h1>Vitis™ Example Tutorials</h1>
    </td>
  </tr>
  <tr>
    <td></td>
  </tr>
</table>

# 🚀 AHEAD Example Project

Welcome to the AHEAD workshop! Follow this clear, step-by-step guide for the example vector addition project.

# Vitis Getting Started Tutorial

This lab introduces the new **Vitis unified IDE** as described in [Introduction to Vitis unified IDE](https://docs.amd.com/access/sources/dita/topic?Doc_Version=2024.1%20English&url=ug1393-vitis-application-acceleration&resourceid=svk1630656618393.html). The unified IDE provides a single tool for end-to-end application development, without the need to jump between multiple tools for design, debug, integration, and analysis.

> **NOTE:** The following text assumes you have set up the environment as instructed in [Part 2: Environment Setup](./part2.md).

---

## Launch the Vitis unified IDE

The first step is to create a workspace for your project and to launch the Vitis unified IDE using the following steps:

1. `mkdir work`
2. `vitis -w work`


   The Vitis Unified IDE opens the specified workspace displaying the Welcome page. The workspace is a folder for holding the various components and projects of a design.

   ![vitis](./images/u1.png)


### Creating the HLS Component 

Use the **File > New Component > HLS** to create a new HLS component. This opens the Create HLS Component wizard to the *Name and Location* page. 

1. For the **Component name** field specify `krnl_vadd` 
2. For the **Component location** specify the workspace which is the default value
3. Click Next to open the *Configuration File* page.
   

The *Configuration File* lets you specify commands for building and running the HLS component as described in [*HLS Config File Commands*](https://docs.amd.com/access/sources/dita/topic?Doc_Version=2024.1%20English&url=ug1399-vitis-hls&resourceid=azw1690243984459.html). You can specify a new empty file, an existing config file, or generate a config file from an existing HLS project as described in [*Creating an HLS Component*](https://docs.amd.com/access/sources/dita/topic?Doc_Version=2024.1%20English&url=ug1399-vitis-hls&resourceid=yzz1661583719823.html).

4.  Select **Empty File** and click **Next**. 

This opens the *Source Files* page. 

5.  Select the **Add Files** icon to open a file browser, navigate to `<downloaded_git_repo_path>/AHEAD/AHEAD_2025/vadd/src/krnl_vadd.cpp` and select **Open** to add the **kernel design** file. 

6.  Under the Top Function browse and select the `krnl_vadd` function and click **OK**.
   ![vitis](./images/u4.png)
8.  Select the **Add Files** icon to open a file browser, navigate to `<downloaded_git_repo_path>/AHEAD/AHEAD_2025/vadd/src/krnl_vadd_test.cpp` and select **Open** to add the **Test Bench** file. 
9. Click **Next** to open the the *Select Part* page.
10. Select **Platform**, select the `xilinx_u250_gen3x16_xdma_4_1_202210_1` platform and click **Next** to open the *Settings* page.

    ![vitis](./images/u6.png)

12.  On the *Settings* page specify `8ns` for the **clock**, and `12%` for the **clock_uncertainty** to override the default values.
13.  For **flow_target** select the `Vitis Kernel Flow` 
14. For **package.output.format** specify `Generate a Vitis XO` to create .xo output`. 

The default clock uncertainty, when it is not specified, is 27% of the clock period. For more information, refer to [Specifying the Clock Frequency](https://docs.amd.com/access/sources/dita/topic?Doc_Version=2024.1%20English&url=ug1399-vitis-hls&resourceid=ycw1585572210561.html)

13. Click **Next** to open the *Summary* page. Review the *Summary* page and click **Finish** to create the defined HLS component.

    ![vitis](./images/u7.png)

In the Vitis Components Explorer you can see the `krnl_vadd` component created, with the `vitis-comp.json` file opened in the center editor. You can see the `hls-config.cfg` file which is where the build directives will be placed to control the simulation and synthesis process. 

The Flow Navigator displays the `krnl_vadd` component as the active component, and shows the flow for designing the HLS component including C Simulation, C Synthesis, C/RTL Co-simuation, and Implementation.

One advantage of the unified Vitis IDE is the ability to work from the bottom-up, building your HLS or AIE components and then integrating them into a higher-level system project. 
The HLS component is created and opened as shown in the figure below.

![img](./images/part1_build_flow.png)



### Creating the Application Component

The Application component is an application that runs on the processor, Arm or x86, that loads and runs the device binary (`.xclbin`) which you will build later. The Vitis unified IDE automatically detects whether the Application component uses XRT native API or OpenCL and compiles the code as needed. Create the Application component using the following steps: 

1.  From the main menu select **File > New Component > Application**

This opens the Create Application Component wizard on the *Name and Location* page. 

2.  Enter the **Component name** as `host`, enter the **Component location** as the workspace (default), and click **Next**. 

This opens the *Select Platform* page. 

3.  On the *Select Platform* page select the `xilinx_u250_gen3x16_xdma_4_1_202210_1` platform and click **Next** to open the *Select Domain* page. 

On the *Select Domain* page you will select from the available processor domains and OS. In this case there is only one choice. 

4.  Review the *Summary* page and click **Finish** to create the defined Application component. 
 
The Application component `vitis-comp.json` file is opened in the center editor, and the component is added to the Component Explorer. When creating the Application component you do not specify source files so you must add the required source files after the component is created. 

In the Vitis Components Explorer view expand the `host` component, right-click the `Sources` folder and **Import > Files** to import the following source file: `<downloaded_git_repo_path>/AHEAD/AHEAD_2025/vadd/src/vadd.cpp`

After adding it, you can select the `vadd.cpp` and  `vadd.h` file in the Vitis Components Explorer to open it in the Code Editor in the central editor window. This example shows the simplest way of using XRT API to interact with the hardware accelerator.
 
Having added the source code to the component, you are now ready to compile the code. Looking at the Flow Navigator with the Application component the active component, you can see there are Build commands under X86 Simulation and Hardware. For Data Center applications, these two are essentially the same as the Application component runs on the X86 processor for both Hardware and Emulation. However, for Embedded Processor-based platforms, these are two different build configurations. For software emulation, even though the platform uses an embedded processor, emulation is run on the x86 processor as described in [*Embedded Processor Emulation Using PS on x86*](https://docs.amd.com/access/sources/dita/topic?Doc_Version=2024.1%20English&url=ug1393-vitis-application-acceleration&resourceid=vfp1662765605490.html). For hardware emulation, or to run on hardware, the Application component must be compiled for the embedded processor domain. These Build choices reflect that requirement. 

6. After the `host.cpp` is imported, click the **Build** command to build the application for X86 Simulation or for Hardware.
