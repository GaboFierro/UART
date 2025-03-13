# UART

📌 Descripción

Este proyecto implementa un sistema de comunicación UART (Universal Asynchronous Receiver-Transmitter) en Verilog. Incluye módulos para la transmisión, recepción y procesamiento de datos en serie, permitiendo la comunicación con dispositivos externos a través de una interfaz UART.

⚙️ Requisitos

Tarjeta FPGA compatible con el diseño (ejemplo: DE10-Lite, Basys 3, Nexys A7)

Software Intel Quartus Prime Lite u otro entorno de desarrollo HDL

Cable UART-USB para conectar con una computadora

Terminal serie (PuTTY, Tera Term, Minicom, etc.) para la visualización y envío de datos

Alimentación de 3.3V o 5V según la tarjeta FPGA utilizada

│── debounce.v           
│── receiver.v            
│── receiver.v.bak       
│── top.qpf               
│── top.qsf               
│── top_loopback.v        
│── tx.v                  
│── vga.v                 
│── vga.v.bak             
│── vga_pwm.v             
│── vga_pwm.v.bak         
│── README.md            
