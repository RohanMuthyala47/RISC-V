// parameters.svh
`ifndef PARAMETERS_SVH
`define PARAMETERS_SVH

parameter DATA_WIDTH  = 32;
parameter ADDR_WIDTH  = 32;
parameter INSTR_WIDTH = 32;

parameter REGISTER_FILE_SIZE       = 32;
parameter REGISTER_FILE_ADDR_WIDTH = $clog2(REGISTER_FILE_SIZE);

parameter MEMORY_SIZE       = 1024;
parameter MEMORY_ADDR_WIDTH = $clog2(MEMORY_SIZE);

parameter CACHE_SIZE = 128;

`endif
