I2C protocol project
===
介紹
---
I2C（Inter-Integrated Circuit），中文稱為"兩線式串行總線"，是一種廣泛使用的串行匯流排，主要用於嵌入式系統中的微控制器與外部裝置之間的通訊。I2C由飛利浦半導體（現在的恩智浦半導體）在1980年代初開發，具有以下幾個關鍵特點：

簡單的兩條信號線：I2C通訊只需要兩條線，一條是數據線（SDA）和一條時鐘線（SCL）。
多主多從架構：I2C允許多個主裝置（發送命令的裝置）和多個從裝置（接收命令的裝置）在同一條線上共存。
地址化：每個從裝置都有一個唯一的地址，主裝置可以通過地址來選擇與哪個從裝置通信。
同步通信：所有的數據傳輸都是在時鐘信號的控制下進行，確保數據的正確性和時序的一致性。
![i2c data flow](https://github.com/W3iii/I2C_protocal/blob/master/image/i2c%20data%20flow.png)


模擬方式
---
使用verilog撰寫並模擬I2C protocal運作方式。使用FSM模擬master與slave module。分為三大always block。  
 - 第一個sequencial logic 做state與next state的切換。
 - 第二部分為combinational logic做next state的assign。
 - 第三部分的sequencial logic做當下state的input output動作。  

狀態機是使用one-hot state machine。
```
localparam IDLE            = 11'b00000000001; //1
localparam ADDR            = 11'b00000000010; //2
localparam OFFSET          = 11'b00000000100; //4
localparam IN_DATA         = 11'b00000001000; //8
localparam OUT_DATA        = 11'b00000010000; //16
localparam ADDR_ACK        = 11'b00000100000; //32
localparam OFFSET_ACK      = 11'b00001000000; //64
localparam IN_DATA_ACK     = 11'b00010000000; //128
localparam OUT_DATA_ACK    = 11'b00100000000; //256
localparam STOP            = 11'b01000000000; //512
localparam START           = 11'b10000000000; //1024

assign ST_IDLE             = state[0];	
assign ST_ADDR             = state[1];
assign ST_OFFSET           = state[2];
assign ST_IN_DATA          = state[3];
assign ST_OUT_DATA         = state[4];
assign ST_ADDR_ACK         = state[5];
assign ST_OFFSET_ACK       = state[6];
assign ST_IN_DATA_ACK      = state[7];
assign ST_OUT_DATA_ACK     = state[8];
assign ST_STOP             = state[9];
assign ST_START            = state[10];
```

one-hot state machinec優點
---
獨熱碼常常被用來表示一個有限狀態機的狀態。如果使用二進制或格雷碼來代表狀態，則需要用到解碼器才能得知該碼代表的狀態。使用獨熱碼來代表狀態的話，則不需要解碼器，因爲若第𝑛個位元爲1，就代表機器目前在第𝑛個狀態。

## slave state flow
![slave state](https://github.com/W3iii/I2C_protocal/blob/master/image/slave%20state.drawio.png)
## master state flow
![master state](https://github.com/W3iii/I2C_protocal/blob/master/image/master%20state.drawio.png)

project block
---
使用verilog撰寫並模擬I2C protocal運作方式。
整個project分為三大module與testbed，module分別是mast、slave跟8bit register map。
 - master: 產生sda與scl I2C data flow。
 - slave: 接受master發出的指令做狀態的切換以及動作。
 - 8bit register map: 當master對slave下記憶體位置offset時，slave對register map做存取。
 - testbed: generate main clk以及下I2C_go的指令，告訴master start。

## module關係架構圖
![module](https://github.com/W3iii/I2C_protocal/blob/master/image/module.png)

## simulate waveform
![simulate waveform](https://github.com/W3iii/I2C_protocal/blob/master/image/simulate%20waveform.png)
