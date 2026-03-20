# Architecture
This design is for an 8-bit cpu along with a bootloader and IO capability

The processor additionally has two `8-bit` registers: `reg_a`, `reg_b` - and memory `data_mem`

![arch](./arch.png)

# ISA

### Supported instructions

```
instruction || 7:7 | 6:5  | 4:4   | 3:0      || elaboration
=========================================================================
add         || 0   | 00   | x     | x        || reg_a + reg_b
-------------------------------------------------------------------------
add 1       || 0   | 01   | x     | x        || reg_a + 1
-------------------------------------------------------------------------
and         || 0   | 10   | x     | x        || reg_a & reg_b
-------------------------------------------------------------------------
not         || 0   | 11   | x     | x        || ~reg_a
-------------------------------------------------------------------------
jmp         || 1   | 00   | x     | address  || pc = address
-------------------------------------------------------------------------
store       || 1   | 01   | x     | address  || data_mem[address] = reg_a
-------------------------------------------------------------------------
load        || 1   | 10   | x     | address  || reg_b = data_mem[address]
-------------------------------------------------------------------------
nop         || 1   | 11   | x     | x        || 
```

# Setup

Install project dependencies

> if no venv/

```
python3 -m venv venv
```

> if venv/ exists:

```
source ./venv/bin/activate
```

> then

```
chmod a+x *.sh
./install.sh
export PATH="$HOME/.local/bin:$PATH"
```

> generate simulation waveform

```
cd src
./gen_sim.sh
```

> de-activate

```
deactivate
```