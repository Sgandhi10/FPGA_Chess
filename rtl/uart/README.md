# UART

While other protocols such as i2c would work UART is a fairly simple and straightforward protocol that allow for very easy implementation. A system such as UART also allows for significantly less overhead for each packet such as address, read/write bit, acks. While a UART setup is less sophisticated and vulnerable to bit loss.

## Packets

Our setup will utilized a semi-modified version of UART that allows for sending all desired information in a singular packet avoiding data spanning multiple packets.

- 1 Start Bit
- 32 Data Bits
- 1 Parity Bits
- 1 Stop Bit

To create a setup that is effective in the long-term you would need to utilize an oversampling based setup which ensures the system receives the correct values.

## System Design

```mermaid
graph TD
    %% Inputs
    CLOCK_50 --> vga_pll
    CLOCK_50 --> keypress1
    CLOCK_50 --> keypress2
    CLOCK_50 --> keypress3
    CLOCK_50 --> screen_fsm
    CLOCK_50 --> UART_handler
    CLOCK_50 --> hex_counter
    CLOCK_50 --> screen_gen
    CLOCK_50 --> board

    KEY0 --> vga_pll
    KEY0 --> UART_handler
    KEY0 --> screen_fsm
    KEY0 --> hex_counter  
    KEY1 --> keypress1
    KEY2 --> keypress2
    KEY3 --> keypress3
    KEY1 --> keypress1
    KEY2 --> keypress2
    KEY3 --> keypress3
    RX --> UART_handler

    %% Keypress outputs
    keypress1 --> board
    keypress2 --> board
    keypress3 --> screen_fsm

    %% Inter-module connections
    vga_pll --> vga_controller
    screen_fsm --> screen_gen
    screen_fsm --> board
    screen_fsm --> UART_handler
    screen_gen --> vga_controller
    board --> screen_gen
    board --> UART_handler
    UART_handler --> hex_counter

    %% VGA output (combined)
    vga_controller --> VGA_Ports[VGA Ports]

    %% Output display (combined)
    hex_counter --> HEX_Ports[HEX Ports]
    board --> LED

    %% Node definitions
    subgraph Modules
        vga_pll[vga_pll_25_175]
        vga_controller[vga_controller]
        screen_fsm[screen_fsm]
        screen_gen[screen_gen]
        UART_handler[UART_handler]
        board[board]
        hex_counter[hex_counter]
        keypress1[keypress_1]
        keypress2[keypress_2]
        keypress3[keypress_3]
    end

    subgraph Inputs
        CLOCK_50
        KEY0
        KEY1
        KEY2
        KEY3
        RX
    end

    subgraph Outputs
        VGA_Ports[VGA Ports]
        HEX_Ports[HEX Ports]
        LED
    end

    %% Apply styles for all nodes and labels
    style CLOCK_50 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style KEY0 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style KEY1 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style KEY2 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style KEY3 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style RX fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style vga_pll fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style keypress1 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style keypress2 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style keypress3 fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style screen_fsm fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style UART_handler fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style hex_counter fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style screen_gen fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style board fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style vga_controller fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style VGA_Ports fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style HEX_Ports fill:#fff,stroke:#000,stroke-width:2px,font-size:20px
    style LED fill:#fff,stroke:#000,stroke-width:2px,font-size:20px

```

## Useful links

https://www.analog.com/en/resources/analog-dialogue/articles/uart-a-hardware-communication-protocol.html

https://www.circuitbasics.com/basics-uart-communication/
