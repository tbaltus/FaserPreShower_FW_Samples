----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC.vhd
-- Description...: Slow control entity Production Faser Chip
-- Project Name..: FaserPreShower
-- Created.......: Aug 22, 2023
-- Version.......: -
--
-- Revision History:
-- Aug 22, 2023: file creation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;
use work.UFP_Protocol.all;
use work.FPS_SlowControl.all;
use work.TOP_FASER_pkg.all;

-- ENTITY ----------------------------------------------------
-- FPS_SC: System Controller for ASIC, Feeder, and User Set Configuration Interface
-- This entity integrates ASIC SPI, feeder control, and user configuration functionality.
-- It provides nreset signals, SPI communication with multiple modules, 
-- GPIO wrapper interfaces for user set requests/acknowledgements, and DPRAM access.
-- 6 dprams in total, each capable of holding two super-columns (256x16b)

-- Required components inside the entity :
-- UFP_USER_SET_CONFIG
-- FPS_SC_FEEDER_EN
-- FPS_SC_FEEDER
-- FPS_SC_2K16b_DPRAM
-- FPS_SC_SPI

entity FPS_SC is
   Generic(
      x_reset_active       : std_logic := '0');
   Port (
      x_nreset             : in  std_logic;
      x_clk                : in  std_logic;

      --FPS_NRESET interface-------
      x_SC_nreset          : out std_logic_vector(35 downto 0);
      
      --ASIC interface-----------
      x_clk_spi_M0         : out std_logic;
      x_cs_M0              : out std_logic;
      x_mosi_M0            : out std_logic;
         
      x_clk_spi_M1         : out std_logic;
      x_cs_M1              : out std_logic;
      x_mosi_M1            : out std_logic;
         
      x_clk_spi_M2         : out std_logic;
      x_cs_M2              : out std_logic;
      x_mosi_M2            : out std_logic;
         
      x_clk_spi_M3         : out std_logic;
      x_cs_M3              : out std_logic;
      x_mosi_M3            : out std_logic;
         
      x_clk_spi_M4         : out std_logic;
      x_cs_M4              : out std_logic;
      x_mosi_M4            : out std_logic;
         
      x_clk_spi_M5         : out std_logic;
      x_cs_M5              : out std_logic;
      x_mosi_M5            : out std_logic;

         --GPIO wrapper interface-----
      x_user_set_req       : in  std_logic_vector(6 downto 0);
      x_user_set_ack       : out std_logic_vector(6 downto 0);
      x_user_set_err       : out std_logic_vector(6 downto 0);

      x_user_set_0_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
      x_user_set_1_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
      x_user_set_2_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
      x_user_set_3_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
      x_user_set_4_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity
      x_user_set_5_err_d   : out std_logic_vector(3 downto 0); --To multiplexe in the top level entity

      x_param_in           : in  std_logic_vector(15 downto 0);
         
      x_valid_word         : in  std_logic;
      x_dpram_data         : in  std_logic_vector(15 downto 0);
      x_dpram_wraddress    : in  std_logic_vector(10 downto 0);
      x_dpram_wren         : in  std_logic;
      x_dpram_rdaddress    : in  std_logic_vector(10 downto 0);
      x_dpram_q            : out std_logic_vector(15 downto 0)
      );
end FPS_SC; 


-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC is
-- Constants -------------------------------------------------
   
   --UsrSetCgf parameters
   constant FPS_CHIP_USER_SET_CFG_WORD_SIZE : positive := 15;
   constant FPS_CHIP_USER_SET_CFG_WORD_NB   : positive := 2;

   --x_register mapping indexes
   constant FPS_SC_NRESET_MSB    : natural := 28;
   constant FPS_SC_NRESET_LSB    : natural := 23;

   constant FPS_SPI_CMD_MSB      : natural := 22;
   constant FPS_SPI_CMD_LSB      : natural := 17;

   constant FPS_SPI_DATA_CMD_MSB : natural := 16;
   constant FPS_SPI_DATA_CMD_LSB : natural := 9;

   constant FPS_CHIP_ADDR_MSB    : natural := 8;
   constant FPS_CHIP_ADDR_LSB    : natural := 6;

   constant FPS_SUPER_COLUMN_MSB : natural := 5;
   constant FPS_SUPER_COLUMN_LSB : natural := 2;

   constant FPS_FEEDER_SEL_MSB   : natural := 1;
   constant FPS_FEEDER_SEL_LSB   : natural := 0;
      
