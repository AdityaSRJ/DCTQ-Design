# Design of Discrete Cosine Transform and Quantization Processor

Basic Operations involved in Image Processing are:
* Discrete Cosine Transorm
* Quantization
* Variable Length Coding

2D-DCT of a block of size 8x8 pixels of an image is defined as :
![2D DCT](https://github.com/user-attachments/assets/3be0e9a3-6948-4b22-9e8b-4a4280747dfa)

## Matrix Form Of DCT:

![DCT Matrix](https://github.com/user-attachments/assets/b0f20f8d-4322-4611-a7a3-03ea41ba5681)
## Contribution of The Algorithm

**While computing the (i+1)th partial product of CX, the ith row of the DCT coefficient can also be computed simultaneously since the ith partial products of CX are already available.**


Quantized outputs can be obtained by dividing each of the 64 coefficients by the quantization table values.

These stages can be pipelined in such a way that **one DCTQ output can be generated every clock cycle.**

## Modules

### ON-CHIP DUAL ADDRESS ROM

There is only a single ROM content table of size 8x64 bits but two addresses are being considered.


![Dual ROM](https://github.com/user-attachments/assets/18d28dc5-a47f-4502-ac33-3feeebe2ec71)


ROM stores the cosine matrix:
* addr1 accesses 2C values
* addr2 accesses 2CT(Transpose values)

Two Stage pipelining to keep pace with the Dual RAM used in DCTQ design.

### ON-CHIP SINGLE ADDRESS ROM DESIGN

Single address ROM is used to store the inverse of the quantization matrix.

![DUAL RAM COPY](https://github.com/user-attachments/assets/f5515234-f01c-4875-9246-e7c37ea35e3a)

Although organized as 8x64 bits, it is byte-addressed while reading.

### ON-CHIP DUAL RAM

There are two RAMs. We write an image in RAM1 and concurrently read from RAM2 and vice-versa.


![DUAL RAM](https://github.com/user-attachments/assets/ae4281b0-f259-4140-b8ec-e42f3e326ccf)

When we write, we write 8 bytes at a time. Thus, we write 8 times as the image block is 64 pixels.

**Special access feature different from Conventional RAM: Write horizontally and read vertically.**

### Adder/Subtractor Design

The Design uses an adder module to add 8 numbers ( signed or unsigned).

The numbers to be added are 11/14 bits. When the bits are large, **conventional full adders are unfavourable due to the large propagation time of carry rippling all through to the MSB**. Even mechanisms like **carry-look ahead suffer from large delays** due to an increase in gate count with an increase in bits.


The solution is to divide data into smaller chunks and introduce **pipelining.**

![adder](https://github.com/user-attachments/assets/06caac53-2fc8-457f-803a-427a44713177)

### Multiplier Design

A multiplier circuit to multiply 2 numbers has been designed.
Similar to the adder, the multiplier is pipelined into **8 pipelining stages.**

### DCTQ Proccessor

This is the top design module, connecting all the sub-modules:
Input-output specification is as given below:

**Inputs:**
* **reset_n**  : Asynchronous active low reset
* **di[63:0]** : One row (8 pixels) of an image is input. di[7:0] is the first pixel, di[63:56] is the last.

* **be[7:0]**  : Byte enable signal. be[0] selects di[7:0] and so on.

* **wa[2:0]**  :This furnishes row address of the image block. wa[0] is the first row.

* **pci_clk**  : Image input synchronous clock. Image is written synchronous to the positive edge of this clock.

* **din_valid**: This input signals when the input data di[63:0] is valid.

* **start**    : Active high start. If deasserted and reapplied latency comes into effect again.

* **hold**     : DCTQ processing can be kept on hold and resumed without any latency.

* **clk**      : DCTQ system clock.


**Outputs:**


* **ready     :** This signal indicates the core is ready to accept an image block.

* **dctq[8:0] :** DCTQ output in twos compliment valid at positive edge of clk.

* **addr[5:0] :** DCTQ coefficient address, addr[0] is the DC Coefficient.

* **dctq_valid:** This signal indicates the validity of dctq output.



## Architechture 

![Screenshot 2024-07-28 112310](https://github.com/user-attachments/assets/ba6ef22c-7f5b-4411-bc1f-6fa6a5fd102d)
