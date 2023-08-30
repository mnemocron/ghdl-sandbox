----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-22
-- Design Name:    dds
-- Module Name:    
-- Project Name:   
-- Target Devices: Xilinx DSP48E2
-- Tool Versions:  GHDL 4.0.0-dev
-- Description:    
-- Dependencies:   
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_m_polyphase_dds is
  generic (
    DATA_WIDTH        : natural := 16;
    ACCUMULATOR_WIDTH : natural := 32;
    LUT_WIDTH         : natural := 11;
    PARALLELIZATION   : natural := 4
  );
  port (
    ftw    : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    dds_en : in  std_logic;
    poff   : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    m00_axis_aclk    : in std_logic;
    m00_axis_aresetn : in std_logic;
    m00_axis_tvalid  : out std_logic;
    m00_axis_tdata   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0);
    m01_axis_tvalid  : out std_logic;
    m01_axis_tdata   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0)
  );
end axis_m_polyphase_dds;

architecture arch_imp of axis_m_polyphase_dds is
  component polyphase_dds is
    generic (
      DATA_WIDTH        : natural := 16;
      ACCUMULATOR_WIDTH : natural := 32;
      LUT_WIDTH         : natural := 11;
      PARALLELIZATION   : natural := 4
    );
    port (
      clk        : in  std_logic;
      rst_n      : in  std_logic;
      ftw        : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      dds_en     : in  std_logic;
      poff       : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      out_real   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0);
      out_imag   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0)
    );
  end component;

begin

  m00_axis_tvalid <= dds_en;
  m01_axis_tvalid <= dds_en;

  polyphase_dds_inst : polyphase_dds
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ACCUMULATOR_WIDTH => ACCUMULATOR_WIDTH,
      LUT_WIDTH         => LUT_WIDTH,
      PARALLELIZATION   => PARALLELIZATION 
    )
    port map (
      clk        => m00_axis_aclk,
      rst_n      => m00_axis_aresetn,
      ftw        => ftw,
      dds_en     => dds_en,
      poff       => poff,
      out_real   => m00_axis_tdata,
      out_imag   => m01_axis_tdata
    );

end arch_imp;