-- Types ----------------------------------------------------- 

   type t_rdaddress        is array (0 to c_module_nb - 1) of std_logic_vector(7 downto 0);
   type t_user_set_cfg     is array (0 to c_module_nb - 1) of std_logic_vector(FPS_CHIP_USER_SET_CFG_WORD_SIZE * FPS_CHIP_USER_SET_CFG_WORD_NB-1 downto 0);
   type t_spi_reg          is array (0 to c_module_nb - 1) of std_logic_vector(19 downto 0);
   type t_feeder_dpram     is array (0 to c_module_nb - 1) of std_logic_vector(15 downto 0);
   type t_feeder_rdaddress is array (0 to c_module_nb - 1) of std_logic_vector(7 downto 0);
   
-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------

   --ASIC interface-----------
   signal s_clk_spi                : std_logic_vector(5 downto 0);
   signal s_cs                     : std_logic_vector(5 downto 0);
   signal s_mosi                   : std_logic_vector(5 downto 0);

   --Feeder interface---------
   signal s_spi_req                : std_logic_vector(5 downto 0);
   signal s_spi_ack                : std_logic_vector(5 downto 0);
   signal s_spi_reg                : t_spi_reg;
   signal s_feeder_dpram_q         : t_feeder_dpram;
   signal s_dpram_feeder_rdaddress : t_feeder_rdaddress;

   --Feeder enable interface---
   signal s_feeder_req             : std_logic_vector(5 downto 0);
   signal s_feeder_ack             : std_logic_vector(5 downto 0);
   signal s_feeder_err             : std_logic_vector(5 downto 0);

   --UsrSetCfg interface------
   signal s_chip_err_d             : t_user_set_err;
   signal s_chip_user_set_cfg      : t_user_set_cfg := (others => "011111100000000000000000000000");

   --DPRAM interface-----------
   signal s_rdaddress              : t_rdaddress;
   signal s_dpram_wren             : std_logic_vector(5 downto 0);
	
 

-- Components ------------------------------------------------
	
component FPS_SC_256x16b_DPRAM IS
	PORT
	(
		clock			: IN STD_LOGIC  := '1';
		data			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wraddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren			: IN STD_LOGIC  := '0';
		q				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;


   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------

begin
   -------------------------------------------------------------------------------
   -- components instanciation
   -------------------------------------------------------------------------------
   
   --UsrSetCfg----------------
GEN_UFP_USER_SET_CONFIG: for i in 0 to 5 generate

   C_CHIP_USER_SET_CFG : UFP_USER_SET_CONFIG
   generic map (
      x_reset_active       => x_reset_active,
      x_nb_addr_bits    => 16-FPS_CHIP_USER_SET_CFG_WORD_SIZE,    
      x_nb_data_word    => FPS_CHIP_USER_SET_CFG_WORD_NB 
      )
   port map( 
      x_clk          => x_clk,
      x_nreset       => x_nreset,
      -- DECODER interface
      x_user_set_req    => x_user_set_req(i),
      x_param_in        => x_param_in,
      x_user_set_ack    => x_user_set_ack(i),
      x_user_set_error  => x_user_set_err(i),
      x_user_set_error_d   => s_chip_err_d(i),
      x_busy            => open,-- not used since mapped on user set
      -- Register output
      x_registers       => s_chip_user_set_cfg(i)
      );      
end generate GEN_UFP_USER_SET_CONFIG;


   --Feeder enable--------------
   C_FPS_SC_FEEDER_EN : FPS_SC_FEEDER_EN
   generic map(
      x_reset_active    => x_reset_active)
   port map (
      x_nreset          => x_nreset,
      x_clk             => x_clk,

      --Feeder interface---------
      x_feeder_req      => s_feeder_req,
      x_feeder_ack      => s_feeder_ack,
      x_feeder_err      => s_feeder_err,

      --GPIO wrapper interface-----
      x_req             => x_user_set_req(6),
      x_ack             => x_user_set_ack(6),
      x_err             => x_user_set_err(6),
      en                => x_param_in(5 downto 0)
      );

      
   --Feeder--------------------
   GEN_FPS_SC_FEEDER: for i in 0 to 5 generate
   C_FPS_SC_FEEDER : FPS_SC_FEEDER
   generic map(
      x_reset_active    => x_reset_active)
   port map (
      x_nreset          => x_nreset,
      x_clk             => x_clk,
      
      --Feeder enable interface----
      x_start           => s_feeder_req(i),
      x_ack             => s_feeder_ack(i),
      x_err             => s_feeder_err(i),
      x_valid_word      => x_valid_word,
      
      --UserSetCfg interface---
      x_spi_cmd         => s_chip_user_set_cfg(i)(FPS_SPI_CMD_MSB      downto FPS_SPI_CMD_LSB),
      x_spi_data_cmd    => s_chip_user_set_cfg(i)(FPS_SPI_DATA_CMD_MSB downto FPS_SPI_DATA_CMD_LSB),
      x_chip_address    => s_chip_user_set_cfg(i)(FPS_CHIP_ADDR_MSB    downto FPS_CHIP_ADDR_LSB),
      x_super_column    => s_chip_user_set_cfg(i)(FPS_SUPER_COLUMN_MSB downto FPS_SUPER_COLUMN_LSB),
      x_sel             => s_chip_user_set_cfg(i)(FPS_FEEDER_SEL_MSB   downto FPS_FEEDER_SEL_LSB),
      
      --DPRAM interface--------
      x_dpram_address   => s_dpram_feeder_rdaddress(i),
      x_dpram_q         => s_feeder_dpram_q(i),
      
      --SPI interface----------
      x_spi_req         => s_spi_req(i),
      x_spi_reg         => s_spi_reg(i),
      x_spi_ack         => s_spi_ack(i)
      );
   end generate GEN_FPS_SC_FEEDER;

   
   --DPRAM
   GEN_FPS_SC_256x16b_DPRAM: for i in 0 to 5 generate
   C_FPS_SC_256x16b_DPRAM : FPS_SC_256x16b_DPRAM
   port map (
      clock             => x_clk,
      data              => x_dpram_data,
      rdaddress         => s_rdaddress(i),
      wraddress         => x_dpram_wraddress(7 downto 0),
      wren              => s_dpram_wren(i),
      q                 => s_feeder_dpram_q(i)
      );
   end generate GEN_FPS_SC_256x16b_DPRAM;

   
   --SPI--------------------
   GEN_FPS_SC_SPI: for i in 0 to 5 generate
   C_FPS_SC_SPI : FPS_SC_SPI
   generic map(
      x_reset_active    => x_reset_active)
   port map (
      x_nreset          => x_nreset,
      x_clk             => x_clk,

      --Feeder interface---------
      x_start           => s_spi_req(i),
      x_ack             => s_spi_ack(i),
      x_reg             => s_spi_reg(i),
      
      --ASIC interface-----------
      x_clk_SPI         => s_clk_spi(i),
      x_CS              => s_cs(i),
      x_mosi            => s_mosi(i)
      );
   end generate GEN_FPS_SC_SPI;


   -------------------------------------------------------------------------------
   -- COMBINATORIAL --------------------------------------------------------------
   -------------------------------------------------------------------------------

   s_dpram_wren(0) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "000" else '0';
   s_dpram_wren(1) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "001" else '0';
   s_dpram_wren(2) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "010" else '0';
   s_dpram_wren(3) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "011" else '0';
   s_dpram_wren(4) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "100" else '0';
   s_dpram_wren(5) <= x_dpram_wren when x_dpram_wraddress(10 downto 8) = "101" else '0';

   s_rdaddress(0) <= s_dpram_feeder_rdaddress(0) when s_feeder_req(0) = '1' else x_dpram_rdaddress(7 downto 0);
   s_rdaddress(1) <= s_dpram_feeder_rdaddress(1) when s_feeder_req(1) = '1' else x_dpram_rdaddress(7 downto 0);
   s_rdaddress(2) <= s_dpram_feeder_rdaddress(2) when s_feeder_req(2) = '1' else x_dpram_rdaddress(7 downto 0);
   s_rdaddress(3) <= s_dpram_feeder_rdaddress(3) when s_feeder_req(3) = '1' else x_dpram_rdaddress(7 downto 0);
   s_rdaddress(4) <= s_dpram_feeder_rdaddress(4) when s_feeder_req(4) = '1' else x_dpram_rdaddress(7 downto 0);
   s_rdaddress(5) <= s_dpram_feeder_rdaddress(5) when s_feeder_req(5) = '1' else x_dpram_rdaddress(7 downto 0);

   x_dpram_q   <= s_feeder_dpram_q(0) when x_dpram_rdaddress(10 downto 8) = "000" else
                  s_feeder_dpram_q(1) when x_dpram_rdaddress(10 downto 8) = "001" else
                  s_feeder_dpram_q(2) when x_dpram_rdaddress(10 downto 8) = "010" else
                  s_feeder_dpram_q(3) when x_dpram_rdaddress(10 downto 8) = "011" else
                  s_feeder_dpram_q(4) when x_dpram_rdaddress(10 downto 8) = "100" else
                  s_feeder_dpram_q(5);

   -------------------------------------------------------------------------------
   -- PROCESS --------------------------------------------------------------------
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   -- COMBINATORIAL process ------------------------------------------------------

   -------------------------------------------------------------------------------
   -- CLOCK process --------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- OUTPUTS --------------------------------------------------------------------
   -------------------------------------------------------------------------------

   x_SC_nreset( 5 downto 0)  <= s_chip_user_set_cfg(0)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);
   x_SC_nreset(11 downto 6)  <= s_chip_user_set_cfg(1)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);
   x_SC_nreset(17 downto 12) <= s_chip_user_set_cfg(2)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);
   x_SC_nreset(23 downto 18) <= s_chip_user_set_cfg(3)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);
   x_SC_nreset(29 downto 24) <= s_chip_user_set_cfg(4)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);
   x_SC_nreset(35 downto 30) <= s_chip_user_set_cfg(5)(FPS_SC_NRESET_MSB downto FPS_SC_NRESET_LSB);

   x_user_set_0_err_d <= s_chip_err_d(0); --To multiplexe in the top level entity
   x_user_set_1_err_d <= s_chip_err_d(1); --To multiplexe in the top level entity
   x_user_set_2_err_d <= s_chip_err_d(2); --To multiplexe in the top level entity
   x_user_set_3_err_d <= s_chip_err_d(3); --To multiplexe in the top level entity
   x_user_set_4_err_d <= s_chip_err_d(4); --To multiplexe in the top level entity
   x_user_set_5_err_d <= s_chip_err_d(5); --To multiplexe in the top level entity

   x_clk_spi_M0   <= s_clk_spi(0);
   x_cs_M0        <= s_cs(0);
   x_mosi_M0      <= s_mosi(0);
      
   x_clk_spi_M1   <= s_clk_spi(1);
   x_cs_M1        <= s_cs(1);
   x_mosi_M1      <= s_mosi(1);
      
   x_clk_spi_M2   <= s_clk_spi(2);
   x_cs_M2        <= s_cs(2);
   x_mosi_M2      <= s_mosi(2);
      
   x_clk_spi_M3   <= s_clk_spi(3);
   x_cs_M3        <= s_cs(3);
   x_mosi_M3      <= s_mosi(3);
      
   x_clk_spi_M4   <= s_clk_spi(4);
   x_cs_M4        <= s_cs(4);
   x_mosi_M4      <= s_mosi(4);
      
   x_clk_spi_M5   <= s_clk_spi(5);
   x_cs_M5        <= s_cs(5);
   x_mosi_M5      <= s_mosi(5);

end rtl;